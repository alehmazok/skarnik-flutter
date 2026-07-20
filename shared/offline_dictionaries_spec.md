# Offline Dictionary Download Feature — Technical Spec

Source of truth: `skarnik_flutter` (Flutter/Dart reference implementation). Goal: let the iOS app
replicate full offline-download parity — user can download an entire dictionary to local storage,
and word lookups then prefer the local copy over network calls.

## 1. Concept

Skarnik has 3 dictionaries (`belRus`, `rusBel`, `tsbm` — see enum below). From the Settings screen,
a user can download any subset of them in full for offline use. A download is a resumable,
rate-limited, paginated bulk fetch from the cloud backend into a local on-device store. Once a
dictionary is downloaded, word lookups for that dictionary's words are served from local storage
first, with network sources (API → cloud → website) as fallback only when the local row is missing.

Non-goals: no partial/selective download (it's whole-dictionary or nothing), no background/OS-level
download (must be foregrounded in-app, though it survives navigating away from Settings), no
delta/incremental re-sync of an already-completed download (only supports resume of an
*interrupted* download, or a full re-download).

## 2. Data model

### Dictionary enum

```
belRus: langId=1, path="belrus"
rusBel: langId=0, path="rusbel"
tsbm:   langId=2, path="tsbm"
```

`path` is the URL segment / cloud `direction` column value. `langId` is the key used in local
storage.

### Downloaded word record (per dictionary, per word)

Fields: `externalId` (int, cloud row's word id within its dictionary), `stress` (string, nullable),
`translation` (string, HTML), `redirectTo` (string, nullable — word was merged/redirected to
another entry).

Local storage key is a **composite** of `langId:externalId` (e.g. `"1:4821"`) — `externalId` alone
is *not* unique across dictionaries, since each direction has its own id sequence in the cloud
table. Local storage upsert-replaces on key conflict (safe to re-download/re-write in place).

## 3. Cloud backend (source for download)

Backend: Supabase, table `main_word`, same table translation lookups already use.

### Count total words

```
GET (Supabase select) main_word?select=id&direction={dictionary.path}&count=exact&limit=1
```
Returns exact row count for that dictionary — used as the download's progress denominator.

### Paginated cursor-based fetch

```
GET (Supabase select) main_word
  ?select=id,external_id,stress,translation,redirect_to
  &direction=eq.{dictionary.path}
  &id=gt.{cursor}
  &order=id.asc
  &limit={pageSize}
```

- `pageSize` default: **5000** rows per page.
- `cursor` starts at 0 (fetch everything) or a persisted resume cursor (see §4).
- Cursor for the *next* page = `id` of the **last** row in the current page (cloud's own internal
  `id`, not `external_id` — note `id` and `external_id` are different columns; the cursor tracks
  `id`, the downloaded word record stores `external_id`).
- Empty page (0 rows) signals the stream is exhausted — stop.
- Each page's rows map into downloaded word records: `translation.external_id → externalId`,
  `translation.stress → stress`, `translation.translation → translation`,
  `translation.redirect_to → redirectTo`.

### Retry policy

A full download is ~20 sequential page requests; treat transient failures as retryable, not fatal:
- Retry up to **5 attempts** per page.
- Backoff: `500ms * attemptNumber` between attempts (linear, so 500ms, 1000ms, 1500ms, 2000ms
  before the 5th and final attempt).
- Retry on any network/timeout/generic exception (including backend statement-timeout errors seen
  in practice). Do **not** retry on a programming-error class of failure — treat those as fatal
  immediately.
- After exhausting retries, the page fetch fails and the whole download stream errors out (see §5
  for how the UI surfaces this).

## 4. Download orchestration (resume + progress)

State needed, persisted locally per dictionary (survives app restarts):
- **Cursor**: last successfully-persisted cloud `id` for this dictionary, or 0/absent if nothing to
  resume from. Persist the cursor after *every* page is successfully written locally (not just at
  the end) — this is what makes resume granular to the last complete page.
- **Rate-limit attempt log**: see below.

### Start/resume algorithm

1. Fetch `total` = cloud count for the dictionary (§3).
2. Read `localCount` = number of rows already stored locally for this dictionary.
3. Read `startCursor` = persisted cursor for this dictionary (0 if none).
4. **Stale-cursor guard**: if `startCursor > 0` but `localCount == 0`, treat the cursor as invalid
   (e.g. local storage was wiped outside the app's own delete flow) — clear it and reset
   `startCursor = 0`. Resuming from a stale cursor with no local data would silently skip that gap
   forever.
5. Compute initial `done` for progress reporting:
   - If resuming (`startCursor > 0`): `done = localCount`.
   - If starting fresh (`startCursor == 0`): `done = 0`, **even if `localCount > 0`**. A fresh
     start re-fetches from page 1 and idempotently overwrites everything via the composite-key
     upsert, so counting pre-existing local rows here would double-count against `total`. (This
     matters for a partial download that predates a resume-cursor feature and never had a cursor
     recorded.)
6. Emit progress `{done, total}` immediately (before any network call), then for each page fetched
   from cursor onward:
   - Write the page's words to local storage.
   - `done += page.rowCount`.
   - Persist the new cursor.
   - Emit progress `{done, total}`.
7. On stream exhaustion (empty page), clear the persisted cursor for this dictionary (download
   complete, nothing to resume).

Progress fraction for UI = `done / total` (guard `total == 0` → `0`).

### Rate limiting (download *attempts*, not pages)

Applies to starting a download (tap-to-download), not to page-fetch retries within an active
download.
- Window: **5 minutes**.
- Max attempts per window: **4**.
- On each download-start attempt: prune the persisted attempt-timestamp list to only those within
  the last 5 minutes.
  - If pruned list already has ≥4 entries → **reject** this attempt (still persist the pruned list,
    so stale entries don't linger). Caller shows a "too many attempts" message.
  - Otherwise → append now's timestamp, persist, **allow** the attempt.
- This check happens before rate-limit-gated work starts; a rejected attempt does not count against
  the limit itself (only successful/allowed starts are recorded).

### Delete downloaded dictionary

Clears all locally-stored words for that `langId` and clears the persisted cursor for that
dictionary. Fully separate from rate limiting (deleting is not rate-limited).

## 5. UI / state flow (Settings screen)

Per-dictionary state machine, one of:
- **Not downloaded** — default.
- **Downloading** — carries `{done, total}` progress.
- **Downloaded** — carries local `wordCount`.
- **Download failed** — carries the error; tapping again retries (falls back to "not downloaded"
  tile visually, but the resume cursor from §4 still applies under the hood if any pages succeeded
  before the failure).

State is **app-scoped**, not screen-scoped: a download must keep running (and keep updating
progress) even if the user navigates away from Settings — otherwise leaving the screen mid-download
would visually truncate it. On (re)entering Settings, per-dictionary "Downloaded" state is
initialized by counting local rows for each dictionary (any dictionary with `count > 0` shows as
Downloaded with that count).

### Row states, per dictionary tile

| State | Leading icon | Title | Subtitle |
|---|---|---|---|
| Not downloaded | download icon | dictionary short name | "Спампаваць для афлайн доступу" |
| Download failed | download icon | dictionary short name | "Адбылася памылка падчас спампоўкі слоўніка." |
| Downloading | spinner | dictionary short name | "Спампоўваецца…" + linear progress bar (`value = done/total`) + "`{done} / {total} слоў`" |
| Downloaded | checkmark/download-done icon | dictionary short name | "Спампавана: `{wordCount}` слоў" + trailing delete (trash) icon button |

Dictionary short names: `belRus` → "Бел-Рус", `rusBel` → "Рус-Бел", `tsbm` → "Тлумачальны".

- Tapping a "Not downloaded" / "Download failed" row starts the download for that dictionary.
  - If rejected by rate limit: show a snackbar/toast: **"Занадта шмат спроб спампоўкі. Паспрабуйце
    праз некалькі хвілін."** ("Too many download attempts. Try again in a few minutes.")
- Tapping the trash icon on a "Downloaded" row opens a confirm dialog:
  - Title: **"Увага"** ("Attention")
  - Message: **"Вы сапраўды жадаеце выдаліць афлайн-копію слоўніка «{dictionaryName}»?"**
    ("Do you really want to delete the offline copy of the «{name}» dictionary?")
  - Buttons: Cancel = **"Не"**, Confirm = **"Так"**. Confirm triggers delete (§4).

### Section heading

Above the dictionary rows, a section label: **"Афлайн доступ"** (or equivalent "Offline access"
heading — Flutter's `Strings.offlineMode`).

## 6. Promo badge (drives discovery of the feature)

A one-time, unread-style badge dot on the Settings entry point (gear icon in the main/History
screen's app bar), independent from per-dictionary download state:

- Persisted flag: `offline_dictionaries_promo_seen` (bool, default `false` = not yet seen).
- Badge is visible whenever the flag is `false`.
- On entering the Settings screen, immediately mark the flag `true` (fire-and-forget) — this hides
  the badge from then on, permanently. There is no way to bring the badge back once dismissed
  (no re-trigger on new dictionaries, app updates, etc.).
- Badge is a simple dot/indicator overlaid on the settings gear icon — no count, no text.

## 7. Analytics

Fire-and-forget (never awaited) event logged when a user **taps** a download row to start a
download — logged *before* the rate-limit check runs, so it fires even for attempts that get
rejected by rate limiting. Any failure while logging must be swallowed/caught, never surfaced to
the user or allowed to block the download flow.

- Event key/name: **`offline_dictionary_download_click`**
- Parameters:
  - `dict_name`: `dictionary.name` (Dart enum case name, e.g. `"belRus"`, `"rusBel"`, `"tsbm"`)
  - `dict_path`: `dictionary.path` (e.g. `"belrus"`, `"rusbel"`, `"tsbm"`)

## 8. Word lookup cascade (how downloaded data gets used)

Translation lookup for a given word is a strict, ordered cascade — try each source in order, only
falling through to the next on a miss/error:

1. **Local** (downloaded/cached storage) — keyed by `langId:externalId` composite key (§2).
   - Not found locally → fall through to API.
   - Found, `redirectTo == null` → success, `source = "local"`.
   - Found, `redirectTo != null` → **terminal redirect result, stop the cascade here.** Do not
     fall through to API/Cloud/Website, and do not resolve/follow the redirect locally yourself.
     Surface it as a distinct outcome carrying the original word + `redirectTo`; the *caller*
     (UI layer) is responsible for re-triggering a fresh lookup for the `redirectTo` word id,
     which restarts this whole cascade from step 1 for the new id. In the Flutter reference this
     is `Failure(TranslationRedirectError(word, redirectTo))`, which the presentation layer
     catches to show a "redirected from X" banner/snackbar and navigate to the new word — it is
     *not* resolved inline inside the lookup use case.
2. **API** (primary network endpoint):
   - Exception (network/parse error) → fall through to Cloud.
   - Success, `redirectTo != null` → same terminal redirect result as step 1 (stop, don't fall
     through to Cloud/Website).
   - Success, `redirectTo == null` → success, `source = "api"`.
3. **Cloud** (direct Supabase read, same `main_word` table as download uses, single-row fetch by
   `external_id` + `direction`):
   - Exception → fall through to Website.
   - Success, `redirectTo != null` → same terminal redirect result (stop, don't fall through to
     Website).
   - Success, `redirectTo == null` → success, `source = "cloud"`.
4. **Website** (HTML scrape fallback) — on exception, final failure. (This source has no
   `redirectTo` concept of its own in the reference implementation.)

**Key rule**: a non-null `redirectTo` is terminal *at whichever tier detects it* — it is never
treated as a miss/fallthrough condition at any level, local included. Only an actual absence of
data (local: no row for the key; API/Cloud: a thrown exception) causes fallthrough to the next
tier.

Each source that succeeds tags the result with a `source` field (`"local"` / `"api"` / `"cloud"`)
for diagnostics — not shown to the user, just carried on the domain object.

This cascade is why downloading a dictionary matters functionally, not just cosmetically: once
downloaded, lookups for that dictionary's words resolve at step 1 with **no network call at all**,
including fully offline.

## 9. Reference implementation locations (Flutter)

| Concern | File |
|---|---|
| Dictionary enum | `lib/features/app/domain/entity/dictionary.dart` |
| Download page/progress entities | `lib/features/translation/domain/entity/download_page.dart`, `download_progress.dart` |
| Cloud repo interface | `lib/features/translation/domain/repository/cloud_translation_repository.dart` |
| Cloud repo impl (Supabase) | `lib/features/translation/data/repository/supabase_api_translation_repository_impl.dart` |
| Local repo interface | `lib/features/translation/domain/repository/local_translation_repository.dart` |
| Local repo impl (ObjectBox) | `lib/features/translation/data/repository/objectbox_translation_repository.dart` |
| Local entity / composite key | `lib/features/app/data/model/objectbox_translation_word.dart` |
| Cursor persistence (interface + impl) | `lib/features/translation/domain/repository/download_cursor_repository.dart`, `lib/features/translation/data/repository/shared_preferences_download_cursor_repository.dart` |
| Rate-limit persistence (interface + impl) | `lib/features/translation/domain/repository/download_rate_limit_repository.dart`, `lib/features/translation/data/repository/shared_preferences_download_rate_limit_repository.dart` |
| Download use case (resume algorithm) | `lib/features/translation/domain/use_case/download_dictionary.dart` |
| Rate-limit check use case | `lib/features/translation/domain/use_case/check_download_rate_limit.dart` |
| Count downloaded words use case | `lib/features/translation/domain/use_case/count_downloaded_words.dart` |
| Clear/delete downloaded dictionary use case | `lib/features/translation/domain/use_case/clear_downloaded_dictionary.dart` |
| Word lookup cascade | `lib/features/translation/domain/use_case/get_translation.dart` |
| Settings cubit (per-dictionary state machine) | `lib/features/settings/presentation/offline_dictionaries_cubit.dart` |
| Settings UI (dictionary rows) | `lib/features/settings/presentation/widgets/offline_dictionaries_section.dart` |
| Promo badge cubit | `lib/features/settings/presentation/offline_dictionaries_promo_cubit.dart` |
| Promo badge persistence | `lib/features/settings/domain/repository/offline_dictionaries_promo_repository.dart`, `lib/features/settings/data/repository/shared_preferences_offline_dictionaries_promo_repository.dart` |
| Promo badge UI (gear icon) | `lib/features/history/presentation/history_page.dart` (search `Badge(`) |
| Settings entry marks promo seen | `lib/features/settings/presentation/settings_page.dart` (`initState`) |
| Analytics use case | `lib/features/settings/domain/use_case/log_analytics_dictionary_download.dart` |
| Analytics repo (interface + dev/Firebase impls) | `lib/features/settings/domain/repository/analytics_settings_repository.dart`, `lib/features/settings/data/repository/{dev,firebase}_analytics_settings_repository.dart` |
| Rate-limit / page-size constants | `lib/app_config.dart` (`downloadRateLimitWindow`, `downloadMaxAttemptsPerWindow`) |
| UI copy strings | `lib/strings.dart` (search `download`, `offlineMode`) |

## 10. Gotchas for the porting agent

- **Redirect ≠ miss, at any cascade tier.** A non-null `redirectTo` (local, API, or Cloud) must
  stop the cascade immediately with a terminal redirect outcome — it must NOT be treated as
  "nothing here, try next source" and must NOT be auto-resolved by re-querying inside the source
  itself. This differs from source implementations that recurse/auto-follow `redirect_to` — that
  behavior is out of scope here; the redirect must bubble up to the caller for it to re-issue a
  fresh top-of-cascade lookup for the new word id. See §8.
- Cloud `id` (cursor value) and `external_id` (the id actually used to key/display a word) are
  **different columns** — don't conflate them. The cursor is purely an internal pagination
  bookmark.
- The `done` count on a *fresh* download start is `0`, not `localCount`, even if there's pre-existing
  local data — see §4 step 5. Only a resume (`startCursor > 0`) seeds `done` from `localCount`.
  Getting this backwards double-counts progress on first-ever downloads with stale leftover data.
  On resume, note the pre-existing local words are not re-verified — the code (and this spec) treat
  a persisted cursor as proof the words up to that cursor are already correctly stored.
- Local storage key must be a composite of `langId` + `externalId` — a plain `externalId` primary
  key will corrupt data across dictionaries once the user downloads more than one.
  Store/insert semantics for the composite key must be **upsert** (replace-on-conflict) — a plain
  insert-only key will crash the download on any word already present (e.g. re-download after a
  partial delete, or a lookup-triggered cache hit landing in the same store before download runs).
- Rate limiting gates *download attempts* (button taps), not the page-fetch retry loop inside an
  already-running download — don't merge these two retry/limit concepts.
- Analytics logging happens *before* the rate-limit check, unconditionally on tap — don't gate it on
  whether the attempt is actually allowed.
- The promo badge and the per-dictionary download state are two entirely independent pieces of
  state — a dictionary being downloaded doesn't affect the badge, and viewing Settings dismisses the
  badge regardless of whether the user downloads anything.
