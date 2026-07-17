# GrammarDB → Supabase stress_word import

One-off/rerunnable ETL: parses the GrammarDB release XML (`bnkorpus/RELEASE-202601/`)
into `public.stress_word` rows, giving the app's stress-lookup feature a fallback
data source for when starnik.by is unreachable. See
`lib/features/stress/data/repository/starnik_stress_repository.dart` and
`lib/features/translation/domain/use_case/get_translation.dart` (the fallback-chain
pattern this mirrors).

## Files

- `tags.py` — decodes GrammarDB `Form` tags into Starnik-style HTML table rows
  (same CSS classes as `StressHtmlCell`, so no client changes needed to render
  them). Read the module docstring for verified-vs-assumed cases before trusting
  it blindly, especially adverb degree titles and the imperfective past-gerund
  question — both unverified against a live starnik.by sample.
- `parse.py` — streams the XML (`lxml.etree.iterparse`, safe for the 81MB files),
  yields one record per `<Paradigm>`.
- `import_data.py` — batched upsert into Supabase, idempotent on `source_pdg_id`.

## Setup

```sh
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt
```

## Review before importing

```sh
.venv/bin/python3 parse.py ../../bnkorpus/RELEASE-202601 --sample 20 --out sample.txt
```

Eyeball `sample.txt` (or better, a native Belarusian speaker should) against
a few live `https://starnik.by/pravapis/{id}` pages before running the real
import — case names, question words (`.pytanne`), and the verb aspect
templates in `tags.py` were verified against only a handful of live samples.

## Import

```sh
.venv/bin/python3 import_data.py ../../bnkorpus/RELEASE-202601 --dry-run   # parse-only sanity check
export DATABASE_URL=postgresql://postgres:***@db.<project-ref>.supabase.co:5432/postgres
.venv/bin/python3 import_data.py ../../bnkorpus/RELEASE-202601             # ~246k rows, direct connection not pooler
```

Safe to re-run after editing `tags.py` — upserts on `source_pdg_id`.
