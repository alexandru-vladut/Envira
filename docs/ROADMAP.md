# Roadmap

Known gaps and planned improvements — see [PROJECT_QA.md](PROJECT_QA.md) for a fuller evidence-based audit of current limitations.

## General
- firestore security rules + other firebase products
- proxy third-party API calls (Gemini, Barcode Lookup, NewsAPI) through a backend (e.g. a Cloud Function) so
  keys never ship inside the client binary — `--dart-define-from-file` keeps them out of git, but anything
  compiled into the APK is still extractable by decompilation
- separate colors and texts in other files
- improve dialog widgets design
- project structure and configuration (Coding with T on YT)
- onboarding screen (Coding with T on YT)
- responsive UIs (flutter util vs MediaQuery) => refactor whole app
- .arb localizations

## Login
- live update errors in text field forms as user is typing
- New UI for landing pages, PIN code pages and others
- Sign in with Google
