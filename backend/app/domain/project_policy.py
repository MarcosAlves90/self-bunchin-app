from __future__ import annotations

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.errors import DomainError, ErrorKind
from app.models import EmployeeProject, Project
from app.schemas.project import ProjectStatus


def project_or_404(db: Session, *, company_id: str, project_id: str) -> Project:
    project = db.scalar(
        select(Project).where(Project.company_id == company_id, Project.id == project_id),
    )
    if project is None:
        raise DomainError(ErrorKind.not_found, "Project not found.")
    return project


def validate_project_for_punch(
    db: Session,
    *,
    company_id: str,
    employee_id: str,
    project_id: str,
) -> Project:
    project = project_or_404(db, company_id=company_id, project_id=project_id)
    if project.status != ProjectStatus.active.value:
        raise DomainError(ErrorKind.forbidden, "Project is inactive.")
    linked = db.scalar(
        select(EmployeeProject).where(
            EmployeeProject.employee_id == employee_id,
            EmployeeProject.project_id == project_id,
        ),
    )
    if linked is None:
        raise DomainError(ErrorKind.forbidden, "Employee is not assigned to this project.")
    return project
