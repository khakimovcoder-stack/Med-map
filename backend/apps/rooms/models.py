"""Room and Bed models."""
from __future__ import annotations

import uuid

from django.db import models


class BedStatus(models.TextChoices):
    BAND = "BAND", "Band"
    BOSH = "BOSH", "Bo'sh"
    NOMALUM = "NOMALUM", "Noma'lum"


class Room(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    floor = models.ForeignKey(
        "hospitals.Floor", related_name="rooms", on_delete=models.CASCADE,
    )
    number = models.CharField(max_length=10)
    capacity = models.PositiveIntegerField(default=4)
    has_window = models.BooleanField(default=True)
    description = models.TextField(blank=True, default="")
    qr_code_token = models.CharField(max_length=64, unique=True)

    class Meta:
        db_table = "rooms_room"
        ordering = ("floor_id", "number")
        constraints = [
            models.UniqueConstraint(
                fields=("floor", "number"), name="uniq_room_floor_number",
            ),
        ]
        indexes = [
            models.Index(fields=("qr_code_token",)),
        ]

    def __str__(self) -> str:
        return f"Palata {self.number}"


class Bed(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    room = models.ForeignKey(Room, related_name="beds", on_delete=models.CASCADE)
    position = models.PositiveSmallIntegerField()
    is_near_window = models.BooleanField(default=False)
    current_status = models.CharField(
        max_length=10, choices=BedStatus.choices, default=BedStatus.NOMALUM,
    )
    last_confirmed_at = models.DateTimeField(null=True, blank=True)
    confirmation_count = models.PositiveIntegerField(default=0)

    class Meta:
        db_table = "rooms_bed"
        ordering = ("room_id", "position")
        constraints = [
            models.UniqueConstraint(
                fields=("room", "position"), name="uniq_bed_room_position",
            ),
        ]
        indexes = [
            models.Index(fields=("current_status",)),
        ]

    def __str__(self) -> str:
        return f"Palata {self.room.number} — karavot #{self.position}"
