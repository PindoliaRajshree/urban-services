# urban_service

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Local config

### Google Maps API key

The Google Maps API key is not committed. Put it (`MAPS_API_KEY`) in these
three gitignored files:

| File | Used by | How |
|---|---|---|
| `dart_defines.json` | Dart (Geocoding API calls) | Copy `dart_defines.example.json`. Run with `flutter run --dart-define-from-file=dart_defines.json` (same flag for `flutter build`). |
| `android/local.properties` | Android map widget | Add a line `MAPS_API_KEY=...`. Flutter keeps extra lines when it rewrites this file. |
| `ios/Flutter/Secrets.xcconfig` | iOS map widget | Copy `ios/Flutter/Secrets.xcconfig.example`. |

Without the key the map stays blank and reverse geocoding falls back to the
on-device geocoder.

### Optional overrides in `dart_defines.json`

Leave a key out to use the default. Don't set it to `""`: an empty value
counts as set and replaces the default.

| Key | Default | When to set it |
|---|---|---|
| `API_BASE_URL` | The shared testing backend | Point a build at another backend (e.g. production). Must end with `/`. |
| `ANDROID_CERT_SHA1` | The release keystore's SHA-1 | Debug builds: set it to the debug keystore's SHA-1 (no colons; from `cd android && ./gradlew signingReport`) so the Geocoding API accepts calls from `flutter run`. Allow that SHA-1 on the key in Cloud Console too. |
