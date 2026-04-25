from django.urls import path

from apps.rooms.views import (
    FloorRoomsView,
    QRCodeListView,
    RoomByQRView,
    RoomDetailView,
)

urlpatterns = [
    path("floors/<uuid:pk>/rooms/", FloorRoomsView.as_view(), name="floor-rooms"),
    path("rooms/<uuid:pk>/", RoomDetailView.as_view(), name="room-detail"),
    path(
        "rooms/by-qr/<str:qr_code_token>/",
        RoomByQRView.as_view(),
        name="room-by-qr",
    ),
    path("qr-codes/", QRCodeListView.as_view(), name="qr-codes"),
]
