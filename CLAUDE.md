# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Flutter customer app for the NowDelivery platform (`nowdelivery_user_app`). Dart SDK `^3.11.4`. Portrait-only, ships Arabic (`ar-EG`) and English (`en-US`).

## Common commands

```bash
flutter pub get                  # install deps
flutter run                      # run on attached device / emulator
flutter analyze                  # lint (flutter_lints, see analysis_options.yaml)
flutter test                     # run all tests
flutter test test/features/cart/cart_model_test.dart   # run a single test file

# Regenerate flutter_gen output (asset & font classes) after adding assets:
dart run build_runner build --delete-conflicting-outputs

# Regenerate the native splash after changing assets or config in pubspec.yaml:
dart run flutter_native_splash:create

# QA build with the Chucker network inspector (toast per request + "Network inspector" row on Profile):
flutter build apk --release --dart-define=CHUCKER=true
flutter build ipa --dart-define=CHUCKER=true

# Home frame-time benchmark — real device, profile mode; writes build/perf/<label>/*.json:
PERF_LABEL=<label> flutter drive --profile --no-dds --keep-app-running \
  --driver=test_driver/perf_driver.dart --target=integration_test/home_perf_test.dart -d <device>
```

**Never pass `CHUCKER=true` to a store build.** Chucker saves every request in full, tokens included, and anyone holding the phone can share them. It also slows every response, so don't judge performance on a Chucker build. Without the flag, none of it runs (`ChuckerInterceptor.enabled` in `core/dio/interceptors/chucker_interceptor.dart`).

The benchmark (`integration_test/home_perf_test.dart`) needs `--no-dds` (its timeline connection fails behind DDS) and `--keep-app-running` (otherwise `flutter drive` uninstalls the app, session and location grant included). Grant the location prompt by hand before the first run. Emulator raster numbers measure the host GPU; judge on a phone.

**`frame_count` is not app demand.** The harness runs under the `fullyLive` frame policy (without it the app's animations never advance), and under that policy the test binding requests a new frame after every frame it draws, so it renders every vsync by itself: a static screen reads ~600 frames / 10 s at 60 Hz. `app_animation_frame_count`, next to it in each JSON, counts the frames in which an app ticker ran; read that one for idle work. It leaves out one-off rebuilds with no ticker. The near-empty frames also sit in every scenario's averages and missed-budget counts; the worst-frame numbers are mostly unaffected.

Windows/PowerShell: same commands, no shell-specific tweaks needed.

## Architecture

### Layout

```
lib/
  main.dart            # async init (prefs, Hive, DI) → DevicePreview → LocalizationInit → ProviderScope → NowUserApp
  my_app.dart          # MaterialApp.router; wires localization, themes, routerConfig (go_router)
  core/                # shared, cross-feature code (see below)
  features/<feature>/  # feature-scoped code
```

Features (24): `address`, `auth`, `cart`, `categories`, `checkout`, `favourites`, `home`, `main`, `notifications`, `orders`, `payment_methods`, `personal_information`, `products`, `promotion`, `promotions`, `purchase_vouchers`, `search`, `settings`, `stores`, `support`, `support_chat`, `tracking_order`, `wallet`, `welcome`.

The shape of a feature is three layers: `presentation/` (`screens/`, `widgets/` or `components/`, and — where present — `controllers/`), `viewmodel/`, and `data/` (`datasources/`, `models/`, `repo/`).

Most features are now fully wired. The UI-only ones left are `main` (the tab shell), `notifications` (hardcoded mock strings), `payment_methods`, `promotions` and `support_chat`. `search` has a viewmodel but no `data/` (it reads the shared `core/data/repo/recent_keywords_repo.dart`); `tracking_order` has `data/` but no viewmodel.

### Feature imports

Features do **not** use interface/barrel files — import feature files directly by their full path (e.g. `features/stores/presentation/screens/store_details_screen.dart`). Do not create `<x>_interface.dart` files; this pattern was deliberately removed.

**Known deviations (fix opportunistically, don't copy):**
- `support_chat` is flat — `support_screen.dart` and `components/` sit directly in the feature root with no `presentation/` layer. Restructure toward the standard layout when doing non-trivial work in it.
- `purchase_vouchers` has `data/` and `viewmodel/` but no `presentation/`; its widgets live in `promotions/presentation/widgets/vouchers/`. `promotion` (singular, wired) and `promotions` (plural, UI-only) are two different features — check which one you mean.
- All colors come from the theme via `context.colors`; the former `AppColors` palettes are gone.

### Data flow pattern (see `features/categories/`)

Screen → viewmodel → repo → API service → shared Dio singleton:

- **API service** (`data/datasources/remote/api/<x>_api_service.dart`): raw requests only, gets `Dio` from `DioFactory.getDio()`, returns the raw `Response`. Endpoint paths/queries live in a sibling `<x>_endpoints.dart` constants class.
- **Repo** (`data/repo/<x>_repo.dart`): all parsing and error handling. Every method returns `Either<Failure, T>` (dartz). Checks `ConnectionChecker.isConnected` first (the one deliberate exception is `AuthRepo.logout()` — see [Session & logout](#session--logout)); maps errors through `ApiErrorHandler.extractErrorMessage`. `Failure.message` is either a `LangKeys` key or a raw server message — callers apply `.tr()`, which leaves non-key strings untouched.
- **Viewmodel** (`viewmodel/get_<x>_vm.dart`): a `StateNotifier<AsyncValue<T>>` exposed via `StateNotifierProvider.autoDispose`, kicked off on first watch (`..getX()` in the provider factory). Screens `ref.watch` the provider and render the `AsyncValue`; guard state writes with `if (!mounted) return;` after awaits.
- **`.autoDispose` is the default — dropping it has session consequences.** A kept-alive provider survives navigation *and* survives logout, so it must be classified in `sessionScopedProviders` (see [Session & logout](#session--logout)). Paginated lists extend `PaginatedViewModel` (`core/viewmodel/pagination/`) rather than hand-rolling page state.

### `lib/core/` conventions

- `dio/` — `DioFactory` (single shared `Dio` singleton), `DioConstants` (base URL, timeouts, default JSON headers), `ApiErrorHandler`, `interceptors/`. All API services must use `DioFactory.getDio()` — never construct their own `Dio`. That Dio is a `DedupingDio`: identical reads in flight are joined and a successful read is reused for 3 s, and any write drops all of it (rapid sheet open/close used to hit 429). `AppRefreshIndicator` forgets the reused answers before a pull, so a pull always reaches the server, then ignores pulls (no spinner) for the same 3 s. A read sent as a `POST` must carry `extra: {DedupingDio.readOnlyFlag: true}` (see checkout `preview`), or it counts as a write.
- `errors/` — `failures/failure.dart` (the `Failure` type used in `Either`), `exceptions/` (network, cache). Shared error types live here; feature-specific ones stay in the feature.
- `routing/` — navigation uses the **go_router** package (Navigator 1.0/2.0 named routes were fully removed). `app_routes.dart` holds route-name constants (kebab-case strings, also used as URL paths); `app_router.dart` exposes `AppRouter.router`, a `GoRouter` wired into `MaterialApp.router` via `routerConfig`. **New screens must be added in both files** (a name constant + a `GoRoute` with `name` and `path: '/<name>'`). Navigate only with go_router context extensions: `context.pushNamed(AppRoutes.x)` to push, `context.goNamed(...)` for stack resets (splash → onboarding → main), `context.pop()` / `context.canPop()` for back. Route arguments go through `extra:` and are read from `state.extra` in the route builder (see the `addressDetailsScreen` case). Never use `Navigator.push/pop/pushNamed` directly.
- `localization/` — `easy_localization` config (`LocalizationInit` in `configs.dart`), `LangKeys` constants, JSON at `assets/json/lang/{ar-EG,en-US}.json`. Wrap keys with `.tr()`.
- `presentation/` — the design system. `theme/` (light + dark), `styles/` (radii, borders, shadows, text styles), `responsive/` (only `spacing_extension.dart` — the `.hSpace` / `.wSpace` gaps; there is no scaling layer), `assets/` (flutter_gen output: `assets.gen.dart`, `fonts.gen.dart`), plus shared `components/` and `widgets/` (organized by kind: `buttons/`, `text_fields/`, `sliders/`, `tab_bars/`, etc.).
- `caching/` — `SharedPrefManager` (static wrapper, `init()` in `main.dart`), `CacheKeys` (**every** prefs key is declared here), and `TokenCacheService`, the single source of truth for the three session tokens. Never call `SharedPrefManager` with a literal key.
- `database/` — Hive. `HiveManager.init()` opens every box at startup; `HiveBoxes` / `HiveKeys` declare all names; `CachePurger` wipes the user-scoped boxes on logout. A new box must be declared in `HiveBoxes` **and** classified in `CachePurger` (see below).
- `viewmodel/` — shared view-model bases, notably `pagination/paginated_view_model.dart`.
- `data/` — shared models used by more than one feature (`ProductModel`, `StoreModel`, `CategoryModel`, `CouponModel`, `PaginationModel`, …) plus the recent-keywords repo. Check here before adding a model to a feature.
- `connection/`, `notifications/{local,remote}/`, `formatters/`, `enums/`, `params/`, `extensions/`, `utils/` — utility bins; check here before adding a new helper. `utils/di/` holds the `get_it` service locator (`setupServiceLocator()`, called from `main.dart`); `utils/auth_guard.dart` has `redirectGuestToLogin` for taps no route guard covers. Both files under `notifications/` are currently **empty** — push is not wired yet.
- `readme` (file, no extension) documents the intent: "shared between more than one main layer (data, view model or view)".

### State management

Riverpod (`flutter_riverpod`). Two flavors in use:
- **UI-only state**: providers under a feature's `presentation/controllers/` — see `lib/features/home/presentation/controllers/` (`Provider` for static lists, `StateProvider` for mutable index-style state, `.autoDispose` when tied to a screen).
- **Async/backend state**: `StateNotifier<AsyncValue<T>>` viewmodels under `viewmodel/` — see the data-flow pattern above.

### Session & logout

`authSessionProvider` (`features/auth/viewmodel/auth_session_vm.dart`) is the single orchestrator of session state. `SessionType` is `user` or `guest`, decided solely by whether an access token is cached (`TokenCacheService.hasAccessToken`) — there is no cached user id or user model. `resolveSession()` is called from exactly three places: the splash (boot), OTP verify (login), and logout.

`resolveSession()` clears the outgoing session whenever the session type actually changes and it is not cold boot — so login and logout both purge. Cold boot is exempt on purpose: it must keep the offline caches the repos are about to read.

**Two rules when adding anything user-scoped:**

1. **A kept-alive (non-`autoDispose`) provider holding user data must be listed in `sessionScopedProviders`** in `auth_session_vm.dart`. That list is iterated to invalidate providers, so listing it is what makes it die — nothing else does. `test/core/session/session_scoped_providers_test.dart` scans `lib/` and fails when a non-`autoDispose` provider is in neither that list nor the test's own `_appScoped` exemption set, so you cannot forget silently. If the provider is genuinely app-wide (locale, catalogue, device state), add it to `_appScoped` with a reason instead.
2. **A Hive box holding user data must be added to `CachePurger._userScopedBoxes`.** "Looks like catalogue" is not the test: the home feed and featured stores payloads embed the fetching user's `cart_quantity` and `is_favourite` per item and *are* purged, while app info and categories are not.

Two traps that already caused bugs here:

- **The "fetch only when empty" guard.** Several screens do `if (!ref.read(xProvider).hasValue) fetch();`. On a kept-alive provider that means a stale value is never refreshed — it is simply shown to the next user. Invalidating alone is not enough either: if the provider does not self-fetch and its screen can stay mounted across a login (the OTP screen *pops* back to a live shell), it strands on a loading shimmer. Either fetch it in `_loadUserDependencies()`, or listen for the session change on the screen (see `home_view.dart`, which needs a `BuildContext` for the locale so it must reload itself).
- **Logout always succeeds locally.** `AuthRepo.logout()` tells the server best-effort and clears the cached session regardless of the outcome — offline, 500, or an already-expired token. Do not reintroduce a connectivity gate or a 2xx requirement; a failed request used to leave the user signed in after asking to leave.

Forced logout: when a token refresh fails, `TokenRefreshInterceptor` clears the dead tokens and fires its static `onSessionExpired` hook, wired once in `my_app.dart` to `resolveSession()` + a go_router reset. It is gated on `hasAccessToken` so a guest's 401 is never mistaken for an expiry, and latched so a burst of concurrent 401s purges once.

### Assets & codegen

- `pubspec.yaml` declares asset folders under `assets/`; `flutter_gen_runner` generates typed accessors into `lib/core/presentation/assets/` (set via `flutter_gen.output`). Import `Assets`/`FontFamily` from there.
- Fonts: `Roboto` (light) and `IbmPlexSans` (thin→bold, Arabic-capable) declared in `pubspec.yaml`.

### Bootstrap details worth knowing

- `main.dart` runs inside `AppErrorHandler.runGuarded`, and before the first frame awaits `EasyLocalization.ensureInitialized()`, `SharedPrefManager.init()`, `HiveManager.init()` and `setupServiceLocator()` — all four must finish first, so anything reading prefs, Hive or DI at startup is safe. It then locks orientation to portrait and makes the status bar transparent.
- `DevicePreview` wraps the app but is hard-coded `enabled: false`; flip it by hand to use it.
- `initialLocation` in `AppRouter.router` (`core/routing/app_router.dart`) is sometimes pointed at whatever screen is under active development as a dev shortcut; it must be `'/'` (splash) for release (currently it is).
- `ThemeManager.appThemeMode` is hard-coded to `ThemeMode.light`; no persisted theme toggle yet.
- Locale is persisted by `easy_localization` (`saveLocale: true`) and read through `context.locale`; there is no locale provider. Don't add a second, manual persistence alongside it. The current language reaches the backend as the `lang` header, set in `NowUserApp.build`.

## Tests

There is a real suite: 85 test files under `test/`, mirroring `lib/`'s structure, plus shared harnesses in `test/helpers/`. The convention is plain `flutter_test` — `ProviderContainer` for view models (see `test/features/address/edit_address_vm_test.dart`), `WidgetTester` for widgets. No mocking framework, no generated mocks.

**`flutter analyze` is clean — 0 issues.** The old "69 issues, mostly unused imports" baseline is gone; treat any new issue as yours.

**`flutter test` is green — 430 passing, 0 failing** (measured 2026-09-28, after the Home Tier 2 performance work). The last pre-existing failure, the top banner's geometry test, was measuring the banner mid-way through its 600 ms entrance slide. Treat any failure as yours. Counts drift as tests are added, so when in doubt `git stash` and re-measure rather than trusting the number written here.
