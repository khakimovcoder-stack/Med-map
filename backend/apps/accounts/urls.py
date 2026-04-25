from django.urls import path

from apps.accounts.views import OneIDStartView, OneIDVerifyView

urlpatterns = [
    path("oneid/start/", OneIDStartView.as_view(), name="oneid-start"),
    path("oneid/verify/", OneIDVerifyView.as_view(), name="oneid-verify"),
]
