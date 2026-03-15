# Skarnik Flutter App - Codebase Context

## Overview

**Skarnik** (Скарнік) is a Belarusian dictionary and translation mobile application built with Flutter. The app provides access to three dictionaries:
- **Бел-Рус** (Belarusian-Russian)
- **Рус-Бел** (Russian-Belarusian)  
- **Тлумачальны** (Explanatory/Belarusian dictionary)

The app is available on Android and iOS, uses Firebase for analytics/crash reporting, and supports deep linking.

---

## Architecture

### Clean Architecture Layers

```
lib/
├── core/                          # Shared utilities
│   ├── base_use_case.dart         # UseCase result types (Success/Failure)
│   └── exceptions.dart            # Custom exceptions
├── features/                      # Feature modules
│   ├── app/                       # App-level features
│   │   ├── data/                  # Data layer (repositories impl, models)
│   │   │   ├── model/             # ObjectBox entities
│   │   │   ├── repository/        # Repository implementations
│   │   │   └── service/           # Services (ObjectBox store holder)
│   │   ├── domain/                # Domain layer
│   │   │   ├── entity/            # Domain entities
│   │   │   ├── repository/        # Repository interfaces
│   │   │   └── use_case/          # Use cases
│   │   └── presentation/         # Presentation layer
│   │       ├── skarnik_app.dart   # Main app widget
│   │       ├── skarnik_router.dart # GoRouter configuration
│   │       └── skarnik_app_bloc.dart # App-level BLoC
│   ├── home/                      # History/Search tab
│   ├── search/                    # Search functionality
│   ├── translation/               # Translation detail view
│   ├── favorites/                # Bookmarks feature
│   ├── vocabulary/                # Dictionary browse feature
│   └── settings/                  # Settings feature
├── widgets/                       # Shared widgets
└── main.dart                      # Entry point
```

### State Management

- **flutter_bloc** for state management using Cubit/Bloc pattern
- **get_it** for dependency injection (configured in [`lib/di.skarnik.config.dart`](lib/di.skarnik.config.dart))
- **go_router** for navigation

### Data Persistence

- **ObjectBox** for local database storage
- Data stored in `assets/objectbox/data.mdb`
- Entities: `ObjectboxSearchWord`, `ObjectboxFavoriteWord`, `ObjectboxHistoryWord`

### API Layer

- **Dio** HTTP client with caching (dio_http_cache_lts)
- API hostname configured via `AppConfig.apiHostName` (can be set via environment variable)
- Endpoint pattern: `{apiHostName}/api/words/{dictionary_path}/{wordId}/`

---

## Key Files Reference

### Entry Point & Configuration

| File | Purpose |
|------|---------|
| [`lib/main.dart`](lib/main.dart) | App entry point, Firebase initialization |
| [`lib/app_config.dart`](lib/app_config.dart) | App configuration constants |
| [`lib/strings.dart`](lib/strings.dart) | Localized strings (Belarusian) |
| [`lib/di.skarnik.config.dart`](lib/di.skarnik.config.dart) | Dependency injection setup |

### Core Domain Entities

| Entity | Location | Description |
|--------|----------|-------------|
| [`Word`](lib/features/app/domain/entity/word.dart) | `lib/features/app/domain/entity/word.dart` | Represents a dictionary word |
| [`SearchWord`](lib/features/app/domain/entity/search_word.dart) | `lib/features/app/domain/entity/search_word.dart` | Interface for search results |
| [`Dictionary`](lib/features/app/domain/entity/dictionary.dart) | `lib/features/app/domain/entity/dictionary.dart` | Enum for dictionary types |
| [`Translation`](lib/features/translation/domain/entity/translation.dart) | `lib/features/translation/domain/entity/translation.dart` | Translation result |

### Dictionary Types

Defined in [`lib/features/app/domain/entity/dictionary.dart`](lib/features/app/domain/entity/dictionary.dart):

```dart
enum Dictionary {
  belRus(langId: 1, path: 'belrus'),    // Belarusian → Russian
  rusBel(langId: 0, path: 'rusbel'),    // Russian → Belarusian  
  tsbm(langId: 2, path: 'tsbm'),        // Explanatory dictionary
}
```

### Key Use Cases

| Use Case | Location | Description |
|----------|----------|-------------|
| [`GetTranslationUseCase`](lib/features/translation/domain/use_case/get_translation.dart) | `lib/features/translation/domain/use_case/` | Fetches translation from API |
| [`SearchUseCase`](lib/features/search/domain/use_case/search_use_case.dart) | `lib/features/search/domain/use_case/` | Searches words in local DB |
| [`AddToFavoritesUseCase`](lib/features/translation/domain/use_case/add_to_favorites.dart) | `lib/features/translation/domain/use_case/` | Adds word to bookmarks |
| [`LoadVocabularyUseCase`](lib/features/vocabulary/domain/use_case/load_vocabulary.dart) | `lib/features/vocabulary/domain/use_case/` | Loads dictionary words |

### State Management (BLoC/Cubit)

| Cubit | Location | Purpose |
|-------|----------|---------|
| [`SkarnikAppBloc`](lib/features/app/presentation/skarnik_app_bloc.dart) | `lib/features/app/presentation/` | App initialization, remote config |
| [`TranslationCubit`](lib/features/translation/presentation/translation_cubit.dart) | `lib/features/translation/presentation/` | Translation detail page state |
| [`SearchCubit`](lib/features/search/presentation/search_cubit.dart) | `lib/features/search/presentation/` | Search functionality |
| [`VocabularyCubit`](lib/features/vocabulary/presentation/vocabulary_cubit.dart) | `lib/features/vocabulary/presentation/` | Dictionary browse |
| [`FavoritesCubit`](lib/features/favorites/presentation/favorites_cubit.dart) | `lib/features/favorites/presentation/` | Bookmarks management |
| [`HistoryCubit`](lib/features/history/presentation/history_cubit.dart) | `lib/features/history/presentation/` | Search history |

### Navigation Routes

Defined in [`lib/features/app/presentation/skarnik_router.dart`](lib/features/app/presentation/skarnik_router.dart):

```
/                     → HomePage (with bottom navigation)
/search               → SearchPage
/settings             → SettingsPage
/translate/:langId/:wordId → TranslationPage (by ID)
/translate/word       → TranslationPage (by Word object)
```

### Data Models

| Model | Type | Purpose |
|-------|------|---------|
| [`ApiWordModel`](lib/features/translation/data/model/api_word_model.dart) | BuiltValue | API response model |
| [`ObjectboxSearchWord`](lib/features/app/data/model/objectbox_search_word.dart) | ObjectBox Entity | Local search index |
| [`ObjectboxFavoriteWord`](lib/features/app/data/model/objectbox_favorite_word.dart) | ObjectBox Entity | Bookmarks storage |
| [`ObjectboxHistoryWord`](lib/features/app/data/model/objectbox_history_word.dart) | ObjectBox Entity | Search history |

---

## Dependencies

### Key Dependencies (from [`pubspec.yaml`](pubspec.yaml))

| Package | Version | Purpose |
|---------|---------|---------|
| flutter_bloc | ^9.1.1 | State management |
| get_it | ^8.2.0 | Dependency injection |
| go_router | ^14.6.2 | Navigation |
| objectbox | ^5.2.0 | Local database |
| dio | ^5.9.2 | HTTP client |
| firebase_core, firebase_analytics, firebase_crashlytics | various | Firebase services |
| built_value | ^8.12.4 | JSON serialization |
| injectable | ^2.5.1 | DI code generation |
| equatable | ^2.0.8 | Value equality |
| rxdart | ^0.28.0 | Reactive extensions |

---

## Development Patterns

### Result Type Pattern

The app uses a custom `UseCaseResult<R>` sealed class for handling success/failure:

```dart
sealed class UseCaseResult<R> extends Equatable {}

class Success<R> extends UseCaseResult<R> {
  final R result;
}

class Failure<R> extends UseCaseResult<R> {
  final dynamic error;
  final StackTrace? stackTrace;
}
```

Usage with extension methods:
```dart
final result = await useCase();
switch (result) {
  case Failure(error: final error): 
    // handle error
  case Success(result: final data): 
    // handle data
}
```

### ObjectBox Entity Pattern

Entities are defined with annotations and implement domain interfaces:

```dart
@Entity(uid: 1)
class ObjectboxSearchWord implements SearchWord {
  @Id(assignable: false)
  int id = 0;
  
  @Unique()
  int wordId;
  
  @Index(type: IndexType.value)
  String lword;
  // ...
}
```

### Dependency Injection

Dependencies are registered in [`lib/di.skarnik.config.dart`](lib/di.skarnik.config.dart) using Injectable:

```dart
gh.factory<MyUseCase>(() => MyUseCase(gh<MyRepository>()));
gh.lazySingleton<MyRepository>(() => MyRepositoryImpl());
```

---

## Build & Run

### Build Commands

```bash
# Debug build
flutter build apk --debug
flutter build ios --debug

# Release build
flutter build apk --release
flutter build ios --release
```

### Environment Variables

```bash
# API hostname (optional, defaults to empty)
--dart-define=API_HOSTNAME=https://api.example.com

# Dev email for feedback
--dart-define=DEV_EMAIL_ADDRESS=dev@example.com
```

### Firebase Configuration

Firebase is configured via [`lib/firebase_options.dart`](lib/firebase_options.dart) with platform-specific configurations in:
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

---

## Testing

Tests are located in `test/` directory and use:
- **flutter_test** - Unit and widget testing
- **bloc_test** - BLoC/Cubit testing
- **mocktail** - Mocking

---

## Important Notes

1. **Language**: The app UI is in Belarusian (see [`lib/strings.dart`](lib/strings.dart))
2. **Platform-specific**: Font family "SF Pro" is used on iOS only
3. **Caching**: Translations are cached using Dio HTTP cache
4. **Analytics**: Separate implementations for dev (logging only) and prod (Firebase)
5. **Deep Linking**: Supports app links via `app_links` package
