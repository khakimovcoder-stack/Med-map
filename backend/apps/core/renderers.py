"""Custom DRF renderer that wraps responses in the standard envelope."""
from __future__ import annotations

from typing import Any

from rest_framework.renderers import JSONRenderer

from apps.core.envelope import build_meta


class EnvelopeJSONRenderer(JSONRenderer):
    """Wraps view payloads in `{success, data, meta}` if not already wrapped.

    Pagination + exception handler return pre-wrapped payloads (they include
    a ``success`` key). Everything else is wrapped here.
    """

    def render(self, data: Any, accepted_media_type: Any = None, renderer_context: Any = None) -> bytes:
        renderer_context = renderer_context or {}
        response = renderer_context.get("response")
        request = renderer_context.get("request")
        request_id = getattr(request, "id", None) if request else None

        # If pre-wrapped (paginator / exception handler / explicit envelope), pass through.
        if isinstance(data, dict) and "success" in data:
            # Make sure meta exists with timestamp/request_id.
            meta = data.get("meta") or {}
            if "timestamp" not in meta:
                meta = {**build_meta(request_id), **meta}
            elif request_id and "request_id" not in meta:
                meta = {**meta, "request_id": request_id}
            data["meta"] = meta
            return super().render(data, accepted_media_type, renderer_context)

        # Empty 204-style responses
        if response is not None and response.status_code == 204:
            return b""

        wrapped = {
            "success": True,
            "data": data,
            "meta": build_meta(request_id),
        }
        return super().render(wrapped, accepted_media_type, renderer_context)
