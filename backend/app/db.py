from __future__ import annotations

from datetime import datetime, timezone

from sqlalchemy import inspect, text
from sqlalchemy import create_engine
from sqlalchemy.pool import StaticPool
from sqlalchemy.orm import DeclarativeBase, sessionmaker

from app.config import get_settings


def utcnow() -> datetime:
    return datetime.now(timezone.utc)


def ensure_utc(value: datetime | None) -> datetime | None:
    if value is None:
        return None
    if value.tzinfo is None:
        return value.replace(tzinfo=timezone.utc)
    return value.astimezone(timezone.utc)


class Base(DeclarativeBase):
    pass


settings = get_settings()
is_sqlite = settings.database_url.startswith("sqlite")
is_memory_sqlite = settings.database_url in {"sqlite://", "sqlite:///:memory:"}
connect_args = {"check_same_thread": False} if is_sqlite else {}
engine_kwargs = {
    "future": True,
    "pool_pre_ping": True,
    "connect_args": connect_args,
}
if is_memory_sqlite:
    engine_kwargs["poolclass"] = StaticPool

engine = create_engine(settings.database_url, **engine_kwargs)
SessionLocal = sessionmaker(
    bind=engine,
    autoflush=False,
    autocommit=False,
    expire_on_commit=False,
)


def init_database() -> None:
    from app import models  # noqa: F401

    Base.metadata.create_all(bind=engine)
    upgrade_database_schema(engine)


def upgrade_database_schema(bind) -> None:
    inspector = inspect(bind)
    if "punches" not in inspector.get_table_names():
        return

    punch_columns = {column["name"] for column in inspector.get_columns("punches")}
    if "project_id" in punch_columns:
        return

    with bind.begin() as connection:
        connection.execute(text("ALTER TABLE punches ADD COLUMN project_id VARCHAR(64)"))
        connection.execute(text("CREATE INDEX IF NOT EXISTS ix_punches_project_id ON punches (project_id)"))

        if bind.dialect.name == "postgresql" and "projects" in inspector.get_table_names():
            foreign_keys = {
                foreign_key.get("name")
                for foreign_key in inspector.get_foreign_keys("punches")
            }
            if "fk_punches_project_id_projects" not in foreign_keys:
                connection.execute(
                    text(
                        "ALTER TABLE punches "
                        "ADD CONSTRAINT fk_punches_project_id_projects "
                        "FOREIGN KEY(project_id) REFERENCES projects(id)",
                    ),
                )
