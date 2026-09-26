# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Envira — a Flutter recycling/rewards app (Android only; iOS is not configured, see below). Firebase-backed (Auth, Firestore, Storage), package name still `flutter_app_base` (pubspec `name:`), display name "Envira".

A very detailed, evidence-based Q&A about this codebase already exists at [docs/PROJECT_QA.md](docs/PROJECT_QA.md) — read it before making architectural claims or non-trivial changes; it documents exact patterns, dead code, and gaps (e.g. no tests, iOS unconfigured, forgot-password UI not wired up) that aren't obvious from a quick scan.

## Commands

There is no Makefile/scripts directory — use plain Flutter/Dart tooling.

```bash
flutter pub get                # install dependencies
flutter run                    # run on connected device/emulator (Android only — see iOS note)
flutter analyze                # static analysis (flutter_lints)
flutter build apk               # build Android release APK
```

**Toolchain requirement**: this repo is pinned to an older Android build stack (Gradle 8.4, AGP 8.3.0) and
`intl: ^0.19.0`, which is incompatible with recent Flutter releases (roughly 3.44+) — they raise the minimum
required AGP/Gradle and bump the `intl` version `flutter_localizations` needs, which conflicts with this
project's pin. Use **Flutter 3.29.3** (pin via `fvm use 3.29.3`) and **JDK 17** (Gradle 8.4 doesn't reliably
build on JDK 21+, and hard-fails on very new JDKs like 25). Full setup steps, including the Android emulator
requirements (Google Play system image, for Firebase) are in [docs/SETUP.md](docs/SETUP.md).
Don't bump Flutter/Gradle/AGP versions to "fix" a build error here without first checking whether it's actually
this mismatch — reverting to the pinned versions above is usually the right fix, not upgrading further.

- No test suite exists (no `test/` or `integration_test/` dir, nothing in `flutter_test` is used). Don't assume `flutter test` will find anything.
- No CI configured.
- After changing the app icon: `dart run flutter_launcher_icons`
- After changing the splash screen: `dart run flutter_native_splash:create --path=flutter_native_splash.yaml`
- iOS is not set up: `firebase_options.dart` throws `UnsupportedError` for iOS, there's no `GoogleService-Info.plist`, no `Podfile`, and `Info.plist` has no camera/location/photo-library usage strings. Don't assume `flutter run` on an iOS simulator will work without first doing this setup.

## Architecture

Feature-first modules (`lib/modules/<feature>/`) on top of a shared data layer (`lib/data/`), wired together with hand-rolled globals instead of DI. Not Clean Architecture, not strict MVVM.

```
lib/
  main.dart                 entry point: Firebase.initializeApp, MultiProvider, MaterialApp(home: ConnectionGate())
  core/
    config.dart              feature flags + hardcoded API keys (AppConfig, NewsConfig)
    global_instances.dart    service locator: top-level `final` repositories/services + navigatorKey + logger
    theme/                   colors/text styles
    utils/                   AppNavigator (imperative nav), ContextUtils, dialog widgets, memojis
  data/                      shared layer, NOT per-feature
    models/                  plain classes with toMap()/fromDocumentSnapshot() (no freezed/json_serializable)
    repositories/            BaseRepository<T> (generic Firestore CRUD) + one subclass per collection
    providers/               BaseProvider<T> (ChangeNotifier wrapping a Firestore stream) + one subclass per collection
  session/                   app-lifecycle gating: ConnectionGate -> AuthGate -> CustomNavBar
  modules/<feature>/         pages/, and where relevant providers/, services/, widgets/, utils/
```

Key patterns to follow when adding to this codebase:

- **State management**: `provider` + `ChangeNotifier` only (no BLoC/Riverpod/GetX). Global collection-backed state (`UsersProvider`, `VouchersProvider`, etc.) subclasses `BaseProvider<T>` in one line and is registered in `main.dart`'s `MultiProvider`. Feature-level "providers" under `modules/*/providers/` (e.g. `HomeDataProvider`, `LeaderboardProvider`) are actually builder widgets that read the global providers via `context.select`/`context.watch` and hand a derived data object to a `builder` callback — they are not `ChangeNotifier`s.
- **Adding a new entity** (documented in [docs/SETUP.md](docs/SETUP.md)): 1) Model in `data/models/`, 2) Repository (extends `BaseRepository<T>`) and/or Service, registered in `global_instances.dart`, 3) Optionally a `ChangeNotifierProvider` registered in `main.dart` **and** added to both `startListeningToProviders()`/`stopListeningToProviders()` in [lib/session/session_manager.dart](lib/session/session_manager.dart) — forgetting the session_manager step means the collection never starts/stops streaming.
- **Mutations bypass providers**: services write directly to Firestore through repositories; the Firestore stream then pushes the change back into the relevant `BaseProvider`, which calls `notifyListeners()`. Don't try to mutate provider state directly.
- **Service locator, not DI**: everything is wired in [lib/core/global_instances.dart](lib/core/global_instances.dart) as top-level `final`s (repositories, services, `logger`, `navigatorKey`). Services take their repository dependencies via constructor but are themselves globals imported everywhere — there's nothing injectable for tests.
- **Navigation**: imperative only, via [lib/core/utils/app_navigator.dart](lib/core/utils/app_navigator.dart) (`AppNavigator.navigateTo/navigateAndReplace/navigateAndRemoveAll`) using the global `navigatorKey`. No named routes, no `go_router`.
- **Session gating**: `ConnectionGate` (connectivity check, else `NoInternetPage`) → `AuthGate` (Firebase Auth state, else `LoginPage`; PIN flow exists but is dead code while `AppConfig.pinCodeEnabled == false`) → `CustomNavBar` (4-tab shell: Home/Leaderboard/Vouchers/Profile). `SessionManager.startListeningToProviders()` starts all Firestore streams after login and awaits each `initializationCompleter` before proceeding.
- **Error handling**: ad-hoc try/catch → `logger.e(...)` → error dialog with the raw exception message shown to the user. No typed errors, no `Result`/`Either`, no retry (except a manual "Retry" button on `NoInternetPage`). Repositories swallow errors and return `[]`/`void`, so callers can't distinguish "empty" from "failed". Match this style rather than introducing a new error-handling pattern unless asked to.
- **Offline**: the app is online-only by design — `ConnectionGate`/`ConnectionStateProvider` actively kick users to `NoInternetPage` on disconnect. No local persistence package is used; the only cache is an in-memory list of recycling points loaded from `assets/recycling_points.json`.
- **Config/secrets**: [lib/core/config.dart](lib/core/config.dart) reads third-party API keys (Gemini, Barcode Lookup, NewsAPI) via `String.fromEnvironment(...)`, supplied at build/run time with `--dart-define-from-file=env.json` (gitignored; see `env.json.example` and [docs/SETUP.md](docs/SETUP.md)) — never hardcode a real key back into `config.dart`. The Firebase `apiKey` in `firebase_options.dart`/`google-services.json` is a different case and stays committed — it's not a secret (see docs/SETUP.md).
