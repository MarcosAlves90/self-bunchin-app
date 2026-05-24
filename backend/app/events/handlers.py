from __future__ import annotations

from app.events.bus import EventBus, get_event_bus
from app.events.contracts import CompanyRegisteredEvent
from app.services import brevo


def _handle_company_registered(event: CompanyRegisteredEvent) -> None:
    brevo.send_company_welcome_email(
        recipient_email=event.recipient_email,
        company_name=event.company_name,
        trade_name=event.trade_name,
    )


def register_event_handlers(bus: EventBus | None = None) -> EventBus:
    bus = bus or get_event_bus()
    bus.reset()
    bus.subscribe(CompanyRegisteredEvent, _handle_company_registered)
    return bus
