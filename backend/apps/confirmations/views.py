"""Confirmation create endpoint — single-bed claim."""
from __future__ import annotations

from django.db import transaction
from django.shortcuts import get_object_or_404
from django.utils import timezone
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.request import Request
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.confirmations.models import Confirmation, ConfirmationType
from apps.confirmations.serializers import ConfirmationCreateSerializer
from apps.confirmations.services import (
    has_active_claim_by_user,
    has_active_claim_on_bed,
    recompute_bed_state,
)
from apps.core.exceptions import APIError
from apps.rooms.models import Bed, BedStatus
from apps.rooms.utils import aggregate_room_status


def _client_ip(request: Request) -> str:
    xff = request.META.get("HTTP_X_FORWARDED_FOR")
    if xff:
        return xff.split(",")[0].strip()
    return request.META.get("REMOTE_ADDR", "")


class ConfirmationCreateView(APIView):
    """Citizen claims a single bed as theirs.

    Anti-cheat:
    - One user can hold at most one active claim across the whole system.
    - One bed can have at most one active claimant; first claim wins.
    - Active = within last 24h.
    """

    permission_classes = (IsAuthenticated,)

    @transaction.atomic
    def post(self, request: Request) -> Response:
        serializer = ConfirmationCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        bed_id = serializer.validated_data["bed_id"]

        bed = get_object_or_404(
            Bed.objects.select_related("room__floor__hospital"),
            pk=bed_id,
        )
        room = bed.room

        # 1) User cannot hold two active claims.
        existing_user_claim = has_active_claim_by_user(request.user.id)
        if existing_user_claim and existing_user_claim.bed_id != bed.id:
            other = existing_user_claim.bed
            raise APIError(
                "DUPLICATE_CONFIRMATION",
                "Siz allaqachon boshqa karavotni band qilgansiz. "
                "24 soatdan keyin boshqasini tanlash mumkin.",
                status_code=status.HTTP_409_CONFLICT,
                details={
                    "active_bed_id": str(other.id),
                    "active_room_id": str(other.room_id),
                },
            )

        # 2) Bed cannot be claimed by two people.
        existing_bed_claim = has_active_claim_on_bed(bed.id)
        if existing_bed_claim and existing_bed_claim.user_id != request.user.id:
            raise APIError(
                "DUPLICATE_CONFIRMATION",
                "Bu karavot allaqachon boshqa bemor tomonidan band qilingan.",
                status_code=status.HTTP_409_CONFLICT,
                details={"bed_id": str(bed.id)},
            )

        # 3) If the same user re-claims the same bed inside the window,
        # treat it as idempotent — return current state.
        if existing_user_claim and existing_user_claim.bed_id == bed.id:
            available, _, _ = aggregate_room_status(
                list(Bed.objects.filter(room=room).order_by("position")),
            )
            return Response(_response_payload(
                bed=bed,
                room=room,
                available=available,
                already=True,
            ), status=status.HTTP_200_OK)

        ip = _client_ip(request)
        ua = request.META.get("HTTP_USER_AGENT", "")[:1024]

        Confirmation.objects.create(
            bed=bed,
            user=request.user,
            status_reported=BedStatus.BAND,
            confirmation_type=ConfirmationType.SELF,
            ip_address=ip,
            user_agent=ua,
        )

        recompute_bed_state(bed)
        bed.refresh_from_db()

        request.user.current_room = room
        request.user.last_login_at = timezone.now()
        request.user.save(update_fields=["current_room", "last_login_at"])

        refreshed = list(Bed.objects.filter(room=room).order_by("position"))
        available, _, _ = aggregate_room_status(refreshed)

        return Response(
            _response_payload(
                bed=bed, room=room, available=available, already=False,
            ),
            status=status.HTTP_201_CREATED,
        )


def _response_payload(*, bed: Bed, room, available: int, already: bool) -> dict:
    return {
        "bed": {
            "id": str(bed.id),
            "position": bed.position,
            "current_status": bed.current_status,
            "last_confirmed_at": (
                bed.last_confirmed_at.isoformat() if bed.last_confirmed_at else None
            ),
        },
        "room": {
            "id": str(room.id),
            "number": room.number,
            "available_beds": available,
        },
        "message": (
            "Bu karavot allaqachon sizning nomingizga band qilingan."
            if already
            else "Rahmat! Karavot sizning nomingizga band qilindi."
        ),
        "already_claimed": already,
    }
