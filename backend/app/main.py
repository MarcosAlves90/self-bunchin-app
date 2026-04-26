from __future__ import annotations

from contextlib import asynccontextmanager

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from app.api.router import api_router
from app.config import get_settings
from app.db import SessionLocal, init_database
from app.seed import seed_database_if_empty


@asynccontextmanager
async def lifespan(app: FastAPI):
    settings = get_settings()
    init_database()
    if settings.seed_on_startup:
        with SessionLocal() as db:
            seed_database_if_empty(db)
    yield


def create_app() -> FastAPI:
    settings = get_settings()
    app = FastAPI(
        title=settings.app_name,
        version="1.0.0",
        lifespan=lifespan,
    )

    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.allowed_origins,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    @app.middleware("http")
    async def https_guard(request: Request, call_next):
        if not settings.enforce_https:
            return await call_next(request)

        forwarded_proto = request.headers.get("x-forwarded-proto", "")
        is_secure = request.url.scheme == "https" or forwarded_proto == "https"
        is_localhost = request.url.hostname in {"127.0.0.1", "localhost"}
        if not is_secure and not is_localhost:
            return JSONResponse(
                status_code=400,
                content={
                    "detail": (
                        "HTTPS is required for non-local requests because this API "
                        "handles personal and location data."
                    ),
                },
            )
        return await call_next(request)

    app.include_router(api_router)
    return app


app = create_app()
