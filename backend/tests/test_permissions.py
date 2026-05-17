from app.permissions import get_permissions_for_role


def test_admin_has_employee_permissions():
    permissions = get_permissions_for_role("admin")
    assert "employees.read" in permissions
    assert "employees.update" in permissions
    assert "admin.cross_company" not in permissions


def test_super_admin_has_cross_company_permission():
    permissions = get_permissions_for_role("super_admin")
    assert "admin.cross_company" in permissions
    assert "companies.manage" in permissions
