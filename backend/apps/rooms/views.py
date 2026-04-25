"""Room + floor-rooms views."""
from __future__ import annotations

from django.shortcuts import get_object_or_404
from rest_framework.permissions import AllowAny
from rest_framework.request import Request
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.hospitals.models import Floor
from apps.rooms.models import Room
from apps.rooms.serializers import (
    RoomDetailSerializer,
    serialize_room_list_item,
)


class FloorRoomsView(APIView):
    permission_classes = (AllowAny,)

    def get(self, request: Request, pk) -> Response:
        floor = get_object_or_404(
            Floor.objects.select_related("hospital"), pk=pk,
        )
        rooms = (
            Room.objects.filter(floor=floor)
            .prefetch_related("beds")
            .order_by("number")
        )
        return Response({
            "floor": {
                "id": str(floor.id),
                "number": floor.number,
                "name": floor.name or None,
                "hospital": {
                    "id": str(floor.hospital.id),
                    "name": floor.hospital.short_name or floor.hospital.name,
                },
            },
            "rooms": [serialize_room_list_item(r) for r in rooms],
        })


def _room_queryset():
    return (
        Room.objects.select_related("floor__hospital")
        .prefetch_related("beds")
    )


class RoomDetailView(APIView):
    permission_classes = (AllowAny,)

    def get(self, request: Request, pk) -> Response:
        room = get_object_or_404(_room_queryset(), pk=pk)
        return Response(RoomDetailSerializer().to_representation(room))


class RoomByQRView(APIView):
    permission_classes = (AllowAny,)

    def get(self, request: Request, qr_code_token: str) -> Response:
        room = get_object_or_404(_room_queryset(), qr_code_token=qr_code_token)
        return Response(RoomDetailSerializer().to_representation(room))


class QRCodeListView(APIView):
    """Demo helper: list every room with its QR token + URL.

    Not part of the public anti-cheat API — exposed for hackathon
    demos so judges can scan a QR printed in the simulator page.
    """

    permission_classes = (AllowAny,)

    def get(self, request: Request) -> Response:
        hospital_id = request.query_params.get("hospital_id")
        rooms = (
            Room.objects.select_related("floor__hospital")
            .order_by(
                "floor__hospital__short_name",
                "floor__number",
                "number",
            )
        )
        if hospital_id:
            rooms = rooms.filter(floor__hospital_id=hospital_id)

        items = [
            {
                "room_id": str(r.id),
                "room_number": r.number,
                "floor_number": r.floor.number,
                "hospital_id": str(r.floor.hospital.id),
                "hospital_short_name": (
                    r.floor.hospital.short_name or r.floor.hospital.name
                ),
                "qr_code_token": r.qr_code_token,
                "qr_url": f"https://shifo-radar.uz/r/{r.qr_code_token}",
            }
            for r in rooms
        ]
        return Response(items)
