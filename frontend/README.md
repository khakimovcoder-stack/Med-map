# Shifo-Radar — Frontend (Web)

Web client for the Shifo-Radar hospital bed transparency platform.

This app is **public-viewing only** — it lets relatives and searchers browse
hospitals, floors, rooms and live bed availability.

> Patient confirmation, QR scanning and OneID authentication are **mobile-only**
> (Flutter) and are not part of this codebase.

## Stack

- **Vite** + **React 18** (JavaScript, no TypeScript)
- **Tailwind CSS** with custom design tokens (see `tailwind.config.js`)
- **react-router-dom v6** for routing
- **@tanstack/react-query v5** for server state + 30s polling
- **axios** with envelope unwrapping for the REST API
- **lucide-react** for icons
- **react-hot-toast** for notifications

## Routes

| Path | Page | Purpose |
|------|------|---------|
| `/` | HomePage | Hospital search + cards |
| `/hospitals/:id` | HospitalPage | Hospital hero + 4 floor cards |
| `/floors/:id` | FloorPage | 10-room grid with green / red / gray status |
| `/rooms/:id` | RoomPage | 2D room visual + info panel |

Unknown URLs redirect to `/`.

## Setup

```bash
cd frontend
npm install
cp .env.example .env
npm run dev
```

The dev server runs on http://localhost:5173.

## Environment

`.env`:

```
VITE_API_BASE_URL=http://localhost:8000/api/v1
VITE_USE_MOCK=true
```

- `VITE_USE_MOCK=true` — uses an in-memory mock dataset (3 hospitals × 4 floors × 10 rooms × 4 beds). The whole UI is fully clickable without a backend.
- `VITE_USE_MOCK=false` — calls the real REST API at `VITE_API_BASE_URL`. Endpoints follow `docs/API_CONTRACT.md` exactly.

## Build

```bash
npm run build
npm run preview   # local preview of the production build
```

Output goes to `dist/`.

## Project structure

```
src/
├── api/
│   ├── client.js       # axios + envelope unwrapping + error toast
│   ├── endpoints.js    # getHospitals / getHospital / getFloorRooms / getRoom
│   └── mockData.js     # deterministic mock topology (3 × 4 × 10 × 4)
├── hooks/              # React Query wrappers, one per domain query
├── lib/format.js       # Uzbek-friendly time + phone formatting
├── components/
│   ├── layout/         # Header, Footer, Container, Breadcrumb
│   ├── ui/             # Button, Card, Input, Badge, Skeleton, EmptyState, ProgressBar
│   ├── hospital/       # HospitalCard, HospitalSearch
│   ├── floor/          # FloorCard
│   └── room/           # RoomCard, BedTile, RoomVisual2D
└── pages/              # HomePage, HospitalPage, FloorPage, RoomPage
```

## Live updates

Every query uses `staleTime: 30000` + `refetchInterval: 30000`, so floor and
room views refresh themselves every 30 seconds without manual reload. The room
detail page shows a small "Yangilanmoqda..." indicator during background
refetches.

## Notes

- All user-facing copy is in Uzbek.
- Mobile-first responsive layout, validated from 320px upwards.
- Status colors follow the design system tokens (`success-500`, `danger-500`,
  `unknown`, `brand-blue-*`).
- Accessibility: semantic landmarks, `aria-label` on icon-only controls,
  visible focus rings, keyboard-navigable cards (rendered as `<a>`).
