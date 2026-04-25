"""Confirmation model — record of a patient confirming bed status."""
from __future__ import annotations

import uuid

from django.db import models

from apps.rooms.models import BedStatus


class ConfirmationType(models.TextChoices):
    SELF = "SELF", "Meniki"
    NEIGHBOR = "NEIGHBOR", "Qo'shni"


class Confirmation(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    bed = models.ForeignKey(
        "rooms.Bed", related_name="confirmations", on_delete=models.CASCADE,
    )
    user = models.ForeignKey(
        "accounts.User", related_name="confirmations", on_delete=models.CASCADE,
    )
    status_reported = models.CharField(max_length=10, choices=BedStatus.choices)
    confirmation_type = models.CharField(
        max_length=10, choices=ConfirmationType.choices,
    )
    confirmed_at = models.DateTimeField(auto_now_add=True)
    ip_address = models.CharField(max_length=45, blank=True, default="")
    user_agent = models.TextField(blank=True, default="")
    oneid_session_id = models.CharField(max_length=64, blank=True, default="")

    class Meta:
        db_table = "confirmations_confirmation"
        ordering = ("-confirmed_at",)
        indexes = [
            # Index for "find latest confirmation per bed quickly".
            models.Index(fields=("bed", "-confirmed_at"), name="idx_conf_bed_time"),
            models.Index(fields=("user", "-confirmed_at"), name="idx_conf_user_time"),
        ]

    def __str__(self) -> str:
        return f"{self.user_id} -> {self.bed_id} = {self.status_reported}"
