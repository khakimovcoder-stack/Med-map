# Shifo-Radar — Backend

Django 5 + DRF backend for the Shifo-Radar hospital bed availability platform.

## Stack

- Python 3.11+
- Django 5.0
- Django REST Framework
- djangorestframework-simplejwt (OneID mock)
- django-cors-headers
- python-decouple
- SQLite (dev)

## Run locally (Windows)

```cmd
cd backend
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
copy .env.example .env
python manage.py migrate
python manage.py seed
python manage.py createsuperuser   :: optional
python manage.py runserver
```

## Run locally (macOS / Linux)

```bash
cd backend
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
python manage.py migrate
python manage.py seed
python manage.py createsuperuser   # optional
python manage.py runserver
```

App listens on `http://localhost:8000`.
Django admin: `http://localhost:8000/admin/`.
API base: `http://localhost:8000/api/v1/`.

## Endpoints

All responses are wrapped in the standard envelope:

```json
{ "success": true, "data": {...}, "meta": {...} }
```

| Method | Path | Auth | Purpose |
|--------|------|------|---------|
| GET  | `/api/v1/health/`                              | no  | Liveness |
| GET  | `/api/v1/hospitals/`                           | no  | List (search, city, page) |
| GET  | `/api/v1/hospitals/{id}/`                      | no  | Detail with floors |
| GET  | `/api/v1/hospitals/{id}/floors/`               | no  | Floors list |
| GET  | `/api/v1/floors/{id}/rooms/`                   | no  | Rooms in a floor |
| GET  | `/api/v1/rooms/{id}/`                          | no  | Room detail with beds |
| GET  | `/api/v1/rooms/by-qr/{qr_code_token}/`         | no  | QR lookup -> Room |
| POST | `/api/v1/auth/oneid/start/`                    | no  | Begin OneID flow (mock OTP `123456`) |
| POST | `/api/v1/auth/oneid/verify/`                   | no  | Verify OTP -> JWT |
| POST | `/api/v1/confirmations/`                       | yes | Create patient confirmation |
| GET  | `/api/v1/stats/hospitals/{id}/`                | no  | Hospital dashboard stats |

Auth header for `confirmations`:

```
Authorization: Bearer <jwt-from-verify>
```

## Demo data after `seed`

- 3 hospitals: `RIKM` (Toshkent), `SVKTM` (Samarqand), `BVSh` (Buxoro)
- Each: 4 floors x 10 rooms x 4 beds = **160 beds**
- Room numbers `101..110, 201..210, 301..310, 401..410`
- Random initial bed states (60% BAND / 30% BOSH / 10% NOMALUM, deterministic with `--seed 42`)
- Demo users: `+998901111111`, `+998902222222`, `+998903333333`
- Mock OTP: always `123456`

Re-seed from scratch:

```bash
python manage.py seed --reset
```

## Tests

```bash
python manage.py test apps -v 2
```

## Project layout

```
backend/
  manage.py
  requirements.txt
  .env.example
  shifo_radar/        # project (settings, urls, wsgi/asgi)
  apps/
    core/             # envelope renderer, exception handler, pagination, /health
    hospitals/        # Hospital, Floor (+ seed command, stats view)
    rooms/            # Room, Bed
    accounts/         # User, OneIDSession, OneID auth
    confirmations/    # Confirmation + create endpoint
```

## Standard error codes

`VALIDATION_ERROR` (400), `UNAUTHORIZED` (401), `FORBIDDEN` (403), `NOT_FOUND` (404),
`DUPLICATE_CONFIRMATION` (409), `RATE_LIMIT` (429), `OTP_INVALID` (400),
`OTP_EXPIRED` (400), `INTERNAL_ERROR` (500).
