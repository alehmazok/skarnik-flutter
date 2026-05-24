# Feature Plan: In-App Review Request

## Goal

Prompt user to rate the app on Google Play / App Store at the right moment using the native system dialog. No custom UI — fully delegated to the platform.

## Package

**`in_app_review: ^2.0.9`** — wraps `StoreReviewController` (iOS) and `ReviewManager` (Android). System decides whether the dialog actually appears (platform rate-limits it internally).

Also add **`shared_preferences: ^2.3.0`** — persists review request state (key-value, simpler than ObjectBox for this).

---

## Trigger Logic

Request review after a **successful translation load** when all conditions pass:

| Condition | Value | Rationale |
|-----------|-------|-----------|
| Successful translations loaded | ≥ 5 | User has seen real value |
| Days since last request | ≥ 30 | Avoid spam; platform may suppress anyway |
| Total requests ever made | < 3 | Stay well within platform limits |

**Counter increments on every successful translation** (regardless of review trigger).

---

## Architecture

New feature module: `lib/features/review/` following existing clean architecture pattern.

### Domain Layer

**`lib/features/review/domain/repository/review_repository.dart`**
```dart
abstract interface class ReviewRepository {
  Future<bool> shouldRequestReview();
  Future<void> recordTranslationLoaded();
  Future<void> recordReviewRequested();
}
```

**`lib/features/review/domain/use_case/request_review_use_case.dart`**
```dart
@injectable
class RequestReviewUseCase {
  const RequestReviewUseCase(this._repo);
  final ReviewRepository _repo;

  Future<UseCaseResult<bool>> call() async {
    // 1. Increment translation counter
    await _repo.recordTranslationLoaded();
    // 2. Check all conditions
    final should = await _repo.shouldRequestReview();
    if (!should) return const Success(false);
    // 3. Record + trigger (repo handles platform call)
    await _repo.recordReviewRequested();
    return const Success(true);
  }
}
```

### Data Layer

**`lib/features/review/data/repository/in_app_review_repository.dart`** (prod)

```dart
@prod
@Injectable(as: ReviewRepository)
class InAppReviewRepository implements ReviewRepository {
  static const _keyCount = 'review_translation_count';
  static const _keyLastMs = 'review_last_requested_ms';
  static const _keyTotal = 'review_request_total';

  static const _countThreshold = 5;
  static const _cooldownDays = 30;
  static const _maxRequests = 3;

  @override
  Future<bool> shouldRequestReview() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_keyCount) ?? 0;
    final lastMs = prefs.getInt(_keyLastMs);
    final total = prefs.getInt(_keyTotal) ?? 0;

    if (count < _countThreshold) return false;
    if (total >= _maxRequests) return false;
    if (lastMs != null) {
      final daysSince = DateTime.now()
          .difference(DateTime.fromMillisecondsSinceEpoch(lastMs))
          .inDays;
      if (daysSince < _cooldownDays) return false;
    }
    return true;
  }

  @override
  Future<void> recordTranslationLoaded() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_keyCount) ?? 0;
    await prefs.setInt(_keyCount, count + 1);
  }

  @override
  Future<void> recordReviewRequested() async {
    final prefs = await SharedPreferences.getInstance();
    final total = prefs.getInt(_keyTotal) ?? 0;
    await prefs.setInt(_keyLastMs, DateTime.now().millisecondsSinceEpoch);
    await prefs.setInt(_keyTotal, total + 1);
    await InAppReview.instance.requestReview();
  }
}
```

**`lib/features/review/data/repository/dev_review_repository.dart`** (dev)

```dart
@dev
@Injectable(as: ReviewRepository)
class DevReviewRepository implements ReviewRepository {
  final _logger = getLogger(DevReviewRepository);

  @override
  Future<bool> shouldRequestReview() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt('review_translation_count') ?? 0;
    final should = count >= 5; // same threshold, skip date/total checks in dev
    _logger.info('shouldRequestReview: $should (count=$count)');
    return should;
  }

  @override
  Future<void> recordTranslationLoaded() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt('review_translation_count') ?? 0;
    await prefs.setInt('review_translation_count', count + 1);
    _logger.info('Translation count: ${count + 1}');
  }

  @override
  Future<void> recordReviewRequested() async {
    _logger.info('Review requested (dev: no native dialog)');
    // InAppReview.instance.openStoreListing() could be used here for manual testing
  }
}
```

### Integration: TranslationCubit

Inject `RequestReviewUseCase` and call **fire-and-forget** after `TranslationLoadedState` is emitted.

```dart
// In _getWord(), after the final switch case Success:
case Success(result: (final translation, final inFavorites)):
  emitGuarded(TranslationLoadedState(translation: translation));
  emitGuarded(TranslationInFavoritesState(word: translation.word, inFavorites: inFavorites));
  unawaited(requestReviewUseCase());  // <-- add this
```

`TranslationCubit` constructor gets `required this.requestReviewUseCase` added.

Since `TranslationCubit` is **not** injected via `@injectable` (it's constructed manually in the router with runtime params `langId`/`wordId`), the use case must be resolved from `getIt` at construction site.

---

## File Checklist

```
lib/features/review/
├── domain/
│   ├── repository/
│   │   └── review_repository.dart          # abstract interface
│   └── use_case/
│       └── request_review_use_case.dart    # @injectable
└── data/
    └── repository/
        ├── in_app_review_repository.dart   # @prod
        └── dev_review_repository.dart      # @dev

pubspec.yaml                                # add in_app_review, shared_preferences
lib/features/translation/
  presentation/translation_cubit.dart       # inject + call unawaited
  (wherever TranslationCubit is constructed) # resolve requestReviewUseCase from getIt
```

After changes: `dart run build_runner build --delete-conflicting-outputs`

---

## Platform Setup

### Android
No extra setup. `in_app_review` works out of the box on Google Play distributed builds. Does **not** show dialog on debug/sideloaded builds — use dev env to test logic only.

### iOS
No extra setup. Works on TestFlight and App Store builds. Simulator: dialog appears but submission is blocked.

---

## Out of Scope

- Custom "Would you rate us?" pre-prompt UI — unnecessary; platform handles frequency limiting
- Analytics logging for review events — can add later as `LogAnalyticsReviewUseCase` following existing pattern
- Resetting counter on app update — platform handles suppression; not needed

---

## Implementation Order

1. Add `in_app_review` + `shared_preferences` to `pubspec.yaml`, run `flutter pub get`
2. Create `ReviewRepository` interface
3. Create `InAppReviewRepository` (prod) + `DevReviewRepository` (dev)
4. Create `RequestReviewUseCase`
5. Run `build_runner` to regenerate DI
6. Inject `RequestReviewUseCase` into `TranslationCubit`, wire call
7. Test: run 5 translations in debug → verify log output from `DevReviewRepository`
8. Test: on device/TestFlight → verify native dialog appears
