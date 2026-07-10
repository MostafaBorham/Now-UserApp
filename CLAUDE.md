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
flutter test test/auth/login/unit_test.dart   # run a single test file

# Regenerate flutter_gen output (asset & font classes) after adding assets:
dart run build_runner build --delete-conflicting-outputs

# Regenerate the native splash after changing assets or config in pubspec.yaml:
dart run flutter_native_splash:create
```

Windows/PowerShell: same commands, no shell-specific tweaks needed.

## Architecture

### Layout

```
lib/
  main.dart            # bootstraps DevicePreview → LocalizationInit (easy_localization) → ProviderScope → NowUserApp
  my_app.dart          # MaterialApp.router; wires localization, themes, routerConfig (go_router)
  core/                # shared, cross-feature code (see below)
  features/<feature>/  # feature-scoped code
```

Features (22): `address`, `cart`, `categories`, `checkout`, `discount`, `faq`, `favourites`, `guest_verification`, `home`, `notifications`, `orders`, `payment_methods`, `privacy`, `products`, `search`, `settings`, `stores`, `support`, `support_chat`, `tracking_order`, `wallet`, `welcome`.

The intended shape of a feature is three layers: `presentation/` (`screens/`, `widgets/` or `components/`, and — where present — `controllers/`), `viewmodel/`, and `data/` (`datasources/`, `models/`, `repo/`). Most features are still UI-only; **`categories` is the only feature with a wired data layer and viewmodel — treat it as the reference implementation** when adding backend integration to any other feature.

### Feature imports

Features do **not** use interface/barrel files — import feature files directly by their full path (e.g. `features/stores/presentation/screens/store_details_screen.dart`). Do not create `<x>_interface.dart` files; this pattern was deliberately removed.

**Known deviations (fix opportunistically, don't copy):**
- Several newer features (`address`, `discount`, `faq`, `privacy`, `settings`, `support_chat`) are flat — screens and `components/` sit directly in the feature root with no `presentation/` layer. `settings` even carries its own `app_colors.dart` instead of using the core design system. Restructure toward the standard layout when doing non-trivial work in them.

### Data flow pattern (see `features/categories/`)

Screen → viewmodel → repo → API service → shared Dio singleton:

- **API service** (`data/datasources/remote/api/<x>_api_service.dart`): raw requests only, gets `Dio` from `DioFactory.getDio()`, returns the raw `Response`. Endpoint paths/queries live in a sibling `<x>_endpoints.dart` constants class.
- **Repo** (`data/repo/<x>_repo.dart`): all parsing and error handling. Every method returns `Either<Failure, T>` (dartz). Checks `ConnectionChecker.isConnected` first; maps errors through `ApiErrorHandler.extractErrorMessage`. `Failure.message` is either a `LangKeys` key or a raw server message — callers apply `.tr()`, which leaves non-key strings untouched.
- **Viewmodel** (`viewmodel/get_<x>_vm.dart`): a `StateNotifier<AsyncValue<T>>` exposed via `StateNotifierProvider.autoDispose`, kicked off on first watch (`..getX()` in the provider factory). Screens `ref.watch` the provider and render the `AsyncValue`; guard state writes with `if (!mounted) return;` after awaits.

### `lib/core/` conventions

- `dio/` — `DioFactory` (single shared `Dio` singleton), `DioConstants` (base URL, timeouts, default JSON headers), `ApiErrorHandler`, `interceptors/`. All API services must use `DioFactory.getDio()` — never construct their own `Dio`.
- `errors/` — `failures/failure.dart` (the `Failure` type used in `Either`), `exceptions/` (network, cache). Shared error types live here; feature-specific ones stay in the feature.
- `routing/` — navigation uses the **go_router** package (Navigator 1.0/2.0 named routes were fully removed). `app_routes.dart` holds route-name constants (kebab-case strings, also used as URL paths); `app_router.dart` exposes `AppRouter.router`, a `GoRouter` wired into `MaterialApp.router` via `routerConfig`. **New screens must be added in both files** (a name constant + a `GoRoute` with `name` and `path: '/<name>'`). Navigate only with go_router context extensions: `context.pushNamed(AppRoutes.x)` to push, `context.goNamed(...)` for stack resets (splash → onboarding → main), `context.pop()` / `context.canPop()` for back. Route arguments go through `extra:` and are read from `state.extra` in the route builder (see the `addressDetailsScreen` case). Never use `Navigator.push/pop/pushNamed` directly.
- `localization/` — `easy_localization` config (`LocalizationInit` in `configs.dart`), `LangKeys` constants, JSON at `assets/json/lang/{ar-EG,en-US}.json`. Wrap keys with `.tr()`.
- `presentation/` — the design system. `theme/` (light + dark), `styles/` (radii, borders, shadows, text styles), `responsive/` (uses `flutter_screenutil`, design size 390×844), `assets/` (flutter_gen output: `assets.gen.dart`, `fonts.gen.dart`), plus shared `components/` and `widgets/` (organized by kind: `buttons/`, `text_fields/`, `sliders/`, `tab_bars/`, etc.).
- `connection/`, `notifications/{local,remote}/`, `formatters/`, `pickers/`, `enums/`, `params/`, `extensions/`, `utils/` — utility bins; check here before adding a new helper.
- `data/` — empty directory scaffolding (`datasources/{local/cache,remote}/`) reserved for shared data-layer code; contains no files yet.
- `readme` (file, no extension) documents the intent: "shared between more than one main layer (data, view model or view)".

### State management

Riverpod (`flutter_riverpod`). Two flavors in use:
- **UI-only state**: providers under a feature's `presentation/controllers/` — see `lib/features/home/presentation/controllers/` (`Provider` for static lists, `StateProvider` for mutable index-style state, `.autoDispose` when tied to a screen).
- **Async/backend state**: `StateNotifier<AsyncValue<T>>` viewmodels under `viewmodel/` — see the data-flow pattern above.

### Assets & codegen

- `pubspec.yaml` declares asset folders under `assets/`; `flutter_gen_runner` generates typed accessors into `lib/core/presentation/assets/` (set via `flutter_gen.output`). Import `Assets`/`FontFamily` from there.
- Fonts: `Roboto` (light) and `IbmPlexSans` (thin→bold, Arabic-capable) declared in `pubspec.yaml`.

### Bootstrap details worth knowing

- `main.dart` locks orientation to portrait, makes the status bar transparent, and wraps the app in `DevicePreview` (enabled outside release mode).
- `initialLocation` in `AppRouter.router` (`core/routing/app_router.dart`) is sometimes pointed at whatever screen is under active development as a dev shortcut; it must be `'/'` (splash) for release (currently it is).
- `ThemeManager.appThemeMode` is hard-coded to `ThemeMode.light`; no persisted theme toggle yet.
- Locale is persisted by `easy_localization` (`saveLocale: true`); the commented `LocalController.getCurrentLocale()` in `main.dart` is a leftover from a manual approach — don't reintroduce it without removing `easy_localization`'s own persistence.

## Tests

`test/auth/{login,register}/{unit,widget,integration}_test.dart` exist as empty scaffolding (single line each). There is no working test suite yet — running `flutter test` will pass trivially. Populate these files before relying on CI signal.
