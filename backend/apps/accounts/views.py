"""OneID mock auth views."""
from __future__ import annotations

from datetime import timedelta

from django.conf import settings
from django.core.cache import cache
from django.utils import timezone
from rest_framework import status
from rest_framework.permissions import AllowAny
from rest_framework.request import Request
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken

from apps.accounts.models import OneIDSession, User
from apps.accounts.serializers import (
    OneIDStartSerializer,
    OneIDVerifySerializer,
    UserPublicSerializer,
)
from apps.core.exceptions import APIError


class OneIDStartView(APIView):
    permission_classes = (AllowAny,)

    def post(self, request: Request) -> Response:
        serializer = OneIDStartSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        phone: str = serializer.validated_data["phone"]

        # Simple cache-based rate limiter: 1 request / minute / phone.
        cache_key = f"oneid:start:{phone}"
        if cache.get(cache_key):
            raise APIError(
                "RATE_LIMIT",
                "Juda ko'p so'rov. Iltimos, biroz kuting.",
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                details={"retry_after_seconds": 60},
            )
        cache.set(cache_key, True, timeout=60)

        ttl = settings.ONEID_OTP_TTL_SECONDS
        session = OneIDSession.objects.create(
            phone=phone,
            otp_code=settings.ONEID_MOCK_OTP,
            expires_at=timezone.now() + timedelta(seconds=ttl),
        )

        return Response({
            "session_id": session.session_id,
            "phone": phone,
            "expires_at": session.expires_at.strftime("%Y-%m-%dT%H:%M:%SZ"),
            "message": f"Tasdiqlash kodi yuborildi (mock: {settings.ONEID_MOCK_OTP})",
        }, status=status.HTTP_200_OK)


class OneIDVerifyView(APIView):
    permission_classes = (AllowAny,)

    def post(self, request: Request) -> Response:
        serializer = OneIDVerifySerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        session_id: str = serializer.validated_data["session_id"]
        otp_code: str = serializer.validated_data["otp_code"]

        session = OneIDSession._from_short_hex(  # noqa: SLF001
            session_id[len("sess_"):] if session_id.startswith("sess_") else session_id,
        )
        if session is None:
            raise APIError(
                "NOT_FOUND",
                "Sessiya topilmadi.",
                status_code=status.HTTP_404_NOT_FOUND,
                details={"session_id": session_id},
            )

        if session.is_expired():
            raise APIError(
                "OTP_EXPIRED",
                "Tasdiqlash kodi muddati o'tgan.",
                status_code=status.HTTP_400_BAD_REQUEST,
            )

        if otp_code != session.otp_code:
            raise APIError(
                "OTP_INVALID",
                "Tasdiqlash kodi noto'g'ri.",
                status_code=status.HTTP_400_BAD_REQUEST,
            )

        user, _ = User.objects.get_or_create(
            phone=session.phone,
            defaults={"oneid_pin": f"mock-{session.phone[-9:]}"},
        )
        user.last_login_at = timezone.now()
        user.save(update_fields=["last_login_at"])

        refresh = RefreshToken.for_user(user)
        access_token = str(refresh.access_token)
        ttl = settings.JWT_TTL

        session.is_verified = True
        session.token = access_token
        session.save(update_fields=["is_verified", "token"])

        return Response({
            "token": access_token,
            "token_type": "Bearer",
            "expires_in": ttl,
            "user": UserPublicSerializer(user).data,
        }, status=status.HTTP_200_OK)
