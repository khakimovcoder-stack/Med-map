from django.contrib import admin

from apps.rooms.models import Bed, Room


class BedInline(admin.TabularInline):
    model = Bed
    extra = 0


@admin.register(Room)
class RoomAdmin(admin.ModelAdmin):
    list_display = ("number", "floor", "capacity", "qr_code_token")
    list_filter = ("floor__hospital", "floor")
    search_fields = ("number", "qr_code_token")
    inlines = (BedInline,)


@admin.register(Bed)
class BedAdmin(admin.ModelAdmin):
    list_display = ("room", "position", "current_status", "last_confirmed_at", "confirmation_count")
    list_filter = ("current_status",)
