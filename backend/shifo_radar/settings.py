"""Django settings for shifo_radar project."""
from __future__ import annotations

from datetime import timedelta
from pathlib import Path

import dj_database_url
from decouple import Csv, config

BASE_DIR = Path(__file__).resolve().parent.parent

SECRET_KEY = config("SECRET_KEY", default="dev-insecure-key-change-me")
DEBUG = config("DEBUG", default=True, cast=bool)
ALLOWED_HOSTS = config(
    "ALLOWED_HOSTS",
    default="*",
    cast=Csv(),
)

# Railway sets RAILWAY_PUBLIC_DOMAIN automatically — auto-trust it.
_railway_domain = config("RAILWAY_PUBLIC_DOMAIN", default="")
if _railway_domain and _railway_domain not in ALLOWED_HOSTS:
    ALLOWED_HOSTS = [*ALLOWED_HOSTS, _railway_domain]

# Railway healthcheck probes use this Host header.
if "healthcheck.railway.app" not in ALLOWED_HOSTS:
    ALLOWED_HOSTS = [*ALLOWED_HOSTS, "healthcheck.railway.app"]

CSRF_TRUSTED_ORIGINS = config(
    "CSRF_TRUSTED_ORIGINS",
    default="",
    cast=Csv(),
)
if _railway_domain:
    railway_origin = f"https://{_railway_domain}"
    if railway_origin not in CSRF_TRUSTED_ORIGINS:
        CSRF_TRUSTED_ORIGINS = [*CSRF_TRUSTED_ORIGINS, railway_origin]

INSTALLED_APPS = [
    "django.contrib.admin",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.staticfiles",
    # Third-party
    "rest_framework",
    "corsheaders",
    # Local apps
    "apps.core",
    "apps.hospitals",
    "apps.rooms",
    "apps.accounts",
    "apps.confirmations",
]

MIDDLEWARE = [
    "corsheaders.middleware.CorsMiddleware",
    "django.middleware.security.SecurityMiddleware",
    # WhiteNoise — serves static files in prod (no-op in dev with DEBUG=True)
    "whitenoise.middleware.WhiteNoiseMiddleware",
    "django.contrib.sessions.middleware.SessionMiddleware",
    "django.middleware.common.CommonMiddleware",
    "django.middleware.csrf.CsrfViewMiddleware",
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    "django.contrib.messages.middleware.MessageMiddleware",
    "django.middleware.clickjacking.XFrameOptionsMiddleware",
    # Local: stamp request.id for envelope meta.request_id
    "apps.core.middleware.RequestIdMiddleware",
]

ROOT_URLCONF = "shifo_radar.urls"

TEMPLATES = [
    {
        "BACKEND": "django.template.backends.django.DjangoTemplates",
        "DIRS": [],
        "APP_DIRS": True,
        "OPTIONS": {
            "context_processors": [
                "django.template.context_processors.debug",
                "django.template.context_processors.request",
                "django.contrib.auth.context_processors.auth",
                "django.contrib.messages.context_processors.messages",
            ],
        },
    },
]

WSGI_APPLICATION = "shifo_radar.wsgi.application"
ASGI_APPLICATION = "shifo_radar.asgi.application"

# Database — use DATABASE_URL when present (Railway / Heroku style),
# otherwise fall back to local SQLite for dev.
DATABASE_URL = config("DATABASE_URL", default="")
if DATABASE_URL:
    DATABASES = {
        "default": dj_database_url.parse(
            DATABASE_URL,
            conn_max_age=600,
            conn_health_checks=True,
            ssl_require=not DEBUG,
        ),
    }
else:
    DATABASES = {
        "default": {
            "ENGINE": "django.db.backends.sqlite3",
            "NAME": BASE_DIR / "db.sqlite3",
        }
    }

AUTH_PASSWORD_VALIDATORS = [
    {"NAME": "django.contrib.auth.password_validation.UserAttributeSimilarityValidator"},
    {"NAME": "django.contrib.auth.password_validation.MinimumLengthValidator"},
    {"NAME": "django.contrib.auth.password_validation.CommonPasswordValidator"},
    {"NAME": "django.contrib.auth.password_validation.NumericPasswordValidator"},
]

# Custom user model
AUTH_USER_MODEL = "accounts.User"

LANGUAGE_CODE = "uz"
TIME_ZONE = "UTC"
USE_I18N = True
USE_TZ = True

STATIC_URL = "static/"
STATIC_ROOT = BASE_DIR / "staticfiles"
STATICFILES_STORAGE = "whitenoise.storage.CompressedManifestStaticFilesStorage"
DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"

# Behind a proxy on Railway — trust X-Forwarded-Proto.
SECURE_PROXY_SSL_HEADER = ("HTTP_X_FORWARDED_PROTO", "https")
USE_X_FORWARDED_HOST = True

# Production hardening (only when DEBUG is off).
if not DEBUG:
    SESSION_COOKIE_SECURE = True
    CSRF_COOKIE_SECURE = True
    SECURE_HSTS_SECONDS = 31536000
    SECURE_HSTS_INCLUDE_SUBDOMAINS = True
    SECURE_HSTS_PRELOAD = True
    SECURE_CONTENT_TYPE_NOSNIFF = True
    SECURE_REFERRER_POLICY = "strict-origin-when-cross-origin"
    X_FRAME_OPTIONS = "DENY"

# ---- DRF ----
REST_FRAMEWORK = {
    "DEFAULT_AUTHENTICATION_CLASSES": (
        "rest_framework_simplejwt.authentication.JWTAuthentication",
    ),
    "DEFAULT_PERMISSION_CLASSES": (
        "rest_framework.permissions.AllowAny",
    ),
    "DEFAULT_RENDERER_CLASSES": (
        "apps.core.renderers.EnvelopeJSONRenderer",
        "rest_framework.renderers.BrowsableAPIRenderer",
    ),
    "DEFAULT_PAGINATION_CLASS": "apps.core.pagination.EnvelopePagination",
    "PAGE_SIZE": 20,
    "EXCEPTION_HANDLER": "apps.core.exceptions.envelope_exception_handler",
    "DEFAULT_THROTTLE_CLASSES": (),
    "DEFAULT_THROTTLE_RATES": {
        "oneid_start": "1/min",
    },
}

# ---- SimpleJWT ----
JWT_TTL = config("JWT_ACCESS_TOKEN_LIFETIME_SECONDS", default=86400, cast=int)
SIMPLE_JWT = {
    "ACCESS_TOKEN_LIFETIME": timedelta(seconds=JWT_TTL),
    "REFRESH_TOKEN_LIFETIME": timedelta(days=7),
    "AUTH_HEADER_TYPES": ("Bearer",),
    "USER_ID_FIELD": "id",
    "USER_ID_CLAIM": "user_id",
}

# ---- CORS ----
# In dev we allow all origins for convenience; in prod we expect an explicit list
# of frontend origins (e.g. https://medmap.vercel.app, https://medmap.uz).
CORS_ALLOW_ALL_ORIGINS = config("CORS_ALLOW_ALL_ORIGINS", default=DEBUG, cast=bool)
CORS_ALLOWED_ORIGINS = config(
    "CORS_ALLOWED_ORIGINS",
    default="http://localhost:5173,http://localhost:3000,http://localhost:8080",
    cast=Csv(),
)
CORS_ALLOWED_ORIGIN_REGEXES = config(
    "CORS_ALLOWED_ORIGIN_REGEXES",
    default=r"^https://.*\.vercel\.app$",
    cast=Csv(),
)
CORS_ALLOW_HEADERS = ["authorization", "content-type", "accept"]
CORS_ALLOW_METHODS = ["GET", "POST", "OPTIONS"]

# ---- OneID Mock ----
ONEID_MOCK_OTP = config("ONEID_MOCK_OTP", default="123456")
ONEID_OTP_TTL_SECONDS = config("ONEID_OTP_TTL_SECONDS", default=300, cast=int)

# ---- App version ----
APP_VERSION = "0.1.0"

# ---- Caches (used by throttle + simple rate limiter) ----
CACHES = {
    "default": {
        "BACKEND": "django.core.cache.backends.locmem.LocMemCache",
        "LOCATION": "shifo-radar-cache",
    }
}
