from __future__ import annotations

from app import models  # noqa: F401
from app.config import get_settings
from app.db import Base, engine


def drop_postgres_tables() -> None:
    settings = get_settings()
    if engine.dialect.name != "postgresql":
        raise RuntimeError(
            "This drop task only supports PostgreSQL. "
            f"Current database URL is '{settings.database_url}'.",
        )

    Base.metadata.drop_all(bind=engine)


if __name__ == "__main__":
    drop_postgres_tables()
    print("PostgreSQL tables dropped (database preserved).")
