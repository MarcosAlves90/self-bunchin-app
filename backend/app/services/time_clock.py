from __future__ import annotations

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.config import get_settings
from app.crypto import FieldCipher
from app.db import ensure_utc, utcnow
from app.domain.project_policy import validate_project_for_punch
from app.domain.time_clock import derive_shift_status
from app.domain.time_clock_read import (
    get_employee_records,
    serialize_managed_record,
    serialize_record,
)
from app.errors import DomainError, ErrorKind
from app.models import Employee, Punch
from app.schemas.punch import (
    CreatePunchRequest,
    ManagePunchRequest,
    PunchType,
    UpdateManagedPunchRequest,
)


def _cipher() -> FieldCipher:
    settings = get_settings()
    return FieldCipher(settings.encryption_secret or "")


def _get_company_employee(db: Session, *, company_id: str, employee_id: str) -> Employee:
    employee = db.scalar(
        select(Employee).where(Employee.company_id == company_id, Employee.id == employee_id),
    )
    if employee is None:
        raise DomainError(ErrorKind.not_found, "Funcionário não encontrado.")
    return employee


def _get_employee_punch(
    db: Session,
    *,
    company_id: str,
    employee_id: str,
    punch_id: str,
) -> Punch:
    record = db.scalar(
        select(Punch).where(
            Punch.company_id == company_id,
            Punch.employee_id == employee_id,
            Punch.id == punch_id,
        ),
    )
    if record is None:
        raise DomainError(ErrorKind.not_found, "Registro de ponto não encontrado.")
    return record


def create_punch(
    db: Session,
    *,
    employee: Employee,
    payload: CreatePunchRequest,
    timezone_name: str,
):
    cipher = _cipher()
    punch_type = PunchType(payload.type)
    all_records = get_employee_records(db, employee_id=employee.id)
    current_status = derive_shift_status(all_records)
    allowed_types = {
        "checkedOut": {PunchType.check_in},
        "working": {PunchType.break_start, PunchType.check_out},
        "onBreak": {PunchType.break_end, PunchType.check_out},
    }
    if punch_type not in allowed_types[current_status.value]:
        raise DomainError(
            ErrorKind.conflict,
            (
                "Transição de ponto inválida para o estado atual. "
                f"Estado atual: {current_status.value}."
            ),
        )

    if employee.requires_location_on_punch and payload.location is None:
        raise DomainError(
            ErrorKind.bad_request,
            "Este funcionário precisa enviar dados de localização ao bater ponto.",
        )

    if payload.project_id is not None:
        validate_project_for_punch(
            db,
            company_id=employee.company_id,
            employee_id=employee.id,
            project_id=payload.project_id,
        )

    detail = {
        PunchType.check_in: "Entrada registrada com localização validada.",
        PunchType.break_start: "Pausa iniciada com localização capturada.",
        PunchType.break_end: "Jornada retomada com localização capturada.",
        PunchType.check_out: "Saída registrada com localização validada.",
    }[punch_type]
    record = Punch(
        company_id=employee.company_id,
        employee_id=employee.id,
        project_id=payload.project_id,
        type=punch_type.value,
        timestamp=utcnow(),
        detail_ciphertext=cipher.encrypt(detail) or "",
        location_payload_ciphertext=cipher.encrypt_json(
            payload.location.model_dump(mode="json", by_alias=False)
            if payload.location is not None
            else None,
        ),
    )
    db.add(record)
    db.commit()
    db.refresh(record)
    return serialize_record(record, cipher=cipher)


def create_managed_punch(
    db: Session,
    *,
    company_id: str,
    employee_id: str,
    payload: ManagePunchRequest,
):
    cipher = _cipher()
    employee = _get_company_employee(db, company_id=company_id, employee_id=employee_id)
    if payload.project_id is not None:
        validate_project_for_punch(
            db,
            company_id=company_id,
            employee_id=employee.id,
            project_id=payload.project_id,
        )

    record = Punch(
        company_id=company_id,
        employee_id=employee.id,
        project_id=payload.project_id,
        type=PunchType(payload.type).value,
        timestamp=ensure_utc(payload.timestamp) if payload.timestamp is not None else utcnow(),
        detail_ciphertext=cipher.encrypt(payload.detail) or "",
        location_payload_ciphertext=cipher.encrypt_json(
            payload.location.model_dump(mode="json", by_alias=False)
            if payload.location is not None
            else None,
        ),
    )
    db.add(record)
    db.commit()
    db.refresh(record)
    return serialize_managed_record(record, cipher=cipher)


def update_managed_punch(
    db: Session,
    *,
    company_id: str,
    employee_id: str,
    punch_id: str,
    payload: UpdateManagedPunchRequest,
):
    cipher = _cipher()
    record = _get_employee_punch(
        db,
        company_id=company_id,
        employee_id=employee_id,
        punch_id=punch_id,
    )

    if "type" in payload.model_fields_set and payload.type is not None:
        record.type = PunchType(payload.type).value
    if "timestamp" in payload.model_fields_set and payload.timestamp is not None:
        record.timestamp = ensure_utc(payload.timestamp)
    if "detail" in payload.model_fields_set and payload.detail is not None:
        record.detail_ciphertext = cipher.encrypt(payload.detail) or ""
    if "project_id" in payload.model_fields_set:
        if payload.project_id is not None:
            validate_project_for_punch(
                db,
                company_id=company_id,
                employee_id=employee_id,
                project_id=payload.project_id,
            )
        record.project_id = payload.project_id
    if "location" in payload.model_fields_set:
        record.location_payload_ciphertext = cipher.encrypt_json(
            payload.location.model_dump(mode="json", by_alias=False)
            if payload.location is not None
            else None,
        )

    db.commit()
    db.refresh(record)
    return serialize_managed_record(record, cipher=cipher)


def delete_managed_punch(
    db: Session,
    *,
    company_id: str,
    employee_id: str,
    punch_id: str,
) -> None:
    record = _get_employee_punch(
        db,
        company_id=company_id,
        employee_id=employee_id,
        punch_id=punch_id,
    )
    db.delete(record)
    db.commit()
