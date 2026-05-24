from __future__ import annotations


def normalize_email(value: str) -> str:
    return value.strip().lower()
