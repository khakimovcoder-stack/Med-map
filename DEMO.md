# Shifo-Radar — Hakamlar uchun Demo Skript

> **Maqsad:** 5-7 daqiqada hakamlarga loyihaning antikorruptsion qiymatini ko'rsatish.

---

## 0. Tayyorgarlik (demo dan oldin)

**3 ta terminal oching:**

### Terminal 1 — Backend
```bash
cd "D:/Ulugbek/projects/Shifo Radar/backend"
./venv/Scripts/activate
python manage.py runserver 0.0.0.0:8000
```

### Terminal 2 — Frontend (web)
```bash
cd "D:/Ulugbek/projects/Shifo Radar/frontend"
npm run dev
```

### Terminal 3 — Mobile (emulator yoki qurilma)
```bash
cd "D:/Ulugbek/projects/Shifo Radar/mobile_app"
flutter run
```

**Brauzerda oching:** http://localhost:5173

**Qurilmada hozir bo'lishi kerak:**
- Backend ishlamoqda (logsiz, port 8000)
- Web tab tayyor (HomePage)
- Telefon/emulator tayyor (HospitalListPage)

---

## 1. Muammo (30 sek)

> "Hurmatli hakamlar! Sizning yaqiningizni shoshilinch shifoxonaga olib kelganingizda, registratsiyada 'palatalarda joy yo'q, kutib turing' deyilganini eshitgansiz. Lekin haqiqatda joy bor — faqat ko'rsatilmaydi. Bu — korruptsion sxema. Bizning loyihamiz — **Shifo-Radar** — bemorlarning o'zi bu ma'lumotni shaffof qilib taqdim etadi."

---

## 2. Web tomon — Jamoatchilik nazorati (1.5 daqiqa)

**Brauzerda http://localhost:5173 ochiq:**

1. **Bosh sahifa** — "Mana, hozir 3 ta shifoxona ulangan. Real vaqtda bo'sh joylar ko'rinmoqda."
   - Search bar: "Toshkent" deb yozing → RIKM filterlandi

2. **RIKM kartasini bosing** → 4 qavat ko'rinadi
   - "Har qavat uchun bo'sh joy soni real ma'lumot — bemor o'zi tasdiqlagan."

3. **3-qavat ni bosing** → 10 ta palata grid
   - Yashil = bo'sh joy bor, Qizil = to'liq band
   - "Hech kim qog'ozda yashirin tutmaydi — barcha shaffof."

4. **305-palata ni bosing** → 2D xona vizual
   - 4 ta karavot, deraza ko'rsatilgan
   - "5 daqiqa oldin yangilandi" — real vaqt
   - "3 bemor tomonidan tasdiqlangan" — konsensus

---

## 3. Mobile tomon — Bemor tasdig'i (2 daqiqa)

**Telefon yoki emulator qo'lingizda:**

1. **App ochiladi → HospitalListPage** — xuddi web kabi, lekin telefonga moslashtirilgan

2. **QR Scanner ko'rsatish** — bottom navda yoki menyuda QR icon
   - Kamera ochiladi
   - **Demo trick:** oldindan yozib qo'yilgan QR kodni ko'rsating (room 305 uchun)
   - Yoki "Manual" tugmasini bosing va `29d5280e3bf84aa9abb8071a387241f6` token ni kiriting

3. **Bemor tasdig'i sahifasi ochiladi:**
   - "Siz 3-qavat, 305-palatadasiz" katta ko'k matn
   - 4 ta karavot tugma
   - **Karavot 1 ni bosing** → "Meniki" tanlang (★ deraza yonida)
   - **Karavot 2** → "Band" tanlang
   - **Karavot 3** → "Bo'sh" tanlang
   - **Karavot 4** → "Bo'sh" tanlang
   - Pastda anti-cheat eslatma ko'rinadi

4. **"Xonangizni Tasdiqlang" yashil tugmani bosing**
   - **OneID modal** ochiladi
   - Telefon: `+998901111111`
   - "Davom etish" → OTP ekrani
   - OTP: `123456` (mock)
   - "Tasdiqlash" → success ✅

5. **Toast:** "Rahmat! Sizning ma'lumotingiz qabul qilindi."

---

## 4. JONLI KO'RSATISH — Web da o'zgarish (1 daqiqa) ⭐

**Bu — eng kuchli moment!**

1. Brauzerga qayting — 305-palata ekrani ochiq
2. **30 sekund kutmasdan** sahifani yangilang (F5)
3. **Karavot 3 va 4 endi YASHIL** (bo'sh) ko'rsatiladi
4. **"1 bemor tomonidan tasdiqlangan"** matn paydo bo'ldi
5. **"0 daqiqa oldin yangilandi"**

> "Mana! Bemor mobil app orqali tasdiq berdi → o'sha lahzada hammaga ko'rinmoqda. Bu — **crowdsourcing antikorruptsiya**. Hech qanday vositachi, qog'oz, korrupsion sxema yo'q."

---

## 5. Anti-cheat namoyishi (30 sek)

> "Yolg'on ma'lumot kiritmasligini qanday ta'minlaymiz?"

1. **OneID** — har bir tasdiq elektron hukumat orqali bemor identifikatsiyasi (xakatonda mock, prod da real)
2. **24-soatlik dedup** — bitta bemor 1 xona uchun 24 soatda 1 ta tasdiq (terminalda ko'rsatish):
   ```bash
   curl -X POST http://localhost:8000/api/v1/confirmations/ ...
   # → 409 DUPLICATE_CONFIRMATION
   ```
3. **Konsensus** — 2+ bemor tasdiqlasa "tasdiqlangan", aks holda "ko'pchilik fikri"
4. **IP + user-agent log** — har bir tasdiq qaydda saqlanadi
5. **Qonuniy javobgarlik** — anti-cheat eslatma har doim ko'rinadi

---

## 6. Texnik arxitektura (45 sek — agar so'rashsa)

```
┌────────────┐   ┌─────────────┐   ┌──────────────┐
│ React Web  │   │ Flutter App │   │  Admin       │
│ (qarindosh)│   │ (bemor)     │   │  (panel)     │
└─────┬──────┘   └──────┬──────┘   └───────┬──────┘
      │                 │                  │
      └────────┬────────┴──────────────────┘
               │ REST API (JSON)
       ┌───────▼────────┐
       │ Django + DRF   │
       │ + JWT (OneID)  │
       │ + 11 endpoint  │
       └───────┬────────┘
               │
       ┌───────▼────────┐
       │ PostgreSQL     │
       │ (yoki SQLite)  │
       └────────────────┘
```

**Stack:** Django 5, React 18 + Vite + Tailwind, Flutter 3 + Riverpod
**Real-time:** 30s polling (yetarli, WebSocket xakatonda overkill)
**Test:** 26/26 backend test pass, Flutter analyze 0 issues

---

## 7. Yakuniy gap (30 sek)

> "Shifo-Radar — bu davlat byudjetidan bir tiyin ham olmasdan, bemorlarning o'zi shifoxonalarni shaffof qiladigan platforma. Korrupsiyaga qarshi — eng arzon, eng oson, eng tez yechim. Birinchi 3 ta shifoxonada 480 ta karavot real vaqtda kuzatuvda. Keyingi qadam — butun mamlakat bo'ylab kengaytirish. **Rahmat!**"

---

## Demo paytida foydali ma'lumotlar

**Demo ma'lumotlari:**
- 3 ta shifoxona: RIKM (Toshkent), SVKTM (Samarqand), BVSh (Buxoro)
- Har biri: 4 qavat × 10 palata × 4 karavot = **160 karavot**
- Jami: **480 karavot real vaqtda kuzatiladi**

**Demo OneID:**
- Telefon: `+998901111111` / `+998902222222` / `+998903333333`
- OTP: har doim **`123456`** (xakaton uchun mock)

**Demo QR token (palata 305):**
- `29d5280e3bf84aa9abb8071a387241f6`
- URL formati: `https://shifo-radar.uz/r/{token}`

**Backend URL:** http://localhost:8000/api/v1
**Frontend URL:** http://localhost:5173
**Admin panel:** http://localhost:8000/admin/ (superuser kerak)

---

## Demo nazorat ro'yxati (oldindan tekshiring)

- [ ] Backend ishlayapti (`/health/` 200 qaytaryapti)
- [ ] Frontend ochiladi va shifoxonalar ko'rinadi
- [ ] Flutter app emulator/qurilmada ishga tushgan
- [ ] OneID modal ishlayapti (123456 qabul qilyapti)
- [ ] Tasdiq POST 201 qaytaryapti
- [ ] Web da yangilanish ko'rinyapti (F5 bilan)
- [ ] QR token tayyor (palata 305 uchun: `29d5280e3bf84aa9abb8071a387241f6`)
- [ ] Brauzer telefon emulatori (yoki haqiqiy telefon) bor
- [ ] Internet ulanishi (CDN font, icon)
