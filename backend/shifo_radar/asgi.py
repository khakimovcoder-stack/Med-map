"""ASGI config for shifo_radar."""
import os

from django.core.asgi import get_asgi_application

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "shifo_radar.settings")
application = get_asgi_application()
