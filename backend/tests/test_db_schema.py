from sqlalchemy import create_engine, inspect, text

from app.db import upgrade_database_schema


def test_upgrade_database_schema_adds_project_id_to_legacy_punches_table(tmp_path):
    database_path = tmp_path / "legacy.db"
    engine = create_engine(f"sqlite:///{database_path}", future=True)
    with engine.begin() as connection:
        connection.execute(
            text(
                "CREATE TABLE punches ("
                "id VARCHAR(64) PRIMARY KEY, "
                "company_id VARCHAR(64) NOT NULL, "
                "employee_id VARCHAR(64) NOT NULL, "
                "type VARCHAR(32) NOT NULL, "
                "timestamp DATETIME NOT NULL, "
                "detail_ciphertext TEXT NOT NULL, "
                "location_payload_ciphertext TEXT, "
                "created_at DATETIME NOT NULL"
                ")",
            ),
        )

    upgrade_database_schema(engine)

    inspector = inspect(engine)
    columns = {column["name"] for column in inspector.get_columns("punches")}
    indexes = {index["name"] for index in inspector.get_indexes("punches")}
    assert "project_id" in columns
    assert "ix_punches_project_id" in indexes
