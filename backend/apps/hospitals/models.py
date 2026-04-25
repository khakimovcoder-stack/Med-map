"""Hospital and Floor models."""
from __future__ import annotations

import uuid

from django.db import models


class Hospital(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=255)
    short_name = models.CharField(max_length=100, blank=True, default="")
    address = models.TextField()
    city = models.CharField(max_length=100, blank=True, default="")
    region = models.CharField(max_length=100, blank=True, default="")
    phone = models.CharField(max_length=20, blank=True, default="")
    latitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    longitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "hospitals_hospital"
        ordering = ("name",)
        indexes = [
            models.Index(fields=("city",)),
            models.Index(fields=("name",)),
        ]

    def __str__(self) -> str:
        return self.short_name or self.name


class Floor(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    hospital = models.ForeignKey(
        Hospital, related_name="floors", on_delete=models.CASCADE,
    )
    number = models.PositiveIntegerField()
    name = models.CharField(max_length=100, blank=True, default="")

    class Meta:
        db_table = "hospitals_floor"
        ordering = ("hospital_id", "number")
        constraints = [
            models.UniqueConstraint(
                fields=("hospital", "number"),
                name="uniq_floor_hospital_number",
            ),
        ]

    def __str__(self) -> str:
        return f"{self.hospital.short_name or self.hospital.name} — qavat {self.number}"
