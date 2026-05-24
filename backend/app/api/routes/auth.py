from __future__ import annotations

from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.authorization import require_permission
from app.dependencies import get_current_context, get_db
from app.schemas.auth import (
    AuthContextResponse,
    AuthSessionResponse,
    CompanyRegisterRequest,
    LoginRequest,
)
from app.schemas.base import MessageResponse
from app.services.auth import (
    AuthenticatedContext,
    get_auth_context,
    login,
    logout,
    register_company,
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
