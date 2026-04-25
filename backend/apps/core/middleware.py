"""Middleware that stamps a unique request_id on every incoming request."""
from __future__ import annotations

import uuid
from typing import Callable

from django.http import HttpRequest, HttpResponse


class RequestIdMiddleware:
    """Attaches a short request id to ``request.id`` for envelope meta."""

    def __init__(self, get_response: Callable[[HttpRequest], HttpResponse]) -> None:
        self.get_response = get_response

    def __call__(self, request: HttpRequest) -> HttpResponse:
        request.id = f"req_{uuid.uuid4().hex[:12]}"
        response = self.get_response(request)
        response["X-Request-Id"] = request.id
        return response
