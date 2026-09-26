# Setup Guide

## Prerequisites / Local Environment (Android)

This project pins an older Android toolchain (Gradle 8.4, AGP 8.3.0, Kotlin 1.8.22) and an `intl: ^0.19.0`
constraint that conflicts with the `intl` version bundled by newer Flutter releases' `flutter_localizations`.
Using a mismatched Flutter/JDK version leads to build failures. Follow this exact setup to avoid that.

1. **Use [fvm](https://fvm.app/) and pin Flutter 3.29.3** (Dart 3.7.2, matches this repo's `sdk: ^3.7.2` and
   `intl: ^0.19.0` exactly — no pubspec changes needed):
   ```bash
   fvm use 3.29.3
   ```
   Newer Flutter versions (roughly 3.44+) raise the minimum required AGP/Gradle far past what this repo uses
   and also bump the `intl` version required by `flutter_localizations`, which conflicts with this project's
   `intl: ^0.19.0` pin — don't `flutter upgrade`/use a system-wide Flutter without checking this first.

2. **Use JDK 17** — Gradle 8.4 (used by this project) does not reliably support building on JDK 21+, and will
   hard-fail on very new JDKs (e.g. JDK 25) with an "Unsupported class file major version" error. Install it if
   needed:
   ```bash
   brew install openjdk@17
   ```
   Then point Flutter at it (this is a global `flutter config` setting, not project-local):
   ```bash
   fvm flutter config --jdk-dir="$(brew --prefix openjdk@17)/libexec/openjdk.jdk/Contents/Home"
   ```

3. **Android emulator**: create/use an AVD with a **Google Play** system image (not plain "Google APIs"), since
   Firebase Auth/Firestore require Google Play Services.

4. **Firebase config is already checked in** — `android/app/google-services.json` and `lib/firebase_options.dart`
   are committed, so no Firebase setup is required to run on Android. (iOS is not configured — see
   [CLAUDE.md](../CLAUDE.md).) The Firebase `apiKey` embedded there is not a secret — see the note below.

5. **API keys — required, not checked in.** Copy [env.json.example](../env.json.example) to `env.json` (repo
   root, gitignored) and fill in real values, then always run/build with
   `--dart-define-from-file=env.json`:
   ```bash
   cp env.json.example env.json   # then fill in the three keys
   fvm flutter devices            # confirm the emulator is detected
   fvm flutter pub get
   fvm flutter run --dart-define-from-file=env.json
   ```
   The VS Code launch config already passes this flag, so debugging from the editor works without extra setup
   once `env.json` exists.

6. **Permissions**: the app requests location (`ACCESS_FINE_LOCATION`/`ACCESS_COARSE_LOCATION`) for the
   recycling-points feature and camera (`CAMERA`) for barcode/product scanning — grant these when prompted on
   first use.

7. **No offline mode**: the app requires an active internet connection at all times (`ConnectionGate` redirects
   to a "no internet" page otherwise), so make sure the emulator has network access.

## External Services / API Keys

- **Firebase (Auth, Firestore, Storage)** — `android/app/google-services.json` and `lib/firebase_options.dart`
  are committed and point at the project's real Firebase backend (project ID `bachelor-project-47b18`; there's
  no emulator/local Firebase setup). Any signups/logins/data you create while running locally go to that shared
  backend. iOS is not configured (`firebase_options.dart` throws `UnsupportedError` for iOS) — see
  [CLAUDE.md](../CLAUDE.md). Manage it at the
  [Firebase Console](https://console.firebase.google.com/project/bachelor-project-47b18/overview) (requires
  access to the Google account/team that owns this project).

  The Firebase `apiKey` in these files is **not treated as a secret** — per Google's own docs, it only
  identifies the project to Google's backend and is designed to be embedded in public client apps; access
  control is meant to come from Firestore/Storage security rules (not yet present in this repo — see
  [ROADMAP.md](ROADMAP.md)), not from hiding this key.

- **Google Gemini** (recycling image recognition) — read at runtime via
  `String.fromEnvironment('GEMINI_API_KEY')` in [lib/core/config.dart](../lib/core/config.dart). Get/rotate
  keys at [Google AI Studio](https://aistudio.google.com/api-keys).
- **Barcode Lookup API** (product/barcode scanning) — read via
  `String.fromEnvironment('BARCODE_LOOKUP_API_KEY')` in
  [lib/core/config.dart](../lib/core/config.dart). Manage the account/key at
  [barcodelookup.com/api](https://www.barcodelookup.com/api) (log in, then see account settings).
- **NewsAPI** (news feed) — read via `String.fromEnvironment('NEWS_API_KEY')` in
  [lib/core/config.dart](../lib/core/config.dart). Manage/rotate the key at
  [newsapi.org/account](https://newsapi.org/account).

These three are supplied at build/run time via `--dart-define-from-file=env.json` (see step 5 above) and are
**not** committed to the repo. `env.json` is gitignored; only `env.json.example` (blank placeholders) is
tracked. Note this only keeps the keys out of source control — a compiled APK can still be decompiled to
recover any value baked in via `--dart-define`, since there is no backend to hold them server-side. Treat these
as leaked if the app is ever redistributed publicly, and rotate accordingly.

## Commands

```bash
flutter pub get                                        # install dependencies
flutter run --dart-define-from-file=env.json            # run on connected device/emulator (Android only)
flutter analyze                                         # static analysis (flutter_lints)
flutter build apk --dart-define-from-file=env.json      # build Android release APK
```

- After changing app icon: `dart run flutter_launcher_icons`
- After changing splash screen icon: `dart run flutter_native_splash:create --path=flutter_native_splash.yaml`
- You may also update the Gradle version used by running
  `./gradlew wrapper --gradle-version=<COMPATIBLE_GRADLE_VERSION>`.

## Creating a new entity

1. Model in `lib/data/models/`.
2. Repository (extends `BaseRepository<T>`) and/or Service, registered in
   [lib/core/global_instances.dart](../lib/core/global_instances.dart).
3. [Optional] A `ChangeNotifierProvider` registered in `main.dart` **and** added to both
   `startListeningToProviders()`/`stopListeningToProviders()` in
   [lib/session/session_manager.dart](../lib/session/session_manager.dart) — forgetting the session_manager step
   means the collection never starts/stops streaming.
