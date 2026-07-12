# Fuzzy Search — Implementation Spec (for iOS port)

Source of truth: Flutter app, `lib/features/search/` (local dictionary DB, currently ObjectBox).
Goal: reproduce identical matching behavior and ranking on iOS, against SQLite.

This spec describes the algorithm in database-independent terms. Where the Flutter
implementation leans on ObjectBox-specific mechanics, an equivalent SQLite approach
is suggested — treat those as suggestions, not requirements; match on behavior/output,
not on storage engine.

## 1. Data model

Each searchable word record needs these fields:

| Field | Type | Notes |
|---|---|---|
| `id` | int | local PK |
| `langId` | int | maps to dictionary (0=rusBel, 1=belRus, 2=tsbm) |
| `letter` | string | **first character of `lword`**, precomputed. Used to bucket fuzzy candidates. Index this column. |
| `wordId` | int | remote/canonical word id, unique |
| `word` | string | original display form |
| `lword` | string | lowercased word. Index this column. |
| `lwordMask` | string? | lowercased word variant used for accent/diacritic-insensitive matching, nullable. Index this column. |

`letter` and `lword`/`lwordMask` are pre-lowercased by the dictionary build pipeline — no runtime normalization needed beyond what's described below.

SQLite mapping: a single `search_words` table with these columns, plus indexes on
`letter`, `lword`, and `lwordMask` (`CREATE INDEX ... ON search_words(letter)`, etc.)
is sufficient — no need for a separate FTS/virtual table, since all lookups here are
either exact prefix matches or app-side scoring over a pre-filtered row set.

## 2. Query normalization

Before any search:

1. Lowercase the input query.
2. Apply letter substitutions to produce a second variant, `searchQueryWithSubstitutions`:

```
и → і
е → ё
щ → ў
ъ → ‘
' → ‘
```

(These normalize common Belarusian/Russian look-alike letters and typewriter apostrophes so users don't need the exact Belarusian keyboard.)

Both `searchQuery` and `searchQueryWithSubstitutions` are used in every step below (OR'd together).

## 3. Search pipeline (in order)

### Step A — exact prefix match on `lword`

Conceptually: `lword STARTS WITH searchQuery OR lword STARTS WITH searchQueryWithSubstitutions`

SQLite: `SELECT * FROM search_words WHERE lword LIKE ?1 || '%' OR lword LIKE ?2 || '%' ORDER BY lword LIMIT 15`
(bind `searchQuery` / `searchQueryWithSubstitutions` as `?1`/`?2`; escape any literal `%`/`_` in the query if present, or use `GLOB` instead of `LIKE` to avoid wildcard-escaping entirely — `lword GLOB ?1 || '*'`).

### Step B — exact prefix match on `lwordMask`

Same as A but against `lwordMask`, **excluding** any ids already returned by Step A
(`AND id NOT IN (...)`).

Combine A ∪ B (dedupe by id) → `combinedExact`.

### Step C — fuzzy fallback (only runs if applicable)

Fuzzy search triggers **only when both**:
- `combinedExact` is empty (no exact/prefix hits at all), AND
- `searchQuery.length >= 3` (`fuzzySearchMinQueryLength`)

If not applicable, return `combinedExact` as-is (empty results included).

If applicable:

1. **Candidate bucket**: pull all words where `letter == searchQueryWithSubstitutions[0]` (first character of the *substituted* query), excluding ids already in `combinedExact`. Cap this candidate set at **65,000** rows (`fuzzySearchCandidateLimit`) — sized to safely exceed the largest single-letter bucket in the dataset (~62k, letter "П", ~316k total words as of 2026-07-02). If your dataset is meaningfully different, resize this cap so it still exceeds the largest bucket.

   SQLite: `SELECT * FROM search_words WHERE letter = ?1 AND id NOT IN (...) LIMIT 65000`.
   This is a plain indexed equality lookup — any embedded SQL engine handles it the same way; nothing ObjectBox-specific here.

2. **Score** (in application code, not SQL): compute Damerau-Levenshtein edit distance between `searchQueryWithSubstitutions` and each candidate's `lword`.
3. **Distance threshold** (`maxDistance`):
   - query length ≤ 5 → `maxDistance = 1`
   - query length > 5 → `maxDistance = 2`
4. **Filter**: keep candidates with `distance <= maxDistance`.
5. **Sort**: by distance ascending, then alphabetically by `lword` ascending (tie-break).
6. **Cap**: take top 15 (`wordsSearchLimit`).

Final result = `combinedExact ∪ fuzzyResults` (dedupe by id; in practice these sets are already disjoint since fuzzy excludes exact-match ids).

Scoring/filtering/sorting/capping happens entirely in-memory, after the candidate
rows are fetched — this step has no database dependency at all. Any language-level
port of the Damerau-Levenshtein function (Swift, in this case) works unchanged.

## 4. Edit distance algorithm

Damerau-Levenshtein (Optimal String Alignment variant, restricted transpositions), not plain Levenshtein — adjacent transpositions (e.g. "паляна" vs "плаяна") count as **1** edit instead of 2.

Standard O(n·m) DP matrix:
- `dp[i][0] = i`, `dp[0][j] = j`
- `dp[i][j] = min(delete, insert, substitute)`, cost 0 if chars equal else 1
- transposition case: if `i>1 && j>1 && a[i-1]==b[j-2] && a[i-2]==b[j-1]`, also consider `dp[i-2][j-2] + cost`, take min

Pure algorithm, no DB dependency. Reference implementation: `lib/features/search/data/util/damerau_levenshtein.dart` (port directly to Swift).

## 5. Performance / threading notes

- The candidate-fetch + scoring for fuzzy search runs off the main thread (Flutter dispatches it to a background isolate). Port equivalently on iOS: run the SQLite query and the DP scoring loop over up to 65k candidates on a background queue/thread (e.g. `Task.detached`, `DispatchQueue.global()`, or whatever queue your SQLite wrapper already uses for reads) — never on the UI thread.
- Exact prefix queries (Steps A/B) are simple indexed lookups and can stay synchronous/fast-path.
- If your SQLite access layer serializes all queries on one connection/thread, make sure the fuzzy candidate query doesn't block exact-match queries from other in-flight searches; a read-only connection or WAL mode helps if this becomes an issue.

## 6. Known limitation (carry over, don't "fix" silently)

Fuzzy matching only searches within the **same first letter** bucket. A typo in the first character of the query (e.g. "к" instead of "г") will never fuzzy-match, even though it's a valid 1-edit-distance typo. This is a deliberate perf/scale tradeoff (avoids Levenshtein over the whole ~316k-word table per query), not a bug. If iOS has looser perf constraints (e.g. smaller dictionary subset, faster device-class assumptions), this is a candidate for improvement, but match current Flutter behavior by default for parity.

## 7. Config constants to port

| Constant | Value | Purpose |
|---|---|---|
| `fuzzySearchMinQueryLength` | 3 | min query length to attempt fuzzy fallback |
| `fuzzySearchCandidateLimit` | 65000 | cap on candidates fetched per first-letter bucket before scoring |
| `wordsSearchLimit` | 15 | max results returned (applies to both exact and fuzzy paths) |

## 8. Files for reference (Flutter side)

- `lib/features/search/data/repository/objectbox_search_repository.dart` — orchestration, substitutions, applicability check
- `lib/features/search/data/repository/query_repository_impl.dart` — DB queries, background dispatch (ObjectBox-specific plumbing; logic is what matters, not the API)
- `lib/features/search/data/util/fuzzy_candidate_ranking.dart` — scoring/filter/sort/cap (pure Dart, no DB dependency)
- `lib/features/search/data/util/damerau_levenshtein.dart` — distance algorithm (pure Dart, no DB dependency)
- `lib/app_config.dart` — constants
- `lib/features/app/data/model/objectbox_search_word.dart` — entity shape (field names/types only; ObjectBox annotations don't apply to SQLite)
