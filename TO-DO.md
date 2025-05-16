# TO DO

- improve dialog widgets design
- use only needed icons from assets

- Tutoriale YT config, splash screen, onboarding screen (with on/off config variable, not shared pref)
- Kit UI login
- New UI for landing pages, PIN code pages and others
- Sign in with Google - backend

- separate colors and texts in other files
- responsive layout (flutter util vs MediaQuery)
- .arb localizations

## Commands

- After changing app icon: dart run flutter_launcher_icons
- After changing splash screen icon: dart run flutter_native_splash:create --path=flutter_native_splash.yaml
- You may also update the Gradle version used by running
`./gradlew wrapper --gradle-version=<COMPATIBLE_GRADLE_VERSION>`.

## Creating a new entity

1. Model
2. Repository/Service (to be added in app_constants.dart)
3. [Optional] Provider (to be added in main(), startListeningToProviders() and stopListeningToProviders())
