# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter pub get                                        # Install / sync dependencies
flutter run -t lib/main_dev.dart --flavor dev          # Run dev flavor (local backend)
flutter run -t lib/main_prod.dart --flavor prod        # Run prod flavor (live backend)
flutter analyze                                        # Static analysis (dart analyze lib/ also works)
flutter test                                           # Run all tests
flutter test test/widget_test.dart                     # Run a single test file
flutter build apk --flavor dev -t lib/main_dev.dart    # Android dev APK
flutter build apk --flavor prod -t lib/main_prod.dart  # Android prod release APK (signed, see Release signing below)
flutter build ios -t lib/main_prod.dart                # iOS release build (no flavor — see Flavors below)
```

## Flavors

Two flavors, each with its own Dart entry point and `AppConfig` (`lib/core/config/app_config.dart`, `lib/flavors.dart`):

| Flavor | Entry point | `applicationId` | `appName` | `baseUrl` |
|---|---|---|---|---|
| `dev` | `lib/main_dev.dart` | `com.example.pet_carrying_app.dev` | Paw Care (Dev) | `http://localhost:3000` |
| `prod` | `lib/main_prod.dart` | `com.example.pet_carrying_app` | Paw Care | `https://backend-paw-eo3p.onrender.com` |

`lib/main.dart` is the plain entry point (defaults to dev config) used by `flutter test` / `flutter run` without `-t`; prefer the explicit `-t lib/main_<flavor>.dart` form above for anything flavor-sensitive.

Android product flavors are declared in `android/app/build.gradle.kts` (`flavorDimensions`/`productFlavors`) and must be passed via `--flavor`. **iOS has no per-flavor Xcode scheme yet** — only one `Runner` scheme exists, so iOS builds always use the entry-point's baked-in config (`-t lib/main_prod.dart`) without a `--flavor` flag. Add `dev`/`prod` schemes and xcconfigs if iOS flavor parity is needed later.

## Architecture

Four-layer clean architecture with **GetX** for state management, DI, and navigation. Dependencies always flow inward: `presentation → domain ← data`, with `core` as a shared utility belt.

```
lib/
├── core/          Stateless helpers used by any layer
│   ├── network/   ApiClient (Dio singleton), ApiEndpoints (URL constants)
│   ├── errors/    AppException hierarchy, Failure sealed class
│   └── utils/     DateFormatter
├── domain/        Pure Dart — no Flutter, no Dio, no JSON
│   ├── entities/  PetBooking (Equatable value object with computed totalDays/totalCharge)
│   ├── repositories/  BookingRepository (abstract interface)
│   └── usecases/  GetBookingsUseCase, AddBookingUseCase (callable via call())
├── data/          Implements domain interfaces, owns all I/O
│   ├── models/    PetBookingModel extends PetBooking — adds fromJson/toJson/fromEntity
│   ├── datasources/
│   │   ├── remote/  BookingRemoteDataSourceImpl — Dio calls, throws NetworkException
│   │   └── local/   BookingLocalDataSourceImpl — in-memory cache, seeded with mock data
│   └── repositories/  BookingRepositoryImpl — tries remote, falls back to local cache
├── presentation/
│   ├── theme/       AppColors, AppTypography, AppSpacing, AppTheme (see Design Tokens below)
│   ├── controllers/ GetxController subclasses — one per feature
│   ├── views/       Screens organised by feature: home/, booking/, history/
│   └── widgets/     Shared: BookingCard, AppButton (primary/secondary/ghost variants)
└── di/            app_binding.dart — GetX Bindings, registered in GetMaterialApp(initialBinding:)
```

### Data flow

`View` wraps reactive reads in `Obx(() => ...)` → reads from `BookingController` (GetxController with `.obs` fields) → controller calls a UseCase → UseCase calls `BookingRepository` (interface) → `BookingRepositoryImpl` calls `BookingRemoteDataSource`, falls back to `BookingLocalDataSource` on `AppException`.

### State management (GetX)

- Reactive fields use `.obs`: `RxList`, `Rx<ViewState>`, `RxString`
- Wrap any widget that reads `.obs` values in `Obx(() => widget)`
- Access a controller anywhere via `Get.find<BookingController>()`
- `onInit()` is the right place for initial data fetches — called automatically when controller is first found

### Dependency injection (GetX Bindings)

`AppBinding` in `lib/di/app_binding.dart` registers everything with `Get.lazyPut(..., fenix: true)`. `fenix: true` means the dependency is recreated if disposed and requested again. Registration order: `ApiClient` → datasources → repository → usecases → controllers.

### Navigation (GetX)

No `BuildContext` needed. Use `Get.to(() => Screen())` to push, `Get.back()` to pop.

### GetX quick-reference

| Task | How |
|---|---|
| Read reactive data in UI | Wrap widget in `Obx(() => ...)` |
| Access a controller | `Get.find<BookingController>()` |
| Navigate forward | `Get.to(() => SomeScreen())` |
| Navigate back | `Get.back()` |
| Declare reactive state | Append `.obs` — `false.obs`, `<PetBooking>[].obs` |
| Update reactive value | `myVar.value = newValue` |

Adding new reactive state to a controller always follows the same pattern:

```dart
// In the controller
final RxBool isFavorite = false.obs;

// In the view — inside Obx
Obx(() => Icon(
  controller.isFavorite.value ? Icons.star : Icons.star_border,
))
```

`ViewState` enum (`idle / loading / success / error`) is declared in `booking_controller.dart` and used by views inside `Obx` to switch between loading spinner, error message, empty state, and list.

### API integration

Set `ApiEndpoints.baseUrl` in `lib/core/network/api_endpoints.dart`. The repository already handles the remote→cache fallback. When the API is live, `BookingLocalDataSourceImpl`'s seed data is overwritten on first successful fetch.

## Release signing (Android)

`android/app/build.gradle.kts` signs `release` builds with `android/key.properties` + `android/app/upload-keystore.jks` when present, falling back to the debug key when they're absent (so a fresh checkout without the keystore still builds via `flutter run --release`).

- Both `key.properties` and `*.jks` are gitignored — **never commit them**. `android/key.properties.example` documents the expected keys (`storePassword`, `keyPassword`, `keyAlias`, `storeFile`).
- The keystore is the app's permanent Play Store signing identity. **Back it up somewhere durable outside git** (password manager / secrets vault) — losing it means you can never ship an update under the same identity again.
- To regenerate from scratch (only if no keystore exists yet or you're starting a new app identity):
  ```bash
  keytool -genkeypair -v -keystore android/app/upload-keystore.jks \
    -keyalg RSA -keysize 2048 -validity 10000 -alias upload
  ```
  then fill in `android/key.properties` from `android/key.properties.example`.
- CI: provide `key.properties` and the `.jks` as secrets/artifacts at build time rather than committing them.

## Design Tokens

All tokens live in `lib/presentation/theme/`. Use these classes directly — never hardcode colors or sizes.

### Color Palette (`AppColors`)

| Token | Hex | Usage |
|---|---|---|
| `sageDeep` | `#2D4A3E` | AppBar, buttons, headers |
| `sageMid` | `#4A7C6F` | Icons, secondary text |
| `creamWarm` | `#FAF6F0` | Scaffold background |
| `amberAccent` | `#E8904A` | FAB, highlights |
| `blushSoft` | `#F2E8E0` | Cards, input fills |
| `ink` | `#1A2420` | Body text |
| `mist` | `#B8C9C3` | Borders, disabled, micro text |

### Typography (`AppTypography`)

Fonts loaded at runtime via `google_fonts` — no local font assets needed.

| Style | Font | Weight | Size |
|---|---|---|---|
| `display` | Fraunces (opsz 144) | 700 | 36px |
| `sectionHeader` | Fraunces | 600 | 22px |
| `bodyLarge` | DM Sans | 400 | 16px |
| `bodyMedium` | DM Sans | 500 | 14px |
| `dataMono` | DM Mono | 500 | 13px |
| `micro` | DM Sans | 400 | 11px |

### Spacing & Theme

| Class | Contents |
|---|---|
| `AppSpacing` | `xs/sm/md/lg/xl/xxl` → 4/8/16/24/32/48px |
| `AppTheme` | `AppTheme.light` — pass to `GetMaterialApp(theme:)` |
