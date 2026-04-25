"""Custom DRF exception handler that produces the standard error envelope."""
from __future__ import annotations

from typing import Any

from django.core.exceptions import ValidationError as DjangoValidationError
from django.http import Http404
from rest_framework import exceptions, status
from rest_framework.response import Response
from rest_framework.views import exception_handler as drf_exception_handler

from apps.core.envelope import error_envelope


class APIError(exceptions.APIException):
    """Application-level error with explicit envelope code."""

    status_code = status.HTTP_400_BAD_REQUEST
    default_code = "VALIDATION_ERROR"
    default_detail = "Request invalid"

    def __init__(
        self,
        code: str,
        message: str,
        *,
        status_code: int = status.HTTP_400_BAD_REQUEST,
        details: dict[str, Any] | None = None,
    ) -> None:
        super().__init__(detail=message, code=code)
        self.code = code
        self.message = message
        self.status_code = status_code
        self.details = details or {}


_STATUS_TO_CODE = {
    status.HTTP_400_BAD_REQUEST: "VALIDATION_ERROR",
    status.HTTP_401_UNAUTHORIZED: "UNAUTHORIZED",
    status.HTTP_403_FORBIDDEN: "FORBIDDEN",
    status.HTTP_404_NOT_FOUND: "NOT_FOUND",
    status.HTTP_405_METHOD_NOT_ALLOWED: "VALIDATION_ERROR",
    status.HTTP_409_CONFLICT: "DUPLICATE_CONFIRMATION",
    status.HTTP_415_UNSUPPORTED_MEDIA_TYPE: "VALIDATION_ERROR",
    status.HTTP_429_TOO_MANY_REQUESTS: "RATE_LIMIT",
}


def _flatten_details(detail: Any) -> dict[str, Any]:
    if isinstance(detail, dict):
        return {k: v for k, v in detail.items()}
    if isinstance(detail, list):
        return {"errors": detail}
    return {"info": str(detail)}


def envelope_exception_handler(exc: Exception, context: dict[str, Any]) -> Response | None:
    request = context.get("request")
    request_id = getattr(request, "id", None) if request else None

    # Custom application errors come pre-shaped.
    if isinstance(exc, APIError):
        body = error_envelope(
            exc.code,
            exc.message,
            details=exc.details,
            request_id=request_id,
        )
        return Response(body, status=exc.status_code)

    # Normalise Django's ValidationError before delegation (DRF won't otherwise).
    if isinstance(exc, DjangoValidationError):
        exc = exceptions.ValidationError(detail=exc.message_dict if hasattr(exc, "message_dict") else exc.messages)

    if isinstance(exc, Http404):
        body = error_envelope(
            "NOT_FOUND",
            "Topilmadi",
            request_id=request_id,
        )
        return Response(body, status=status.HTTP_404_NOT_FOUND)

    response = drf_exception_handler(exc, context)
    if response is None:
        # Unhandled exception — bubble up as 500 envelope.
        body = error_envelope(
            "INTERNAL_ERROR",
            "Server xatosi",
            request_id=request_id,
        )
        return Response(body, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

    code = _STATUS_TO_CODE.get(response.status_code, "INTERNAL_ERROR")
    if isinstance(exc, exceptions.NotAuthenticated) or isinstance(exc, exceptions.AuthenticationFailed):
        code = "UNAUTHORIZED"
    elif isinstance(exc, exceptions.PermissionDenied):
        code = "FORBIDDEN"
    elif isinstance(exc, exceptions.Throttled):
        code = "RATE_LIMIT"
    elif isinstance(exc, exceptions.NotFound):
        code = "NOT_FOUND"
    elif isinstance(exc, exceptions.ValidationError):
        code = "VALIDATION_ERROR"

    detail = response.data
    if isinstance(detail, dict) and "detail" in detail and len(detail) == 1:
        message = str(detail["detail"])
        details: dict[str, Any] = {}
    else:
        message = "So'rov yaroqsiz"
        details = _flatten_details(detail)

    response.data = error_envelope(
        code,
        message,
        details=details,
        request_id=request_id,
    )
    return response
