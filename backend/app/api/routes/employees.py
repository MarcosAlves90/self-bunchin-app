from __future__ import annotations

from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.dependencies import get_db, require_admin
from app.schemas.employee import EmployeeDraftPayload, EmployeeProfileResponse
from app.services.auth import AuthenticatedContext
from app.services.employees import create_employee, get_employee, list_employees, update_employee


router = APIRouter()


@router.get("", response_model=list[EmployeeProfileResponse])
def list_employees_route(
    context: AuthenticatedContext = Depends(require_admin),
    db: Session = Depends(get_db),
) -> list[EmployeeProfileResponse]:
    return list_employees(
        db,
        company_id=context.company.id,
        timezone_name=context.company.timezone,
    )


@router.get("/{employee_id}", response_model=EmployeeProfileResponse)
def get_employee_route(
    employee_id: str,
    context: AuthenticatedContext = Depends(require_admin),
    db: Session = Depends(get_db),
) -> EmployeeProfileResponse:
    return get_employee(
        db,
        company_id=context.company.id,
        employee_id=employee_id,
        timezone_name=context.company.timezone,
    )


@router.post(
    "",
    response_model=EmployeeProfileResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_employee_route(
    payload: EmployeeDraftPayload,
    context: AuthenticatedContext = Depends(require_admin),
    db: Session = Depends(get_db),
) -> EmployeeProfileResponse:
    return create_employee(
        db,
        company_id=context.company.id,
        payload=payload,
        timezone_name=context.company.timezone,
    )


@router.put("/{employee_id}", response_model=EmployeeProfileResponse)
def update_employee_route(
    employee_id: str,
    payload: EmployeeDraftPayload,
    context: AuthenticatedContext = Depends(require_admin),
    db: Session = Depends(get_db),
) -> EmployeeProfileResponse:
    return update_employee(
        db,
        company_id=context.company.id,
        employee_id=employee_id,
        payload=payload,
        timezone_name=context.company.timezone,
    )
