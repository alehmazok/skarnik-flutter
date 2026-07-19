# Word Stress (Націск) Feature — Technical Spec

Source of truth: `skarnik_flutter` (Flutter/Dart reference implementation). Goal: align iOS app's
existing single-source stress lookup with this dual-source (primary + fallback) behavior.

## 1. Concept

Skarnik shows a "На́ціск" (stress) table for a word: its full declension/conjugation paradigm with
stress marks on each form. Data comes from two independent backends. There is **no merge** of
results — it's a strict cascade: try primary, and only if primary yields nothing usable, try
fallback. Each source has its own ID space, so once a wordId is resolved from a given source, all
follow-up calls for that word must stay pinned to that same source.

## 2. The two sources

### Primary: "api" source — starnik.by (live HTML scrape)

- Base URL: `https://starnik.by`
- Word candidates: `GET /api/wordList?lemma={word}` → JSON:
  ```json
  { "word_list": [ { "id": 123, "lemma": "слова", "word": "сло́ва", "table_name": "Nouns" }, ... ] }
  ```
  - `id`: int, starnik.by's own numeric id (**only valid within this source**)
  - `lemma`: unstressed form (compared against the plain search query)
  - `word`: stressed display form
  - `table_name`: optional part-of-speech key (see §5 for display mapping), nullable
- Stress table: `GET /pravapis/{wordId}` → HTML page (not JSON). Parse:
  - Select `.wrapper table` in the document.
  - For each `<tr>` with exactly 2 `<td>` cells, emit one row: `title = td[0].innerHTML`,
    `content = td[1].innerHTML` (row content is **HTML**, not plain text — must be rendered as
    HTML/rich text, not raw string, since it contains markup like `<font>`/italics/spans for
    styling individual stressed syllables).
  - If no table found, or no valid rows → empty list.
- HTTP client should apply response caching (Flutter side caches per `http_cache_duration_in_hours`
  remote-config value). Not a functional requirement, just a perf note.

### Fallback: "cloud" source — Skarnik's own Django/MariaDB API

- **Not Supabase.** Originally launched on Supabase (commit `3012c51`), but the `stress_word` table
  (248k rows, ~486MB) pushed the free-tier project over its 500MB cap, so storage moved to the
  existing Django/MariaDB backend — **`skarnik_admin`** (https://github.com/alehmazok/skarnik_admin,
  the same backend that already serves skarnik.by and the translation API) — as of commit `3ed3150`
  ("fix: switch stress cloud fallback from Supabase to Django API"). Data itself still originates
  from a one-time bulk import from GrammarDB (https://github.com/Belarus/GrammarDB); only the
  *storage/serving* backend changed, not the data provenance.
  - Note: `lib/features/stress/domain/repository/cloud_stress_repository.dart`'s doc comment still
    says "Supabase-backed" — that's stale in the Flutter codebase itself, left over from before the
    migration. Don't follow it; follow this spec / the actual `ApiStressRepositoryImpl` code instead.
- Base URL in production: `https://skarnik.play.of.by` (Flutter reads it from `AppConfig.apiHostName`
  — same host used for translation lookups, configured via `--dart-define=API_HOSTNAME=...`).
- This fallback exists to cover words starnik.by doesn't have, or when starnik.by is unreachable.
- Word candidates: `GET /api/stress_words/?word={word.lowercased()}` → JSON array:
  ```json
  [ { "id": 456, "word": "слова", "lemma": "сло́ва", "table_name": null }, ... ]
  ```
  **Important field-name gotcha**: in this endpoint's JSON, `word` is the *unstressed* form and
  `lemma` is the *stressed* form — inverted from what the field names suggest, and inverted from
  the primary/starnik.by convention. When mapping into the shared domain model, swap them:
  entry.lemma = json.word, entry.word = json.lemma. This keeps the domain model's meaning
  consistent across both sources: `lemma` = unstressed (used for exact-match comparison against the
  search query), `word` = stressed (used for display). Get this swap wrong and cloud-sourced exact
  matches will silently never match.
- Stress table: `GET /api/stress_words/{wordId}/` → JSON:
  ```json
  { "id": 456, "rows": [ { "title": "...", "content": "..." }, ... ] }
  ```
  `rows[].title` / `rows[].content` are HTML strings, same rendering requirement as the primary
  source's parsed HTML cells.
- Same one wire model can serve both endpoints (fields are nullable depending which endpoint
  populated them) — not a functional requirement, just how the Flutter side structures it.

## 3. Domain model (shared shape both sources map into)

```
StressSource: enum { api, cloud }   // tags which backend a StressWordEntry.id belongs to

StressWordEntry:
  id: Int              // only unique within its own source — never compare ids across sources
  lemma: String         // unstressed form
  word: String          // stressed display form
  tableName: String?    // optional part-of-speech tag, drives the label in the disambiguation list
  source: StressSource

StressRow:
  title: String   // HTML
  content: String // HTML
```

## 4. Fallback orchestration logic

### 4a. Word resolution (search → candidate list)

Given a search `word: String`:

1. Call primary `resolveWordList(word)`. Filter the returned entries to **exact** matches:
   `entry.lemma == word` (case-sensitive, exact string equality — not fuzzy).
2. If the filtered list is non-empty → **success**, return it. **Do not call the fallback.**
3. If the primary call throws/network-fails → log a warning, and proceed to fallback (do not
   propagate the error yet).
4. If the primary call succeeded but the exact-match filter yielded an empty list → also proceed to
   fallback (this is the "primary has no data for this word" case, distinct from an error).
5. Call fallback `resolveWordList(word)` (note: cloud endpoint takes `word.lowercased()` per §2).
   Filter to exact matches the same way.
6. If the fallback list is empty → return **not-found** (a distinct empty-result state, not an
   error — no error was necessarily thrown).
7. If the fallback call throws → return **error** (propagate it — this is a real failure, not a
   "not found").
8. Otherwise → **success**, return the fallback's exact matches.

Net effect: primary and fallback results are never combined. It's "primary if it has an exact
match, else cloud if it has an exact match, else not-found/error."

### 4b. Stress table fetch (candidate selected → show table)

Given `(wordId: Int, source: StressSource)` (source must be whatever tagged the entry the user
picked, or the sole entry if there was only one exact match):

1. Route strictly by `source`: `source == .api` → call primary's `getStressTable(wordId)`;
   `source == .cloud` → call fallback's `getStressTable(wordId)`.
2. **No cross-source retry of any kind.** If the call for that source fails, or returns an empty
   row list, return failure/not-found immediately. Do not attempt the other source. Reason: the two
   sources' ids are independent (unrelated numbering schemes) — retrying wordId `456` against the
   other source could return a completely wrong word's table by coincidence, so it must never be
   attempted.
3. Empty row list → not-found. Thrown error → error (propagate).

## 5. UI / UX flow to replicate

1. User triggers stress lookup for a word (either from a "На́ціск" action on the translation page,
   which extracts stress-candidate word(s) from the currently-displayed translation, or from
   whatever entry point the app already has).
2. Run §4a (word resolution) for the tapped word.
   - Exactly 1 exact match → skip straight to the table (auto-select, no candidate list shown;
     replace the current screen rather than pushing, since there's nothing meaningful to go "back"
     to in the selection flow).
   - 2+ exact matches → show a disambiguation list: each row shows `entry.word` (stressed form) as
     title, and if `entry.tableName` is present, a localized part-of-speech label as subtitle (see
     mapping table below; if the tableName has no mapping, just show the raw tableName). Tapping an
     entry pushes to the table screen for that entry's `(id, source)`.
   - 0 exact matches after both sources tried → show a "not found" message
     ("Інфармацыя аб націску для гэтага слова не знойдзена.") and dismiss the flow.
   - Error (fallback threw) → show a generic error message
     ("Адбылася памылка падчас загрузцы інфармацыі аб націску.").
3. Table screen: run §4b for `(id, source)`, render `StressRow` list as a 2-column table
   (title | content), each cell rendered as HTML (both columns can contain inline markup — at
   minimum expect font-color spans and italics; the Flutter renderer applies custom styling to
   specific CSS classes `.pytanne` (italic, secondary/muted color, smaller font — used for
   question/comment asides in the table) and `.skarot` (italic, medium weight, a fixed reddish
   accent color `#F44C3E` — used for abbreviated/shortened forms); replicate that distinction if the
   iOS HTML renderer supports per-class styling, otherwise plain HTML rendering is an acceptable
   first pass). Same not-found / error states as above if the table call fails.
4. Screen title throughout: "На́ціск" (note: contains a combining acute accent character — copy
   exactly, don't retype).

### Part-of-speech label mapping (for `tableName` subtitle)

```
Adjectives   → Прыметнік
Adverbs      → Прыслоўе
Conjunctions → Злучнік
Interjections→ Выклічнік
Nouns        → Назоўнік
Numerals     → Лічэбнік
Particles    → Частка
Participles  → Дзеепрыметнік
Prepositions → Прыназоўнік
Pronouns     → Займеннік
Verbs        → Дзеяслоў
```

## 6. UI copy (Belarusian, verbatim)

| Key | Text |
|---|---|
| Screen title | На́ціск |
| Select-word prompt (disambiguation list header) | Абярыце слова: |
| Not-found message | Інфармацыя аб націску для гэтага слова не знойдзена. |
| Error message | Адбылася памылка падчас загрузцы інфармацыі аб націску. |

## 7. Analytics

Fire a `stress_clicked` event with parameter `{"word": <the searched word string>}` when the stress
flow is entered (fire-and-forget, don't block/await it, don't let its failure affect the UI flow).

## 8. Non-goals / explicit exclusions

- No merging of primary + fallback results into one combined list.
- No retrying the *other* source when a table fetch fails for the resolved source — ids aren't
  transferable between sources.
- No fuzzy/partial matching in the exact-match filter — it's plain string equality against the
  unstressed `lemma`.

## 9. Reference implementation locations (Flutter, for cross-checking only)

- `lib/features/stress/domain/entity/stress_source.dart`
- `lib/features/stress/domain/entity/stress_word_entry.dart`
- `lib/features/stress/domain/entity/stress_row.dart`
- `lib/features/stress/domain/repository/stress_repository.dart` (primary interface)
- `lib/features/stress/domain/repository/cloud_stress_repository.dart` (fallback interface)
- `lib/features/stress/domain/use_case/resolve_stress_word_list.dart` (§4a logic)
- `lib/features/stress/domain/use_case/get_stress_table.dart` (§4b logic)
- `lib/features/stress/data/repository/starnik_stress_repository.dart` (primary impl, HTML scrape)
- `lib/features/stress/data/repository/api_stress_repository_impl.dart` (fallback impl, JSON API
  against skarnik_admin/Django, not Supabase — see §2)
- `lib/features/stress/data/model/cloud_stress_word_model.dart` (field-swap mapping, §2 gotcha)
- `lib/features/stress/presentation/stress_cubit.dart` (state machine for §5 flow)
- `lib/features/stress/presentation/widgets/stress_html_cell.dart` (HTML cell styling, §5)
- `lib/strings.dart` (lines ~27-30, ~35-47 — UI copy and part-of-speech map)
- Tests: `test/features/stress/**` — cover every branch of §4a/§4b exactly; use as acceptance
  criteria if porting tests too.
