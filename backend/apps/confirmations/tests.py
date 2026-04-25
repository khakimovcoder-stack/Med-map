"""Smoke tests for confirmations app."""
from __future__ import annotations

from rest_framework import status
from rest_framework.test import APITestCase
from rest_framework_simplejwt.tokens import RefreshToken

from apps.accounts.models import User
from apps.confirmations.models import Confirmation
from apps.hospitals.models import Floor, Hospital
from apps.rooms.models import Bed, BedStatus, Room


def _auth_token_for(user):
    return str(RefreshToken.for_user(user).access_token)


class ConfirmationCreateTests(APITestCase):
    @classmethod
    def setUpTestData(cls):
        cls.user = User.objects.create_user(
            phone="+998900000001", full_name="Test User",
        )
        cls.h = Hospital.objects.create(name="H", address="a")
        cls.f = Floor.objects.create(hospital=cls.h, number=1)
        cls.room = Room.objects.create(
            floor=cls.f, number="101", qr_code_token="tkn101", capacity=4,
        )
        cls.beds = [
            Bed.objects.create(
                room=cls.room, position=i, is_near_window=i <= 2,
                current_status=BedStatus.NOMALUM,
            )
            for i in range(1, 5)
        ]

    def setUp(self):
        token = _auth_token_for(self.user)
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {token}")

    def _payload(self):
        return {
            "room_id": str(self.room.id),
            "beds": [
                {
                    "bed_id": str(self.beds[0].id),
                    "position": 1,
                    "status_reported": "BAND",
                    "confirmation_type": "SELF",
                },
                {
                    "bed_id": str(self.beds[1].id),
                    "position": 2,
                    "status_reported": "BOSH",
                    "confirmation_type": "NEIGHBOR",
                },
                {
                    "bed_id": str(self.beds[2].id),
                    "position": 3,
                    "status_reported": "BAND",
                    "confirmation_type": "NEIGHBOR",
                },
                {
                    "bed_id": str(self.beds[3].id),
                    "position": 4,
                    "status_reported": "BAND",
                    "confirmation_type": "NEIGHBOR",
                },
            ],
        }

    def test_unauthenticated_rejected(self):
        self.client.credentials()
        r = self.client.post(
            "/api/v1/confirmations/", self._payload(), format="json",
        )
        self.assertEqual(r.status_code, status.HTTP_401_UNAUTHORIZED)
        self.assertEqual(r.json()["error"]["code"], "UNAUTHORIZED")

    def test_create_confirmation_success(self):
        r = self.client.post(
            "/api/v1/confirmations/", self._payload(), format="json",
        )
        self.assertEqual(r.status_code, status.HTTP_201_CREATED)
        body = r.json()["data"]
        self.assertEqual(body["confirmations_created"], 4)
        self.assertEqual(body["room"]["available_beds"], 1)
        self.assertEqual(Confirmation.objects.count(), 4)

        bed1 = Bed.objects.get(id=self.beds[0].id)
        self.assertEqual(bed1.current_status, BedStatus.BAND)
        bed2 = Bed.objects.get(id=self.beds[1].id)
        self.assertEqual(bed2.current_status, BedStatus.BOSH)

    def test_duplicate_within_24h_blocked(self):
        r1 = self.client.post(
            "/api/v1/confirmations/", self._payload(), format="json",
        )
        self.assertEqual(r1.status_code, status.HTTP_201_CREATED)

        r2 = self.client.post(
            "/api/v1/confirmations/", self._payload(), format="json",
        )
        self.assertEqual(r2.status_code, status.HTTP_409_CONFLICT)
        self.assertEqual(r2.json()["error"]["code"], "DUPLICATE_CONFIRMATION")

    def test_requires_exactly_one_self(self):
        payload = self._payload()
        for item in payload["beds"]:
            item["confirmation_type"] = "NEIGHBOR"
        r = self.client.post("/api/v1/confirmations/", payload, format="json")
        self.assertEqual(r.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(r.json()["error"]["code"], "VALIDATION_ERROR")

    def test_bed_must_belong_to_room(self):
        # Create a bed in a different room and try to submit it.
        other_room = Room.objects.create(
            floor=self.f, number="102", qr_code_token="tkn102",
        )
        stray = Bed.objects.create(room=other_room, position=1)
        payload = self._payload()
        payload["beds"][0]["bed_id"] = str(stray.id)
        r = self.client.post("/api/v1/confirmations/", payload, format="json")
        self.assertEqual(r.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(r.json()["error"]["code"], "VALIDATION_ERROR")
