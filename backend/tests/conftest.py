from __future__ import annotations

import os
from pathlib import Path

import pytest
from fastapi.testclient import TestClient


TEST_DB_PATH = Path(__file__).resolve().parent / "test.db"
os.environ["BUNCHIN_DATABASE_URL"] = f"sqlite:///{TEST_DB_PATH.as_posix()}"
os.environ["BUNCHIN_TOKEN_SECRET"] = "tests-token-secret"
os.environ["BUNCHIN_ENCRYPTION_SECRET"] = "tests-encryption-secret"
os.environ["BUNCHIN_SEED_ON_STARTUP"] = "true"
os.environ["BUNCHIN_SEED_ADMIN_PASSWORD"] = "Bunchin@123"

from app.db import Base, SessionLocal, engine  # noqa: E402
from app.main import create_app  # noqa: E402
from app.seed import seed_database_if_empty  # noqa: E402


@pytest.fixture()
def client() -> TestClient:
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)
    with SessionLocal() as db:
        seed_database_if_empty(db)

    app = create_app()
    with TestClient(app) as test_client:
        yield test_client
