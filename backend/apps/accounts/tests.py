"""Smoke tests for accounts app (OneID mock auth)."""
from __future__ import annotations

from datetime import timedelta

from django.utils import timezone
from rest_framework import status
from rest_framework.test import APITestCase

from apps.accounts.models import OneIDSession, User


class UserModelTests(APITestCase):
    def test_create_user_via_manager(self):
        u = User.objects.create_user(phone="+998901234567", full_name="Test User")
        self.assertEqual(u.phone, "+998901234567")
        self.assertTrue(u.is_active)
        self.assertFalse(u.is_staff)

    def test_phone_unique(self):
        User.objects.create_user(phone="+998900000001")
        with self.assertRaises(Exception):
            User.objects.create_user(phone="+998900000001")


class OneIDAuthTests(APITestCase):
    def test_start_validates_phone(self):
        r = self.client.post(
            "/api/v1/auth/oneid/start/", {"phone": "12345"}, format="json",
        )
        self.assertEqual(r.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(r.json()["error"]["code"], "VALIDATION_ERROR")

    def test_start_creates_session(self):
        r = self.client.post(
            "/api/v1/auth/oneid/start/",
            {"phone": "+998901234567"}, format="json",
        )
        self.assertEqual(r.status_code, status.HTTP_200_OK)
        data = r.json()["data"]
        self.assertTrue(data["session_id"].startswith("sess_"))
        self.assertEqual(OneIDSession.objects.count(), 1)

    def test_verify_otp_success(self):
        # Use the start endpoint to create a session, then verify with mock OTP.
        r = self.client.post(
            "/api/v1/auth/oneid/start/",
            {"phone": "+998901111111"}, format="json",
        )
        self.assertEqual(r.status_code, status.HTTP_200_OK)
        sess_id = r.json()["data"]["session_id"]

        r2 = self.client.post(
            "/api/v1/auth/oneid/verify/",
            {"session_id": sess_id, "otp_code": "123456"},
            format="json",
        )
        self.assertEqual(r2.status_code, status.HTTP_200_OK)
        body = r2.json()["data"]
        self.assertIn("token", body)
        self.assertEqual(body["token_type"], "Bearer")
        self.assertEqual(body["user"]["phone"], "+998901111111")

    def test_verify_otp_invalid(self):
        session = OneIDSession.objects.create(
            phone="+998900000099",
            otp_code="123456",
            expires_at=timezone.now() + timedelta(minutes=5),
        )
        r = self.client.post(
            "/api/v1/auth/oneid/verify/",
            {"session_id": session.session_id, "otp_code": "000000"},
            format="json",
        )
        self.assertEqual(r.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(r.json()["error"]["code"], "OTP_INVALID")

    def test_verify_otp_expired(self):
        session = OneIDSession.objects.create(
            phone="+998900000088",
            otp_code="123456",
            expires_at=timezone.now() - timedelta(seconds=1),
        )
        r = self.client.post(
            "/api/v1/auth/oneid/verify/",
            {"session_id": session.session_id, "otp_code": "123456"},
            format="json",
        )
        self.assertEqual(r.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(r.json()["error"]["code"], "OTP_EXPIRED")
