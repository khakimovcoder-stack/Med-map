"""Serializers for OneID auth."""
from __future__ import annotations

import re

from rest_framework import serializers

PHONE_RE = re.compile(r"^\+998\d{9}$")


class OneIDStartSerializer(serializers.Serializer):
    phone = serializers.CharField(max_length=20)

    def validate_phone(self, value: str) -> str:
        if not PHONE_RE.match(value):
            raise serializers.ValidationError(
                "Telefon raqam formati noto'g'ri (kutilgan: +998XXXXXXXXX)."
            )
        return value


class OneIDVerifySerializer(serializers.Serializer):
    session_id = serializers.CharField(max_length=64)
    otp_code = serializers.CharField(min_length=4, max_length=6)


class UserPublicSerializer(serializers.Serializer):
    id = serializers.UUIDField()
    phone = serializers.CharField()
    full_name = serializers.CharField(allow_blank=True)
