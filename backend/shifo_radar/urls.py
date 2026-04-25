"""Top-level URL routes for shifo_radar."""
from __future__ import annotations

from django.contrib import admin
from django.urls import include, path

api_v1_patterns = [
    path("", include("apps.core.urls")),
    path("", include("apps.hospitals.urls")),
    path("", include("apps.rooms.urls")),
    path("auth/", include("apps.accounts.urls")),
    path("", include("apps.confirmations.urls")),
]

urlpatterns = [
    path("admin/", admin.site.urls),
    path("api/v1/", include(api_v1_patterns)),
]
