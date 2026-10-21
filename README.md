# Orvex Ai: User App

Flutter (Android) client for **Orvex Ai**, a multi-tenant, AI-assisted commerce automation platform for Facebook Messenger and WhatsApp Business sellers.

> **Phase 1 scope.** This repository contains the **User App only**. The PHP/MySQL backend, Admin App, Meta webhooks and courier API integrations are **not** included. The app is built so the backend can be connected later by setting one URL.

- Flutter, Dart (null-safe), Material 3, light and dark themes
- English and Bangla (Hind Siliguri bundled for Bangla)
- State: `provider` + `ChangeNotifier`. No repositories or use-case layers.
- Application ID: `com.orvex.user`

---

## 1. Install Flutter

1. Install the Flutter SDK (stable channel): <https://docs.flutter.dev/get-started/install>
2. Install Android Studio (or the command-line Android SDK) and a **JDK 17**.
3. Accept licences: `flutter doctor --android-licenses`
4. Check your setup: `flutter doctor`

## 2. Run the project

```bash
flutter pub get
flutter run
```

With a backend and Google configured (see sections 5 and 6):

```bash
flutter run \
  --dart-define=API_BASE_URL=https://api.example.com/v1 \
  --dart-define=GOOGLE_SERVER_CLIENT_ID=1234567890-abc.apps.googleusercontent.com
```

### Quality checks

```bash
dart format lib test
flutter analyze
flutter test
```

## 3. Build an APK

```bash
flutter build apk --debug      # build/app/outputs/flutter-apk/app-debug.apk
flutter build apk --release    # build/app/outputs/flutter-apk/app-release.apk
```

Pass the same `--dart-define` values as above for builds that should talk to a backend.

**Release signing.** Without a keystore, release builds fall back to the debug key (fine for testing, **not** for the Play Store). To sign properly, create `android/key.properties` (it is git-ignored):

```properties
storeFile=/absolute/path/to/upload-keystore.jks
storePassword=...
keyAlias=upload
keyPassword=...
```

**CI.** `.github/workflows/build-user-app.yml` formats, analyzes, tests and builds a release APK on every push, then uploads it as an artifact. Set the repository **variables** `API_BASE_URL` and `GOOGLE_SERVER_CLIENT_ID` (public identifiers, not secrets) if you want them baked in.

## 4. Demo mode vs real mode

| Mode | How you get there | What you see |
|---|---|---|
| **Demo** | Welcome screen > **Explore with demo data** | Clearly labelled sample data (a "Demo data" banner on every data screen). Nothing leaves the device. |
| **Real** | Log in / register / Google with a configured backend | Only data returned by the API. With no backend you see empty states, **never** demo data. |

Demo data lives in `lib/services/demo_data.dart`, separate from the real API layer (`lib/services/data_api.dart`).

## 5. Configure the backend URL

The backend base URL is supplied at build time, never hardcoded:

```bash
--dart-define=API_BASE_URL=https://api.yourdomain.com/v1
```

Requests are sent with `Authorization: Bearer <platform session token>`. A `401` on an authenticated call clears the session and returns the user to the login screen with an "session expired" notice. Endpoint paths are in `lib/core/api_endpoints.dart`:

`/auth/login`, `/auth/register`, `/auth/google`, `/auth/logout`, `/auth/refresh`, `/auth/forgot-password`, `/auth/reset-password`, `/auth/change-password`, `/auth/me`, `/business`, `/agent`, `/agent/test`, `/agent/knowledge`, `/dashboard`, `/conversations`, `/comments`, `/comments/rules`, `/comments/logs`, `/products`, `/orders`, `/couriers`, `/shipments`, `/automations`, `/insights`, `/integrations`, `/subscription`, `/plans`, `/notifications`, `/team`, `/profile`.

Models in `lib/models/` parse defensively (missing or malformed fields fall back to safe defaults). The session token is stored with `flutter_secure_storage`.

## 6. Configure Google Sign-In

The app uses the official `google_sign_in` package (v7 API). **No credentials are included.** Until you configure them, the Google button shows a "setup required" notice and does nothing else. A local Google account selection is **never** treated as being logged in.

**Intended flow**

1. User taps **Continue with Google**.
2. Google's account picker runs on the device.
3. The app obtains a Google **ID token**.
4. The app sends it to `POST {API_BASE_URL}/auth/google` as `{ "id_token": "..." }`.
5. The backend verifies the token (see below), then creates or finds the platform account.
6. The backend returns `{ "token": "<platform session token>", "user": { ... } }`.
7. The app stores that platform token and opens business setup or the dashboard.

**Google Cloud setup**

1. Create a project at <https://console.cloud.google.com/> and configure the **OAuth consent screen**.
2. Create an **OAuth client ID, type Android**:
   - Package name: `com.orvex.user`
   - SHA-1 fingerprint of **each** signing key you use (debug, release/upload, and Play App Signing key if used).
3. Create a second **OAuth client ID, type Web application**. Its client ID is the **server client ID**. This is what you pass as `GOOGLE_SERVER_CLIENT_ID`, and it is the audience the backend must verify.

Get fingerprints:

```bash
# debug key
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
# release key
keytool -list -v -keystore /path/to/upload-keystore.jks -alias upload
# or, from the project:
cd android && ./gradlew signingReport
```

> The Android client and the Web client must be in the **same Google Cloud project**. A wrong package name or missing SHA-1 is the most common cause of sign-in error code 10 / `DEVELOPER_ERROR`.

**Backend verification (required, future PHP backend)**

1. Verify the ID token signature against Google's public keys (<https://www.googleapis.com/oauth2/v3/certs>), for example with `google/apiclient` (`verifyIdToken`).
2. Check `aud` equals your **Web** client ID, `iss` is `accounts.google.com` or `https://accounts.google.com`, `exp` has not passed, and `email_verified` is true.
3. Create or look up the user by the verified `sub` / `email`. Never trust an email sent separately by the client.
4. Issue your **own** session token. Do not reuse the Google token as the session.
5. Never put a client secret in the app.

## 7. What is demo-only vs what needs the backend

| Area | Without backend | Needs backend / third party |
|---|---|---|
| Login, register, forgot/reset/change password | Form validation only. Submitting reports that the backend is not configured. | Auth endpoints |
| Google Sign-In | "Setup required" state | Google OAuth config + `/auth/google` |
| Onboarding | Works locally, kept in memory | `/business`, `/agent` to persist |
| Dashboard, Inbox, Orders, Products | Demo data in demo mode; empty states otherwise | All real data |
| Manual reply, order status change, product save | Local preview only. The UI states it is **not saved/sent**. Messages and statuses are not marked as delivered. | Persistence + Meta delivery |
| AI agent replies / test | Not available. The test screen says a backend and AI provider are required. | Backend + AI provider (keys stay server-side) |
| Facebook comments (reply, private message) | List and rule editor are local. Posting is refused with an explanation. | Meta app review, permissions, backend |
| Messenger / WhatsApp / comment connection | "Not connected" with setup steps. No tokens in the app. | Meta OAuth handled by the backend |
| Couriers: Pathao, Steadfast, RedX | "Not connected". No bookings or tracking are invented. | Backend + official courier API credentials |
| Subscription / billing | Plans display. Upgrades are never shown as completed. | Billing backend |
| Team invites | Listed as "pending" only | Backend invitation email |

**Not implemented by design:** website live chat. The inbox is for existing **Facebook Messenger** and **WhatsApp Business** conversations only.

## 8. Project structure

```
lib/
  main.dart, app.dart        app entry, providers, theme, routing gate
  core/                      config, theme, localisation (EN/BN), endpoints
  models/                    data models + enums (defensive fromJson)
  services/                  api client, auth, data layer, demo data, storage
  screens/                   auth, onboarding, home, inbox, facebook, ai,
                             products, orders, courier, automation,
                             integrations, account
  widgets/                   reusable cards, inputs, dialogs, chips, states
  utils/                     validators, formatting
test/                        logic, widget and full-screen layout tests
assets/fonts/                Hind Siliguri, Inter
```

## 9. Testing notes

- `test/all_screens_test.dart` renders every screen in English and Bangla, light and dark, with demo and empty data, at 1.5x text scale on a 360x640 phone, and fails on any layout overflow.
- Auth, API client, data-layer honesty (nothing is reported as saved/sent without confirmation) and translation parity (every English key exists in Bangla) are covered.

## 10. Security notes

- No API keys, Meta tokens, OAuth secrets or AI provider keys are in the app.
- Only the platform session token is stored, in secure storage.
- Release builds include the `INTERNET` permission; cleartext HTTP should not be used. Use HTTPS for `API_BASE_URL`.

## Licence and branding

The Orvex Ai name, mark and UI are original to this project; no third-party branding or proprietary assets are used. Fonts are open source (SIL OFL).
