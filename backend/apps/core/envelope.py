"""Helpers for building the standard API response envelope."""
from __future__ import annotations

from datetime import datetime, timezone
from typing import Any


def utc_now_iso() -> str:
    """Return current UTC time in ISO 8601 with 'Z' suffix."""
    return datetime.now(tz=timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def build_meta(request_id: str | None = None, **extra: Any) -> dict[str, Any]:
    meta: dict[str, Any] = {"timestamp": utc_now_iso()}
    if request_id:
        meta["request_id"] = request_id
    meta.update(extra)
    return meta


def success_envelope(
    data: Any,
    *,
    request_id: str | None = None,
    meta_extra: dict[str, Any] | None = None,
) -> dict[str, Any]:
    return {
        "success": True,
        "data": data,
        "meta": build_meta(request_id, **(meta_extra or {})),
    }


def error_envelope(
    code: str,
    message: str,
    *,
    details: dict[str, Any] | None = None,
    request_id: str | None = None,
) -> dict[str, Any]:
    return {
        "success": False,
        "error": {
            "code": code,
            "message": message,
            "details": details or {},
        },
        "meta": build_meta(request_id),
    }
