"""Stats endpoint for hospital dashboard."""
from __future__ import annotations

from datetime import timedelta

from django.db.models import Count, Q
from django.shortcuts import get_object_or_404
from django.utils import timezone
from rest_framework.permissions import AllowAny
from rest_framework.request import Request
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.confirmations.models import Confirmation
from apps.hospitals.models import Floor, Hospital
from apps.hospitals.queries import annotate_floor_bed_counts


class HospitalStatsView(APIView):
    permission_classes = (AllowAny,)

    def get(self, request: Request, pk) -> Response:
        hospital = get_object_or_404(Hospital, pk=pk)

        floors = annotate_floor_bed_counts(
            Floor.objects.filter(hospital=hospital),
        ).order_by("number")

        total_beds = 0
        available_beds = 0
        by_floor = []
        for f in floors:
            total = f.total_beds_agg or 0
            available = f.available_beds_agg or 0
            total_beds += total
            available_beds += available
            by_floor.append({
                "floor_number": f.number,
                "available": available,
                "total": total,
            })

        occupancy_rate = (
            round((total_beds - available_beds) / total_beds, 3)
            if total_beds else 0.0
        )

        since = timezone.now() - timedelta(hours=24)
        confirmations_today_qs = Confirmation.objects.filter(
            bed__room__floor__hospital=hospital,
            confirmed_at__gte=since,
        )
        confirmations_today = confirmations_today_qs.count()
        active_confirmers_today = (
            confirmations_today_qs.values("user_id").distinct().count()
        )

        return Response({
            "hospital_id": str(hospital.id),
            "total_beds": total_beds,
            "available_beds": available_beds,
            "occupancy_rate": occupancy_rate,
            "confirmations_today": confirmations_today,
            "active_confirmers_today": active_confirmers_today,
            "by_floor": by_floor,
        })
