from django.urls import path

from apps.hospitals.views import (
    HospitalDetailView,
    HospitalFloorsView,
    HospitalListView,
)
from apps.hospitals.stats_views import HospitalStatsView

urlpatterns = [
    path("hospitals/", HospitalListView.as_view(), name="hospital-list"),
    path("hospitals/<uuid:pk>/", HospitalDetailView.as_view(), name="hospital-detail"),
    path("hospitals/<uuid:pk>/floors/", HospitalFloorsView.as_view(), name="hospital-floors"),
    path("stats/hospitals/<uuid:pk>/", HospitalStatsView.as_view(), name="hospital-stats"),
]
