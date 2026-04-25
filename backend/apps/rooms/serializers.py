"""Room + Bed serializers."""
from __future__ import annotations

from rest_framework import serializers

from apps.rooms.models import Bed, Room
from apps.rooms.utils import aggregate_room_status, minutes_since


class _IsoZDateTimeField(serializers.DateTimeField):
    """ISO 8601 with trailing Z (the contract uses '...Z')."""

    def to_representation(self, value):
        if value is None:
            return None
        return value.strftime("%Y-%m-%dT%H:%M:%SZ")


class BedSerializer(serializers.ModelSerializer):
    last_confirmed_at = _IsoZDateTimeField(allow_null=True)

    class Meta:
        model = Bed
        fields = (
            "id",
            "position",
            "is_near_window",
            "current_status",
            "last_confirmed_at",
            "confirmation_count",
        )


class RoomListItemSerializer(serializers.Serializer):
    """Used by /floors/{id}/rooms/."""

    id = serializers.UUIDField()
    number = serializers.CharField()
    capacity = serializers.IntegerField()
    available_beds = serializers.IntegerField()
    status_color = serializers.CharField()
    status_label = serializers.CharField()
    last_updated_at = serializers.CharField(allow_null=True)
    minutes_since_update = serializers.IntegerField(allow_null=True)


def serialize_room_list_item(room: Room) -> dict:
    beds = list(room.beds.all())
    available, color, label = aggregate_room_status(beds)
    last_updated = max(
        (b.last_confirmed_at for b in beds if b.last_confirmed_at),
        default=None,
    )
    return {
        "id": str(room.id),
        "number": room.number,
        "capacity": room.capacity,
        "available_beds": available,
        "status_color": color,
        "status_label": label,
        "last_updated_at": (
            last_updated.strftime("%Y-%m-%dT%H:%M:%SZ") if last_updated else None
        ),
        "minutes_since_update": minutes_since(last_updated),
    }


class RoomDetailSerializer(serializers.Serializer):
    """Used by /rooms/{id}/ and /rooms/by-qr/{token}/."""

    def to_representation(self, room: Room) -> dict:
        beds = list(room.beds.all().order_by("position"))
        available, _, _ = aggregate_room_status(beds)

        floor = room.floor
        hospital = floor.hospital
        last_updated = max(
            (b.last_confirmed_at for b in beds if b.last_confirmed_at),
            default=None,
        )

        # Confirmation summary (last 24h)
        from datetime import timedelta

        from django.utils import timezone

        from apps.confirmations.models import Confirmation

        since = timezone.now() - timedelta(hours=24)
        recent = Confirmation.objects.filter(
            bed__room=room, confirmed_at__gte=since,
        )
        total_confirmations_24h = recent.count()
        unique_users_24h = recent.values("user_id").distinct().count()

        return {
            "id": str(room.id),
            "number": room.number,
            "capacity": room.capacity,
            "has_window": room.has_window,
            "description": room.description or None,
            "floor": {
                "id": str(floor.id),
                "number": floor.number,
                "name": floor.name or None,
            },
            "hospital": {
                "id": str(hospital.id),
                "name": hospital.name,
                "short_name": hospital.short_name or None,
            },
            "available_beds": available,
            "total_beds": len(beds),
            "beds": BedSerializer(beds, many=True).data,
            "confirmation_summary": {
                "total_confirmations_24h": total_confirmations_24h,
                "unique_users_24h": unique_users_24h,
                "last_updated_at": (
                    last_updated.strftime("%Y-%m-%dT%H:%M:%SZ")
                    if last_updated else None
                ),
                "minutes_since_update": minutes_since(last_updated),
            },
        }
