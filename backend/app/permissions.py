from __future__ import annotations

AUTH_READ_CONTEXT = "auth.read_context"
TIME_CLOCK_READ = "time_clock.read"
TIME_CLOCK_PUNCH = "time_clock.punch"
EMPLOYEES_READ = "employees.read"
EMPLOYEES_CREATE = "employees.create"
EMPLOYEES_UPDATE = "employees.update"
EMPLOYEES_DELETE = "employees.delete"
COMPANIES_MANAGE = "companies.manage"
ADMIN_CROSS_COMPANY = "admin.cross_company"

ROLE_PERMISSIONS: dict[str, set[str]] = {
    "employee": {
        AUTH_READ_CONTEXT,
        TIME_CLOCK_READ,
        TIME_CLOCK_PUNCH,
    },
    "manager": {
        AUTH_READ_CONTEXT,
        EMPLOYEES_READ,
        EMPLOYEES_UPDATE,
        TIME_CLOCK_READ,
        TIME_CLOCK_PUNCH,
    },
    "admin": {
        AUTH_READ_CONTEXT,
        COMPANIES_MANAGE,
        EMPLOYEES_READ,
        EMPLOYEES_CREATE,
        EMPLOYEES_UPDATE,
        EMPLOYEES_DELETE,
        TIME_CLOCK_READ,
        TIME_CLOCK_PUNCH,
    },
    "super_admin": {
        AUTH_READ_CONTEXT,
        ADMIN_CROSS_COMPANY,
        COMPANIES_MANAGE,
        EMPLOYEES_READ,
        EMPLOYEES_CREATE,
        EMPLOYEES_UPDATE,
        EMPLOYEES_DELETE,
        TIME_CLOCK_READ,
        TIME_CLOCK_PUNCH,
    },
}


def get_permissions_for_role(role: str) -> set[str]:
    return set(ROLE_PERMISSIONS.get(role, set()))
