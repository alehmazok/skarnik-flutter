# Skarnik Flutter — Claude Code Context

## Project

Belarusian dictionary app (Скарнік). Three dictionaries: Бел-Рус, Рус-Бел, Тлумачальны. Flutter, Android + iOS. Firebase analytics/crashlytics, deep linking, ObjectBox local DB.

## Architecture

Clean Architecture. Feature-first structure under `lib/features/`. Each feature has `data/`, `domain/`, `presentation/` layers.

```
lib/
├── core/               # UseCaseResult, exceptions, extensions
├── features/
│   ├── app/            # DI, routing, app BLoC, ObjectBox entities
│   ├── home/           # History tab
│   ├── search/         # Word search (ObjectBox)
│   ├── translation/    # Translation detail (Dio API + cache)
│   ├── favorites/      # Bookmarks
│   ├── vocabulary/     # Dictionary browse
│   └── settings/       # Clear history
├── widgets/            # Shared widgets
└── main.dart
```

## State Management

- **flutter_bloc** — Cubit/Bloc pattern
- **get_it + injectable** — DI (`lib/di.skarnik.config.dart` is generated, don't edit)
- **go_router** — navigation (`skarnik_router.dart`)

## Key Patterns

### Result type — always use for use case returns

```dart
sealed class UseCaseResult<R> extends Equatable {}
class Success<R> extends UseCaseResult<R> { final R result; }
class Failure<R> extends UseCaseResult<R> { final dynamic error; final StackTrace? stackTrace; }
```

Pattern-match with `switch` on `UseCaseResult`.

### Use case structure

```dart
@injectable
class MyUseCase {
  const MyUseCase(this._repo);
  final MyRepository _repo;
  Future<UseCaseResult<T>> call(...) async { ... }
}
```

### Dictionary enum

```dart
enum Dictionary {
  belRus(langId: 1, path: 'belrus'),
  rusBel(langId: 0, path: 'rusbel'),
  tsbm(langId: 2, path: 'tsbm'),
}
```

### Analytics pattern

Two implementations per analytics repo: `DevAnalytics*` (logs only) and `FirebaseAnalytics*`. Never await analytics calls.

### ObjectBox entities

Implement domain interfaces. Annotated with `@Entity`, `@Id`, `@Unique`, `@Index`. See `lib/features/app/data/model/`.

## Key Files

| File | Purpose |
|------|---------|
| `lib/main.dart` | Bootstrap, Firebase init |
| `lib/app_config.dart` | Constants (API host, page sizes) |
| `lib/strings.dart` | Belarusian UI strings |
| `lib/core/base_use_case.dart` | UseCaseResult sealed class |
| `lib/di.skarnik.config.dart` | **Generated** — DI wiring |
| `lib/objectbox.g.dart` | **Generated** — ObjectBox |
| `lib/serializers.g.dart` | **Generated** — BuiltValue |
| `lib/features/app/presentation/skarnik_router.dart` | Routes |
| `lib/features/translation/data/http/skarnik_dio.dart` | Dio instance |

## Generated Files — Never Edit Manually

- `lib/di.skarnik.config.dart` — `dart run build_runner build`
- `lib/objectbox.g.dart` — `dart run build_runner build`
- `lib/serializers.g.dart` — `dart run build_runner build`
- `lib/features/translation/data/model/api_word_model.g.dart`

After changing DI annotations or ObjectBox entities: `dart run build_runner build --delete-conflicting-outputs`

## Build & Run

```bash
# Run
flutter run

# With env vars
flutter run --dart-define=API_HOSTNAME=https://api.example.com

# Build
flutter build apk --release
flutter build ios --release

# Regenerate code
dart run build_runner build --delete-conflicting-outputs

# Tests
flutter test
```

## Testing

- `flutter_test` — unit/widget
- `bloc_test` — Cubit/Bloc
- `mocktail` — mocking
- Tests in `test/` mirroring `lib/` structure

## Conventions

- UI language: Belarusian (all strings in `lib/strings.dart`)
- iOS font: SF Pro (platform-specific only)
- HTTP caching: `dio_http_cache_lts` in `SkarnikDio`
- API pattern: `{apiHostName}/api/words/{dictionary.path}/{wordId}/`
- Analytics: fire-and-forget (no await), separate dev/prod impls
- Prefer constructor injection; use `@injectable`/`@lazySingleton`/`@singleton` annotations
