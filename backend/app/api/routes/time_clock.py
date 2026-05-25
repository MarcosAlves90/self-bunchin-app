from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, Response, status
from sqlalchemy.orm import Session

from app.authorization import require_permission
from app.dependencies import get_current_context, get_db
from app.schemas.punch import (
    CreatePunchRequest,
    ManagedPunchPageResponse,
    ManagedPunchRecordResponse,
    ManagePunchRequest,
    PunchRecordResponse,
    TimeClockStateResponse,
    UpdateManagedPunchRequest,
)
from app.services.auth import AuthenticatedContext
from app.services.time_clock import (
    create_managed_punch,
    create_punch,
    delete_managed_punch,
    update_managed_punch,
)
from app.domain.time_clock_read import list_managed_punches_page, time_clock_state_page


router = APIRouter()


def _require_employee_context(context: AuthenticatedContext):
    if context.employee is None:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="This account is not linked to an employee profile.",
        )
    return context.employee


@router.get("/me", response_model=TimeClockStateResponse)
def get_time_clock_state_route(
    page: int = 1,
    limit: int = 4,
    context: AuthenticatedContext = Depends(require_permission("time_clock.read")),
    db: Session = Depends(get_db),
) -> TimeClockStateResponse:
    employee = _require_employee_context(context)
    return time_clock_state_page(
        db,
        employee=employee,
        timezone_name=context.company.timezone,
        page=page,
        page_size=limit,
    )


@router.post("/me/punches", response_model=PunchRecordResponse)
def create_punch_route(
    payload: CreatePunchRequest,
    context: AuthenticatedContext = Depends(require_permission("time_clock.punch")),
    db: Session = Depends(get_db),
) -> PunchRecordResponse:
    employee = _require_employee_context(context)
    return create_punch(
        db,
        employee=employee,
        payload=payload,
        timezone_name=context.company.timezone,
    )


@router.get("/employees/{employee_id}/punches", response_model=ManagedPunchPageResponse)
def list_managed_punches_route(
    employee_id: str,
    page: int = 1,
    limit: int = 4,
    context: AuthenticatedContext = Depends(require_permission("time_clock.manage")),
    db: Session = Depends(get_db),
) -> ManagedPunchPageResponse:
    return list_managed_punches_page(
        db,
        company_id=context.company.id,
        employee_id=employee_id,
        page=page,
        page_size=limit,
    )


@router.post(
    "/employees/{employee_id}/punches",
    response_model=ManagedPunchRecordResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_managed_punch_route(
    employee_id: str,
    payload: ManagePunchRequest,
    context: AuthenticatedContext = Depends(require_permission("time_clock.manage")),
    db: Session = Depends(get_db),
) -> ManagedPunchRecordResponse:
    return create_managed_punch(
        db,
        company_id=context.company.id,
        employee_id=employee_id,
        payload=payload,
    )


@router.put(
    "/employees/{employee_id}/punches/{punch_id}",
    response_model=ManagedPunchRecordResponse,
)
@router.patch(
    "/employees/{employee_id}/punches/{punch_id}",
    response_model=ManagedPunchRecordResponse,
)
def update_managed_punch_route(
    employee_id: str,
    punch_id: str,
    payload: UpdateManagedPunchRequest,
    context: AuthenticatedContext = Depends(require_permission("time_clock.manage")),
    db: Session = Depends(get_db),
) -> ManagedPunchRecordResponse:
    return update_managed_punch(
        db,
        company_id=context.company.id,
        employee_id=employee_id,
        punch_id=punch_id,
        payload=payload,
    )


@router.delete(
    "/employees/{employee_id}/punches/{punch_id}",
    status_code=status.HTTP_204_NO_CONTENT,
)
def delete_managed_punch_route(
    employee_id: str,
    punch_id: str,
    context: AuthenticatedContext = Depends(require_permission("time_clock.manage")),
    db: Session = Depends(get_db),
) -> Response:
    delete_managed_punch(
        db,
        company_id=context.company.id,
        employee_id=employee_id,
        punch_id=punch_id,
    )
    return Response(status_code=status.HTTP_204_NO_CONTENT)
