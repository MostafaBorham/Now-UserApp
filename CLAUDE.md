# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter pub get                       # Install dependencies
flutter run                           # Run on connected device/emulator
flutter analyze                       # Static analysis (analysis_options.yaml)
flutter test                          # Run all tests
flutter test test/path/to_test.dart   # Run a single test file
flutter build apk                     # Android release build
dart run build_runner build           # Regenerate assets (assets.gen.dart) after adding files under assets/
dart run build_runner watch           # Watch mode for code generation
```

Re-run `build_runner build` any time new files are added under `assets/media/images/svg/`, `png/`, `assets/media/sounds/`, `videos/`, or `assets/json/` — the generated `Assets` class must be regenerated for the new paths to be accessible.

Package import prefix: `package:nowdelivery_user_app/`.

## Architecture

**Feature-first layout** under `lib/` (not a layered MVVM tree — do not put new code under `lib/common`, `lib/data`, `lib/view`, or `lib/viewmodels`; those folders do not exist).

- `lib/core/` — cross-cutting/shared code:
  - `route/` — `app_routes.dart` (route name constants) and `router.dart` (switch-based `onGenerateRoute`).
  - `localization/` — `lang_keys.dart` (string key constants) and `local_controller.dart` (Riverpod locale state).
  - `presentation/` — shared UI atoms: `assets/` (flutter_gen output: `assets.gen.dart`, `fonts.gen.dart`), `styles/` (`text_styles.dart`, `app_border_radius.dart`, `app_borders.dart`, `app_box_shadows.dart`), `theme/` (`app_themes.dart`, `theme_manager.dart`), `responsive/` (`spacing_extension.dart`), `components/`, and `widgets/` (shared widgets grouped by kind: `buttons/`, `images/`, `text_fields/`, …).
  - Other cross-cutting folders: `connection/`, `enums/`, `errors/`, `extensions/`, `formatters/`, `loggers/`, `notifications/`, `params/`, `pickers/`, `utils/`.
- `lib/features/<feature>/` — self-contained feature module. Each has `data/` (`datasources/`, `models/`, `repo/`), `presentation/` (`screens/`, `widgets/<group>/`, sometimes `controllers/` for Riverpod), and `viewmodel/`. Current features: `categories`, `favourites`, `home`, `notifications`, `orders`, `products`, `search`, `stores`, `support`, `wallet`, `welcome`.

**Current phase is UI-first.** `data/`, `repo/`, `datasources/`, `viewmodel/` folders are largely empty scaffolding. Most screens use inline hardcoded/sample data; Riverpod state that exists today lives in feature-level `presentation/controllers/`.

**State management:** Flutter Riverpod 2.6.1. Use `ConsumerWidget` / `ConsumerStatefulWidget` when Riverpod is needed; default to `StatelessWidget` otherwise. `StateNotifierProvider` for mutable state, `StateProvider.autoDispose` for transient UI state.

**Navigation:** Custom `onGenerateRoute` switch in `lib/core/route/router.dart`, keyed on constants in `lib/core/route/app_routes.dart`. Navigate with `Navigator.pushNamed(context, AppRoutes.xScreen)`.

**Localization:** `easy_localization` with JSON files under `assets/json/lang/` (`en-US.json`, `ar-EG.json`). Always use `LangKeys` constants — e.g. `LangKeys.homeTitle.tr()` — never raw strings in a `Text()` widget. Locale state is a Riverpod `StateNotifier<Locale>` in `LocalController`.

**Responsive sizing:** Design base 390×844. Use `flutter_screenutil` extensions everywhere — `.sp` for font sizes, `.w` / `.h` for widths/heights and padding, `.r` for radii. Never pass raw `double` literals for sizes. Spacing widgets via `.hSpace` / `.wSpace` from `spacing_extension.dart`.

**Type-safe assets:** All images/SVGs/animations go through the generated `Assets` class (e.g. `Assets.media.images.svg.logo.svg()`). Never reference raw string paths.

**Functional errors:** `dartz` `Either<Failure, Success>` is the intended return type for repository methods once the data layer lands.

## Adding a New Screen (checklist)

1. Screen file → `lib/features/<feature>/presentation/screens/<name>_screen.dart`.
2. Feature-local widgets → `lib/features/<feature>/presentation/widgets/<group>/`. Genuinely shared widgets → `lib/core/presentation/widgets/<group>/`.
3. Add a route constant to `lib/core/route/app_routes.dart` and a `case` + import to `lib/core/route/router.dart`.
4. Wrap the body in `AppWavedScaffold(appBarTitle:, body:, canPop:)` for standard screens.
5. Localize every static user-visible string: key in `lib/core/localization/lang_keys.dart`, plus entries in `assets/json/lang/en-US.json` and `assets/json/lang/ar-EG.json`. Reference as `LangKeys.myKey.tr()`.

## Screen Building Rules (MUST follow)

### 1. Colors — from `AppThemes` ColorScheme only
Never hardcode `Color(0xff...)` in widgets. If the color already exists in `lib/core/presentation/theme/app_themes.dart` `ColorScheme`, use it via `Theme.of(context).colorScheme.<property>`. If it does not, add it to **both** light and dark `ColorScheme` first, then reference it semantically.

### 2. Text styles — from `AppTextStyles`
Never create inline `TextStyle` objects. Check `lib/core/presentation/styles/text_styles.dart` for a matching size+weight (`AppTextStyles.style16SemiBold`); add a new entry there if missing.

### 3. Border radius — from `AppBorderRadius`
Never use inline `BorderRadius.circular(...)`. Use `AppBorderRadius.brCircular12` (etc.) from `lib/core/presentation/styles/app_border_radius.dart`; add missing values there.

### 4. Icons — SVG assets, never Flutter built-ins
Do **not** use `Icons.*`. Icons come from the design as SVGs under `assets/media/images/svg/`. After adding a file, run `dart run build_runner build` and reference it as `Assets.media.images.svg.iconName.svg()`.

### 5. Network images — always `CachedNetworkImage`
Never use `Image.network()`. Use `CachedNetworkImage` (or the project wrapper `AppCachedNetworkImage`) for any URL-loaded image.

### 6. Localization — Arabic and English for every static string
Static labels/titles/buttons/hints/errors MUST be localized (key + `en-US` + `ar-EG` entries). Dynamic values from the API (product names, prices, IDs) are not translated. RTL layout mirroring goes through the project's `ReverseWidget` helper where needed.

## Widget Coding Style

- **Flat `build()` methods.** Do not extract `_buildSomething()` helper methods returning `Widget`, and do not create small single-use `StatelessWidget` subclasses purely to tidy the tree. Build inline. Extract to a class only when the widget is genuinely reused across files. Private sub-widget classes (e.g. `_DiscountBadge`) are preferred over helper methods when extraction is warranted.
- No data-model classes for placeholder/sample content during UI-first work — hardcode dummy values inline in the widget. Model classes come with the data layer later.
- Add pub.dev packages freely when needed (`flutter pub add <package>`); no need to ask.

## Design System

- **Primary:** Green `#4BB749`. **Accent:** Yellow `#EAD800`.
- **Fonts:** IBM Plex Sans (Arabic + English, weights 100–700), Roboto Light fallback.
- Themes toggled via `ThemeManager` in `lib/core/presentation/theme/`.

## Networking & Connectivity

DIO client lives under the data layer (per-feature `datasources/` once populated). `PrettyDioLogger` is used in debug builds. Connectivity is monitored via `connectivity_plus` + `internet_connection_checker`; the app routes to a no-internet screen when offline via the router.
