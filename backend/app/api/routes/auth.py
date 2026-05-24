from __future__ import annotations

from fastapi import APIRouter, BackgroundTasks, Depends, status
from sqlalchemy.orm import Session

from app.authorization import require_permission
from app.dependencies import get_current_context, get_db
from app.schemas.auth import (
    AuthContextResponse,
    AuthSessionResponse,
    CompanyRegisterRequest,
    LoginRequest,
    PasswordChangeRequest,
    PasswordResetRequest,
)
from app.schemas.base import MessageResponse
from app.services.auth import (
    AuthenticatedContext,
    change_password,
    get_auth_context,
    login,
    logout,
    register_company,
    reset_password,
)
from app.services.brevo import (
    send_company_welcome_email,
    send_password_changed_email,
    send_password_reset_email,
)


router = APIRouter()


@router.post(
    "/register-company",
    response_model=AuthSessionResponse,
    status_code=status.HTTP_201_CREATED,
)
def register_company_route(
    payload: CompanyRegisterRequest,
    db: Session = Depends(get_db),
) -> AuthSessionResponse:
    return register_company(db, payload)


@router.post("/login", response_model=AuthSessionResponse)
def login_route(
    payload: LoginRequest,
    db: Session = Depends(get_db),
) -> AuthSessionResponse:
    return login(db, payload)


@router.post("/reset-password", response_model=MessageResponse)
def reset_password_route(
    payload: PasswordResetRequest,
    background_tasks: BackgroundTasks,
    db: Session = Depends(get_db),
) -> MessageResponse:
    recipient_email, display_name, temp_password = reset_password(
        db,
        email=str(payload.email).strip(),
    )
    background_tasks.add_task(
        send_password_reset_email,
        recipient_email=recipient_email,
        display_name=display_name,
        temp_password=temp_password,
    )
    return MessageResponse(message="Password reset email sent.")


@router.post("/change-password", response_model=MessageResponse)
def change_password_route(
    payload: PasswordChangeRequest,
    background_tasks: BackgroundTasks,
    context: AuthenticatedContext = Depends(get_current_context),
    db: Session = Depends(get_db),
) -> MessageResponse:
    recipient_email, display_name = change_password(
        db,
        context=context,
        current_password=payload.current_password,
        new_password=payload.new_password,
    )
    background_tasks.add_task(
        send_password_changed_email,
        recipient_email=recipient_email,
        display_name=display_name,
    )
    return MessageResponse(message="Password updated successfully.")


@router.get("/me", response_model=AuthContextResponse)
def me_route(
    context: AuthenticatedContext = Depends(require_permission("auth.read_context")),
) -> AuthContextResponse:
    return get_auth_context(context)


@router.post("/logout", response_model=MessageResponse)
def logout_route(
    context: AuthenticatedContext = Depends(get_current_context),
    db: Session = Depends(get_db),
) -> MessageResponse:
    logout(db, context)
    return MessageResponse(message="Session revoked successfully.")
