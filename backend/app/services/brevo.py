from __future__ import annotations

import logging
from html import escape

import httpx

from app.config import Settings, get_settings


logger = logging.getLogger(__name__)

BREVO_SMTP_EMAIL_URL = "https://api.brevo.com/v3/smtp/email"
BREVO_TIMEOUT_SECONDS = 10.0


def _is_brevo_enabled(settings: Settings) -> bool:
    return bool(
        settings.brevo_welcome_enabled
        and settings.brevo_api_key
        and settings.brevo_sender_email
    )


def _welcome_subject(display_name: str) -> str:
    return f"Bem-vindo ao Bunchin, {display_name}"


def _welcome_text(display_name: str, recipient_email: str) -> str:
    return (
        f"Ola, {display_name}.\n\n"
        "Seu cadastro no Bunchin foi concluido com sucesso.\n"
        f"Use o e-mail {recipient_email} para acessar a plataforma.\n\n"
        "Se voce nao reconhece este cadastro, responda este e-mail.\n"
    )


def _welcome_html(display_name: str, recipient_email: str) -> str:
    safe_display_name = escape(display_name)
    safe_email = escape(recipient_email)
    return (
        "<p>Ola, "
        f"{safe_display_name}."
        "</p>"
        "<p>Seu cadastro no <strong>Bunchin</strong> foi concluido com sucesso.</p>"
        "<p>"
        "Use o e-mail "
        f"<strong>{safe_email}</strong> "
        "para acessar a plataforma."
        "</p>"
        "<p>Se voce nao reconhece este cadastro, responda este e-mail.</p>"
    )


def send_company_welcome_email(
    *,
    recipient_email: str,
    company_name: str,
    trade_name: str,
) -> None:
    settings = get_settings()
    if not _is_brevo_enabled(settings):
        return

    display_name = trade_name.strip() or company_name.strip()
    payload = {
        "sender": {
            "email": settings.brevo_sender_email,
            "name": settings.brevo_sender_name,
        },
        "to": [{"email": recipient_email.strip(), "name": display_name}],
        "subject": _welcome_subject(display_name),
        "textContent": _welcome_text(display_name, recipient_email.strip()),
        "htmlContent": _welcome_html(display_name, recipient_email.strip()),
    }
    headers = {
        "accept": "application/json",
        "api-key": settings.brevo_api_key or "",
        "content-type": "application/json",
    }

    try:
        response = httpx.post(
            BREVO_SMTP_EMAIL_URL,
            json=payload,
            headers=headers,
            timeout=BREVO_TIMEOUT_SECONDS,
        )
        response.raise_for_status()
    except httpx.HTTPError as exc:
        status_code = exc.response.status_code if exc.response is not None else "n/a"
        logger.warning(
            "Brevo welcome email failed without blocking registration. status=%s",
            status_code,
        )
