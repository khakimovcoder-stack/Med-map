"""Health-check endpoint."""
from __future__ import annotations

import time

from django.conf import settings
from rest_framework.permissions import AllowAny
from rest_framework.request import Request
from rest_framework.response import Response
from rest_framework.views import APIView


_BOOT_MONOTONIC = time.monotonic()


class HealthView(APIView):
    permission_classes = (AllowAny,)

    def get(self, request: Request) -> Response:
        uptime = int(time.monotonic() - _BOOT_MONOTONIC)
        return Response({
            "status": "ok",
            "version": settings.APP_VERSION,
            "uptime_seconds": uptime,
        })
