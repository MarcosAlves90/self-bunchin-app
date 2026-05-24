from __future__ import annotations

from collections import defaultdict
from datetime import datetime, timedelta, timezone
from zoneinfo import ZoneInfo

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.config import get_settings
from app.crypto import FieldCipher
from app.db import ensure_utc, utcnow
from app.errors import DomainError, ErrorKind
from app.domain.project_policy import validate_project_for_punch
from app.models import Employee, Punch
from app.schemas.punch import (
    CreatePunchRequest,
    ManagedPunchRecordResponse,
    ManagePunchRequest,
    PunchLocationSnapshotPayload,
    PunchRecordResponse,
    PunchType,
    ShiftStatus,
    TimeClockEmployeeSummary,
    TimeClockStateResponse,
    UpdateManagedPunchRequest,
)
def _cipher() -> FieldCipher:
    settings = get_settings()
    return FieldCipher(settings.encryption_secret or "")


def local_day_bounds(timezone_name: str) -> tuple[datetime, datetime]:
    zone = ZoneInfo(timezone_name)
    local_now = utcnow().astimezone(zone)
    start_local = datetime(
        local_now.year,
        local_now.month,
        local_now.day,
        tzinfo=zone,
    )
    end_local = start_local + timedelta(days=1)
    return start_local.astimezone(timezone.utc), end_local.astimezone(timezone.utc)


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
        raise DomainError(ErrorKind.not_found, "Employee not found.")
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
        raise DomainError(ErrorKind.not_found, "Punch not found.")
    return record


def derive_shift_status(records: list[Punch]) -> ShiftStatus:
    if not records:
        return ShiftStatus.checked_out

    last_type = PunchType(records[-1].type)
    if last_type in {PunchType.check_in, PunchType.break_end}:
        return ShiftStatus.working
    if last_type == PunchType.break_start:
        return ShiftStatus.on_break
    return ShiftStatus.checked_out


def calculate_worked_minutes(records: list[Punch]) -> int:
    total = timedelta()
    start: datetime | None = None
    for record in records:
        record_timestamp = ensure_utc(record.timestamp) or utcnow()
        record_type = PunchType(record.type)
        if record_type in {PunchType.check_in, PunchType.break_end}:
            start = record_timestamp if start is None else start
        if record_type in {PunchType.break_start, PunchType.check_out} and start is not None:
            total += record_timestamp - start
            start = None
    if derive_shift_status(records) == ShiftStatus.working and start is not None:
        total += utcnow() - start
    return max(int(total.total_seconds() // 60), 0)


def calculate_break_minutes(records: list[Punch]) -> int:
    total = timedelta()
    start: datetime | None = None
    for record in records:
        record_timestamp = ensure_utc(record.timestamp) or utcnow()
        record_type = PunchType(record.type)
        if record_type == PunchType.break_start:
            start = record_timestamp
        if record_type in {PunchType.break_end, PunchType.check_out} and start is not None:
            total += record_timestamp - start
            start = None
    if derive_shift_status(records) == ShiftStatus.on_break and start is not None:
        total += utcnow() - start
    return max(int(total.total_seconds() // 60), 0)


def group_today_records(
    db: Session,
    *,
    company_id: str,
    timezone_name: str,
) -> dict[str, list[Punch]]:
    start_at, end_at = local_day_bounds(timezone_name)
    today_records = db.scalars(
        select(Punch)
        .where(
            Punch.company_id == company_id,
            Punch.timestamp >= start_at,
            Punch.timestamp < end_at,
        )
        .order_by(Punch.employee_id, Punch.timestamp),
    ).all()

    grouped: dict[str, list[Punch]] = defaultdict(list)
    for record in today_records:
        grouped[record.employee_id].append(record)
    return grouped


def get_employee_records(db: Session, *, employee_id: str) -> list[Punch]:
    return db.scalars(
        select(Punch).where(Punch.employee_id == employee_id).order_by(Punch.timestamp),
    ).all()


def time_clock_state(db: Session, *, employee: Employee, timezone_name: str) -> TimeClockStateResponse:
    cipher = _cipher()
    all_records = get_employee_records(db, employee_id=employee.id)
    today_records = group_today_records(
        db,
        company_id=employee.company_id,
        timezone_name=timezone_name,
    ).get(employee.id, [])

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
        records=[serialize_record(record, cipher=cipher) for record in today_records],
    )


def create_punch(
    db: Session,
    *,
    employee: Employee,
    payload: CreatePunchRequest,
    timezone_name: str,
) -> PunchRecordResponse:
    cipher = _cipher()
    punch_type = PunchType(payload.type)
    all_records = get_employee_records(db, employee_id=employee.id)
    current_status = derive_shift_status(all_records)
    allowed_types = {
        ShiftStatus.checked_out: {PunchType.check_in},
        ShiftStatus.working: {PunchType.break_start, PunchType.check_out},
        ShiftStatus.on_break: {PunchType.break_end, PunchType.check_out},
    }
    if punch_type not in allowed_types[current_status]:
        raise DomainError(
            ErrorKind.conflict,
            (
                "Invalid punch transition for the current shift status. "
                f"Current status: {current_status.value}."
            ),
        )

    if employee.requires_location_on_punch and payload.location is None:
        raise DomainError(
            ErrorKind.bad_request,
            "This employee must submit location data when punching.",
        )

    if payload.project_id is not None:
        validate_project_for_punch(
            db,
            company_id=employee.company_id,
            employee_id=employee.id,
            project_id=payload.project_id,
        )

    detail = {
        PunchType.check_in: "Entrada registrada com localizacao validada.",
        PunchType.break_start: "Pausa iniciada com localizacao capturada.",
        PunchType.break_end: "Jornada retomada com localizacao capturada.",
        PunchType.check_out: "Saida registrada com localizacao validada.",
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


def list_managed_punches(
    db: Session,
    *,
    company_id: str,
    employee_id: str,
) -> list[ManagedPunchRecordResponse]:
    cipher = _cipher()
    _get_company_employee(db, company_id=company_id, employee_id=employee_id)
    records = db.scalars(
        select(Punch)
        .where(Punch.company_id == company_id, Punch.employee_id == employee_id)
        .order_by(Punch.timestamp.asc(), Punch.id.asc()),
    ).all()
    return [serialize_managed_record(record, cipher=cipher) for record in records]


def create_managed_punch(
    db: Session,
    *,
    company_id: str,
    employee_id: str,
    payload: ManagePunchRequest,
) -> ManagedPunchRecordResponse:
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
) -> ManagedPunchRecordResponse:
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
