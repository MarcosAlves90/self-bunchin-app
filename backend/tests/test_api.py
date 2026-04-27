from __future__ import annotations

from sqlalchemy import select

from app.api.routes import auth as auth_routes
from app.db import SessionLocal
from app.models import Employee


def login_headers(client):
    response = client.post(
        "/api/v1/auth/login",
        json={
            "email": "marina.costa@bunchin.com",
            "password": "Bunchin@123",
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
            "expectedShift": "08:00 as 17:00",
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
            "expectedShift": "08:00 as 17:00",
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


def test_pii_is_not_stored_in_plain_text(client):
    login_headers(client)
    with SessionLocal() as db:
        employee = db.scalar(select(Employee).where(Employee.id == "emp-01"))
        assert employee is not None
        assert employee.email_ciphertext != "marina.costa@bunchin.com"
        assert "@bunchin.com" not in employee.email_ciphertext


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

    monkeypatch.setattr(
        auth_routes,
        "send_company_welcome_email",
        fake_send_company_welcome_email,
    )

    response = client.post(
        "/api/v1/auth/register-company",
        json={
            "companyName": "Acme Tecnologia Ltda",
            "tradeName": "Acme Tech",
            "cnpj": "98.765.432/0001-10",
            "email": "contato@acmetech.com",
            "phone": "(11) 99888-7766",
            "password": "Acme@1234",
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
