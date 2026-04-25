# Shifo-Radar — Mobile (Flutter)

Shifoxonalardagi palatadagi haqiqiy bo'sh karavotlar sonini bemorlar tomonidan
crowdsourcing orqali tasdiqlaydigan shaffof platformaning Flutter ilovasi.

## Stack

- Flutter 3.16+ / Dart 3.2+
- State: `flutter_riverpod`
- Routing: `go_router`
- HTTP: `dio`
- QR: `mobile_scanner`
- Storage: `flutter_secure_storage`, `shared_preferences`
- Icons: `lucide_icons`
- Fonts: `google_fonts` (Inter)

## Folder structure

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── api/            # Dio client + endpoints + mock data
│   ├── router/         # go_router config
│   ├── storage/        # Secure storage wrapper
│   ├── theme/          # Colors, typography, ThemeData
│   └── utils/          # Time/phone formatters
├── features/
│   ├── hospitals/      # List + detail pages, hospital model + repo
│   ├── rooms/          # Floor grid + room detail (2D visual)
│   ├── scanner/        # mobile_scanner page
│   ├── auth/           # OneID modal + login page
│   └── confirmation/   # Patient confirm page
└── shared/
    └── widgets/        # PrimaryButton, ShifoCard, badges, skeletons
```

## Configuration

The mock/real toggle lives in `lib/core/api/api_endpoints.dart`:

```dart
static const bool kUseMock = true;  // ← set false when backend is up
```

Base URL resolution:
- Android emulator → `http://10.0.2.2:8000/api/v1`
- iOS simulator / desktop → `http://localhost:8000/api/v1`

## Running locally

```bash
flutter pub get
flutter run -d <android-emulator | ios-simulator>
```

## Building

```bash
flutter analyze
flutter build apk --debug
```

For release:

```bash
flutter build apk --release --obfuscate --split-debug-info=./debug-info/
```

## Routes

| Path | Page | Auth |
|------|------|------|
| `/` | Hospital list + search | ❌ |
| `/hospitals/:id` | Hospital detail (floors) | ❌ |
| `/floors/:id` | Floor rooms grid (10) | ❌ |
| `/rooms/:id` | Room detail (2D visual) | ❌ |
| `/scan` | QR scanner | ❌ |
| `/patient/room/:id` | Patient confirm | ✅ OneID |
| `/login` | OneID login | ❌ |

QR codes encode either a full URL `…/r/{token}` or just the bare token.

## Mock OneID

Any valid `+998XXXXXXXXX` phone number works. The OTP is always `123456`.

## Permissions

- Android — `CAMERA`, `INTERNET`, `usesCleartextTraffic` for dev backend
- iOS — `NSCameraUsageDescription`

## Style

Davlat portali (e-Gov) uslubi: oq + ko'k. Tokens defined in
`lib/core/theme/app_colors.dart` mirror `docs/STYLE_GUIDE.md` exactly.
