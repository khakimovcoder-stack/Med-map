"""Hospital + Floor serializers."""
from __future__ import annotations

from rest_framework import serializers

from apps.hospitals.models import Floor, Hospital


class FloorListItemSerializer(serializers.ModelSerializer):
    total_beds = serializers.IntegerField(source="total_beds_agg", default=0)
    available_beds = serializers.IntegerField(source="available_beds_agg", default=0)
    rooms_count = serializers.IntegerField(source="rooms_count_agg", default=0)
    name = serializers.SerializerMethodField()

    class Meta:
        model = Floor
        fields = ("id", "number", "name", "total_beds", "available_beds", "rooms_count")

    def get_name(self, obj: Floor) -> str | None:
        return obj.name or None


class FloorEmbeddedSerializer(serializers.ModelSerializer):
    """Floor inside Hospital detail (no rooms_count per contract)."""

    total_beds = serializers.IntegerField(source="total_beds_agg", default=0)
    available_beds = serializers.IntegerField(source="available_beds_agg", default=0)
    name = serializers.SerializerMethodField()

    class Meta:
        model = Floor
        fields = ("id", "number", "name", "total_beds", "available_beds")

    def get_name(self, obj: Floor) -> str | None:
        return obj.name or None


class HospitalListSerializer(serializers.ModelSerializer):
    total_beds = serializers.IntegerField(source="total_beds_agg", default=0)
    available_beds = serializers.IntegerField(source="available_beds_agg", default=0)
    floors_count = serializers.IntegerField(source="floors_count_agg", default=0)
    latitude = serializers.FloatField(allow_null=True)
    longitude = serializers.FloatField(allow_null=True)

    class Meta:
        model = Hospital
        fields = (
            "id",
            "name",
            "short_name",
            "city",
            "address",
            "phone",
            "latitude",
            "longitude",
            "total_beds",
            "available_beds",
            "floors_count",
        )


class HospitalDetailSerializer(serializers.ModelSerializer):
    total_beds = serializers.IntegerField(source="total_beds_agg", default=0)
    available_beds = serializers.IntegerField(source="available_beds_agg", default=0)
    latitude = serializers.FloatField(allow_null=True)
    longitude = serializers.FloatField(allow_null=True)
    floors = serializers.SerializerMethodField()

    class Meta:
        model = Hospital
        fields = (
            "id",
            "name",
            "short_name",
            "city",
            "address",
            "phone",
            "latitude",
            "longitude",
            "total_beds",
            "available_beds",
            "floors",
        )

    def get_floors(self, obj: Hospital) -> list[dict]:
        from apps.hospitals.queries import annotate_floor_bed_counts

        floors_qs = annotate_floor_bed_counts(
            Floor.objects.filter(hospital=obj),
        ).order_by("number")
        return FloorEmbeddedSerializer(floors_qs, many=True).data
