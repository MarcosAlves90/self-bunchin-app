from __future__ import annotations

from math import ceil

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.config import get_settings
from app.crypto import FieldCipher
from app.db import ensure_utc
from app.domain.time_clock import (
    calculate_break_minutes,
    calculate_worked_minutes,
    derive_shift_status,
    group_today_records,
)
from app.errors import DomainError, ErrorKind
from app.models import Employee, Punch
from app.schemas.punch import (
    ManagedPunchPageResponse,
    ManagedPunchRecordResponse,
    PunchLocationSnapshotPayload,
    PunchRecordResponse,
    PunchType,
    TimeClockEmployeeSummary,
    TimeClockStateResponse,
)


def _cipher() -> FieldCipher:
    settings = get_settings()
    return FieldCipher(settings.encryption_secret or "")


def deserialize_location(
    ciphertext: str | None,
    *,
    cipher: FieldCipher,
) -> PunchLocationSnapshotPayload | None:
    payload = cipher.decrypt_json(ciphertext)
    if payload is None:
        return None
    return PunchLocationSnapshotPayload.model_validate(payload)


def serialize_record(record: Punch, *, cipher: FieldCipher) -> PunchRecordResponse:
    return PunchRecordResponse(
        type=record.type,
        timestamp=ensure_utc(record.timestamp),
        detail=cipher.decrypt(record.detail_ciphertext) or "",
        project_id=record.project_id,
        location=deserialize_location(record.location_payload_ciphertext, cipher=cipher),
    )


def serialize_managed_record(record: Punch, *, cipher: FieldCipher) -> ManagedPunchRecordResponse:
    return ManagedPunchRecordResponse(
        id=record.id,
        employee_id=record.employee_id,
        type=record.type,
        timestamp=ensure_utc(record.timestamp),
        detail=cipher.decrypt(record.detail_ciphertext) or "",
        project_id=record.project_id,
        location=deserialize_location(record.location_payload_ciphertext, cipher=cipher),
    )


def _get_company_employee(db: Session, *, company_id: str, employee_id: str) -> Employee:
    employee = db.scalar(
        select(Employee).where(Employee.company_id == company_id, Employee.id == employee_id),
    )
    if employee is None:
        raise DomainError(ErrorKind.not_found, "Funcionário não encontrado.")
    return employee


def get_employee_records(db: Session, *, employee_id: str) -> list[Punch]:
    return db.scalars(
        select(Punch).where(Punch.employee_id == employee_id).order_by(Punch.timestamp),
    ).all()


def _paginate_records(
    records: list[Punch],
    *,
    page: int,
    page_size: int,
) -> tuple[list[Punch], int, int, int, bool, bool]:
    normalized_page_size = max(page_size, 1)
    total_records = len(records)
    total_pages = max(ceil(total_records / normalized_page_size), 1)
    normalized_page = min(max(page, 1), total_pages)
    start_index = (normalized_page - 1) * normalized_page_size
    end_index = start_index + normalized_page_size
    page_records = records[start_index:end_index]
    return (
        page_records,
        normalized_page,
        normalized_page_size,
        total_records,
        total_pages,
        normalized_page > 1,
        normalized_page < total_pages,
    )


def time_clock_state(db: Session, *, employee: Employee, timezone_name: str) -> TimeClockStateResponse:
    return time_clock_state_page(
        db,
        employee=employee,
        timezone_name=timezone_name,
        page=1,
        page_size=4,
    )


def time_clock_state_page(
    db: Session,
    *,
    employee: Employee,
    timezone_name: str,
    page: int,
    page_size: int,
) -> TimeClockStateResponse:
    cipher = _cipher()
    all_records = get_employee_records(db, employee_id=employee.id)
    today_records = group_today_records(
        db,
        company_id=employee.company_id,
        timezone_name=timezone_name,
    ).get(employee.id, [])
    display_records = list(reversed(today_records))
    page_records, normalized_page, normalized_page_size, total_records, total_pages, has_previous, has_next = _paginate_records(
        display_records,
        page=page,
        page_size=page_size,
    )

    first_check_in_at = next(
        (
            ensure_utc(record.timestamp)
            for record in today_records
            if record.type == PunchType.check_in.value
        ),
        None,
    )
    last_punch_at = ensure_utc(all_records[-1].timestamp) if all_records else None

    return TimeClockStateResponse(
        employee=TimeClockEmployeeSummary(
            id=employee.id,
            name=cipher.decrypt(employee.name_ciphertext) or "",
            unit=cipher.decrypt(employee.unit_ciphertext) or "",
            status=employee.status,
            work_mode=employee.work_mode,
            requires_location_on_punch=employee.requires_location_on_punch,
            trusted_device_required=employee.trusted_device_required,
        ),
        current_status=derive_shift_status(all_records),
        today_worked_minutes=calculate_worked_minutes(today_records),
        today_break_minutes=calculate_break_minutes(today_records),
        first_check_in_at=first_check_in_at,
        last_punch_at=last_punch_at,
        records=[serialize_record(record, cipher=cipher) for record in page_records],
        records_page=normalized_page,
        records_page_size=normalized_page_size,
        records_total=total_records,
        records_total_pages=total_pages,
        records_has_previous=has_previous,
        records_has_next=has_next,
    )


def list_managed_punches_page(
    db: Session,
    *,
    company_id: str,
    employee_id: str,
    page: int,
    page_size: int,
) -> ManagedPunchPageResponse:
    cipher = _cipher()
    _get_company_employee(db, company_id=company_id, employee_id=employee_id)
    records = db.scalars(
        select(Punch)
        .where(Punch.company_id == company_id, Punch.employee_id == employee_id)
        .order_by(Punch.timestamp.desc(), Punch.id.desc()),
    ).all()
    page_records, normalized_page, normalized_page_size, total_records, total_pages, has_previous, has_next = _paginate_records(
        records,
        page=page,
        page_size=page_size,
    )
    return ManagedPunchPageResponse(
        records=[serialize_managed_record(record, cipher=cipher) for record in page_records],
        records_page=normalized_page,
        records_page_size=normalized_page_size,
        records_total=total_records,
        records_total_pages=total_pages,
        records_has_previous=has_previous,
        records_has_next=has_next,
    )
