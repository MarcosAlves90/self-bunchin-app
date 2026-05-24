from __future__ import annotations

from dataclasses import dataclass
from datetime import timedelta

from sqlalchemy import or_, select
from sqlalchemy.orm import Session

from app.config import get_settings
from app.crypto import FieldCipher, lookup_digest
from app.db import ensure_utc, utcnow
from app.errors import DomainError, ErrorKind
from app.models import AuthSession, Company, Employee, UserAccount
from app.schemas.auth import (
    AuthContextResponse,
    AuthSessionResponse,
    CompanyRegisterRequest,
    CompanySummary,
    LoginRequest,
    UserSummary,
)
from app.security import generate_temp_password, hash_password, issue_bearer_token, verify_password


@dataclass(slots=True)
class AuthenticatedContext:
    session: AuthSession
    user: UserAccount
    company: Company
    employee: Employee | None


def _cipher() -> FieldCipher:
    settings = get_settings()
    return FieldCipher(settings.encryption_secret or "")


def normalize_email(value: str) -> str:
    return value.strip().lower()


def digits_only(value: str) -> str:
    return "".join(character for character in value if character.isdigit())


def mask_email(value: str) -> str:
    local_part, domain = value.split("@", 1)
    visible = local_part[:2]
    hidden = "*" * max(len(local_part) - 2, 1)
    return f"{visible}{hidden}@{domain}"


def mask_phone(value: str) -> str:
    digits = digits_only(value)
    if len(digits) < 4:
        return "*" * len(digits)
    return f"{digits[:2]}*****{digits[-4:]}"


def mask_cnpj(value: str) -> str:
    digits = digits_only(value)
    return f"{digits[:2]}.***.***/****-{digits[-2:]}"


def summarize_company(company: Company, cipher: FieldCipher | None = None) -> CompanySummary:
    if cipher is None:
        cipher = _cipher()
    legal_name = cipher.decrypt(company.legal_name_ciphertext) or ""
    trade_name = cipher.decrypt(company.trade_name_ciphertext) or ""
    cnpj = cipher.decrypt(company.cnpj_ciphertext) or ""
    email = cipher.decrypt(company.contact_email_ciphertext) or ""
    phone = cipher.decrypt(company.contact_phone_ciphertext) or ""
    return CompanySummary(
        id=company.id,
        legal_name=legal_name,
        trade_name=trade_name,
        cnpj_masked=mask_cnpj(cnpj),
        email_masked=mask_email(email),
        phone_masked=mask_phone(phone),
    )


def _user_summary(user: UserAccount, cipher: FieldCipher) -> UserSummary:
    return UserSummary(
        id=user.id,
        email=cipher.decrypt(user.email_ciphertext) or "",
        role=user.role,
        employee_id=user.employee_id,
    )


def _display_name_for_user(
    db: Session,
    *,
    user: UserAccount,
    cipher: FieldCipher,
) -> str:
    if user.employee_id:
        employee = db.get(Employee, user.employee_id)
        if employee is not None:
            name = cipher.decrypt(employee.name_ciphertext) or ""
            if name.strip():
                return name.strip()
    email = cipher.decrypt(user.email_ciphertext) or ""
    return email.strip()


def _issue_session(
    db: Session,
    *,
    user: UserAccount,
    keep_connected: bool,
) -> tuple[str, AuthSession]:
    settings = get_settings()
    issued_at = utcnow()
    ttl = (
        timedelta(days=settings.remember_me_ttl_days)
        if keep_connected
        else timedelta(hours=settings.token_ttl_hours)
    )
    token = issue_bearer_token()
    session = AuthSession(
        user=user,
        token_hash=lookup_digest(token, settings.token_secret or ""),
        issued_at=issued_at,
        expires_at=issued_at + ttl,
    )
    db.add(session)
    return token, session


def _build_auth_response(
    token: str,
    auth_session: AuthSession,
    user: UserAccount,
    company: Company,
    cipher: FieldCipher,
) -> AuthSessionResponse:
    return AuthSessionResponse(
        access_token=token,
        expires_at=ensure_utc(auth_session.expires_at),
        must_change_password=user.must_change_password,
        company=summarize_company(company, cipher),
        user=_user_summary(user, cipher),
    )


def register_company(db: Session, payload: CompanyRegisterRequest) -> AuthSessionResponse:
    settings = get_settings()
    cipher = _cipher()
    normalized_email = normalize_email(str(payload.email))
    normalized_cnpj = digits_only(payload.cnpj)
    email_hash = lookup_digest(normalized_email, settings.encryption_secret or "")
    cnpj_hash = lookup_digest(normalized_cnpj, settings.encryption_secret or "")

    existing_company = db.scalar(
        select(Company).where(
            or_(
                Company.cnpj_hash == cnpj_hash,
                Company.contact_email_hash == email_hash,
            ),
        ),
    )
    if existing_company is not None:
        raise DomainError(
            ErrorKind.conflict,
            "A company with this CNPJ or contact email already exists.",
        )

    existing_user = db.scalar(
        select(UserAccount).where(UserAccount.email_hash == email_hash),
    )
    if existing_user is not None:
        raise DomainError(ErrorKind.conflict, "A user with this email already exists.")

    company = Company(
        legal_name_ciphertext=cipher.encrypt(payload.company_name) or "",
        trade_name_ciphertext=cipher.encrypt(payload.trade_name) or "",
        cnpj_ciphertext=cipher.encrypt(normalized_cnpj) or "",
        cnpj_hash=cnpj_hash,
        contact_email_ciphertext=cipher.encrypt(normalized_email) or "",
        contact_email_hash=email_hash,
        contact_phone_ciphertext=cipher.encrypt(payload.phone) or "",
        consented_at=utcnow(),
        timezone=settings.timezone,
    )
    user = UserAccount(
        company=company,
        email_ciphertext=cipher.encrypt(normalized_email) or "",
        email_hash=email_hash,
        password_hash=hash_password(payload.password),
        role="admin",
    )
    db.add_all([company, user])
    token, auth_session = _issue_session(db, user=user, keep_connected=True)
    db.commit()
    db.refresh(company)
    db.refresh(user)
    db.refresh(auth_session)
    return _build_auth_response(token, auth_session, user, company, cipher)


def login(db: Session, payload: LoginRequest) -> AuthSessionResponse:
    settings = get_settings()
    cipher = _cipher()
    normalized_email = normalize_email(str(payload.email))
    email_hash = lookup_digest(normalized_email, settings.encryption_secret or "")
    user = db.scalar(select(UserAccount).where(UserAccount.email_hash == email_hash))
    if user is None or not verify_password(payload.password, user.password_hash):
        raise DomainError(ErrorKind.unauthorized, "Invalid email or password.")
    if not user.is_active:
        raise DomainError(ErrorKind.forbidden, "This account is inactive.")

    company = db.get(Company, user.company_id)
    if company is None or not company.is_active:
        raise DomainError(ErrorKind.forbidden, "The company account is inactive.")

    user.last_login_at = utcnow()
    token, auth_session = _issue_session(
        db,
        user=user,
        keep_connected=payload.keep_connected,
    )
    db.commit()
    db.refresh(auth_session)
    return _build_auth_response(token, auth_session, user, company, cipher)


def reset_password(
    db: Session,
    *,
    email: str,
) -> tuple[str, str, str]:
    settings = get_settings()
    cipher = _cipher()
    normalized_email = normalize_email(email)
    email_hash = lookup_digest(normalized_email, settings.encryption_secret or "")
    user = db.scalar(select(UserAccount).where(UserAccount.email_hash == email_hash))
    if user is None:
        raise DomainError(ErrorKind.not_found, "User not found.")
    if not user.is_active:
        raise DomainError(ErrorKind.forbidden, "This account is inactive.")

    company = db.get(Company, user.company_id)
    if company is None or not company.is_active:
        raise DomainError(ErrorKind.forbidden, "The company account is inactive.")

    temp_password = generate_temp_password()
    user.password_hash = hash_password(temp_password)
    user.must_change_password = True
    db.commit()

    recipient_email = cipher.decrypt(user.email_ciphertext) or normalized_email
    display_name = _display_name_for_user(db, user=user, cipher=cipher)
    return recipient_email, display_name, temp_password


def change_password(
    db: Session,
    *,
    context: AuthenticatedContext,
    current_password: str,
    new_password: str,
) -> tuple[str, str]:
    cipher = _cipher()
    user = context.user
    if not verify_password(current_password, user.password_hash):
        raise DomainError(ErrorKind.unauthorized, "Invalid password.")

    user.password_hash = hash_password(new_password)
    user.must_change_password = False
    db.commit()

    recipient_email = cipher.decrypt(user.email_ciphertext) or ""
    display_name = _display_name_for_user(db, user=user, cipher=cipher)
    return recipient_email, display_name


def resolve_context(db: Session, token: str) -> AuthenticatedContext:
    settings = get_settings()
    token_hash = lookup_digest(token, settings.token_secret or "")
    auth_session = db.scalar(select(AuthSession).where(AuthSession.token_hash == token_hash))
    now = utcnow()
    expires_at = ensure_utc(auth_session.expires_at) if auth_session is not None else None
    if auth_session is None or auth_session.revoked_at is not None or expires_at is None or expires_at <= now:
        raise DomainError(ErrorKind.unauthorized, "Invalid or expired access token.")

    user = db.get(UserAccount, auth_session.user_id)
    if user is None or not user.is_active:
        raise DomainError(
            ErrorKind.unauthorized,
            "The account associated with this token is unavailable.",
        )

    company = db.get(Company, user.company_id)
    if company is None or not company.is_active:
        raise DomainError(
            ErrorKind.unauthorized,
            "The company associated with this token is unavailable.",
        )

    auth_session.last_used_at = now
    db.commit()
    employee = db.get(Employee, user.employee_id) if user.employee_id else None
    return AuthenticatedContext(
        session=auth_session,
        user=user,
        company=company,
        employee=employee,
    )


def get_auth_context(context: AuthenticatedContext) -> AuthContextResponse:
    cipher = _cipher()
    return AuthContextResponse(
        company=summarize_company(context.company, cipher),
        user=_user_summary(context.user, cipher),
    )


def logout(db: Session, context: AuthenticatedContext) -> None:
    context.session.revoked_at = utcnow()
    db.commit()