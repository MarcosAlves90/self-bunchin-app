from __future__ import annotations

from uuid import uuid4

from sqlalchemy import select

from app.config import get_settings
from app.events import get_event_bus
from app.db import SessionLocal
from app.models import Employee
from app.services.employees import _cipher

TEST_SEED_SECRET = get_settings().seed_admin_password
TEST_REGISTER_SECRET = f"test-register-{uuid4().hex}"


def login_headers(client):
    response = client.post(
        "/api/v1/auth/login",
        json={
            "email": "marina.costa@bunchin.com",
            "password": TEST_SEED_SECRET,
            "keepConnected": True,
        },
    )
    assert response.status_code == 200
    token = response.json()["accessToken"]
    return {"Authorization": f"Bearer {token}"}


def login_headers_for(client, *, email: str, password: str):
    response = client.post(
        "/api/v1/auth/login",
        json={
            "email": email,
            "password": password,
            "keepConnected": True,
        },
    )
    assert response.status_code == 200
    token = response.json()["accessToken"]
    return {"Authorization": f"Bearer {token}"}


def test_health_check(client):
    response = client.get("/api/v1/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_login_and_get_employees(client):
    headers = login_headers(client)
    response = client.get("/api/v1/employees", headers=headers)
    assert response.status_code == 200
    employees = response.json()
    assert len(employees) == 5
    assert employees[0]["id"] == "emp-05"
    assert employees[-1]["id"] == "emp-01"
    assert employees[-1]["requiresLocationOnPunch"] is True


def test_employee_cannot_list_employees(client):
    headers = login_headers_for(
        client,
        email="joao.lima@bunchin.com",
        password=TEST_SEED_SECRET,
    )
    response = client.get("/api/v1/employees", headers=headers)
    assert response.status_code == 403


def test_create_and_update_employee(client):
    headers = login_headers(client)
    create_response = client.post(
        "/api/v1/employees",
        headers=headers,
        json={
            "name": "Renata Souza",
            "role": "Analista Financeira",
            "department": "Financeiro",
            "email": "renata.souza@bunchin.com",
            "phone": "(11) 94444-6060",
            "unit": "Backoffice Centro",
            "expectedShiftStart": "08:00",
            "expectedShiftEnd": "17:00",
            "status": "active",
            "workMode": "hybrid",
            "roleLevel": "specialist",
            "requiresLocationOnPunch": False,
            "trustedDeviceRequired": True,
            "notes": "Nova contratacao para apoiar o fechamento mensal.",
        },
    )
    assert create_response.status_code == 201
    employee = create_response.json()
    assert employee["email"] == "renata.souza@bunchin.com"
    assert employee["expectedShiftStart"] == "08:00:00"
    assert employee["expectedShiftEnd"] == "17:00:00"
    assert employee["todayWorkedMinutes"] == 0

    update_response = client.put(
        f"/api/v1/employees/{employee['id']}",
        headers=headers,
        json={
            "name": "Renata Souza",
            "role": "Analista Financeira Senior",
            "department": "Financeiro",
            "email": "renata.souza@bunchin.com",
            "phone": "(11) 94444-6060",
            "unit": "Backoffice Centro",
            "expectedShiftStart": "08:00",
            "expectedShiftEnd": "17:00",
            "status": "active",
            "workMode": "remote",
            "roleLevel": "specialist",
            "requiresLocationOnPunch": False,
            "trustedDeviceRequired": True,
            "notes": "Atualizada para operacao remota.",
        },
    )
    assert update_response.status_code == 200
    updated = update_response.json()
    assert updated["role"] == "Analista Financeira Senior"
    assert updated["workMode"] == "remote"


def test_delete_employee(client):
    headers = login_headers(client)
    create_response = client.post(
        "/api/v1/employees",
        headers=headers,
        json={
            "name": "Renata Souza",
            "role": "Analista Financeira",
            "department": "Financeiro",
            "email": "renata.souza@bunchin.com",
            "phone": "(11) 94444-6060",
            "unit": "Backoffice Centro",
            "expectedShiftStart": "08:00",
            "expectedShiftEnd": "17:00",
            "status": "active",
            "workMode": "hybrid",
            "roleLevel": "specialist",
            "requiresLocationOnPunch": False,
            "trustedDeviceRequired": True,
            "notes": "Nova contratacao para apoiar o fechamento mensal.",
        },
    )
    assert create_response.status_code == 201
    employee = create_response.json()

    delete_response = client.delete(
        f"/api/v1/employees/{employee['id']}",
        headers=headers,
    )
    assert delete_response.status_code == 204

    list_response = client.get("/api/v1/employees", headers=headers)
    assert list_response.status_code == 200
    ids = [item["id"] for item in list_response.json()]
    assert employee["id"] not in ids


def test_time_clock_requires_location_when_policy_demands_it(client):
    headers = login_headers(client)

    forbidden_response = client.post(
        "/api/v1/time-clock/me/punches",
        headers=headers,
        json={"type": "checkIn"},
    )
    assert forbidden_response.status_code == 400
    assert "location" in forbidden_response.json()["detail"].lower()

    success_response = client.post(
        "/api/v1/time-clock/me/punches",
        headers=headers,
        json={
            "type": "checkIn",
            "location": {
                "latitude": -23.5632,
                "longitude": -46.6545,
                "accuracyMeters": 12,
                "capturedAt": "2026-04-25T16:30:00-03:00",
            },
        },
    )
    assert success_response.status_code == 200
    payload = success_response.json()
    assert payload["type"] == "checkIn"
    assert payload["location"]["latitude"] == -23.5632


def test_employee_cannot_manage_employee_punches(client):
    headers = login_headers_for(
        client,
        email="joao.lima@bunchin.com",
        password=TEST_SEED_SECRET,
    )
    response = client.get("/api/v1/time-clock/employees/emp-02/punches", headers=headers)
    assert response.status_code == 403


def test_manager_can_manage_employee_punches(client):
    headers = login_headers_for(
        client,
        email="caio.martins@bunchin.com",
        password=TEST_SEED_SECRET,
    )

    create_response = client.post(
        "/api/v1/time-clock/employees/emp-02/punches",
        headers=headers,
        json={
            "type": "checkIn",
            "timestamp": "2026-05-20T09:00:00-03:00",
            "detail": "Ajuste manual aprovado pelo gestor.",
        },
    )
    assert create_response.status_code == 201
    created = create_response.json()
    assert created["id"]
    assert created["employeeId"] == "emp-02"
    assert created["type"] == "checkIn"
    assert created["detail"] == "Ajuste manual aprovado pelo gestor."

    list_response = client.get("/api/v1/time-clock/employees/emp-02/punches", headers=headers)
    assert list_response.status_code == 200
    assert any(item["id"] == created["id"] for item in list_response.json())

    update_response = client.put(
        f"/api/v1/time-clock/employees/emp-02/punches/{created['id']}",
        headers=headers,
        json={"detail": "Ajuste revisado pelo gestor."},
    )
    assert update_response.status_code == 200
    assert update_response.json()["detail"] == "Ajuste revisado pelo gestor."

    delete_response = client.delete(
        f"/api/v1/time-clock/employees/emp-02/punches/{created['id']}",
        headers=headers,
    )
    assert delete_response.status_code == 204

    final_list_response = client.get("/api/v1/time-clock/employees/emp-02/punches", headers=headers)
    assert final_list_response.status_code == 200
    assert all(item["id"] != created["id"] for item in final_list_response.json())


def test_pii_is_not_stored_in_plain_text(client):
    login_headers(client)
    with SessionLocal() as db:
        employee = db.scalar(select(Employee).where(Employee.id == "emp-01"))
        assert employee is not None
        assert employee.email_ciphertext != "marina.costa@bunchin.com"
        assert "@bunchin.com" not in employee.email_ciphertext


def test_list_employees_handles_legacy_invalid_shift_payload(client):
    headers = login_headers(client)
    cipher = _cipher()
    with SessionLocal() as db:
        employee = db.scalar(select(Employee).where(Employee.id == "emp-01"))
        assert employee is not None
        employee.expected_shift_ciphertext = cipher.encrypt("string") or ""
        db.commit()

    response = client.get("/api/v1/employees", headers=headers)
    assert response.status_code == 200
    payload = response.json()
    emp = next(item for item in payload if item["id"] == "emp-01")
    assert emp["expectedShiftStart"] == "08:00:00"
    assert emp["expectedShiftEnd"] == "17:00:00"


def test_super_admin_can_list_companies(client):
    headers = login_headers_for(
        client,
        email="super.admin@bunchin.com",
        password=TEST_SEED_SECRET,
    )
    response = client.get("/api/v1/admin/companies", headers=headers)
    assert response.status_code == 200
    assert response.json()[0]["tradeName"] == "Bunchin Servicos Digitais"


def test_register_company_triggers_welcome_email_task(client, monkeypatch):
    calls: list[dict[str, str]] = []

    def fake_send_company_welcome_email(
        *,
        recipient_email: str,
        company_name: str,
        trade_name: str,
    ) -> None:
        calls.append(
            {
                "recipient_email": recipient_email,
                "company_name": company_name,
                "trade_name": trade_name,
            },
        )

    monkeypatch.setattr("app.services.brevo.send_company_welcome_email", fake_send_company_welcome_email)
    get_event_bus().reset()
    from app.events.handlers import register_event_handlers

    register_event_handlers()

    response = client.post(
        "/api/v1/auth/register-company",
        json={
            "companyName": "Acme Tecnologia Ltda",
            "tradeName": "Acme Tech",
            "cnpj": "98.765.432/0001-10",
            "email": "contato@acmetech.com",
            "phone": "(11) 99888-7766",
            "password": TEST_REGISTER_SECRET,
            "acceptTerms": True,
        },
    )

    assert response.status_code == 201
    assert calls == [
        {
            "recipient_email": "contato@acmetech.com",
            "company_name": "Acme Tecnologia Ltda",
            "trade_name": "Acme Tech",
        },
    ]
