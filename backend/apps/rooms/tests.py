"""Smoke tests for rooms app."""
from __future__ import annotations

from rest_framework import status
from rest_framework.test import APITestCase

from apps.hospitals.models import Floor, Hospital
from apps.rooms.models import Bed, BedStatus, Room
from apps.rooms.utils import aggregate_room_status


class RoomAggregateTests(APITestCase):
    def test_status_red_when_all_band(self):
        h = Hospital.objects.create(name="x", address="a")
        f = Floor.objects.create(hospital=h, number=1)
        room = Room.objects.create(floor=f, number="101", qr_code_token="t1")
        for i in range(1, 5):
            Bed.objects.create(
                room=room, position=i, current_status=BedStatus.BAND,
            )
        beds = list(room.beds.all())
        avail, color, label = aggregate_room_status(beds)
        self.assertEqual(avail, 0)
        self.assertEqual(color, "red")
        self.assertEqual(label, "To'liq band")

    def test_status_green_when_some_bosh(self):
        h = Hospital.objects.create(name="x", address="a")
        f = Floor.objects.create(hospital=h, number=1)
        room = Room.objects.create(floor=f, number="101", qr_code_token="t2")
        statuses = [BedStatus.BAND, BedStatus.BOSH, BedStatus.BAND, BedStatus.BOSH]
        for i, s in enumerate(statuses, start=1):
            Bed.objects.create(room=room, position=i, current_status=s)
        avail, color, label = aggregate_room_status(list(room.beds.all()))
        self.assertEqual(avail, 2)
        self.assertEqual(color, "green")
        self.assertEqual(label, "2 bo'sh")

    def test_status_gray_when_all_unknown(self):
        h = Hospital.objects.create(name="x", address="a")
        f = Floor.objects.create(hospital=h, number=1)
        room = Room.objects.create(floor=f, number="101", qr_code_token="t3")
        for i in range(1, 5):
            Bed.objects.create(
                room=room, position=i, current_status=BedStatus.NOMALUM,
            )
        avail, color, label = aggregate_room_status(list(room.beds.all()))
        self.assertEqual(avail, 0)
        self.assertEqual(color, "gray")
        self.assertEqual(label, "Noma'lum")


class RoomAPITests(APITestCase):
    @classmethod
    def setUpTestData(cls):
        cls.h = Hospital.objects.create(name="RIKM", short_name="RIKM", address="addr")
        cls.f = Floor.objects.create(hospital=cls.h, number=3)
        cls.room = Room.objects.create(
            floor=cls.f, number="305", qr_code_token="abcdef1234",
        )
        for i in range(1, 5):
            Bed.objects.create(
                room=cls.room, position=i, is_near_window=i <= 2,
                current_status=BedStatus.BOSH if i == 2 else BedStatus.BAND,
            )

    def test_floor_rooms(self):
        r = self.client.get(f"/api/v1/floors/{self.f.id}/rooms/")
        self.assertEqual(r.status_code, status.HTTP_200_OK)
        body = r.json()
        self.assertTrue(body["success"])
        self.assertEqual(body["data"]["floor"]["number"], 3)
        self.assertEqual(len(body["data"]["rooms"]), 1)
        self.assertEqual(body["data"]["rooms"][0]["status_color"], "green")
        self.assertEqual(body["data"]["rooms"][0]["available_beds"], 1)

    def test_room_detail(self):
        r = self.client.get(f"/api/v1/rooms/{self.room.id}/")
        self.assertEqual(r.status_code, status.HTTP_200_OK)
        body = r.json()
        self.assertEqual(body["data"]["number"], "305")
        self.assertEqual(body["data"]["total_beds"], 4)
        self.assertEqual(body["data"]["available_beds"], 1)
        self.assertEqual(len(body["data"]["beds"]), 4)
        self.assertEqual(body["data"]["hospital"]["short_name"], "RIKM")

    def test_room_by_qr(self):
        r = self.client.get("/api/v1/rooms/by-qr/abcdef1234/")
        self.assertEqual(r.status_code, status.HTTP_200_OK)
        self.assertEqual(r.json()["data"]["number"], "305")

    def test_room_by_qr_not_found(self):
        r = self.client.get("/api/v1/rooms/by-qr/nonexistenttoken/")
        self.assertEqual(r.status_code, status.HTTP_404_NOT_FOUND)
        self.assertEqual(r.json()["error"]["code"], "NOT_FOUND")
