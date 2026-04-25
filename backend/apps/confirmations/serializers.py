"""Confirmation request serializers."""
from __future__ import annotations

from rest_framework import serializers


class ConfirmationCreateSerializer(serializers.Serializer):
    """A patient claims a single bed as their own.

    The new flow: each citizen books exactly one bed for themselves; they
    do not report on neighbour beds. Beds without an active SELF claim
    are considered free.
    """

    bed_id = serializers.UUIDField()
