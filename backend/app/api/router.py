from fastapi import APIRouter

from app.api.routes import auth, employees, health, time_clock


api_router = APIRouter(prefix="/api/v1")
api_router.include_router(health.router, tags=["health"])
api_router.include_router(auth.router, prefix="/auth", tags=["auth"])
api_router.include_router(employees.router, prefix="/employees", tags=["employees"])
api_router.include_router(time_clock.router, prefix="/time-clock", tags=["time-clock"])
