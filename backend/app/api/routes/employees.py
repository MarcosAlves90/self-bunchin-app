from __future__ import annotations

from fastapi import Response
from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.authorization import require_permission
from app.dependencies import get_db
from app.schemas.employee import EmployeeDraftPayload, EmployeeProfileResponse
from app.schemas.project import ProjectResponse
from app.services.auth import AuthenticatedContext
from app.services.employees import create_employee, delete_employee, get_employee, list_employees, update_employee
from app.services.projects import list_employee_projects


router = APIRouter()


@router.get("", response_model=list[EmployeeProfileResponse])
def list_employees_route(
    context: AuthenticatedContext = Depends(require_permission("employees.read")),
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
    context: AuthenticatedContext = Depends(require_permission("employees.read")),
    db: Session = Depends(get_db),
) -> EmployeeProfileResponse:
    return get_employee(
        db,
        company_id=context.company.id,
        employee_id=employee_id,
        timezone_name=context.company.timezone,
    )


@router.get("/{employee_id}/projects", response_model=list[ProjectResponse])
def list_employee_projects_route(
    employee_id: str,
    context: AuthenticatedContext = Depends(require_permission("projects.read")),
    db: Session = Depends(get_db),
) -> list[ProjectResponse]:
    return list_employee_projects(
        db,
        company_id=context.company.id,
        employee_id=employee_id,
    )


@router.post(
    "",
    response_model=EmployeeProfileResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_employee_route(
    payload: EmployeeDraftPayload,
    context: AuthenticatedContext = Depends(require_permission("employees.create")),
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
    context: AuthenticatedContext = Depends(require_permission("employees.update")),
    db: Session = Depends(get_db),
) -> EmployeeProfileResponse:
    return update_employee(
        db,
        company_id=context.company.id,
        employee_id=employee_id,
        payload=payload,
        timezone_name=context.company.timezone,
    )


@router.delete("/{employee_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_employee_route(
    employee_id: str,
    context: AuthenticatedContext = Depends(require_permission("employees.delete")),
    db: Session = Depends(get_db),
) -> Response:
    delete_employee(
        db,
        company_id=context.company.id,
        employee_id=employee_id,
    )
    return Response(status_code=status.HTTP_204_NO_CONTENT)
