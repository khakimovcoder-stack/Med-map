from django.contrib import admin

from apps.accounts.models import OneIDSession, User


@admin.register(User)
class UserAdmin(admin.ModelAdmin):
    list_display = ("phone", "full_name", "current_room", "last_login_at", "created_at")
    search_fields = ("phone", "full_name")
    list_filter = ("is_active", "is_staff")


@admin.register(OneIDSession)
class OneIDSessionAdmin(admin.ModelAdmin):
    list_display = ("phone", "is_verified", "expires_at", "created_at")
    list_filter = ("is_verified",)
    search_fields = ("phone",)
