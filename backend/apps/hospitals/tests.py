"""Smoke tests for hospitals app."""
from __future__ import annotations

from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase

from apps.hospitals.models import Floor, Hospital
from apps.rooms.models import Bed, BedStatus, Room


class HospitalModelTests(APITestCase):
    def test_create_hospital_with_floors(self):
        h = Hospital.objects.create(
            name="Test Hospital", short_name="TH", address="addr", city="Toshkent",
        )
        Floor.objects.create(hospital=h, number=1)
        Floor.objects.create(hospital=h, number=2)
        self.assertEqual(h.floors.count(), 2)

    def test_unique_floor_per_hospital(self):
        h = Hospital.objects.create(name="X", address="a")
        Floor.objects.create(hospital=h, number=1)
        with self.assertRaises(Exception):
            Floor.objects.create(hospital=h, number=1)


class HospitalsAPITests(APITestCase):
    @classmethod
    def setUpTestData(cls):
        cls.h = Hospital.objects.create(
            name="RIKM", short_name="RIKM",
            address="Tashkent", city="Toshkent",
        )
        cls.f1 = Floor.objects.create(hospital=cls.h, number=1)
        room = Room.objects.create(
            floor=cls.f1, number="101", qr_code_token="qr101token",
        )
        for i, st in enumerate([BedStatus.BAND, BedStatus.BOSH, BedStatus.BAND, BedStatus.BAND], start=1):
            Bed.objects.create(
                room=room, position=i, is_near_window=i <= 2, current_status=st,
            )

    def test_health(self):
        r = self.client.get("/api/v1/health/")
        self.assertEqual(r.status_code, status.HTTP_200_OK)
        body = r.json()
        self.assertTrue(body["success"])
        self.assertEqual(body["data"]["status"], "ok")

    def test_hospital_list_envelope_and_aggregates(self):
        r = self.client.get("/api/v1/hospitals/")
        self.assertEqual(r.status_code, status.HTTP_200_OK)
        body = r.json()
        self.assertTrue(body["success"])
        self.assertIn("page", body["meta"])
        self.assertEqual(body["meta"]["total"], 1)
        self.assertEqual(body["data"][0]["available_beds"], 1)
        self.assertEqual(body["data"][0]["total_beds"], 4)
        self.assertEqual(body["data"][0]["floors_count"], 1)

    def test_hospital_detail(self):
        r = self.client.get(f"/api/v1/hospitals/{self.h.id}/")
        self.assertEqual(r.status_code, status.HTTP_200_OK)
        body = r.json()
        self.assertTrue(body["success"])
        self.assertEqual(len(body["data"]["floors"]), 1)
        self.assertEqual(body["data"]["floors"][0]["available_beds"], 1)

    def test_hospital_search(self):
        r = self.client.get("/api/v1/hospitals/?search=tos")
        self.assertEqual(r.status_code, status.HTTP_200_OK)
        self.assertEqual(r.json()["meta"]["total"], 1)

    def test_hospital_404_envelope(self):
        r = self.client.get("/api/v1/hospitals/00000000-0000-0000-0000-000000000000/")
        self.assertEqual(r.status_code, status.HTTP_404_NOT_FOUND)
        body = r.json()
        self.assertFalse(body["success"])
        self.assertEqual(body["error"]["code"], "NOT_FOUND")
