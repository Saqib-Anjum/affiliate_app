# CSMS — Flutter App (Admin + Student)

A single Flutter app serving both roles (`admin` and `student`) of the Client & Student Management
System, talking to the NestJS backend (`../backend`).

## ⚠️ Important: not yet compiled/verified
Unlike the backend (NestJS) and admin dashboard (Next.js) in this project, **there is no Flutter/Dart
SDK available in the environment this app was written in**, so this code has been written carefully
by hand but has *not* been run through `flutter analyze`, `flutter pub get`, or `flutter build`. Please
run the following before trusting it fully:
```bash
flutter pub get
flutter analyze
flutter run --dart-define=API_BASE_URL=http://localhost:5000/api
```
Fix up anything the analyzer flags — most likely candidates are minor API surface drift in
`share_plus`/`go_router`/`fl_chart` versions (pin exact versions in `pubspec.yaml` if you hit issues).

## Setup
```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:5000/api
```
The base URL defaults to `http://localhost:5000/api` if not overridden (see `core/constants/app_constants.dart`).

## Architecture
```
lib/
├── core/            theme, constants, formatters, validators, generic widgets (buttons, states, search)
├── models/          User, Client, Meeting, Recording, BankDetails, Payout, DashboardStats
├── services/        ApiClient (dio + secure-storage + auto token refresh), one service per domain
├── providers/       Riverpod: auth, dashboard, clients, meetings, recordings, payments, students
├── screens/         auth, dashboard, clients, meetings, recordings, payments, students, profile, shell
├── widgets/         StatCard, ClientCard, ClientStatusBadge, EmergencyBadge, MeetingCard, RecordingCard,
│                    QuoteShareSheet
└── main.dart        MaterialApp.router + GoRouter with auth-aware redirects
```
There is no separate `repositories/` layer — each `services/*.dart` file both calls the API and shapes
the result into models, which is what a repository would otherwise do here. Kept as one layer to avoid
pointless indirection.

## How the business rules show up here
- **Closed sale / revenue / payout are never computed in this app.** `dashboard_service.dart` just
  displays exactly what `/dashboard/student` or `/dashboard/admin` returns — the aggregation happens
  server-side (see backend README). This app also never posts a `saleAmount`/`payoutAmount` change
  without going through `PATCH /clients/:id/status`, so those numbers cannot drift from what the
  backend considers authoritative.
- **Ownership**: every list call goes through the backend's already-scoped endpoints; there is no
  student-only filtering logic here to keep in sync — if the backend scopes it, so does the app.
- **Emergency Meeting**: a plain boolean on `Client` (`emergencyMeeting`), added to the backend schema
  specifically to support this screen. It only affects visibility/highlighting, never the dashboard math.
- **Quote / Pricing**: `discount` and `finalPrice` (quote − discount) are computed and shown client-side
  for the sharing flow only. `saleAmount` — the number that actually feeds revenue — is a separate field
  the student sets explicitly, so a discount typed into the quote box can never silently change revenue.

## Quote sharing (spec section 8/27)
`QuoteShareSheet` builds a formatted text quote and offers:
- WhatsApp (`wa.me` deep link)
- Email (`mailto:`)
- SMS (`sms:`)
- Native share sheet (`share_plus`)
- Copy to clipboard

**PDF quote generation/download is not implemented** — it would need the `pdf`/`printing` packages,
which were left out to keep this build's risk down given it could not be compiled here. Straightforward
to add: render the same fields `QuoteShareSheet._buildMessage()` already assembles into a `pw.Document`.

## Known simplifications (documented, not hidden)
- **Activity History** (spec section 23) is not implemented as a persisted audit trail — the backend
  doesn't have that endpoint yet either (see backend README's "not yet built"). Adding it is a backend
  schema + a `GET /clients/:id/activity` endpoint, then a simple ListView here.
- **In-app notifications** (spec section 22) are not implemented as a push/local-notification system.
  The pieces needed to compute them (upcoming meetings, emergency clients) are already fetched by the
  dashboard providers; wiring a notification badge/list from that data is straightforward but not done.
- **Sample/mock data**: this app always talks to the real backend rather than shipping a mock-data mode,
  since a working backend is included in this project and mocking would risk the two contracts drifting.
- Admin's Payments/Payouts pages are one tap deeper (from Dashboard/Profile) rather than in the bottom
  nav bar, to avoid overcrowding it — the spec's 8-item admin nav does not fit comfortably in a bottom bar.

## Security notes
- Tokens live in `flutter_secure_storage`, never `SharedPreferences`.
- Bank account number / IBAN / mobile wallet number are only ever rendered masked, exactly as the
  backend returns them — this app never has the plaintext values to display, even transiently.
- No Zoom credentials exist anywhere in this app; `MeetingService` only ever talks to this project's own
  backend, which performs the actual Zoom Server-to-Server OAuth calls.
