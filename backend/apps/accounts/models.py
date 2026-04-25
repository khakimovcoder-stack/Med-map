"""User and OneID session models."""
from __future__ import annotations

import uuid

from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.db import models
from django.utils import timezone


class UserManager(BaseUserManager):
    """Phone-based user manager (no email/username required)."""

    use_in_migrations = True

    def _create_user(self, phone: str, password: str | None, **extra_fields):
        if not phone:
            raise ValueError("phone is required")
        user = self.model(phone=phone, **extra_fields)
        if password:
            user.set_password(password)
        else:
            user.set_unusable_password()
        user.save(using=self._db)
        return user

    def create_user(self, phone: str, password: str | None = None, **extra_fields):
        extra_fields.setdefault("is_staff", False)
        extra_fields.setdefault("is_superuser", False)
        return self._create_user(phone, password, **extra_fields)

    def create_superuser(self, phone: str, password: str | None = None, **extra_fields):
        extra_fields.setdefault("is_staff", True)
        extra_fields.setdefault("is_superuser", True)
        if extra_fields.get("is_staff") is not True:
            raise ValueError("Superuser must have is_staff=True.")
        if extra_fields.get("is_superuser") is not True:
            raise ValueError("Superuser must have is_superuser=True.")
        return self._create_user(phone, password, **extra_fields)


class User(AbstractBaseUser, PermissionsMixin):
    """Phone-authenticated user. UUID PK per data contract."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    oneid_pin = models.CharField(max_length=14, unique=True, null=True, blank=True)
    phone = models.CharField(max_length=20, unique=True)
    full_name = models.CharField(max_length=255, blank=True, default="")
    current_room = models.ForeignKey(
        "rooms.Room",
        related_name="current_users",
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
    )
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    last_login_at = models.DateTimeField(null=True, blank=True)

    USERNAME_FIELD = "phone"
    REQUIRED_FIELDS: list[str] = []

    objects = UserManager()

    class Meta:
        db_table = "accounts_user"
        ordering = ("-created_at",)

    def __str__(self) -> str:
        return f"{self.phone} ({self.full_name or 'no name'})"


class OneIDSession(models.Model):
    """Mock OneID OTP session."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    phone = models.CharField(max_length=20)
    otp_code = models.CharField(max_length=6)
    is_verified = models.BooleanField(default=False)
    token = models.CharField(max_length=512, blank=True, default="")
    expires_at = models.DateTimeField()
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "accounts_oneidsession"
        ordering = ("-created_at",)
        indexes = [models.Index(fields=("phone", "-created_at"))]

    def is_expired(self) -> bool:
        return timezone.now() >= self.expires_at

    @property
    def session_id(self) -> str:
        """Frontend-friendly identifier (sess_<short>)."""
        return f"sess_{self.id.hex[:16]}"

    @classmethod
    def from_session_id(cls, session_id: str) -> "OneIDSession | None":
        if not session_id or not session_id.startswith("sess_"):
            return None
        short = session_id[len("sess_"):]
        # Match by hex prefix; uuid hex is unique enough for first 16 chars.
        return cls.objects.filter(id__startswith="").extra(  # noqa: SLF001
            where=["replace(hex(id), '-', '') LIKE %s"],
            params=[f"{short}%"],
        ).first() if False else cls._from_short_hex(short)

    @classmethod
    def _from_short_hex(cls, short: str) -> "OneIDSession | None":
        # Portable lookup: scan recent sessions and compare hex prefix.
        # In SQLite/Postgres uuid->hex differs; iterating recent rows is cheap
        # for a hackathon and avoids backend-specific SQL.
        candidates = cls.objects.order_by("-created_at")[:200]
        for s in candidates:
            if s.id.hex.startswith(short):
                return s
        return None
