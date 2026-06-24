# Paw — Flutter Integration Guide

**Status:** Email/Password login & registration ✅ implemented and working. Google Sign-In ⚠️ designed and working on the backend, **not yet implemented in the app**.

Base URL: `AppConfig.instance.baseUrl` → `http://localhost:3000` (dev, [app_config.dart:20](lib/core/config/app_config.dart#L20)) / `https://your-api.com` (prod placeholder — update before shipping).

All authenticated endpoints require:
```
Authorization: Bearer <jwt_token>
```
attached automatically by `ApiClient`'s request interceptor ([api_client.dart:21](lib/core/network/api_client.dart#L21)) when a token is stored in `flutter_secure_storage` under the key `jwt_token` ([api_client.dart:43](lib/core/network/api_client.dart#L43)).

---

## 1. Where things already live

This app is a working GetX clean-architecture app, not a starter template — see [CLAUDE.md](CLAUDE.md) for the full layout. The pieces relevant to auth:

| Layer | File | Role |
|---|---|---|
| presentation | [`auth_wrapper.dart`](lib/presentation/views/auth/auth_wrapper.dart), [`login_screen.dart`](lib/presentation/views/auth/login_screen.dart), [`register_screen.dart`](lib/presentation/views/auth/register_screen.dart) | UI + form validation |
| presentation | [`auth_controller.dart`](lib/presentation/controllers/auth_controller.dart) | `.obs` state: `isChecking`, `isLoggedIn`, `isLoading`, `currentUser`, `errorMessage` |
| domain | `lib/domain/usecases/{login,register,logout,get_current_user}_usecase.dart` | Thin call-throughs to `AuthRepository` |
| domain | [`auth_repository.dart`](lib/domain/repositories/auth_repository.dart), [`user.dart`](lib/domain/entities/user.dart) | Interface + `User` entity (`userId, email, fullName, role, picture`) |
| data | [`auth_repository_impl.dart`](lib/data/repositories/auth_repository_impl.dart) | Saves/clears token via `ApiClient`, delegates HTTP to the data source |
| data | [`auth_remote_datasource.dart`](lib/data/datasources/remote/auth_remote_datasource.dart) | Actual Dio calls to `/auth/login`, `/auth/register`, `/auth/me` |
| data | [`user_model.dart`](lib/data/models/user_model.dart) | `UserModel.fromJson` |
| core | [`api_client.dart`](lib/core/network/api_client.dart), [`api_endpoints.dart`](lib/core/network/api_endpoints.dart) | Dio instance, secure-storage token, endpoint constants |
| di | [`app_binding.dart`](lib/di/app_binding.dart) | Wires all of the above; `AuthController` is `Get.put` eagerly so `AuthWrapper` can read it on the first frame |

`AuthWrapper` is the app's root widget: spinner while `isChecking` is true, then `LoginScreen` or `AppScreen` based on `isLoggedIn`.

---

## 2. Email + Password — done, and now more reliable

Registration and login were already correctly implemented on your side — the request/response shapes you built against haven't changed. What changed is on the **backend**, where two latent bugs meant every `/auth/register` and `/auth/login` call was returning a `500`:

1. The admin Google Sheets context had no fallback for cached OAuth tokens, so every request crashed with `Cannot read properties of null (reading 'access_token')`.
2. `JWT_SECRET` was never set in the backend's `.env`, so token signing threw on every otherwise-successful registration/login.

Both are fixed and verified end-to-end against the real Google Sheets backend. **No client-side changes are required** — `AuthRemoteDataSourceImpl`, `AuthRepositoryImpl`, and `AuthController` already match the contract:

- `POST /auth/register` → `{ full_name, email, password }` → `201 { token, user }`
- `POST /auth/login` → `{ email, password }` → `200 { token, user }`
- `GET /auth/me` (Bearer) → `200 { user }`

One thing worth knowing for later: the `user` object the backend returns also includes `actor_sheet_id` and `auth_provider`, which `UserModel.fromJson` ([user_model.dart:12](lib/data/models/user_model.dart#L12)) currently drops. Not a bug — the app doesn't need them yet — but `auth_provider` becomes relevant once Google Sign-In exists: `/auth/login` rejects a password login with `400 { error: "This account uses google login. Use Google Sign-In instead." }` if the account was created via Google, so you may eventually want to surface that distinction in the UI.

---

## 3. Google Sign-In — not implemented yet, here's what it needs

[`login_screen.dart:158`](lib/presentation/views/auth/login_screen.dart#L158) already has the button:
```dart
onPressed: () {}, // TODO: Google OAuth
```
It's a stub. There's no `google_sign_in` or `app_links` dependency in `pubspec.yaml`, no custom URL scheme registered in `android/app/src/main/AndroidManifest.xml` or `ios/Runner/Info.plist` (checked both — neither has any deep-link config beyond the default launcher intent-filter), and no `ApiEndpoints` entry for it.

On the backend, `GET /auth/google` → Google consent → `GET /auth/callback` is fully implemented and was just fixed (the `onUser` callback hit the same missing-token/`JWT_SECRET` bugs as §2). It's ready to be wired up, but it's a **browser-redirect flow**, not the native Google Sign-In SDK. That shapes what you need to build:

### What the backend does
On success it redirects the browser to:
```
{FRONTEND_URL}?token=<jwt>
```
`FRONTEND_URL` is currently **unset** in the backend's `.env`, so it defaults to `http://localhost:3000` — not usable as a mobile redirect target. It needs to be set to whatever custom scheme you register below (e.g. `paw://auth-callback`) before this works end to end. That's a one-line backend `.env` change on our side once you've picked a scheme — just tell us what it is.

On failure, the backend does not currently append an error code to the redirect — you'd see a direct error response from `/auth/callback` instead. If you need a specific failure contract (e.g. `paw://auth-callback?error=...`), flag it and we'll add it; it isn't built today.

### What the app needs
1. Add to `pubspec.yaml`: `app_links: ^6.3.2` (catch the redirect) and `url_launcher: ^6.3.1` (open the consent screen in the system browser). Neither is currently a dependency.
2. Register a custom scheme, e.g. `paw://auth-callback`:
   - Android: add an `<intent-filter>` with `<data android:scheme="paw" android:host="auth-callback"/>` to the launcher activity in `android/app/src/main/AndroidManifest.xml`.
   - iOS: add a `CFBundleURLTypes` entry to `ios/Runner/Info.plist`.
3. On tap, launch `${AppConfig.instance.baseUrl}/auth/google` with `launchUrl(..., mode: LaunchMode.externalApplication)` — this must be a real browser hand-off, not a Dio call, since the user has to interact with Google's consent screen.
4. Listen for the return via `AppLinks().uriLinkStream` (set up once — e.g. in `main.dart` or a small service registered in `AppBinding`). When `paw://auth-callback?token=...` arrives, pull `token` from `uri.queryParameters`, save it the same way `AuthRepositoryImpl` does (`ApiClient.saveToken`), then re-run the same check `AuthController` already does on startup (`GetCurrentUserUseCase` → `GET /auth/me`) so `currentUser`/`isLoggedIn` populate exactly like a password login does.

We did **not** build a native-SDK alternative (client-side `google_sign_in` + server-side ID-token verification) — that would need a new backend endpoint that doesn't exist today. If you'd rather have that smoother in-app UX instead of a browser hand-off, tell us and we'll add the endpoint; the redirect flow above is what's actually live right now.

---

## 4. API Reference (verified against current backend code)

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/auth/register` | — | `{ full_name, email, password }` → `201 { token, user }`. `409` if email exists, `422` on weak password (`{ error, details: [...] }`). |
| POST | `/auth/login` | — | `{ email, password }` → `200 { token, user }`. `401` on bad credentials, `400` if the account was created via Google. |
| GET | `/auth/google` | — | Redirects to Google's consent screen. Not yet wired up client-side — see §3. |
| GET | `/auth/me` | Bearer | `200 { user }`. `404` if the JWT's user no longer exists. |
| GET | `/services` | — | `200 { services }` — active services, sorted by `sort_order`. |
| GET | `/services/:id` | — | `200 { service }` or `404`. |
| POST / PATCH / DELETE | `/services[/:id]` | Bearer (admin) | Admin-only service management; `DELETE` is a soft delete (`active: false`). |
| GET | `/profile` | Bearer | `200 { profile }` — auto-creates an empty profile row on first call. `422` if the user has no `actor_sheet_id`. |
| PATCH | `/profile` | Bearer | `{ full_name?, phone?, avatar_url?, bio? }` → `200 { profile }`. `400` if no fields given. |
| POST | `/bookings` | Bearer | `{ pet_name, pet_type, service_id, start_date, end_date, daily_rate, notes? }` → `201 { booking }` (includes computed `nights`/`total`). `404` if `service_id` doesn't exist. |
| GET | `/bookings` | Bearer | `?status=&limit=&offset=` → `200 { bookings, total, limit, offset }`. |
| GET | `/bookings/active` | Bearer | `200 { bookings, total }` — `active` + `confirmed` only. |
| GET | `/bookings/:id` | Bearer | `200 { booking }` or `404`. |
| PATCH | `/bookings/:id` | Bearer | `{ notes?, status: 'cancelled' }` → `200 { booking }`. `409` if already `cancelled`/`completed`. |

### Error response shape
```json
{ "error": "Human-readable message", "details": ["..."] }
```
`details` is only present on `422` validation errors. Status codes in use: `400` bad input · `401` unauthenticated · `403` forbidden · `404` not found · `409` conflict · `422` unprocessable · `500` server error.

---

## 5. Backend commands (for reference, run from `paw_sheetDB/`)

```bash
# Seed services into the admin sheet (run once)
pnpm db:seed seeds/admin.ts --skip-existing

# Create mock user accounts for testing
pnpm db:mock-users 3

# Start the API server
pnpm dev
```
