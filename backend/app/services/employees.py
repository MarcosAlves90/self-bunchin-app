from __future__ import annotations

from collections import defaultdict

from fastapi import HTTPException, status
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.config import get_settings
from app.crypto import FieldCipher, lookup_digest
from app.db import ensure_utc
from app.models import Employee, Punch
from app.schemas.employee import EmployeeDraftPayload, EmployeeProfileResponse
from app.services.auth import normalize_email
from app.services.time_clock import calculate_worked_minutes, group_today_records


def _cipher() -> FieldCipher:
    settings = get_settings()
    return FieldCipher(settings.encryption_secret or "")


def _employee_email_hash(email: str) -> str:
    settings = get_settings()
    return lookup_digest(normalize_email(email), settings.encryption_secret or "")


def _serialize_employee(
    employee: Employee,
    *,
    cipher: FieldCipher,
    today_records: list[Punch],
    last_punch_at,
) -> EmployeeProfileResponse:
    return EmployeeProfileResponse(
        id=employee.id,
        name=cipher.decrypt(employee.name_ciphertext) or "",
        role=cipher.decrypt(employee.role_ciphertext) or "",
        department=cipher.decrypt(employee.department_ciphertext) or "",
        email=cipher.decrypt(employee.email_ciphertext) or "",
        phone=cipher.decrypt(employee.phone_ciphertext) or "",
        unit=cipher.decrypt(employee.unit_ciphertext) or "",
        expected_shift=cipher.decrypt(employee.expected_shift_ciphertext) or "",
        status=employee.status,
        work_mode=employee.work_mode,
        role_level=employee.role_level,
        requires_location_on_punch=employee.requires_location_on_punch,
        trusted_device_required=employee.trusted_device_required,
        today_worked_minutes=calculate_worked_minutes(today_records),
        pending_adjustments=employee.pending_adjustments,
        last_punch_at=ensure_utc(last_punch_at),
        notes=cipher.decrypt(employee.notes_ciphertext) or "",
    )


def list_employees(db: Session, *, company_id: str, timezone_name: str) -> list[EmployeeProfileResponse]:
    cipher = _cipher()
    employees = db.scalars(
        select(Employee)
        .where(Employee.company_id == company_id)
        .order_by(Employee.created_at.desc()),
    ).all()

    today_records_by_employee = group_today_records(
        db,
        company_id=company_id,
        timezone_name=timezone_name,
    )
    last_punch_rows = db.execute(
        select(Punch.employee_id, func.max(Punch.timestamp))
        .where(Punch.company_id == company_id)
        .group_by(Punch.employee_id),
    ).all()
    last_punch_by_employee = {employee_id: last_punch_at for employee_id, last_punch_at in last_punch_rows}

    return [
        _serialize_employee(
            employee,
            cipher=cipher,
            today_records=today_records_by_employee.get(employee.id, []),
            last_punch_at=last_punch_by_employee.get(employee.id),
        )
        for employee in employees
    ]


def get_employee(db: Session, *, company_id: str, employee_id: str, timezone_name: str) -> EmployeeProfileResponse:
    cipher = _cipher()
    employee = db.scalar(
        select(Employee).where(Employee.company_id == company_id, Employee.id == employee_id),
    )
    if employee is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Employee not found.",
        )

    today_records_by_employee = group_today_records(
        db,
        company_id=company_id,
        timezone_name=timezone_name,
    )
    last_punch_at = db.scalar(
        select(func.max(Punch.timestamp)).where(Punch.employee_id == employee.id),
    )
    return _serialize_employee(
        employee,
        cipher=cipher,
        today_records=today_records_by_employee.get(employee.id, []),
        last_punch_at=last_punch_at,
    )


def create_employee(
    db: Session,
    *,
    company_id: str,
    payload: EmployeeDraftPayload,
    timezone_name: str,
) -> EmployeeProfileResponse:
    cipher = _cipher()
    status_value = str(payload.status)
    work_mode_value = str(payload.work_mode)
    role_level_value = str(payload.role_level)
    email_hash = _employee_email_hash(str(payload.email))
    existing = db.scalar(
        select(Employee).where(
            Employee.company_id == company_id,
            Employee.email_hash == email_hash,
        ),
    )
    if existing is not None:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="An employee with this email already exists in the company.",
        )

    employee = Employee(
        company_id=company_id,
        name_ciphertext=cipher.encrypt(payload.name) or "",
        role_ciphertext=cipher.encrypt(payload.role) or "",
        department_ciphertext=cipher.encrypt(payload.department) or "",
        email_ciphertext=cipher.encrypt(normalize_email(str(payload.email))) or "",
        email_hash=email_hash,
        phone_ciphertext=cipher.encrypt(payload.phone) or "",
        unit_ciphertext=cipher.encrypt(payload.unit) or "",
        expected_shift_ciphertext=cipher.encrypt(payload.expected_shift) or "",
        status=status_value,
        work_mode=work_mode_value,
        role_level=role_level_value,
        requires_location_on_punch=payload.requires_location_on_punch,
        trusted_device_required=payload.trusted_device_required,
        pending_adjustments=2 if status_value == "onboarding" else 0,
        notes_ciphertext=cipher.encrypt(payload.notes) or "",
    )
    db.add(employee)
    db.commit()
    db.refresh(employee)
    return get_employee(
        db,
        company_id=company_id,
        employee_id=employee.id,
        timezone_name=timezone_name,
    )


def update_employee(
    db: Session,
    *,
    company_id: str,
    employee_id: str,
    payload: EmployeeDraftPayload,
    timezone_name: str,
) -> EmployeeProfileResponse:
    cipher = _cipher()
    status_value = str(payload.status)
    work_mode_value = str(payload.work_mode)
    role_level_value = str(payload.role_level)
    employee = db.scalar(
        select(Employee).where(Employee.company_id == company_id, Employee.id == employee_id),
    )
    if employee is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Employee not found.",
        )

    email_hash = _employee_email_hash(str(payload.email))
    duplicate = db.scalar(
        select(Employee).where(
            Employee.company_id == company_id,
            Employee.email_hash == email_hash,
            Employee.id != employee_id,
        ),
    )
    if duplicate is not None:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Another employee already uses this email.",
        )

    employee.name_ciphertext = cipher.encrypt(payload.name) or ""
    employee.role_ciphertext = cipher.encrypt(payload.role) or ""
    employee.department_ciphertext = cipher.encrypt(payload.department) or ""
    employee.email_ciphertext = cipher.encrypt(normalize_email(str(payload.email))) or ""
    employee.email_hash = email_hash
    employee.phone_ciphertext = cipher.encrypt(payload.phone) or ""
    employee.unit_ciphertext = cipher.encrypt(payload.unit) or ""
    employee.expected_shift_ciphertext = cipher.encrypt(payload.expected_shift) or ""
    employee.status = status_value
    employee.work_mode = work_mode_value
    employee.role_level = role_level_value
    employee.requires_location_on_punch = payload.requires_location_on_punch
    employee.trusted_device_required = payload.trusted_device_required
    employee.notes_ciphertext = cipher.encrypt(payload.notes) or ""
    db.commit()
    return get_employee(
        db,
        company_id=company_id,
        employee_id=employee.id,
        timezone_name=timezone_name,
    )
