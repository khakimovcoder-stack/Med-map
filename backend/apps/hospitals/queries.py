"""Aggregation helpers for hospitals/floors.

Computes total_beds and available_beds via SQL annotations to avoid Python loops.
"""
from __future__ import annotations

from django.db.models import Count, Q, QuerySet

from apps.hospitals.models import Floor, Hospital


def annotate_hospital_bed_counts(qs: QuerySet[Hospital]) -> QuerySet[Hospital]:
    return qs.annotate(
        total_beds_agg=Count("floors__rooms__beds", distinct=True),
        available_beds_agg=Count(
            "floors__rooms__beds",
            filter=Q(floors__rooms__beds__current_status="BOSH"),
            distinct=True,
        ),
        floors_count_agg=Count("floors", distinct=True),
    )


def annotate_floor_bed_counts(qs: QuerySet[Floor]) -> QuerySet[Floor]:
    return qs.annotate(
        total_beds_agg=Count("rooms__beds", distinct=True),
        available_beds_agg=Count(
            "rooms__beds",
            filter=Q(rooms__beds__current_status="BOSH"),
            distinct=True,
        ),
        rooms_count_agg=Count("rooms", distinct=True),
    )
