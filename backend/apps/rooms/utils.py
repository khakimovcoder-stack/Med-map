"""Helpers for rooms (status aggregation, time-since formatting)."""
from __future__ import annotations

from datetime import datetime
from typing import Iterable

from django.utils import timezone

from apps.rooms.models import Bed, BedStatus


def aggregate_room_status(beds: Iterable[Bed]) -> tuple[int, str, str]:
    """Return (available_beds, status_color, status_label) for a room.

    Rules per DATA_MODELS.md and API_CONTRACT.md:
      - >=1 BOSH       -> green, "X bo'sh"
      - all BAND       -> red,   "To'liq band"
      - everything else -> gray,  "Noma'lum"
    """
    bosh = 0
    band = 0
    total = 0
    for b in beds:
        total += 1
        if b.current_status == BedStatus.BOSH:
            bosh += 1
        elif b.current_status == BedStatus.BAND:
            band += 1

    if bosh > 0:
        return bosh, "green", f"{bosh} bo'sh"
    if total > 0 and band == total:
        return 0, "red", "To'liq band"
    return 0, "gray", "Noma'lum"


def minutes_since(when: datetime | None) -> int | None:
    if when is None:
        return None
    delta = timezone.now() - when
    return max(0, int(delta.total_seconds() // 60))
