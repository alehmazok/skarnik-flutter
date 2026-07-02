# Search Feature — Known Pitfalls

Reviewed 2026-06-28. All issues in `lib/features/search/`.

---

## 1. Dead code: `isSearchByMaskApplicable` never called [HIGH]

**File:** `data/repository/objectbox_search_repository.dart:48`

Method exists but `search()` always calls `queryByWordMask` regardless of query length.
Intent: skip mask query for queries shorter than 3 chars.

**Fix:** Gate `queryByWordMask` call behind `isSearchByMaskApplicable(searchQuery)`.

```dart
final resultsByWordMask = isSearchByMaskApplicable(searchQuery)
    ? _queryRepository.queryByWordMask(...)
    : const [];
```

---

## 2. `notOneOf([])` with empty excluded list [MEDIUM]

**File:** `data/repository/query_repository_impl.dart:84`

When `queryByWord` returns no results, `excluded` is empty → `notOneOf([])` called.
ObjectBox behavior with empty list is unspecified — could throw or match incorrectly.

**Fix:** Guard the mask query or pass a sentinel value:

```dart
if (excluded.isEmpty) return query.find(); // skip notOneOf entirely
```

Or restructure to only call `queryByWordMask` when `excluded` is non-empty.

---

## 3. Race condition on shared mutable query objects [MEDIUM]

**File:** `data/repository/query_repository_impl.dart:54–84`

`_queryByWord` and `_queryByWordMask` are shared singletons. Each call mutates `.param(...).value` inline. Concurrent calls (possible despite 50ms debounce) corrupt in-flight params.

**Fix:** Either:
- Synchronize access (lock/mutex)
- Create fresh `Query` per call instead of reusing
- Use ObjectBox `QueryBuilder` each time (small perf cost, safe)

---

## 4. Effective result limit is 30, not 15 [LOW]

**File:** `data/repository/query_repository_impl.dart:31,46` + `lib/app_config.dart:8`

`wordsSearchLimit = 15` applied per-query independently. Union returns up to 30 items.
Either rename the constant or apply the limit to the final union.

---

## 5. Redundant OR branch for native Belarusian input [LOW]

**File:** `data/repository/objectbox_search_repository.dart:26`

When user types Belarusian chars not in `letterSubstitutions`, `queryWithSubs == query`.
Both OR branches in DB query hit identical value — wasted work.

**Fix:** Skip substituted query if `searchQueryWithSubstitutions == searchQuery`.
