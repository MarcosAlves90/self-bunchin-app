from __future__ import annotations

from collections import defaultdict
from datetime import datetime, timedelta, timezone, time
from zoneinfo import ZoneInfo

from app.db import ensure_utc, utcnow
from app.models import Punch
from app.schemas.punch import PunchType, ShiftStatus


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
    db,
    *,
    company_id: str,
    timezone_name: str,
) -> dict[str, list[Punch]]:
    from sqlalchemy import select

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
