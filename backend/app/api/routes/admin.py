from __future__ import annotations

from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.authorization import require_permission
from app.dependencies import get_db
from app.schemas.auth import CompanySummary
from app.services.auth import AuthenticatedContext, summarize_company
from app.models import Company


router = APIRouter()


@router.get("/companies", response_model=list[CompanySummary])
def list_companies_route(
    context: AuthenticatedContext = Depends(
        require_permission("admin.cross_company", scope="global"),
    ),
    db: Session = Depends(get_db),
) -> list[CompanySummary]:
    companies = db.scalars(select(Company).order_by(Company.created_at.asc(), Company.id.asc())).all()
    return [summarize_company(company) for company in companies]
