"""Pure business logic for confirmations: dedup, recompute, anti-cheat.

New model (single-bed-claim):
- A bed is BAND iff any user has a SELF confirmation on it in the last 24h.
- Otherwise the bed is BOSH (unclaimed = free).
- A user may have at most one active claim across the whole system.
- A bed may have at most one active claimant (first wins).
"""
from __future__ import annotations

from datetime import timedelta
from typing import Iterable

from django.utils import timezone

from apps.confirmations.models import Confirmation, ConfirmationType
from apps.rooms.models import Bed, BedStatus


CLAIM_WINDOW = timedelta(hours=24)


def _since():
    return timezone.now() - CLAIM_WINDOW


def has_active_claim_by_user(user_id) -> Confirmation | None:
    """Return the user's active SELF claim if any, else None."""
    return (
        Confirmation.objects.filter(
            user_id=user_id,
            confirmation_type=ConfirmationType.SELF,
            confirmed_at__gte=_since(),
        )
        .select_related("bed__room")
        .order_by("-confirmed_at")
        .first()
    )


def has_active_claim_on_bed(bed_id) -> Confirmation | None:
    """Return any active SELF claim on this bed, else None."""
    return (
        Confirmation.objects.filter(
            bed_id=bed_id,
            confirmation_type=ConfirmationType.SELF,
            confirmed_at__gte=_since(),
        )
        .order_by("-confirmed_at")
        .first()
    )


def recompute_bed_state(bed: Bed) -> None:
    """A bed is BAND iff it has an active SELF claim in the last 24h."""
    since = _since()
    claim = (
        Confirmation.objects.filter(
            bed=bed,
            confirmation_type=ConfirmationType.SELF,
            confirmed_at__gte=since,
        )
        .order_by("-confirmed_at")
        .values("confirmed_at", "user_id")
        .first()
    )
    if claim:
        bed.current_status = BedStatus.BAND
        bed.last_confirmed_at = claim["confirmed_at"]
        bed.confirmation_count = 1
    else:
        bed.current_status = BedStatus.BOSH
        bed.confirmation_count = 0
    bed.save(update_fields=[
        "current_status", "last_confirmed_at", "confirmation_count",
    ])


def recompute_beds(beds: Iterable[Bed]) -> None:
    for b in beds:
        recompute_bed_state(b)
