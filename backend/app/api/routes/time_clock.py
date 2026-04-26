from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.dependencies import get_current_context, get_db
from app.schemas.punch import CreatePunchRequest, PunchRecordResponse, TimeClockStateResponse
from app.services.auth import AuthenticatedContext
from app.services.time_clock import create_punch, time_clock_state


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
    context: AuthenticatedContext = Depends(get_current_context),
    db: Session = Depends(get_db),
) -> TimeClockStateResponse:
    employee = _require_employee_context(context)
    return time_clock_state(
        db,
        employee=employee,
        timezone_name=context.company.timezone,
    )


@router.post("/me/punches", response_model=PunchRecordResponse)
def create_punch_route(
    payload: CreatePunchRequest,
    context: AuthenticatedContext = Depends(get_current_context),
    db: Session = Depends(get_db),
) -> PunchRecordResponse:
    employee = _require_employee_context(context)
    return create_punch(
        db,
        employee=employee,
        payload=payload,
        timezone_name=context.company.timezone,
    )
