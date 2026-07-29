# Glued Preposition/Conjunction Search Fallback — Implementation Spec (for iOS port)

Source of truth: Flutter app, `lib/features/search/`. Extends the pipeline described in
`fuzzy_search_spec.md` — read that first, this spec only covers the retry layer wrapped
around it.

## 1. Problem

BigQuery analysis of `search_no_results` events (2026-07-21→27, app version 3.4.6+75+)
found a recurring pattern: users type a one-letter RU/BE preposition or conjunction glued
to the next word, no space — e.g. `всмысле` ("в смысле"), `іранак` ("і ранак").

Root cause: fuzzy search buckets candidates by first letter (`fuzzy_search_spec.md` §3,
step C.1) *before* scoring. `всмысле` buckets on `в`; the target word `смысл` buckets on
`с`. No edit-distance tolerance recovers from a wrong bucket — this is a known limitation
(`fuzzy_search_spec.md` §6), not something the fuzzy step itself can fix.

## 2. Behavior

`search(query)` now returns two things instead of one: the result list, and whether a
fallback retry produced it. iOS should mirror this shape (e.g. a tuple/struct return, or
two output params) — the analytics layer (§4) needs the flag.

```
search(query):
  primary = searchOnce(query)              // full existing pipeline: exact → mask → fuzzy
  if primary is not empty:
    return (words: primary, usedFallback: false)

  stripped = stripGluedPrefixLetter(query)
  if stripped == null:
    return (words: primary, usedFallback: false)   // primary is empty here

  retry = searchOnce(stripped)
  return (words: retry, usedFallback: true)         // retry may itself be empty
```

`searchOnce` is the existing full pipeline (exact/mask/fuzzy) from `fuzzy_search_spec.md`
§3 — unchanged, called once on the original query, and at most once more on the stripped
query. No recursion, no loop: at most 2 calls total.

```
stripGluedPrefixLetter(query):
  if query.length < 2: return null
  if query[0] not in gluedPrefixLetters: return null
  return query.substring(1)
```

The `length < 2` guard exists so a single-character query never strips down to `""` (which
would otherwise match every word as a prefix).

Note the retry is on the **raw stripped substring**, not re-normalized query text — e.g.
`всмысле` → `смысле` (6 chars), which itself won't exact/mask-match `смысл` (shorter,
inflected form) but *will* fuzzy-match it. The retry must run the full pipeline, not just
the exact-match steps.

## 3. Letter set

```
{ а, в, ж, з, и, і, к, о, с, у, ў }
```

Data-derived, not guessed: this is the union of every single-letter dictionary entry
tagged "предлог/прыназоўнік" (preposition) or "союз/злучнік" (conjunction) across all
three dictionaries (belrus/rusbel/tsbm), queried from the production `main_word` table.
Notably includes `ж` and `ў` (Belarusian conjunctions) that a manual guess would likely
miss, and confirms letters like `в`/`к`/`о`/`с` are legitimate despite colliding with
common word-initial letters — safe because the fallback only ever fires after the primary
pass already found **zero** results, so a bad retry costs an irrelevant zero-result state,
never a lost correct result.

Keep this list in sync with Flutter's `_gluedPrefixLetters`
(`lib/features/search/data/repository/objectbox_search_repository.dart`) if it's ever
revised — don't let the two platforms drift.

## 4. Analytics

Both `search_performed` and `search_no_results` (see `search_analytics_spec.md` §2) gain
one new parameter:

```json
{ "used_preposition_fallback": <int, 0 or 1> }
```

**int, not bool** — same constraint as the rest of this app's Firebase events (native
param types are String/int/double only). `1` when the emitted result set came from the
stripped-query retry (§2's `usedFallback: true` case, regardless of whether the retry
itself found results or not — a double-miss still logs `used_preposition_fallback: 1` on
`search_no_results`), `0` otherwise. Default `0` if the param is omitted on older code
paths that haven't been touched.

No changes to `search_result_tapped` or the §3 debounce/firing timing in
`search_analytics_spec.md` — this only adds one param to the two existing settle events.

This flag exists specifically to measure real-world recovery rate via the same BigQuery
query that found the original bug — grouping `search_performed`/`search_no_results` by
`used_preposition_fallback` post-release.

## 5. Files for reference (Flutter side)

- `lib/features/search/data/repository/objectbox_search_repository.dart` — `search()`,
  `_stripGluedPrefixLetter()`, `_gluedPrefixLetters` constant
- `lib/features/search/domain/repository/search_repository.dart` — return-type contract
- `lib/features/search/domain/use_case/search_use_case.dart` — passthrough
- `lib/features/search/presentation/search_cubit.dart` — forwards the flag into the two
  analytics use cases on settle
- `lib/features/search/domain/repository/analytics_search_repository.dart`,
  `firebase_analytics_search_repository.dart` — `used_preposition_fallback` param wiring
- Tests: `test/features/search/search_repository_test.dart`, group `'glued preposition
  fallback'` — real repro cases validated against production Supabase data (`всмысле` →
  `смысл`, `іранак` → `ранак`, `узгадва` → `згадва`, `ураўніннасць` → `раўніннасць`,
  `усціш` → `сціш`) plus negative cases (non-glued letter, primary already found results,
  single-char query, double-miss stays empty)
