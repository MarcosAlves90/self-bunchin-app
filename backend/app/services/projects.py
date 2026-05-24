from __future__ import annotations

from sqlalchemy import select
from sqlalchemy.orm import Session, selectinload

from app.config import get_settings
from app.crypto import FieldCipher
from app.domain.project_policy import validate_project_for_punch as _validate_project_for_punch
from app.errors import DomainError, ErrorKind
from app.models import Employee, EmployeeProject, Project
from app.schemas.project import (
    ProjectDraftPayload,
    ProjectMemberSummary,
    ProjectResponse,
    ProjectStatus,
)


def _cipher() -> FieldCipher:
    settings = get_settings()
    return FieldCipher(settings.encryption_secret or "")


def _project_or_404(db: Session, *, company_id: str, project_id: str) -> Project:
    project = db.scalar(
        select(Project).where(Project.company_id == company_id, Project.id == project_id),
    )
    if project is None:
        raise DomainError(ErrorKind.not_found, "Project not found.")
    return project


def _employee_or_404(db: Session, *, company_id: str, employee_id: str) -> Employee:
    employee = db.scalar(
        select(Employee).where(Employee.company_id == company_id, Employee.id == employee_id),
    )
    if employee is None:
        raise DomainError(ErrorKind.not_found, "Employee not found.")
    return employee


def _serialize_project(project: Project, *, cipher: FieldCipher) -> ProjectResponse:
    return ProjectResponse(
        id=project.id,
        name=cipher.decrypt(project.name_ciphertext) or "",
        description=cipher.decrypt(project.description_ciphertext),
        status=project.status,
        created_at=project.created_at,
        updated_at=project.updated_at,
    )


def _serialize_member(link: EmployeeProject, *, cipher: FieldCipher) -> ProjectMemberSummary:
    return ProjectMemberSummary(
        employee_id=link.employee_id,
        project_id=link.project_id,
        employee_name=cipher.decrypt(link.employee.name_ciphertext) or "",
        created_at=link.created_at,
    )


def _status_value(value: ProjectStatus | str) -> str:
    if isinstance(value, ProjectStatus):
        return value.value
    return value


def list_projects(
    db: Session,
    *,
    company_id: str,
    status_filter: ProjectStatus | None = None,
) -> list[ProjectResponse]:
    cipher = _cipher()
    query = select(Project).where(Project.company_id == company_id)
    if status_filter is not None:
        query = query.where(Project.status == _status_value(status_filter))
    projects = db.scalars(query.order_by(Project.created_at.desc(), Project.id.desc())).all()
    return [_serialize_project(project, cipher=cipher) for project in projects]


def get_project(db: Session, *, company_id: str, project_id: str) -> ProjectResponse:
    cipher = _cipher()
    project = _project_or_404(db, company_id=company_id, project_id=project_id)
    return _serialize_project(project, cipher=cipher)


def create_project(db: Session, *, company_id: str, payload: ProjectDraftPayload) -> ProjectResponse:
    cipher = _cipher()
    project = Project(
        company_id=company_id,
        name_ciphertext=cipher.encrypt(payload.name) or "",
        description_ciphertext=cipher.encrypt(payload.description),
        status=_status_value(payload.status),
    )
    db.add(project)
    db.commit()
    db.refresh(project)
    return _serialize_project(project, cipher=cipher)


def update_project(
    db: Session,
    *,
    company_id: str,
    project_id: str,
    payload: ProjectDraftPayload,
) -> ProjectResponse:
    cipher = _cipher()
    project = _project_or_404(db, company_id=company_id, project_id=project_id)
    project.name_ciphertext = cipher.encrypt(payload.name) or ""
    project.description_ciphertext = cipher.encrypt(payload.description)
    project.status = _status_value(payload.status)
    db.commit()
    db.refresh(project)
    return _serialize_project(project, cipher=cipher)


def delete_project(db: Session, *, company_id: str, project_id: str) -> None:
    project = _project_or_404(db, company_id=company_id, project_id=project_id)
    project.status = ProjectStatus.inactive.value
    db.commit()


def list_project_members(db: Session, *, company_id: str, project_id: str) -> list[ProjectMemberSummary]:
    cipher = _cipher()
    _project_or_404(db, company_id=company_id, project_id=project_id)
    links = db.scalars(
        select(EmployeeProject)
        .join(Employee, Employee.id == EmployeeProject.employee_id)
        .options(selectinload(EmployeeProject.employee))
        .where(
            EmployeeProject.project_id == project_id,
            Employee.company_id == company_id,
        )
        .order_by(EmployeeProject.created_at, EmployeeProject.employee_id),
    ).all()
    return [_serialize_member(link, cipher=cipher) for link in links]


def assign_project_member(
    db: Session,
    *,
    company_id: str,
    project_id: str,
    employee_id: str,
) -> tuple[ProjectMemberSummary, bool]:
    cipher = _cipher()
    _project_or_404(db, company_id=company_id, project_id=project_id)
    employee = _employee_or_404(db, company_id=company_id, employee_id=employee_id)
    link = db.scalar(
        select(EmployeeProject)
        .options(selectinload(EmployeeProject.employee))
        .where(
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
    return _serialize_member(link, cipher=cipher), created


def remove_project_member(db: Session, *, company_id: str, project_id: str, employee_id: str) -> None:
    _project_or_404(db, company_id=company_id, project_id=project_id)
    _employee_or_404(db, company_id=company_id, employee_id=employee_id)
    link = db.scalar(
        select(EmployeeProject).where(
            EmployeeProject.project_id == project_id,
            EmployeeProject.employee_id == employee_id,
        ),
    )
    if link is not None:
        db.delete(link)
        db.commit()


def list_employee_projects(db: Session, *, company_id: str, employee_id: str) -> list[ProjectResponse]:
    cipher = _cipher()
    _employee_or_404(db, company_id=company_id, employee_id=employee_id)
    projects = db.scalars(
        select(Project)
        .join(EmployeeProject, EmployeeProject.project_id == Project.id)
        .where(
            Project.company_id == company_id,
            EmployeeProject.employee_id == employee_id,
        )
        .order_by(Project.created_at.desc(), Project.id.desc()),
    ).all()
    return [_serialize_project(project, cipher=cipher) for project in projects]


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
