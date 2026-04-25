"""Seed command — populate the dev database with deterministic demo data."""
from __future__ import annotations

import random
import uuid
from typing import Any

from django.core.management.base import BaseCommand
from django.db import transaction
from django.utils import timezone

from apps.accounts.models import User
from apps.hospitals.models import Floor, Hospital
from apps.rooms.models import Bed, BedStatus, Room

HOSPITALS_FIXTURE: list[dict[str, Any]] = [
    {
        "name": "Respublika Ixtisoslashtirilgan Kardiologiya Markazi",
        "short_name": "RIKM",
        "city": "Toshkent",
        "region": "Toshkent shahri",
        "address": "Toshkent sh., Yunusobod tumani, A. Qodiriy 4",
        "phone": "+998712345678",
        "latitude": 41.311081,
        "longitude": 69.240562,
    },
    {
        "name": "Samarqand Viloyat Ko'p Tarmoqli Tibbiy Markazi",
        "short_name": "SVKTM",
        "city": "Samarqand",
        "region": "Samarqand viloyati",
        "address": "Samarqand sh., Universitet xiyoboni 18",
        "phone": "+998662345678",
        "latitude": 39.654307,
        "longitude": 66.975999,
    },
    {
        "name": "Buxoro Viloyat Sho'ba Shifoxonasi",
        "short_name": "BVSh",
        "city": "Buxoro",
        "region": "Buxoro viloyati",
        "address": "Buxoro sh., Mustaqillik ko'chasi 5",
        "phone": "+998652345678",
        "latitude": 39.774229,
        "longitude": 64.428108,
    },
]

DEMO_USERS = [
    ("+998901111111", "Ali Valiyev"),
    ("+998902222222", "Vali Aliyev"),
    ("+998903333333", "Hasan Hasanov"),
]


def random_bed_status(rng: random.Random) -> str:
    r = rng.random()
    if r < 0.6:
        return BedStatus.BAND
    if r < 0.9:
        return BedStatus.BOSH
    return BedStatus.NOMALUM


class Command(BaseCommand):
    help = "Seed the database with hospitals, floors, rooms, beds and demo users."

    def add_arguments(self, parser):
        parser.add_argument(
            "--reset",
            action="store_true",
            help="Wipe existing seeded data before re-seeding.",
        )
        parser.add_argument(
            "--seed",
            type=int,
            default=42,
            help="Random seed for deterministic bed statuses.",
        )

    @transaction.atomic
    def handle(self, *args, **options):
        rng = random.Random(options["seed"])
        if options.get("reset"):
            self.stdout.write("Resetting existing seed data...")
            Bed.objects.all().delete()
            Room.objects.all().delete()
            Floor.objects.all().delete()
            Hospital.objects.all().delete()

        self._seed_hospitals(rng)
        self._seed_users()
        self.stdout.write(self.style.SUCCESS("Seed complete."))

    def _seed_hospitals(self, rng: random.Random) -> None:
        now = timezone.now()
        for spec in HOSPITALS_FIXTURE:
            hospital, created = Hospital.objects.get_or_create(
                short_name=spec["short_name"],
                defaults={
                    "name": spec["name"],
                    "city": spec["city"],
                    "region": spec["region"],
                    "address": spec["address"],
                    "phone": spec["phone"],
                    "latitude": spec["latitude"],
                    "longitude": spec["longitude"],
                },
            )
            if created:
                self.stdout.write(f"  + Hospital {hospital.short_name}")
            else:
                self.stdout.write(f"  = Hospital {hospital.short_name} (exists)")

            for floor_number in range(1, 5):
                floor, _ = Floor.objects.get_or_create(
                    hospital=hospital,
                    number=floor_number,
                    defaults={"name": ""},
                )
                for room_idx in range(1, 11):
                    room_number = f"{floor_number}{room_idx:02d}"
                    room, room_created = Room.objects.get_or_create(
                        floor=floor,
                        number=room_number,
                        defaults={
                            "capacity": 4,
                            "has_window": True,
                            "qr_code_token": uuid.uuid4().hex,
                        },
                    )
                    if room_created:
                        beds = []
                        for pos in range(1, 5):
                            beds.append(Bed(
                                room=room,
                                position=pos,
                                is_near_window=pos in (1, 2),
                                current_status=random_bed_status(rng),
                                last_confirmed_at=now,
                                confirmation_count=0,
                            ))
                        Bed.objects.bulk_create(beds)

    def _seed_users(self) -> None:
        for phone, full_name in DEMO_USERS:
            user, created = User.objects.get_or_create(
                phone=phone,
                defaults={
                    "full_name": full_name,
                    "oneid_pin": f"mock-{phone[-9:]}",
                },
            )
            if created:
                self.stdout.write(f"  + User {phone} ({full_name})")
