# MED MAP — Deployment Guide

> **Backend → Railway** (Django + Postgres)
> **Frontend → Vercel** (Vite + React)
>
> Tartib muhim: avval **backend ni Railway** ga deploy qiling, URL ni oling, keyin **frontend ni Vercel** ga shu URL bilan ulang.

---

## 1) Backend — Railway

### Tayyorgarlik

`backend/` papkasida quyidagi fayllar yaratilgan (deploy uchun zarur):

| Fayl | Vazifasi |
|------|----------|
| `Procfile` | release: migrate + collectstatic + seed; web: gunicorn |
| `railway.json` | Healthcheck `/api/v1/health/`, restart policy |
| `runtime.txt` | Python 3.12.6 |
| `requirements.txt` | gunicorn, whitenoise, dj-database-url, psycopg2-binary qo'shildi |
| `.env.example` | Zarur env var lar ro'yxati |
| `.gitignore` | venv/, db.sqlite3, .env va boshqalar |

### Qadamma-qadam

1. **GitHub ga push qilingach** (siz tayyor bo'lganda) → [Railway Dashboard](https://railway.app/) → **New Project** → **Deploy from GitHub** → **Med Map** repo → **`backend`** root directory ni tanlang.

2. **Postgres plugin qo'shing**: Project → **+ New** → **Database** → **PostgreSQL**. Railway avtomatik `DATABASE_URL` ni service ga inject qiladi.

3. **Variables** tab da quyidagilarni qo'shing:

   ```
   SECRET_KEY=<openssl rand -hex 32 yoki uzun random string>
   DEBUG=False
   ALLOWED_HOSTS=                  (bo'sh qoldiring — Railway o'z domenini avto-trust qiladi)
   CORS_ALLOWED_ORIGINS=https://medmap.vercel.app,https://medmap.uz
   CORS_ALLOWED_ORIGIN_REGEXES=^https://.*\.vercel\.app$
   CORS_ALLOW_ALL_ORIGINS=False
   JWT_ACCESS_TOKEN_LIFETIME_SECONDS=86400
   ONEID_MOCK_OTP=123456
   ONEID_OTP_TTL_SECONDS=300
   ```

   > `DATABASE_URL` Postgres plugin tomonidan avtomatik beriladi.

4. **Deploy** boshlanadi. Build log oxirida:
   - Migrations applied
   - Static files collected (WhiteNoise)
   - Seed (3 shifoxona × 480 karavot) idempotent yaratildi
   - Gunicorn 8000 portda ishladi

5. Settings → **Networking** → **Generate Domain** → masalan `medmap-backend-production.up.railway.app`.

6. Sinab ko'ring:
   ```bash
   curl https://YOUR-APP.up.railway.app/api/v1/health/
   curl https://YOUR-APP.up.railway.app/api/v1/hospitals/
   ```

### Lokal nima o'zgardi (deploy uchun moslashtirilgan)

`shifo_radar/settings.py`:
- `DATABASE_URL` bo'lsa Postgres, bo'lmasa SQLite (lokal dev ishlayveradi)
- WhiteNoise middleware (static fayllar)
- `RAILWAY_PUBLIC_DOMAIN` ni `ALLOWED_HOSTS` va `CSRF_TRUSTED_ORIGINS` ga avtomatik qo'shadi
- `DEBUG=False` bo'lganda HSTS, secure cookies, X-Frame DENY
- CORS: prod da explicit list, regex orqali Vercel preview'lar avto

### Lokal dev hali ham ishlayverdi

```bash
cd backend
./venv/Scripts/activate
pip install -r requirements.txt   # yangi paketlarni o'rnatish
python manage.py runserver
```

---

## 2) Frontend — Vercel

### Tayyorgarlik

`frontend/` papkasida:

| Fayl | Vazifasi |
|------|----------|
| `vercel.json` | Vite framework + SPA rewrites + asset cache headers |
| `.env.example` | `VITE_API_BASE_URL`, `VITE_USE_MOCK` |
| `.env.production` | Prod template (real qiymatni Vercel dashboard'da kiriting) |
| `.gitignore` | `.env`, `dist`, `node_modules`, `.vercel` |

### Qadamma-qadam

1. [vercel.com](https://vercel.com/) → **Add New Project** → GitHub repo → **`frontend`** root directory ni tanlang.

2. Framework Preset: **Vite** (avtomatik aniqlanadi).

3. **Environment Variables** bo'limida:

   ```
   VITE_API_BASE_URL = https://YOUR-RAILWAY-APP.up.railway.app/api/v1
   VITE_USE_MOCK     = false
   ```

   Production, Preview, Development uchun bir xilini o'rnating (yoki Preview uchun mock qoldiring).

4. **Deploy** bosing. Bir necha daqiqada `https://medmap.vercel.app` (yoki sizning subdomain) ishga tushadi.

5. Custom domain: Project → **Domains** → `medmap.uz` qo'shing va DNS sozlang.

### Backend CORS ni yangilang

Vercel URL aniq bo'lgach, Railway → Variables → `CORS_ALLOWED_ORIGINS` ga shu URL ni qo'shing va backend ni qayta deploy qiling.

---

## 3) Test reja (deploy dan keyin)

```bash
# Backend smoke
curl https://YOUR-RAILWAY.up.railway.app/api/v1/health/
curl https://YOUR-RAILWAY.up.railway.app/api/v1/hospitals/ | jq '.data[0].short_name'

# Frontend
open https://medmap.vercel.app
# 3 ta shifoxona ko'rinishi va qidiruv ishlashi kerak
```

QR Simulyator (`/qr-simulator`) ham real backend dan ma'lumot oladi.

---

## 4) Mobile (Flutter)

`mobile_app/lib/core/api/api_endpoints.dart`:

```dart
static String get baseUrl => 'https://YOUR-RAILWAY.up.railway.app/api/v1';
```

So'ng `flutter build apk --release` qilib APK ni telefonga o'rnatishingiz mumkin (Play Store ga chiqarish alohida ish).

---

## Eslatma

- `git push` siz qachon hohlasangiz qilasiz — bu hujjatlarda qadamlar GitHub repo tayyor bo'lgandan keyin amal qiladi.
- Railway free tier ishlayveradi, lekin tez orada $5/oy kredit limiti tugaydi. Hobbi loyiha uchun yetadi.
- Vercel hobby plan'i shaxsiy loyihalar uchun bepul — preview deploy va custom domain ham bor.
- `SECRET_KEY` ni hech qachon repo ga commit qilmang. Har bir muhit (prod / preview) uchun alohida key.
