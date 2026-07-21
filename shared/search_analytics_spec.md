# Search Analytics — Technical Spec

Source of truth: `skarnik_flutter` (Flutter/Dart reference implementation). Goal: iOS app fires the
same three Firebase Analytics events, with identical event names and parameter keys, so BigQuery
queries against the shared `analytics_<id>` export dataset work uniformly across both platforms
without per-platform branching.

## 1. Concept

The dictionary search screen previously had zero analytics. This closes the biggest blind spot in
the app's core loop (search → tap a result → view translation → favorite/share): there was no way
to see search→view conversion, no signal for zero-result searches (a proxy for dictionary content
gaps), and no signal for result-tap position (ranking quality). Three events were added:

| Event name | Fires when |
|---|---|
| `search_performed` | A search settles with 1+ results |
| `search_no_results` | A search settles with 0 results |
| `search_result_tapped` | User taps an item in the results list |

All three are fire-and-forget: never block the search UI or navigation on them, and never let a
failure to log propagate into the search/navigation flow (swallow and log locally instead).

## 2. Event definitions

### `search_performed`

Parameters:
```json
{ "query": "<the search query string, trimmed>", "result_count": <int> }
```
Fired once the query has 1+ results (see §3 for the settle/debounce condition — see the note below,
`result_count` is never 0 for this event; a 0-result settle fires `search_no_results` instead, never
both).

### `search_no_results`

Parameters:
```json
{ "query": "<the search query string, trimmed>" }
```
Fired instead of `search_performed` when the settled query returns exactly 0 results. Mutually
exclusive with `search_performed` for the same settle.

### `search_result_tapped`

Parameters:
```json
{
  "word_id": <int>,
  "lang_id": <int>,
  "word": "<the tapped word's display text>",
  "dict_name": "<Dictionary enum name, e.g. \"belRus\"/\"rusBel\"/\"tsbm\">",
  "dict_path": "<Dictionary path segment, e.g. \"belrus\"/\"rusbel\"/\"tsbm\">",
  "position": <int, 0-based index of the tapped item in the results list>,
  "query": "<the query string that was active when the list was shown>"
}
```
Fired on tap, before navigating to the translation screen. `dict_name`/`dict_path`/`word_id`/
`lang_id` are the same fields already logged by the existing `translation` and `add_to_favorites`
events (see `firebase_analytics_translation_repository.dart` in the Flutter repo) — reuse whatever
per-word dictionary/id fields the iOS app already sends for those events, so the values are
consistent across all three event types.

## 3. Firing logic / timing (must replicate exactly)

The search list itself updates fast — Flutter debounces the underlying query-as-you-type at 50ms
purely for UI responsiveness. If `search_performed`/`search_no_results` fired on that same 50ms
cadence, a single word typed at normal speed would fire several events for intermediate substrings
("м", "мо", "мов", "мова"), polluting volume and making the funnel numbers meaningless.

To avoid this, analytics firing uses a **second, independent 500ms debounce**, layered on top of
(not replacing) the UI-responsiveness debounce:

1. User types → UI-level search fires (its own ~50ms debounce, unchanged) → results list updates
   immediately, no analytics yet.
2. Every time a search settles with a result (success or empty), (re)start/reset a 500ms timer
   carrying that settle's `(query, resultCount)`.
3. If the user keeps typing before 500ms elapses, the previous timer is cancelled and a new one
   started with the latest `(query, resultCount)` — so only the *last* settle in a burst of typing
   ever fires an event.
4. When the 500ms timer finally elapses uninterrupted, fire exactly one event:
   `search_performed` if `resultCount > 0`, else `search_no_results`.
5. If the user clears the search field entirely (empty query), do **not** fire anything — this is
   "user cleared input," not a search.
6. If the screen/view is dismissed/torn down while a timer is pending, cancel it — don't fire after
   dismissal.

`search_result_tapped` has no debounce — it fires immediately and synchronously (still
fire-and-forget/non-blocking) on every tap, independent of the 500ms analytics timer described
above.

## 4. Environment gating (Flutter-side context, port equivalent if iOS has a debug/release split)

Flutter has two analytics repository implementations selected at build time: a "dev" build variant
logs each event locally instead of calling Firebase (so engineers see events fire during
development without polluting production data), and "prod" calls the real
`FirebaseAnalytics.instance.logEvent(...)`. This is purely a local-logging convenience — the event
names/params/firing logic above apply identically regardless of which impl is active. Port whatever
equivalent debug-vs-release analytics gating the iOS app already uses for its other events; no new
mechanism is needed for this feature specifically.

## 5. Non-goals / explicit exclusions

- No dictionary-scoped `search_performed`/`search_no_results` — search runs across all three
  dictionaries simultaneously in one flat result list, so these two events are not attributable to
  a single dictionary. Only `search_result_tapped` carries dictionary info, since that's per-item.
- No raw-keystroke-level events — only the debounced settle (§3) and the tap (immediate) fire.
- No query redaction/hashing — the raw query string is logged as-is, matching the existing house
  convention where `translation`/`add_to_favorites` already log the full word text unredacted (not
  treated as PII in this app).
- No retry/queueing if the Firebase call fails — errors are caught and dropped locally (same
  fire-and-forget contract as every other analytics event in this app).

## 6. Reference implementation locations (Flutter, for cross-checking only)

- `lib/features/search/domain/repository/analytics_search_repository.dart` — interface (3 methods,
  one per event)
- `lib/features/search/data/repository/firebase_analytics_search_repository.dart` — prod impl,
  exact `FirebaseAnalytics.instance.logEvent(name:, parameters:)` calls with the param keys in §2
- `lib/features/search/data/repository/dev_analytics_search_repository.dart` — dev/log-only impl
- `lib/features/search/domain/use_case/log_analytics_search_performed.dart`
- `lib/features/search/domain/use_case/log_analytics_search_no_results.dart`
- `lib/features/search/domain/use_case/log_analytics_search_result_tapped.dart`
- `lib/features/search/presentation/search_cubit.dart` — `_debounceSearchAnalytics()` (§3 timer
  logic) and `onResultTapped()` (tap logging)
- `lib/features/search/presentation/widgets/search_list_view.dart` — tap handler wiring
  (`context.read<SearchCubit>().onResultTapped(word, index, query)` before navigation)
- Tests: `test/features/search/search_cubit_test.dart` — covers the settle→state pipeline this
  hooks into (analytics calls themselves are mocked/not directly asserted in that test file).
