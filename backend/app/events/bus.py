from __future__ import annotations

from collections import defaultdict
from dataclasses import dataclass
from typing import Callable


@dataclass(slots=True)
class EventBus:
    _handlers: dict[type[object], list[Callable[[object], None]]]

    def __init__(self) -> None:
        self._handlers = defaultdict(list)

    def reset(self) -> None:
        self._handlers.clear()

    def subscribe(self, event_type: type[object], handler: Callable[[object], None]) -> None:
        self._handlers[event_type].append(handler)

    def publish(self, event: object) -> None:
        for handler in list(self._handlers.get(type(event), [])):
            handler(event)


_EVENT_BUS = EventBus()


def get_event_bus() -> EventBus:
    return _EVENT_BUS


def publish_event(event: object) -> None:
    _EVENT_BUS.publish(event)
