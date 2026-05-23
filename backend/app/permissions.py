from __future__ import annotations

AUTH_READ_CONTEXT = "auth.read_context"
TIME_CLOCK_READ = "time_clock.read"
TIME_CLOCK_PUNCH = "time_clock.punch"
TIME_CLOCK_MANAGE = "time_clock.manage"
EMPLOYEES_READ = "employees.read"
EMPLOYEES_CREATE = "employees.create"
EMPLOYEES_UPDATE = "employees.update"
EMPLOYEES_DELETE = "employees.delete"
PROJECTS_READ = "projects.read"
PROJECTS_CREATE = "projects.create"
PROJECTS_UPDATE = "projects.update"
PROJECTS_DELETE = "projects.delete"
PROJECTS_ASSIGN = "projects.assign"
COMPANIES_MANAGE = "companies.manage"
ADMIN_CROSS_COMPANY = "admin.cross_company"

ROLE_PERMISSIONS: dict[str, set[str]] = {
    "employee": {
        AUTH_READ_CONTEXT,
        PROJECTS_READ,
        TIME_CLOCK_READ,
        TIME_CLOCK_PUNCH,
    },
    "manager": {
        AUTH_READ_CONTEXT,
        EMPLOYEES_READ,
        EMPLOYEES_UPDATE,
        PROJECTS_READ,
        PROJECTS_CREATE,
        PROJECTS_UPDATE,
        PROJECTS_ASSIGN,
        TIME_CLOCK_READ,
        TIME_CLOCK_PUNCH,
        TIME_CLOCK_MANAGE,
    },
    "admin": {
        AUTH_READ_CONTEXT,
        COMPANIES_MANAGE,
        EMPLOYEES_READ,
        EMPLOYEES_CREATE,
        EMPLOYEES_UPDATE,
        EMPLOYEES_DELETE,
        PROJECTS_READ,
        PROJECTS_CREATE,
        PROJECTS_UPDATE,
        PROJECTS_DELETE,
        PROJECTS_ASSIGN,
        TIME_CLOCK_READ,
        TIME_CLOCK_PUNCH,
        TIME_CLOCK_MANAGE,
    },
    "super_admin": {
        AUTH_READ_CONTEXT,
        ADMIN_CROSS_COMPANY,
        COMPANIES_MANAGE,
        EMPLOYEES_READ,
        EMPLOYEES_CREATE,
        EMPLOYEES_UPDATE,
        EMPLOYEES_DELETE,
        PROJECTS_READ,
        PROJECTS_CREATE,
        PROJECTS_UPDATE,
        PROJECTS_DELETE,
        PROJECTS_ASSIGN,
        TIME_CLOCK_READ,
        TIME_CLOCK_PUNCH,
        TIME_CLOCK_MANAGE,
    },
}


def get_permissions_for_role(role: str) -> set[str]:
    return set(ROLE_PERMISSIONS.get(role, set()))
