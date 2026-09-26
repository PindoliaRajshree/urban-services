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

## Local secrets

The Google Maps API key is not committed. Put it (`MAPS_API_KEY`) in these
three gitignored files:

| File | Used by | How |
|---|---|---|
| `dart_defines.json` | Dart (Geocoding API calls) | Copy `dart_defines.example.json`. Run with `flutter run --dart-define-from-file=dart_defines.json` (same flag for `flutter build`). |
| `android/local.properties` | Android map widget | Add a line `MAPS_API_KEY=...`. Flutter keeps extra lines when it rewrites this file. |
| `ios/Flutter/Secrets.xcconfig` | iOS map widget | Copy `ios/Flutter/Secrets.xcconfig.example`. |

Without the key the map stays blank and reverse geocoding falls back to the
on-device geocoder.
