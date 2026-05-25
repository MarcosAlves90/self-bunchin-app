from __future__ import annotations

from sqlalchemy import inspect, text


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
