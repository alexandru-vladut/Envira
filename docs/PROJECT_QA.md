# Envira — Project Q&A

Answers are based only on what is in the repository at commit `60b5528` (2025-07-02). Where something could not be verified from the repo, it is stated as such.

---

## Batch 1

### Q1. What state management solution is used, and why that one?

**Answer: `provider` (v6.1.4) with `ChangeNotifier`, plus local `setState`. No BLoC, Riverpod, or GetX.**

Evidence:

- `pubspec.yaml` — the only state-management dependency is `provider: ^6.1.4`. There is no `flutter_bloc`, `flutter_riverpod`, `get`, or `mobx`.
- `lib/main.dart` — `runApp` wraps `MyApp` in a `MultiProvider` with eight `ChangeNotifierProvider`s: `ConnectionStateProvider`, `AuthStateProvider`, `UsersProvider`, `VouchersProvider`, `TransactionsProvider`, `CompaniesProvider`, `ProductsProvider`, `NewsProvider`.
- `lib/data/providers/base_provider.dart` — a generic `BaseProvider<T> extends ChangeNotifier` that subscribes to a Firestore `Stream<List<T>>`, stores `_items`, exposes an `initializationCompleter`, and calls `notifyListeners()` on every snapshot. The six data providers (`users_provider.dart`, `vouchers_provider.dart`, etc.) are one-line subclasses of it.
- `lib/session/auth_state_provider.dart` and `lib/session/connection_state_provider.dart` — two more `ChangeNotifier`s for Firebase Auth state and connectivity.
- Feature-level "providers" (`lib/modules/home/providers/home_data_provider.dart`, `leaderboard/providers/leaderboard_provider.dart`, `profile/providers/profile_provider.dart`, `work_log/providers/work_log_provider.dart`, `environmental_impact/providers/env_impact_provider.dart`, `recycle/providers/product_data_provider.dart`, `news/providers/news_data_provider.dart`) are **not** `ChangeNotifier`s. They are `StatelessWidget`s (one `StatefulWidget`) that take a `builder` callback, read the global providers via `context.select` / `context.read` / `context.watch`, compute a plain data object (`HomeData`, `LeaderboardData`, …), and hand it to the builder. This is a builder-widget/derived-view-model pattern layered on top of `provider`.
- `setState` is used in 15 files for purely local UI state (loading flags, selected tabs, animation state), e.g. `lib/modules/recycle/pages/recycle_page.dart`, `lib/modules/custom_nav_bar.dart`.
- Mutations do **not** go through the providers. Services (`lib/modules/*/services/*.dart`) write directly to Firestore via repositories; the Firestore stream then pushes the change back into the `BaseProvider`, which notifies the UI.

**Why this one:** Not documented anywhere in the repo. There is no ADR, no comment in `main.dart`, no README rationale, and no commit message explaining the choice (`git log` — the closest is `ca790c0 "refine auth and connection state management"`, which has no body). The `TO-DO.md` mentions following "Coding with T on YT" for structure, which suggests tutorial-driven choices, but that is inference, not evidence. The choice is not stated in the repository.

---

### Q2. What's the project architecture / folder structure?

**Answer: A layered structure with feature-first modules on top — closest to "feature-first with a shared data layer". It is not Clean Architecture and not a strict MVVM.**

Folder layout under `lib/` (from `find lib -type d`):

```
lib/
  main.dart                     entry point, MultiProvider + MaterialApp
  firebase_options.dart         FlutterFire-generated (Android only)
  core/                         cross-cutting
    config.dart                 feature flags + API keys
    global_instances.dart       hand-rolled service locator (top-level finals)
    theme/                      colours/text styles
    utils/                      AppNavigator, ContextUtils, dialog widgets, memojis
  data/                         shared data layer (not per-feature)
    models/                     plain classes with toMap / fromDocumentSnapshot
    repositories/               BaseRepository<T> + one subclass per Firestore collection
    providers/                  BaseProvider<T> + one ChangeNotifier per collection
  session/                      app lifecycle gates
    connection_gate.dart -> auth_gate.dart -> CustomNavBar
    auth_state_provider.dart, connection_state_provider.dart, session_manager.dart
  modules/                      feature-first
    authentication/  pages/ services/ utils/ widgets/
    home/            pages/ providers/ widgets/
    leaderboard/     pages/ providers/
    vouchers/        pages/ services/ utils/ widgets/
    profile/         pages/ providers/
    recycle/         pages/ providers/ services/ widgets/
    work_log/        pages/ providers/ services/
    environmental_impact/ pages/ providers/
    news/            pages/ providers/ services/
    landing/         pages/
    custom_nav_bar.dart, custom_app_bar.dart, placeholder_page.dart
```

Characterisation, with evidence:

- **Feature-first UI**: each `modules/<feature>/` owns its pages, widgets, services, and derived-data providers.
- **Shared, layered data**: models, repositories, and stream providers live in `lib/data/`, not inside features. `lib/data/repositories/base_repository.dart` is a generic Firestore CRUD wrapper; `lib/data/providers/base_provider.dart` is the generic stream cache.
- **Service locator, not DI**: `lib/core/global_instances.dart` instantiates all repositories and services as top-level `final` globals and a global `navigatorKey`. Services take repositories via constructor (e.g. `RecycleService(userRepository, transactionRepository)`), but they are wired up in that one file and imported everywhere. There is no `get_it`, no injector, and nothing is injectable for tests.
- **Not Clean Architecture**: there is no domain layer, no use-cases, no abstract repository interfaces, and models import `cloud_firestore` directly (`lib/data/models/user_model.dart` → `DocumentSnapshot`). Services import UI concerns (`lib/modules/recycle/services/recycle_service.dart` imports `custom_nav_bar.dart` and calls `loadingDialog` / `successDialog` / `AppNavigator`).
- **Not strict MVVM**: the "providers" inside `modules/*/providers/` act like view-models (they compute `HomeData`, `LeaderboardData`, etc.), but they are widgets, not observable classes, and pages call global services directly for actions (`profile_page.dart:375` → `authService.logOut()`).
- **Session gating**: `main.dart` → `ConnectionGate` (`lib/session/connection_gate.dart`) → `AuthGate` (`lib/session/auth_gate.dart`) → `CustomNavBar` (`lib/modules/custom_nav_bar.dart`). `SessionManager.startListeningToProviders()` (`lib/session/session_manager.dart`) starts all six Firestore streams after login and awaits their first snapshot.
- **Navigation**: imperative `Navigator.push` wrapped by `lib/core/utils/app_navigator.dart` using the global key. No named routes, no `go_router`.

The README (`README.md`) documents the intended recipe: "Creating a new entity: 1. Model 2. Repository/Service 3. [Optional] Provider (to be added in main(), startListeningToProviders() and stopListeningToProviders())".

---

### Q3. Are there any tests?

**Answer: No Dart tests of any kind. Not present.**

- There is no `test/` directory and no `integration_test/` directory (`ls test integration_test` → "No such file or directory").
- No `*_test.dart` file exists anywhere in the repo.
- `pubspec.yaml` lists `flutter_test` under `dev_dependencies` (the default template entry), but nothing uses it. No `mockito`, `mocktail`, `fake_cloud_firestore`, or `firebase_auth_mocks`.
- The only test artefact is `ios/RunnerTests/RunnerTests.swift`, which is the unmodified Xcode template with an empty `testExample()` — it tests nothing.
- No CI: there is no `.github/`, no `codemagic.yaml`, no `bitrise.yml`, no `.gitlab-ci.yml`.
- Static analysis is `analysis_options.yaml` → `package:flutter_lints/flutter.yaml` with `constant_identifier_names` and `deprecated_member_use` set to `ignore`. I could not run `flutter analyze` because the Flutter SDK is not on PATH in this environment and the project is not registered with the installed FVM.
- `.vscode/launch.json` has a single config named "🧪 Flutter Debug Test", but it just launches `lib/main.dart` — it is a run config, not a test config.

Testability note (not asked, but relevant): the global-instance pattern in `lib/core/global_instances.dart`, direct `FirebaseFirestore.instance` / `FirebaseAuth.instance` usage in `base_repository.dart` and `auth_service.dart`, and services that open dialogs would all need refactoring before unit tests could be written without a live Firebase project.

---

### Q4. Approximate size in Dart LOC and number of screens?

**Answer: ~15.8k lines of Dart across 103 files; 23 page-level screens plus the nav-bar shell, 4 modal sheets, and 1 unreferenced placeholder page.**

LOC (measured with `wc -l` over `lib/**/*.dart`):

| Measure | Count |
|---|---|
| Raw lines, all `lib/` | 15,831 |
| Excluding generated `firebase_options.dart` | 15,769 |
| Non-blank, non-comment lines | ~14,150 |
| Dart files | 103 |

Largest files: `lib/modules/work_log/pages/work_log_page.dart` (1,380), `lib/modules/home/widgets/overview_card.dart` (733), `lib/modules/leaderboard/pages/leaderboard_page.dart` (721), `lib/modules/recycle/pages/recycle_page.dart` (668).

No non-Dart app code beyond platform templates. `recycling_locations_scraper/main.py` is a separate Python scraper (not part of the app).

Screens (every file under `lib/modules/*/pages/`, 23 total, all reachable):

| Module | Screens |
|---|---|
| authentication | `LoginPage`, `SignIn`, `SignUp`, `CreatePin`, `EnterPin` (5) |
| landing | `NoInternetPage`, `VerificationEmailSent`, `ForgetEmailSent`, `WrongPin` (4) |
| home | `HomePage` (1) |
| leaderboard | `LeaderboardPage` (1) |
| vouchers | `VouchersPage` (1) |
| profile | `ProfilePage` (1) |
| recycle | `RecyclePage`, `RecyclingLocationListPage`, `BarcodeScannerPage`, `ProductPage`, `ProductNotFoundPage` (5) |
| work_log | `WorkLogPage` (1) |
| environmental_impact | `ImpactDashboardPage`, `ImpactDetailsPage`, `ImpactMilestonesPage` (3) |
| news | `NewsPage` (1) |

Plus:
- `lib/modules/custom_nav_bar.dart` — the 4-tab shell (Home / Leaderboard / Vouchers / Profile).
- `lib/modules/placeholder_page.dart` — `PlaceholderPage`, defined but not referenced by any other file (`grep -rn PlaceholderPage lib` only hits its own file).
- 4 bottom-sheet modals that behave like sub-screens: `image_source_selection_modal.dart`, `manual_product_entry_modal.dart`, `recycling_point_detail_modal.dart` (recycle), `promo_code_modal.dart` (vouchers).

Note `CreatePin`, `EnterPin`, and `WrongPin` are only reachable when `AppConfig.pinCodeEnabled` is true; it is currently `false` in `lib/core/config.dart`.

---

### Q5. Does it run on both Android and iOS, and was it tested on both?

**Answer: Android only. iOS is not configured and, from the repo evidence, has never been run.**

Android — configured:
- `lib/firebase_options.dart` has a `static const FirebaseOptions android = …` block for project `bachelor-project-47b18`.
- `android/app/google-services.json` is present and tracked in git.
- `android/app/build.gradle` applies `com.google.gms.google-services`, `minSdkVersion 23`, `compileSdk 35`, `applicationId "com.flutter.app_base"` (still the template ID; TODO comment left in place), release build signed with debug keys.
- `android/app/src/main/AndroidManifest.xml` declares `CAMERA`, `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`, and storage permissions, and `android:label="Envira"`.
- `firebase.json` only lists an `android` platform.
- Commit history touches Android config repeatedly (`"updated android folder"`, icon/splash commits).

iOS — not configured:
- `lib/firebase_options.dart` → `case TargetPlatform.iOS: throw UnsupportedError('DefaultFirebaseOptions have not been configured for ios …')`. `Firebase.initializeApp` in `main.dart` would throw on first launch on any iOS device or simulator.
- No `ios/Runner/GoogleService-Info.plist`.
- No `ios/Podfile` or `Podfile.lock` — CocoaPods has never been run for this project, so the Firebase, `mobile_scanner`, `geolocator`, `image_picker` etc. native pods have never been resolved.
- `ios/Runner/Info.plist` has zero `*UsageDescription` keys. The app uses camera (`mobile_scanner`, `image_picker`), location (`geolocator`), and photo library (`image_picker`); iOS would crash on first access without `NSCameraUsageDescription`, `NSLocationWhenInUseUsageDescription`, `NSPhotoLibraryUsageDescription`.
- `Info.plist` still has `CFBundleDisplayName = "Flutter App Base"` and `CFBundleName = "flutter_app_base"` while Android was renamed to "Envira" in `e3bdd8a`.
- The only commits that touch `ios/` are the initial template (`193f5f3`), a splash-image regeneration (`ca790c0`, `e3bdd8a` — image assets and `LaunchScreen.storyboard` only, produced by `flutter_native_splash`), i.e. no hand-edited iOS configuration ever.

Was it tested on both: the repo contains nothing that records device testing on either platform (no test reports, no CI, no screenshots, no changelog). For Android, the presence of working Firebase config plus the commit history is strong circumstantial evidence it was run there. For iOS, the missing Firebase options alone mean it cannot have launched successfully as committed.

Other platforms: `.metadata` lists linux/macos/web/windows as created by the template, but there are no `linux/`, `macos/`, `web/`, or `windows/` directories in the repo, and `firebase_options.dart` throws for all of them.

---

## Batch 2

### Q6. Any notable packages that signal depth? (dio, freezed, get_it, go_router, hive, isar, retrofit)

**Answer: None of those. The dependency list is Firebase + UI + a few device plugins; no code-gen, DI, routing, or local-DB packages.**

Checked against `pubspec.yaml` (direct deps only):

| Package | Present? |
|---|---|
| dio | no (uses `http: ^1.4.0`) |
| freezed / json_serializable / build_runner | no — all models are hand-written `toMap()` / `fromDocumentSnapshot()` |
| get_it / injectable | no — hand-rolled globals in `lib/core/global_instances.dart` |
| go_router / auto_route | no — imperative `Navigator` via `lib/core/utils/app_navigator.dart` |
| hive / isar / sqflite / drift / shared_preferences / flutter_secure_storage | no |
| retrofit | no |
| rxdart / equatable / dartz / fpdart | no |
| cached_network_image | no |

What *is* there (`pubspec.yaml`):
- Firebase: `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`.
- State: `provider`.
- Network: `http` (two REST calls: Barcode Lookup in `lib/modules/recycle/services/product_service.dart`, NewsAPI in `lib/modules/news/services/news_service.dart`) and `google_generative_ai` (Gemini, `lib/modules/recycle/services/gemini_service.dart`).
- Device: `mobile_scanner`, `geolocator`, `image_picker`, `permission_handler`, `connectivity_plus`, `url_launcher`.
- UI: `google_fonts`, `font_awesome_flutter`, `flutter_svg_provider`, `table_calendar`, `flutter_native_splash`, `flutter_launcher_icons` (dev).
- Misc: `logger`, `collection`, `intl`, `flutter_localizations`.

`path_provider` appears in `pubspec.lock` only as a transitive dependency (pulled by `image_picker`/`google_fonts`); it is not used directly in `lib/`.

The most "depth-signalling" pieces are not packages but hand-written code: the generic `BaseRepository<T>` / `BaseProvider<T>` pair, the Gemini prompt-engineering in `gemini_service.dart`, and the CO2e maths in `lib/modules/work_log/providers/wfh_calculator.dart` and `lib/modules/environmental_impact/providers/env_impact_calculator.dart`.

---

### Q7. Any offline support, local persistence, or caching layer?

**Answer: Effectively none. The app is online-only by design; the one cache is an in-memory list of recycling points.**

- **No local persistence package** — no `shared_preferences`, `hive`, `sqflite`, `isar`, `flutter_secure_storage` (see Q6). `grep` for `SharedPreferences|Hive|sqflite|path_provider|getApplicationDocumentsDirectory` over `lib/` returns nothing.
- **Firestore offline persistence**: not configured. `lib/data/repositories/base_repository.dart` uses `FirebaseFirestore.instance` with no `.settings = Settings(persistenceEnabled: …)` call and no `GetOptions(source: …)`. On Android, `cloud_firestore` enables its disk cache by default, so *some* cached reads would happen implicitly, but nothing in the code relies on or manages that.
- **Online-only gating**: the app actively refuses to run offline. `lib/session/connection_gate.dart` checks connectivity at launch and shows `NoInternetPage` if offline; `lib/session/connection_state_provider.dart` listens to `connectivity_plus` and, on any transition to `ConnectivityResult.none`, does `AppNavigator.navigateAndRemoveAll(page: NoInternetPage())` — wiping the navigation stack. `lib/modules/landing/pages/no_internet_page.dart` has a manual "Retry" button that re-checks and, if online, rebuilds from `AuthGate`.
- **In-memory cache (the only one)**: `lib/modules/recycle/services/recycling_points_service.dart` has `static List<RecyclingPointModel>? _cachedPoints`, populated once from the bundled asset `assets/recycling_points.json` (~124 KB, ~scraped Bucharest recycling points) via `rootBundle.loadString`, with a `clearCache()` method. This is asset data, not remote data, so it works offline but is not "offline support" for user data.
- **Firestore stream cache**: `lib/data/providers/base_provider.dart` keeps the latest snapshot list of each collection in memory (`_items`) for the lifetime of the session. It is cleared on logout (`stopListening()`), never persisted.
- **Images**: `Image.network` is used directly in `lib/modules/news/pages/news_page.dart` and `lib/modules/recycle/pages/product_page.dart` with `errorBuilder`/`loadingBuilder`; no `cached_network_image`, so only Flutter's default in-memory `ImageCache` applies.
- **News "cache"**: `lib/modules/news/services/news_service.dart` stores fetched NewsAPI articles into a Firestore `news` collection and only calls the API when that collection is empty (`loadNewsIfEmpty`) or on manual refresh. That is server-side dedup/storage, not a local cache.

---

### Q8. Any custom animations, custom painters, or non-trivial UI work?

**Answer: Yes — a fair amount of explicit-animation work (18 files use `AnimationController`), one `CustomPainter`, and one camera-overlay scanner. Most is polish (staggered fades, scale-on-tap, pulsing) rather than complex gesture-driven UI.**

Custom painter:
- `lib/modules/home/widgets/overview_card.dart` — `CurvePainter extends CustomPainter` (lines 610–733): draws a circular progress gauge with four layered `drawArc` shadow passes, a `SweepGradient`-shaded arc, and a rotated end-cap dot via `canvas.translate/rotate`. `shouldRepaint` returns `true` unconditionally. The variable names (`shdowPaint`, `redian`), `angle = 140` default, and the sibling `TitleView` / `HomeAppTheme` naming closely match the open-source "Best Flutter UI Templates" fitness-app sample; this looks adapted from that template rather than written from scratch. Not stated in the repo — inference from code similarity.

Reusable animation utilities (`lib/core/utils/dialog_widgets/`):
- `dialog_animations.dart` — `DialogAnimations.bounceIn` (elastic `ScaleTransition`), `fadeInUp` (opacity + translate), `rotate3D` (`Matrix4` perspective + `rotateX` flip), and a `PulseAnimationWidget` (repeating 0.95↔1.05 scale). Used by `dialog_widgets.dart` via `showGeneralDialog` + `transitionBuilder`.
- `custom_loading_indicator.dart` — two `AnimationController`s: a rotating ring (`RotationTransition`) and three staggered bouncing dots built with `TweenSequence` + `Interval`.
- `animated_button.dart` — press-scale feedback (1.0→0.95) on `onTapDown`/`onTapUp`.

Per-screen animation:
- `lib/modules/home/pages/home_page.dart` + `title_view.dart`, `overview_card.dart`, `action_card.dart` — one shared `AnimationController` from `custom_nav_bar.dart` drives staggered entrance (`Interval((1/5)*n, 1.0, curve: fastOutSlowIn)`) for each list section — the template pattern.
- `lib/modules/custom_nav_bar.dart` — icon scale/highlight animation on tab change; `BackdropFilter` + `ClipRRect` rounded translucent bar.
- `lib/modules/recycle/pages/barcode_scanner_page.dart` — `ScanningLineAnimation` (repeating tween moving a `Positioned` line across the scan area) layered over a `mobile_scanner` camera preview with a cut-out overlay.
- `lib/modules/work_log/pages/work_log_page.dart` — fade-in controller, four `FadeTransition` sections, `TableCalendar` with custom day builders (1,380 lines, the largest file).
- `lib/modules/leaderboard/pages/leaderboard_page.dart` — fade controller plus a `TweenAnimationBuilder` rotating 0→2π (podium/crown effect around line 404).
- `lib/modules/vouchers/widgets/` — `animated_voucher_card.dart` (press-scale), `points_indicator.dart` (count-up tween), `empty_vouchers_placeholder.dart`, `promo_code_modal.dart` (entrance anims).
- `lib/modules/profile/pages/profile_page.dart`, `vouchers_page.dart`, `manual_product_entry_modal.dart` — entrance fades/slides.

Not present: no `Hero` transitions, no custom page-route transitions beyond Material/Cupertino defaults, no `CustomClipper`, no `ShaderMask`, no Rive/Lottie, no gesture-driven (drag/physics) animations, no `AnimatedList`, no implicit-animation-heavy layouts. Landing pages (`no_internet_page.dart`, etc.) are plain.

---

### Q9. How is API/network error handling structured? Retry, typed errors, result types?

**Answer: Ad-hoc `try/catch` → log → show dialog. No retry, no typed error hierarchy, no `Result`/`Either` types, no timeouts on HTTP calls.**

Patterns found (40 `catch (` sites across `lib/`):

- **Repositories swallow errors** — `lib/data/repositories/base_repository.dart`: every method wraps Firestore in `try/catch`, calls `logger.e(...)`, and returns `[]` or `void`. Callers cannot distinguish "no data" from "failed". `getDocumentsStream` attaches `.handleError` that logs and returns `<T>[]`, so stream errors are also silently converted to empty lists.
- **Services catch-all and show a dialog** — `lib/modules/recycle/services/recycle_service.dart`, `work_log_service.dart`, `voucher_service.dart`, `product_service.dart`, `news_service.dart`, `image_upload_service.dart`: pattern is `loadingDialog(); try { … } catch (error) { AppNavigator.pop(); errorDialog(title: '… $error'); }`. The raw `error.toString()` is shown to the user.
- **Only typed catch is Firebase Auth** — `lib/modules/authentication/services/auth_service.dart` uses `on FirebaseAuthException catch (error)` and branches on `error.code` (`user-not-found`, `wrong-password`, `weak-password`, `email-already-in-use`) to pick a message (some in Romanian: "Email/parolă greșite!", "Parolele nu corespund!"). Everything else falls to a generic dialog with `error.toString()`.
- **HTTP** — `product_service.dart:_fetchProductFromApi` and `news_service.dart:_fetchNewsFromApi` use bare `http.get(url)` with no `.timeout()`, no `http.Client` injection, and throw a plain `Exception('API request failed with status: …')` on non-200/404. No `SocketException`/`TimeoutException` handling anywhere (`grep` finds none).
- **Gemini** — `gemini_service.dart` has a graceful fallback: if `generateContent` throws, it returns a `GeminiResult` computed by keyword heuristics (`_basicRecyclabilityCheck`), and if JSON parsing fails it returns a zero-point "Failed to analyze product" result. This is the only place with a non-dialog fallback strategy.
- **Retry** — none automatic. The only retry is the manual button in `lib/modules/landing/pages/no_internet_page.dart`, which re-runs `ConnectionStateProvider.recheckConnection()`.
- **Auth-token watchdog** — `lib/session/auth_state_provider.dart` runs a `Timer.periodic` every 60 s (`AppConfig.authTokenRefreshInterval`) calling `getIdToken(true)`; on failure it logs and relies on Firebase to emit a sign-out, which then triggers an "auto-logout" dialog. The timer is never cancelled in `dispose()`.
- **Error types / result types** — not present. No `sealed class`, no `Failure`, no `Result<T>`, no `Either`. Models throw `Exception('Error converting document snapshot …')` from `fromDocumentSnapshot` on bad data, which propagates into the repository's catch-all.
- **Logging** — `logger` package with `PrettyPrinter` (`lib/core/global_instances.dart`), used consistently with `[LEVEL - functionName()]` prefixes; plus five raw `print()` calls in `gemini_service.dart`, `news_service.dart`, `recycling_points_service.dart`. No crash reporting (no Crashlytics/Sentry).

---

### Q10. Any platform channels or native Android/iOS code?

**Answer: No. Not present. Zero custom native code and zero platform channels; all native access is through pub.dev plugins.**

- `grep` for `MethodChannel|EventChannel|BasicMessageChannel|dart:ffi` in `lib/` → no matches. `Platform.isAndroid/isIOS` is also never used.
- Android native: `android/app/src/main/kotlin/com/example/flutter_app_base/MainActivity.kt` is the 5-line template (`class MainActivity: FlutterActivity()`). Note the directory says `com/example/flutter_app_base` while the `package` line and `namespace` in `build.gradle` say `com.flutter.app_base` — harmless for Kotlin but a leftover from renaming.
- iOS native: `ios/Runner/AppDelegate.swift` is the 13-line template; `Runner-Bridging-Header.h` is one line.
- Manifest/plist edits are the only native-side changes: `AndroidManifest.xml` adds `CAMERA`, location, and storage permissions plus `<queries>` for `https` and `geo` intents (needed by `url_launcher` in `recycling_points_service.dart:openInMaps`). `ios/Runner/Info.plist` has no permission strings at all (see Q5).
- Native functionality used, all via plugins: camera/barcode (`mobile_scanner`), GPS (`geolocator`), gallery/camera picker (`image_picker`), connectivity (`connectivity_plus`), external maps/browser (`url_launcher`), runtime permissions (`permission_handler`), Firebase SDKs.
- No Gradle customisation beyond the FlutterFire `google-services` plugin, `minSdkVersion 23`, and JVM 17 (`android/app/build.gradle`). No ProGuard rules, no flavors, no signing config.

---

## Batch 3

### Q11. What are the screens and the main user flows?

**Screens** are listed in Q4. The flows below are traced from `AppNavigator` calls and service methods.

**Launch / session flow** (`lib/main.dart` → `lib/session/`):
1. `ConnectionGate` checks connectivity (`connectivity_plus`). Offline → `NoInternetPage` with a manual Retry. Online → `AuthGate`.
2. `AuthGate.returnPageBasedOnLoginStatus()`: no `FirebaseAuth.currentUser` → `LoginPage`. Logged in and `pinCodeEnabled == false` (current setting) → `sessionManager.startListeningToProviders()` then `CustomNavBar`. (PIN branch is dead while the flag is false.)
3. Any later connectivity loss → `ConnectionStateProvider` pushes `NoInternetPage` and clears the stack. Any unexpected Firebase sign-out → `AuthStateProvider` shows a "Signed Out" dialog then `LoginPage`.

**Auth flow** (`lib/modules/authentication/`):
- `LoginPage` is a landing page with two buttons → `SignUp` or `SignIn` (Cupertino push).
- `SignIn` → `authService.signIn()`: on success, if email verified (or email is in `AppConfig.demoAccountEmails`) → `CustomNavBar`; if unverified → send verification email, sign out, → `VerificationEmailSent` (whose only button goes back to `LoginPage`).
- `SignUp` → `authService.signUp()`: creates the Firebase user, writes a `users` doc with `companyId: "355aInOtLhMaQm6fyMCh"` (hard-coded), sends verification, signs out → `VerificationEmailSent`.
- Forgot password: `AuthService.sendPasswordResetEmail()` and `ForgetEmailSent` page exist, and `signin_page.dart:26` declares a `forgotController`, but **nothing calls `sendPasswordResetEmail`** — the flow is not wired to any UI.
- PIN flow (`CreatePin`, `EnterPin`, `WrongPin`) exists but is unreachable while `AppConfig.pinCodeEnabled = false`.

**Main shell** — `CustomNavBar` with four tabs: Home, Leaderboard, Vouchers, Profile.

**Home** (`lib/modules/home/`): header with name, an `OverviewCard` (goal progress gauge, all-time points, CO2e saved, days left, rank — computed in `home_data_provider.dart`), and an `ActionCard` grid (`action_list_data.dart`) with four entries that push: `RecyclePage`, `WorkLogPage`, `ImpactDashboardPage`, `NewsPage`.

**Recycle flow** (`lib/modules/recycle/`):
1. `RecyclePage`: on open, checks location permission silently; if granted, loads nearby points (≤0.5 km) and shows the closest one with "Open in Maps" and "See all" → `RecyclingLocationListPage` (tap a row → `RecyclingPointDetailModal`). If no permission, shows a prompt to grant it.
2. Bottom panel "Scan Product Barcode" → `recycleService.scanBarcode()` → `BarcodeScannerPage` (camera). On first detected barcode → pops with the value → pushes `ProductPage(barcode)`.
3. `ProductPage` looks the barcode up in the in-memory `ProductsProvider` (`product_data_provider.dart`). Found → shows title/brand/material/points, "Why is this recyclable?" reasoning, an image upload button (`productService.uploadProductImage` → Firebase Storage), and if `isRecyclable` a "Recycle" button → `recycleService.recycleProduct()` (adds `points` to `totalPoints` and `credits`, writes a `transactions` doc, success dialog → `CustomNavBar`).
4. Not found → `ProductNotFoundPage` → "Search" → `productService.searchAndCreateProduct()` → Barcode Lookup API → Gemini → writes a `products` doc; the stream updates and `ProductPage` re-renders. If the API has nothing → `ManualProductEntryModal` (title + brand) → same Gemini path with empty category/material.

**Work-from-home log flow** (`lib/modules/work_log/`): `WorkLogPage`. If the user has no `transportMethod`/`distanceToOffice`, shows a setup form → `workLogService.updateUserTransportAndDistance()`. Otherwise shows a `TableCalendar` (first day 2022-01-01, last day today; already-logged days disabled), a computed points preview (`WFHCalculator`), and "Log" → `workLogService.logWork()` (points + `transactions` doc with `workLogDate`). A reset button clears transport/distance.

**Vouchers flow** (`lib/modules/vouchers/`): `VouchersPage` splits `VouchersProvider.items` into "My vouchers" (ids in `user.myVouchersIds`) and available. Tap available → `voucherService.purchaseVoucher()` (checks `credits >= cost`, deducts, appends id). Tap owned → `PromoCodeModal` showing a **randomly generated** code (`CodeGenerator.generatePartnerCode`, regenerated on every open — not persisted, not validated by any partner). Long-press/refund → `voucherService.refundVoucher()`.

**Leaderboard** (`lib/modules/leaderboard/`): two toggles, "All Time" (by `totalPoints`) and "Goal" (points from transactions between the company's `goalCreatedTimestamp` and `goalDeadlineTimestamp`), podium for top 3, list for the rest, filtered to the current user's `companyId` and excluding `role == 'admin'`.

**Environmental impact** (`lib/modules/environmental_impact/`): `ImpactDashboardPage` (CO2e saved, equivalents, summary) → `ImpactDetailsPage` (full equivalents/projections) and `ImpactMilestonesPage` (four thresholds: 25/100/500/1000 kg).

**News** (`lib/modules/news/`): `NewsPage` lists the Firestore `news` collection newest-first; `RefreshIndicator` and a button both call `newsService.refreshNews()`; tap → `url_launcher` external browser.

**Profile** (`lib/modules/profile/pages/profile_page.dart`): memoji avatar, name, points/credits, and a settings list. "Edit profile" shows a "coming soon" snackbar; "Account Information", "Security", "Contact Support", "Terms & Conditions" have **empty `onTap` bodies**; only "Logout" works (`confirmDialog` → `authService.logOut()`). Memoji is never changeable in-app (no write to `memojiPath` anywhere in `lib/`).

---

### Q12. How is the Gemini integration structured — prompting, response parsing, malformed responses?

All in `lib/modules/recycle/services/gemini_service.dart` (265 lines), called only from `lib/modules/recycle/services/product_service.dart:_createProductInFirestore`.

**Setup**: `google_generative_ai ^0.4.7`. `GeminiService.initialize()` is called once in `main.dart` and builds `GenerativeModel(model: 'gemini-2.0-flash', apiKey: AppConfig.geminiApiKey)`. The key is a string constant in `lib/core/config.dart`. No `generationConfig` (so no `responseMimeType: 'application/json'`, no temperature, no `responseSchema`), no safety settings, no system instruction — everything is in the user prompt.

**Prompt** (`_buildAnalysisPrompt`, ~130 lines of template): one text `Content`. It:
- Injects title, brand, and a `region` (hard-coded default `'EU'`; the parameter is never passed by callers).
- Conditionally appends category/material/description as "guaranteed" info if non-empty, or lists them under "Missing Information to Research" and instructs the model to "research on the internet" (the SDK call has no tool/grounding enabled, so the model cannot actually browse — it will answer from parametric knowledge).
- Embeds a rubric: five tiers (aluminium 16–20 pts, PET/HDPE/clear glass 11–15, cardboard/coloured PET 6–10, mixed plastics 3–5, multilayer 0–2), regional modifiers, "quality factors", and the fixed conversion "each point ≈ 0.2 kg CO2e".
- Requests "ONLY this JSON" with keys `isRecyclable`, `points`, `category`, `material`, `description`, `primaryMaterial`, `co2eSavingsKg`, `recoveryRatePercent`, `reasoning`, `studyBasis`.

**Parsing** (`_parseAiResponse`): takes `response.text`, trims, slices from the first `{` to the last `}` (to strip markdown fences or prose), `json.decode`s, and reads six of the ten requested keys with null-coalescing defaults (`isRecyclable ?? false`, `(points as num?)?.round() ?? 0`, strings → `'Unknown'`/`'No description available'`). `primaryMaterial`, `co2eSavingsKg`, `recoveryRatePercent`, `studyBasis` are requested but discarded. There is no range check on `points` (a model answer of 500 would be stored as 500) and no type check on `isRecyclable` (a string `"true"` would throw inside the cast and hit the fallback).

**Malformed / failed responses** — two layers:
1. Parse failure (`json.decode` throws, or no braces) → returns `GeminiResult(isRecyclable: false, points: 0, category/material: 'Unknown', description: 'Failed to analyze product', reasoning: 'Failed to parse AI response: $error')`. This is then **persisted to Firestore as the product** by `product_service.dart`, so a transient bad response permanently marks that barcode non-recyclable with 0 points; there is no retry and no UI to re-run the analysis.
2. API call failure (network, quota, safety block → `response.text == null` is handled as empty string, which goes to layer 1) → catch block returns a heuristic `GeminiResult` from `_basicRecyclabilityCheck` (keyword match on `plastic|paper|cardboard|metal|aluminum|glass` in category/material → `isRecyclable`, and `_basicPointsCalculation` → 10 or 0), with `reasoning: 'AI analysis failed, using basic logic: $error'`. For manual entries (empty category/material) this always yields 0 points.

Other observations: three `print()` debug statements log the raw response; there is no timeout on `generateContent`; there is no caching of prompts (but see Q13 — the `products` collection means each barcode is analysed once); the prompt's "2024–2025 data" claims are asserted in the prompt text, not sourced.

---

### Q13. What exactly does the Firestore caching layer do? Cache key strategy, invalidation, measurable call reduction?

**There is no component named or designed as a "caching layer".** Three things behave like caches; the answer covers each honestly.

**(a) In-memory collection mirrors — `lib/data/providers/base_provider.dart`.** Each of the six `BaseProvider<T>` subclasses opens one `collection(...).snapshots()` stream (via `base_repository.dart:getDocumentsStream`) when `SessionManager.startListeningToProviders()` runs after login, and holds the latest full list in `_items`. All reads in the UI (`context.select(...)` in the `modules/*/providers/*.dart` builder widgets) come from these lists, so pages never issue their own queries.
- Key strategy: none — the key is the collection name; every stream is unfiltered (`fieldName == null` in all six `startListening()` calls), so the whole `users`, `transactions`, `vouchers`, `companies`, `products`, and `news` collections are downloaded and kept live for every signed-in user.
- Invalidation: push-based by Firestore's realtime listener; no TTL. Cleared on `stopListening()` at logout (`_items = []`).
- Call reduction: it removes per-page queries, but replaces them with six persistent listeners that receive every document change in the project. Cost scales with total documents across all companies, not with what the user views. No measurements exist in the repo.

**(b) Firestore SDK's own offline cache.** Not configured (no `FirebaseFirestore.instance.settings`). Android default (`persistenceEnabled: true`) applies implicitly; nothing in the code reads with `Source.cache`. Not a designed layer.

**(c) Firestore as a cache for external APIs** — the effective "caching" in the product's sense:
- `products` collection: `ProductPage` first checks `ProductsProvider.items` for a matching `barcode` (`lib/modules/recycle/providers/product_data_provider.dart`). Only if absent does the user reach `ProductNotFoundPage` and trigger the Barcode Lookup + Gemini calls in `product_service.dart`. Key = barcode string (compared in memory, not by document ID — `addDocument` uses auto-IDs, so duplicates are possible if two users scan the same new barcode concurrently). Never invalidated: a product's analysis is permanent, including the failure results described in Q12.
- `news` collection: `news_service.dart:loadNewsIfEmpty` calls NewsAPI only when the collection is empty; `refreshNews` fetches and dedups **by title** against existing docs before `addDocument`. Key = article title. No expiry; the collection grows monotonically. `NewsConfig.fromDate/toDate` are computed once at class-load (`DateTime.now()` static initialisers in `config.dart`), so the 7-day window is frozen for the app process lifetime.

**Measurable reduction**: nothing in the repo measures it — no counters, no analytics, no benchmarks, no docs. Structurally, (c) yields at most one Barcode Lookup + one Gemini call per unique barcode ever scanned across all users, and one NewsAPI call per app-install-until-collection-non-empty plus one per manual refresh. That is the only defensible quantitative claim.

---

### Q14. How is barcode scanning implemented — which package, and any handling for bad scans?

**Package**: `mobile_scanner ^7.0.0` (`pubspec.yaml`). Implementation is `lib/modules/recycle/pages/barcode_scanner_page.dart` (319 lines), launched from `lib/modules/recycle/services/recycle_service.dart:scanBarcode`.

**Implementation**:
- `MobileScannerController()` with default settings — no `formats:` restriction (accepts QR, Data Matrix, etc., not just EAN/UPC), no `detectionSpeed`, no `detectionTimeoutMs`, no `returnImage`.
- `MobileScanner(onDetect:)` callback: guarded by a local `bool isScanned`; on the first `BarcodeCapture` whose `barcodes.first.rawValue != null`, sets `isScanned = true` and calls `widget.onBarcodeDetected(rawValue)`, which does `Navigator.pop(barcode)`. `recycle_service.dart` then pushes `ProductPage(barcode: result)`.
- UI: full-screen camera, 50 % black overlay with a centred square cut-out (70 % of width), animated scanning line (`ScanningLineAnimation`), torch toggle (`cameraController.toggleTorch()`), instruction text. No manual-entry fallback from the scanner itself (manual entry only appears later if the API lookup fails, `manual_product_entry_modal.dart`).
- Controller is disposed in `dispose()`.

**Handling of bad scans — mostly not present**:
- No validation of the decoded value: no length check, no numeric check, no EAN-13/UPC-A checksum, no format filter. A QR code containing a URL would be accepted and sent as `?barcode=https://…` to the Barcode Lookup API.
- No debounce/confirmation: the very first frame that yields any barcode wins. There is no "same value seen N times" confirmation, so partial or mis-read codes are accepted.
- No camera-permission handling in this page: `mobile_scanner` will render its own error widget if permission is denied; the app does not request or explain the permission (`permission_handler` is a dependency but is not used in the scanner path).
- No `errorBuilder` on `MobileScanner`, so camera init failures show the plugin's default.
- Downstream, a "bad" (unknown) barcode simply becomes `ProductNotFoundPage` → API lookup → manual entry, which is the only recovery path.

---

### Q15. How is the maps/recycling-points feature built? Which SDK, is the data static or queried?

**No map SDK.** There is no `google_maps_flutter`, `flutter_map`, `mapbox`, or any tile rendering in `pubspec.yaml` or `lib/`. The feature is a **list + "open in external maps app"**.

**Data: static, bundled in the APK.**
- `assets/recycling_points.json` (~124 KB, declared in `pubspec.yaml`), 326 points. Schema per point: `id`, `name`, `latlng: [lat, lng]`, `subheading`, `address`, `materials: [String]`, `info.offers_money`. Materials are Romanian strings (e.g. "Plastic", "Hârtie & carton", "DEEE"); 1 of 326 points has `offers_money: true`.
- Provenance: `recycling_locations_scraper/main.py` scrapes `localizare.hartareciclarii.ro` (Harta Reciclării, a Romanian recycling-map site) via its Inertia.js JSON endpoints for a Bucharest bounding box (`config.py`), then fetches per-point details and reduces them with `extract_point_info`. Full run yields 1,932 points (`points_only.json`); the bundled asset is exactly the union of two smaller runs, `output/home_points_only.json` (162) + `output/upb_points_only.json` (164) — i.e. two neighbourhoods, presumably around the author's home and the Politehnica campus. The asset is therefore a demo subset, not city-wide coverage. Not queried at runtime; not in Firestore; no update mechanism other than re-running the scraper and rebuilding the app.

**Runtime logic** — `lib/modules/recycle/services/recycling_points_service.dart` (all static):
- `_loadFromJson()` reads the asset with `rootBundle.loadString`, parses into `RecyclingPointModel` (`lib/data/models/recycling_point.dart`), memoised in `_cachedPoints`.
- `getCurrentLocation()` uses `geolocator ^10.1.0`: checks service enabled, checks/requests permission, `getCurrentPosition(desiredAccuracy: high, timeLimit: 10s)`; returns `null` on any failure (no distinction surfaced to the UI beyond "no permission").
- `getNearbyPoints()` does a linear scan over all 326 points with a Haversine great-circle distance (`_calculateDistance`, Earth radius 6371 km), keeps those within `AppConfig.recyclingPointsRadiusKm = 0.5`, and sorts ascending. No spatial index (unnecessary at this size).
- `openInMaps()` uses `url_launcher`: tries a `geo:` URI first, falls back to a Google Maps web URL, else a snackbar. Android `<queries>` for `https` and `geo` are declared in the manifest for this.

**UI**: `RecyclePage` shows the closest point card; `RecyclingLocationListPage` lists all in-radius points; `RecyclingPointDetailModal` shows subheading, distance (`formattedDistance` → "350m"/"1.2km"), address, material chips, and the offers-money badge. No map tiles, pins, or routing anywhere.

---

### Q16. What's the Firestore data model — collections, and any security rules?

**Six collections**, each defined by a repository in `lib/data/repositories/` and a model in `lib/data/models/`. All documents use Firestore auto-IDs (`addDocument` → `.add()`); the model's `docId` mirrors `doc.id`. Field lists are from each model's `toMap()`:

| Collection | Fields | Notes |
|---|---|---|
| `users` | `uid`, `name`, `email`, `pin`, `totalPoints`, `credits`, `companyId`, `role`, `myVouchersIds: [String]`, `transportMethod`, `distanceToOffice`, `createdAt`, `memojiPath` | `uid` duplicates the Auth UID but the doc ID is not the UID — lookups are `where('uid' == …)`. `role` is `'user'` or `'admin'` (admins excluded from rankings). `pin` is unused while PIN is disabled. |
| `transactions` | `value`, `userUid`, `timestamp`, `workLogDate` | Append-only ledger. `workLogDate == null` ⇒ recycle transaction; non-null ⇒ WFH log. Points are also denormalised into `users.totalPoints`/`credits`. |
| `companies` | `goalPoints`, `goalCreatedTimestamp`, `goalDeadlineTimestamp`, `type`, `region` | Referenced by `users.companyId`. `type` (e.g. `'tech'`) and `region` (`'EU'`/`'US'`) feed `WFHCalculator`. No name field. New sign-ups are hard-wired to doc `355aInOtLhMaQm6fyMCh`. |
| `products` | `barcode`, `title`, `description`, `category`, `brand`, `material`, `imageUrl`, `isRecyclable`, `points`, `reasoning` | Written once per barcode by `product_service.dart` from Barcode Lookup + Gemini output. |
| `vouchers` | `cost`, `description`, `name`, `partner` | Catalogue, read-only from the app. `partner` keys into `lib/modules/vouchers/utils/constants.dart:partnerLogos`. |
| `news` | `source`, `author`, `title`, `description`, `url`, `urlToImage`, `publishedAt` | Mirrored from NewsAPI. |

Also Firebase Storage: `product_images/product_<barcode>_<millis>.jpg` (`lib/modules/recycle/services/image_upload_service.dart`).

Timestamps are typed `dynamic` in the models (`createdAt`, `timestamp`, `workLogDate`, `goal*Timestamp`) and are written as Dart `DateTime` but read back as Firestore `Timestamp` and `.toDate()`-ed at use sites (`home_data_provider.dart`, `work_log_provider.dart`, `env_impact_provider.dart` handles both).

**Consistency**: no transactions or batched writes for point changes. `recycle_service.dart` and `work_log_service.dart` each do three sequential awaits (`totalPoints`, `credits`, then `transactions.add`); `voucher_service.dart` does two. A failure mid-way leaves the user doc and ledger inconsistent, and concurrent updates on the same user can lose increments (read-modify-write from the in-memory provider snapshot, no `FieldValue.increment`).

**Security rules: not present in the repository.** There is no `firestore.rules`, `firestore.indexes.json`, `storage.rules`, or `.firebaserc`; `firebase.json` only contains the FlutterFire platform config. `TO-DO.md` lists "firestore security rules + other firebase products" as an open item. Whatever rules exist live only in the Firebase console for project `bachelor-project-47b18` and cannot be verified from the repo. Given that the client reads all six collections unfiltered and writes arbitrary field values to `users` (including its own `credits`), rules that enforce per-user access or server-side point validation would break the current client, which suggests permissive rules — but that is inference, not evidence.

---

### Q17. How are the CO₂ calculations implemented and where does the data come from?

Three calculators, all pure Dart with hard-coded constants; no external emissions API and no server-side computation.

**Common conversion**: `1 point = 0.2 kg CO2e`. Declared as `KG_CO2E_PER_POINT = 0.2` in both `lib/modules/work_log/providers/wfh_calculator.dart` and `lib/modules/environmental_impact/providers/env_impact_calculator.dart`, and restated in the Gemini prompt (`gemini_service.dart`: "Each point represents approximately 0.2 kg CO2e savings"). The comment calls it "Our proposed scale" — i.e. an app-defined unit, not a measured one.

**(1) Recycling points** — `lib/modules/recycle/services/gemini_service.dart`. Points per product (0–20) are assigned by Gemini following the rubric embedded in the prompt (tiered by material, with recovery-rate and "quality factor" multipliers). The prompt cites figures such as "aluminium 94 % carbon savings, 43 % US recovery (2023)", "PET 71 % GHG reduction, 29 % recovery", "cardboard 83.2 % EU recovery", and attributes them to "International Aluminum Institute, EPA, and EU recycling statistics" — but no URLs, DOIs, or bibliography exist anywhere in the repo, and the numbers are only inside the prompt string. If Gemini fails, the fallback is a flat 10 points for any keyword-matched recyclable material and 0 otherwise. The returned `co2eSavingsKg` from the model is discarded; the app recomputes CO2e as `points × 0.2` downstream.

**(2) Work-from-home day points** — `wfh_calculator.dart:calculateSingleDayPoints`:
- Office energy saved per day: `OFFICE_ENERGY_SAVINGS_BASE_KG = 1.34` (comment: "Cornell study exact figure") × a company-type modifier (`tech 1.2 … retail 0.6`, comment "CONSERVATIVE modifiers") × a regional-grid modifier (`US 1.0, EU 0.9, Canada 0.85, Australia 1.1, UK 0.92`).
- Commute saved: `2 × distanceToOffice(km) × emissionFactor[region][transport]`, with per-km factors in `TRANSPORT_EMISSIONS_BY_REGION` — e.g. car US 0.189 kg/km ("EPA 2024: 0.67 lbs/mile"), car EU 0.165 ("UK Gov 2024"), transit 0.045–0.050, bike 0.033 ("Our World in Data"), walk 0, mixed ≈0.085–0.095. `region` comes from `companies.region`; `distanceToOffice`/`transportMethod` from the user doc.
- Sum is capped at `MAX_DAILY_SAVINGS = 4.06` kg ("Cornell study (29.11 % reduction)"), divided by 0.2, rounded, and clamped to 1–40 points. Because of the 4.06 cap, the practical maximum is ~20 points/day regardless of distance.
- Inconsistency: `region` lookups use the raw string for transport (`'US'`/`'EU'`, else `'default'`) but `.toUpperCase()` for office modifiers (`'CANADA'`, `'AUSTRALIA'`, `'UK'` keys would therefore never match their mixed-case map entries).

**(3) Impact dashboard equivalents** — `env_impact_calculator.dart:calculateImpactAwareness`, driven by `env_impact_provider.dart` with `totalPoints` and days since `users.createdAt`:
- `co2eSavedKg = totalPoints × 0.2`, `dailyRate = co2e / days`.
- Equivalents constants: tree absorption 21.8 kg/yr, car 0.189 kg/km, smartphone charge 8.4 g, PET bottle 0.025 kg ("estimated"), LED-vs-incandescent 0.000045 kg/h ("estimated"), coal 2.86 kg CO2e/kg. Contextual comparison uses `US_INDIVIDUAL_ANNUAL_CO2E_TONNES = 17.9` ("University of Michigan 2024"). Projections are linear (`daily × 7/30/365`); milestones at 25/100/500/1000 kg.
- The home card's "emissions saved" is `totalPoints × KG_CO2E_PER_POINT` (`home_data_provider.dart`).

**Where the data comes from — summary**: every numeric input is a compile-time constant with an inline comment naming a source family (Cornell, EPA 2024, UK Gov 2024, Our World in Data, University of Michigan, IAI, EU statistics). Several are explicitly marked "estimated". No source is linked, versioned, or reproducible from the repo, and the constants are not tested. The repo does not contain a methodology document; the closest is the prompt text itself and commit messages `a8c9f1c "update WFH algorithm"` and `3610f22 "improve Gemini recyclability prompt"`.
