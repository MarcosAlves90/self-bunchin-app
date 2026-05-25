from __future__ import annotations

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.domain.project_policy import validate_project_for_punch as _validate_project_for_punch
from app.domain.project_read import (
    cipher,
    employee_or_404,
    project_or_404,
    serialize_member,
    serialize_project,
    status_value,
)
from app.models import EmployeeProject, Project
from app.schemas.project import ProjectDraftPayload, ProjectMemberSummary, ProjectResponse, ProjectStatus


def create_project(db: Session, *, company_id: str, payload: ProjectDraftPayload) -> ProjectResponse:
    field_cipher = cipher()
    project = Project(
        company_id=company_id,
        name_ciphertext=field_cipher.encrypt(payload.name) or "",
        description_ciphertext=field_cipher.encrypt(payload.description),
        status=status_value(payload.status),
    )
    db.add(project)
    db.commit()
    db.refresh(project)
    return serialize_project(project, cipher=field_cipher)


def update_project(
    db: Session,
    *,
    company_id: str,
    project_id: str,
    payload: ProjectDraftPayload,
) -> ProjectResponse:
    field_cipher = cipher()
    project = project_or_404(db, company_id=company_id, project_id=project_id)
    project.name_ciphertext = field_cipher.encrypt(payload.name) or ""
    project.description_ciphertext = field_cipher.encrypt(payload.description)
    project.status = status_value(payload.status)
    db.commit()
    db.refresh(project)
    return serialize_project(project, cipher=field_cipher)


def delete_project(db: Session, *, company_id: str, project_id: str) -> None:
    project = project_or_404(db, company_id=company_id, project_id=project_id)
    project.status = ProjectStatus.inactive.value
    db.commit()


def assign_project_member(
    db: Session,
    *,
    company_id: str,
    project_id: str,
    employee_id: str,
) -> tuple[ProjectMemberSummary, bool]:
    field_cipher = cipher()
    project_or_404(db, company_id=company_id, project_id=project_id)
    employee = employee_or_404(db, company_id=company_id, employee_id=employee_id)
    link = db.scalar(
        select(EmployeeProject).where(
            EmployeeProject.project_id == project_id,
            EmployeeProject.employee_id == employee_id,
        ),
    )
    created = False
    if link is None:
        link = EmployeeProject(employee_id=employee.id, project_id=project_id)
        db.add(link)
        db.commit()
        db.refresh(link)
        link.employee = employee
        created = True
    return serialize_member(link, cipher=field_cipher), created


def remove_project_member(db: Session, *, company_id: str, project_id: str, employee_id: str) -> None:
    project_or_404(db, company_id=company_id, project_id=project_id)
    employee_or_404(db, company_id=company_id, employee_id=employee_id)
    link = db.scalar(
        select(EmployeeProject).where(
            EmployeeProject.project_id == project_id,
            EmployeeProject.employee_id == employee_id,
        ),
    )
    if link is not None:
        db.delete(link)
        db.commit()


def validate_project_for_punch(
    db: Session,
    *,
    company_id: str,
    employee_id: str,
    project_id: str,
) -> Project:
    return _validate_project_for_punch(
        db,
        company_id=company_id,
        employee_id=employee_id,
        project_id=project_id,
    )
