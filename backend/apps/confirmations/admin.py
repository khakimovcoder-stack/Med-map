from django.contrib import admin

from apps.confirmations.models import Confirmation


@admin.register(Confirmation)
class ConfirmationAdmin(admin.ModelAdmin):
    list_display = (
        "bed", "user", "status_reported", "confirmation_type", "confirmed_at",
    )
    list_filter = ("status_reported", "confirmation_type")
    search_fields = ("user__phone", "ip_address")
    readonly_fields = ("confirmed_at",)
