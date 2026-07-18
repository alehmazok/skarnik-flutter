<div align="center">
  <img src="assets/branding/logo.png" alt="Skarnik logo" width="120" />

  # Skarnik (Скарнік)

  Belarusian dictionary app — Бел-Рус, Рус-Бел, and Тлумачальны dictionaries in one place.

  [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
  ![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS-blue)
  ![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
</div>

## About

Skarnik is a mobile dictionary app for Belarusian, offering word search, translation, and browsing across three dictionaries:

- **Бел-Рус** — Belarusian to Russian
- **Рус-Бел** — Russian to Belarusian
- **Тлумачальны** — Explanatory (monolingual) dictionary

## Features

- Fast offline word search via local ObjectBox database
- Word translation and detail lookup with HTTP caching
- Word stress (nacisk) lookup, with GrammarDB-backed fallback if the primary source fails
- Favorites / bookmarks
- Search history
- Deep linking support
- Firebase Analytics & Crashlytics integration

## Tech Stack

- [Flutter](https://flutter.dev) — Android & iOS
- **State management:** [flutter_bloc](https://pub.dev/packages/flutter_bloc) (Cubit/Bloc)
- **Dependency injection:** [get_it](https://pub.dev/packages/get_it) + [injectable](https://pub.dev/packages/injectable)
- **Routing:** [go_router](https://pub.dev/packages/go_router)
- **Local storage:** [ObjectBox](https://pub.dev/packages/objectbox)
- **Networking:** [Dio](https://pub.dev/packages/dio) with [dio_http_cache_lts](https://pub.dev/packages/dio_http_cache_lts)
- **Backend:** Firebase (Analytics, Crashlytics) + Supabase/Django API fallback

## Architecture

Clean Architecture, feature-first structure. Each feature is split into `data/`, `domain/`, and `presentation/` layers.

```
lib/
├── core/               # UseCaseResult, exceptions, extensions
├── features/
│   ├── app/            # DI, routing, app BLoC, ObjectBox entities
│   ├── home/            # History tab
│   ├── search/          # Word search (ObjectBox)
│   ├── translation/     # Translation detail (Dio API + cache)
│   ├── favorites/       # Bookmarks
│   ├── vocabulary/      # Dictionary browse
│   └── settings/        # Clear history
├── widgets/             # Shared widgets
└── main.dart
```

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (see `pubspec.yaml` for the required version)
- Android Studio / Xcode for platform toolchains

### Setup

```bash
git clone git@github.com:alehmazok/skarnik-flutter.git
cd skarnik-flutter
flutter pub get
```

### Run

```bash
flutter run

# With custom API host
flutter run --dart-define=API_HOSTNAME=https://api.example.com
```

### Build

```bash
flutter build apk --release
flutter build ios --release
```

### Code generation

After changing DI annotations or ObjectBox entities:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Tests

```bash
flutter test
```

## Data Sources

- **[skarnik.by](https://www.skarnik.by)** — dictionary content (Бел-Рус, Рус-Бел, Тлумачальны)
- **[starnik.by](https://starnik.by)** — primary source for word stress (nacisk) data
- **[GrammarDB](https://github.com/Belarus/GrammarDB)** — fallback source for word stress data, licensed under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/)

## Contributing

This is a personal project. Issues and pull requests are welcome — please open an issue to discuss significant changes before submitting a PR.

## License

Source code licensed under the [MIT License](LICENSE). Dictionary content is © its respective rights holders and is not covered by this license.
