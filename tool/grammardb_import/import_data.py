"""Upsert parsed GrammarDB records into Supabase `public.stress_word`.

Usage:
    export DATABASE_URL=postgresql://postgres:***@db.<project-ref>.supabase.co:5432/postgres
    .venv/bin/python3 import_data.py ../../bnkorpus/RELEASE-202601

Idempotent: upserts on `source_pdg_id` (see migration `create_stress_word_table`
-- unique partial index on that column), so re-running after fixing tags.py
is safe and just updates existing rows.

Get the direct connection string from the Supabase dashboard (Project
Settings -> Database -> Connection string -> URI, "Direct connection" not
the pgbouncer pooler one, since this does a long sequence of writes).
"""
from __future__ import annotations

import argparse
import json
import os
import sys
from pathlib import Path

import psycopg2
import psycopg2.extras

import parse

_UPSERT_SQL = """
insert into public.stress_word (word, lemma, table_name, source_pdg_id, rows)
values %s
on conflict (source_pdg_id) where source_pdg_id is not null do update set
    word = excluded.word,
    lemma = excluded.lemma,
    table_name = excluded.table_name,
    rows = excluded.rows
"""


def _record_to_row(record: dict) -> tuple:
    return (
        record["word"],
        record["lemma"],
        record["table_name"],
        record["source_pdg_id"],
        json.dumps(record["rows"], ensure_ascii=False),
    )


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("xml_dir", type=Path)
    parser.add_argument("--batch-size", type=int, default=2000)
    parser.add_argument("--dry-run", action="store_true", help="parse only, skip DB writes")
    args = parser.parse_args()

    if args.dry_run:
        total = 0
        for _ in parse.iter_records(args.xml_dir):
            total += 1
        print(f"dry run: would upsert {total} records")
        return

    dsn = os.environ.get("DATABASE_URL")
    if not dsn:
        print("DATABASE_URL not set", file=sys.stderr)
        sys.exit(1)

    conn = psycopg2.connect(dsn)
    conn.autocommit = False
    try:
        with conn.cursor() as cur:
            batch: list[tuple] = []
            total = 0
            for record in parse.iter_records(args.xml_dir):
                batch.append(_record_to_row(record))
                if len(batch) >= args.batch_size:
                    psycopg2.extras.execute_values(cur, _UPSERT_SQL, batch, template="(%s,%s,%s,%s,%s::jsonb)")
                    conn.commit()
                    total += len(batch)
                    print(f"upserted {total}", file=sys.stderr)
                    batch.clear()
            if batch:
                psycopg2.extras.execute_values(cur, _UPSERT_SQL, batch, template="(%s,%s,%s,%s,%s::jsonb)")
                conn.commit()
                total += len(batch)
            print(f"done: {total} records upserted")
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()


if __name__ == "__main__":
    main()
