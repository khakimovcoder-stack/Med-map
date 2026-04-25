from django.contrib import admin

from apps.hospitals.models import Floor, Hospital


@admin.register(Hospital)
class HospitalAdmin(admin.ModelAdmin):
    list_display = ("short_name", "name", "city", "phone")
    search_fields = ("name", "short_name", "city")


@admin.register(Floor)
class FloorAdmin(admin.ModelAdmin):
    list_display = ("hospital", "number", "name")
    list_filter = ("hospital",)
