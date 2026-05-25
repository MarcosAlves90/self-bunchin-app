from __future__ import annotations

from datetime import timedelta

from sqlalchemy.orm import Session

from app.config import get_settings
from app.crypto import FieldCipher, lookup_digest
from app.db import ensure_utc, utcnow
from app.models import AuthSession, Company, UserAccount
from app.schemas.auth import AuthSessionResponse
from app.security import issue_bearer_token

from app.domain.auth_read import summarize_company, user_summary


def issue_session(
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


def build_auth_response(
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
        user=user_summary(user, cipher),
    )
