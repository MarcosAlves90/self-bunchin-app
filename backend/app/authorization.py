from __future__ import annotations

from typing import Protocol

from fastapi import Depends, HTTPException, status

from app.dependencies import get_current_context
from app.permissions import get_permissions_for_role


class AuthorizationCompany(Protocol):
    id: str


class AuthorizationUser(Protocol):
    role: str


class AuthorizationContext(Protocol):
    company: AuthorizationCompany
    user: AuthorizationUser


def can(
    context: AuthorizationContext,
    permission: str,
    *,
    company_id: str | None = None,
    scope: str = "company",
) -> bool:
    permissions = get_permissions_for_role(context.user.role)
    if permission not in permissions:
        return False
    if scope == "global":
        return context.user.role == "super_admin"
    if company_id is not None and context.company.id != company_id:
        return False
    return True


def require_permission(permission: str, *, scope: str = "company"):
    def dependency(
        context: AuthorizationContext = Depends(get_current_context),
    ) -> AuthorizationContext:
        allowed = can(context, permission, company_id=context.company.id, scope=scope)
        if not allowed:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Permission denied.",
            )
        return context

    return dependency
