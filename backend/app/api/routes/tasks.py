from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, Response, status
from sqlalchemy.orm import Session

from app.authorization import require_permission
from app.dependencies import get_db
from app.domain.task_read import get_task, list_task_members, list_tasks
from app.schemas.task import TaskDraftPayload, TaskMemberPayload, TaskMemberSummary, TaskResponse
from app.services.auth import AuthenticatedContext
from app.services.tasks import add_task_member, create_task, remove_task_member, update_task


router = APIRouter()


def _employee_id_or_403(context: AuthenticatedContext) -> str:
    if context.employee is None:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Employee profile is required for task membership.",
        )
    return context.employee.id


@router.get("/{project_id}/tasks", response_model=list[TaskResponse])
def list_tasks_route(
    project_id: str,
    context: AuthenticatedContext = Depends(require_permission("projects.read")),
    db: Session = Depends(get_db),
) -> list[TaskResponse]:
    return list_tasks(db, company_id=context.company.id, project_id=project_id)


@router.post("/{project_id}/tasks", response_model=TaskResponse, status_code=status.HTTP_201_CREATED)
def create_task_route(
    project_id: str,
    payload: TaskDraftPayload,
    context: AuthenticatedContext = Depends(require_permission("tasks.create")),
    db: Session = Depends(get_db),
) -> TaskResponse:
    return create_task(
        db,
        company_id=context.company.id,
        project_id=project_id,
        payload=payload,
    )


@router.get("/{project_id}/tasks/{task_id}", response_model=TaskResponse)
def get_task_route(
    project_id: str,
    task_id: str,
    context: AuthenticatedContext = Depends(require_permission("projects.read")),
    db: Session = Depends(get_db),
) -> TaskResponse:
    return get_task(
        db,
        company_id=context.company.id,
        project_id=project_id,
        task_id=task_id,
    )


@router.put("/{project_id}/tasks/{task_id}", response_model=TaskResponse)
@router.patch("/{project_id}/tasks/{task_id}", response_model=TaskResponse)
def update_task_route(
    project_id: str,
    task_id: str,
    payload: TaskDraftPayload,
    context: AuthenticatedContext = Depends(require_permission("tasks.update")),
    db: Session = Depends(get_db),
) -> TaskResponse:
    return update_task(
        db,
        company_id=context.company.id,
        project_id=project_id,
        task_id=task_id,
        payload=payload,
    )


@router.get("/{project_id}/tasks/{task_id}/members", response_model=list[TaskMemberSummary])
def list_task_members_route(
    project_id: str,
    task_id: str,
    context: AuthenticatedContext = Depends(require_permission("projects.read")),
    db: Session = Depends(get_db),
) -> list[TaskMemberSummary]:
    return list_task_members(
        db,
        company_id=context.company.id,
        project_id=project_id,
        task_id=task_id,
    )


@router.post(
    "/{project_id}/tasks/{task_id}/members/me",
    response_model=TaskMemberSummary,
    status_code=status.HTTP_201_CREATED,
)
def join_task_route(
    project_id: str,
    task_id: str,
    response: Response,
    context: AuthenticatedContext = Depends(require_permission("tasks.members.manage")),
    db: Session = Depends(get_db),
) -> TaskMemberSummary:
    member, created = add_task_member(
        db,
        company_id=context.company.id,
        project_id=project_id,
        task_id=task_id,
        employee_id=_employee_id_or_403(context),
    )
    if not created:
        response.status_code = status.HTTP_200_OK
    return member


@router.delete("/{project_id}/tasks/{task_id}/members/me", status_code=status.HTTP_204_NO_CONTENT)
def leave_task_route(
    project_id: str,
    task_id: str,
    context: AuthenticatedContext = Depends(require_permission("tasks.members.manage")),
    db: Session = Depends(get_db),
) -> Response:
    remove_task_member(
        db,
        company_id=context.company.id,
        project_id=project_id,
        task_id=task_id,
        employee_id=_employee_id_or_403(context),
    )
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.post(
    "/{project_id}/tasks/{task_id}/members",
    response_model=TaskMemberSummary,
    status_code=status.HTTP_201_CREATED,
)
def add_task_member_route(
    project_id: str,
    task_id: str,
    payload: TaskMemberPayload,
    response: Response,
    context: AuthenticatedContext = Depends(require_permission("tasks.members.manage")),
    db: Session = Depends(get_db),
) -> TaskMemberSummary:
    _employee_id_or_403(context)
    member, created = add_task_member(
        db,
        company_id=context.company.id,
        project_id=project_id,
        task_id=task_id,
        employee_id=payload.employee_id,
    )
    if not created:
        response.status_code = status.HTTP_200_OK
    return member


@router.delete(
    "/{project_id}/tasks/{task_id}/members/{employee_id}",
    status_code=status.HTTP_204_NO_CONTENT,
)
def remove_task_member_route(
    project_id: str,
    task_id: str,
    employee_id: str,
    context: AuthenticatedContext = Depends(require_permission("tasks.members.manage")),
    db: Session = Depends(get_db),
) -> Response:
    _employee_id_or_403(context)
    remove_task_member(
        db,
        company_id=context.company.id,
        project_id=project_id,
        task_id=task_id,
        employee_id=employee_id,
    )
    return Response(status_code=status.HTTP_204_NO_CONTENT)
