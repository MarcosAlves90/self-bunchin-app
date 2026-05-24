from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True, slots=True)
class CompanyRegisteredEvent:
    recipient_email: str
    company_name: str
    trade_name: str
