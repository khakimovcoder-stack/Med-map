"""Hospital + Floor views."""
from __future__ import annotations

from django.db.models import Q
from django.shortcuts import get_object_or_404
from rest_framework import generics
from rest_framework.permissions import AllowAny
from rest_framework.request import Request
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.hospitals.models import Floor, Hospital
from apps.hospitals.queries import (
    annotate_floor_bed_counts,
    annotate_hospital_bed_counts,
)
from apps.hospitals.serializers import (
    FloorListItemSerializer,
    HospitalDetailSerializer,
    HospitalListSerializer,
)


class HospitalListView(generics.ListAPIView):
    permission_classes = (AllowAny,)
    serializer_class = HospitalListSerializer

    def get_queryset(self):
        qs = annotate_hospital_bed_counts(Hospital.objects.all())
        params = self.request.query_params

        search = params.get("search")
        if search:
            qs = qs.filter(
                Q(name__icontains=search)
                | Q(short_name__icontains=search)
                | Q(city__icontains=search),
            )

        city = params.get("city")
        if city:
            qs = qs.filter(city__iexact=city)

        return qs.order_by("name")


class HospitalDetailView(APIView):
    permission_classes = (AllowAny,)

    def get(self, request: Request, pk) -> Response:
        qs = annotate_hospital_bed_counts(Hospital.objects.all())
        hospital = get_object_or_404(qs, pk=pk)
        return Response(HospitalDetailSerializer(hospital).data)


class HospitalFloorsView(APIView):
    permission_classes = (AllowAny,)

    def get(self, request: Request, pk) -> Response:
        # Validate hospital exists for clearer 404 message.
        hospital = get_object_or_404(Hospital, pk=pk)
        qs = annotate_floor_bed_counts(
            Floor.objects.filter(hospital=hospital),
        ).order_by("number")
        return Response(FloorListItemSerializer(qs, many=True).data)
