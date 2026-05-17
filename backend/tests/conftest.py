from __future__ import annotations

from collections.abc import Generator
import os

import pytest
from fastapi.testclient import TestClient


os.environ["BUNCHIN_DATABASE_URL"] = "sqlite://"
os.environ["BUNCHIN_TOKEN_SECRET"] = "tests-token-secret"
os.environ["BUNCHIN_ENCRYPTION_SECRET"] = "tests-encryption-secret"
os.environ["BUNCHIN_SEED_ON_STARTUP"] = "true"

from app.db import Base, SessionLocal, engine  # noqa: E402
from app.main import create_app  # noqa: E402
from app.seed import seed_database_if_empty  # noqa: E402


@pytest.fixture()
def client() -> Generator[TestClient, None, None]:
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)
    with SessionLocal() as db:
        seed_database_if_empty(db)

    app = create_app()
    with TestClient(app) as test_client:
        yield test_client
