from django.urls import path

from apps.confirmations.views import ConfirmationCreateView

urlpatterns = [
    path("confirmations/", ConfirmationCreateView.as_view(), name="confirmation-create"),
]
