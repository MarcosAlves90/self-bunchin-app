from __future__ import annotations

from contextlib import asynccontextmanager

from fastapi import FastAPI

from app.db import SessionLocal, init_database
from app.seed import seed_database_if_empty
from app.config import get_settings


@asynccontextmanager
async def lifespan(app: FastAPI):
    settings = get_settings()
    if settings.bootstrap_database_on_startup or settings.seed_on_startup:
        init_database()
    if settings.seed_on_startup:
        with SessionLocal() as db:
            seed_database_if_empty(db)
    yield
