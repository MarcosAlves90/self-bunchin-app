from __future__ import annotations

from datetime import datetime
from enum import Enum

from pydantic import Field

from app.schemas.base import CamelModel


class ProjectStatus(str, Enum):
    active = "active"
    inactive = "inactive"


class ProjectDraftPayload(CamelModel):
    name: str = Field(min_length=1, max_length=160)
    description: str | None = Field(default=None, max_length=2000)
    status: ProjectStatus = ProjectStatus.active


class ProjectResponse(CamelModel):
    id: str
    name: str
    description: str | None = None
    status: ProjectStatus
    created_at: datetime
    updated_at: datetime


class ProjectMemberPayload(CamelModel):
    employee_id: str = Field(min_length=1)


class ProjectMemberSummary(CamelModel):
    employee_id: str
    project_id: str
    employee_name: str
    created_at: datetime
