"""Stream-parse GrammarDB release XML files into stress_word row records.

Usage (sample review, no DB writes):
    python3 parse.py /path/to/bnkorpus/RELEASE-202601 --sample 20 --out sample.txt

Each yielded record:
    {
        "source_pdg_id": int,   # GrammarDB Paradigm pdgId -- upsert key
        "word": str,            # UNSTRESSED headword (used as the search key)
        "lemma": str,           # STRESSED display form, combining acute (U+0301)
        "table_name": str | None,
        "rows": [{"title": str, "content": str}, ...],
    }

NOTE on word/lemma naming: this mirrors starnik.by's own API field naming
(GET /api/wordList returns "lemma": unstressed, "word": stressed) so that
StressWordEntry.lemma (used for exact-match filtering against the plain
search query, see ResolveStressWordListUseCase) and StressWordEntry.word
(used for display) line up the same way for both data sources. It is *not*
the standard linguistic sense of "lemma" -- don't rename without checking
both call sites.

Only Paradigms with at least one surviving Form after the pravapis filter
are emitted (or, for indeclinable POS, always -- there's nothing to filter).
One record per <Paradigm>: Forms from all its <Variant> children are unioned
(alternate variants are usually alternate accepted spellings/stresses of the
same word), matching the DB's `unique(source_pdg_id)` constraint.
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path
from typing import Iterator

from lxml import etree

import tags

# Modern orthography filter: keep a Variant if it's marked A2008, or if it
# carries no pravapis attribute at all (unmarked = always valid).
_MODERN_PRAVAPIS = "A2008"

_POS_FILES = [
    "N1", "N2", "N3", "NP",
    "A1", "A2",
    "V", "P", "S", "M", "R",
    "C", "I", "E", "Y", "Z", "W",
]


def _variant_forms(variant: etree._Element) -> dict[str, list[dict]]:
    forms_by_tag: dict[str, list[dict]] = {}
    for form_el in variant.findall("Form"):
        tag = form_el.get("tag")
        text = form_el.text
        if not tag or not text:
            continue
        entry = {"text": text, "type": form_el.get("type"), "options": form_el.get("options")}
        bucket = forms_by_tag.setdefault(tag, [])
        if entry not in bucket:  # dedupe identical forms across merged variants
            bucket.append(entry)
    return forms_by_tag


def _merge(a: dict[str, list[dict]], b: dict[str, list[dict]]) -> None:
    for tag, forms in b.items():
        bucket = a.setdefault(tag, [])
        for f in forms:
            if f not in bucket:
                bucket.append(f)


def _parse_paradigm(pos_file: str, el: etree._Element) -> dict | None:
    pdg_id = el.get("pdgId")
    paradigm_tag = el.get("tag") or ""
    lemma = el.get("lemma")
    if not pdg_id or not lemma:
        return None

    if pos_file in tags.INDECLINABLE_POS:
        rows = [{"title": "Форма", "content": f"<b> {tags.combine_stress(lemma)} </b>"}]
    else:
        forms_by_tag: dict[str, list[dict]] = {}
        for variant in el.findall("Variant"):
            pravapis = variant.get("pravapis")
            if pravapis and _MODERN_PRAVAPIS not in pravapis.split(","):
                continue
            _merge(forms_by_tag, _variant_forms(variant))
        if not forms_by_tag:
            return None
        rows = tags.build_rows(pos_file, paradigm_tag, forms_by_tag)
        if not rows:
            return None

    return {
        "source_pdg_id": int(pdg_id),
        # Always lowercase: `word` is purely an internal search key (never
        # displayed -- StressWordEntry.word/display form comes from `lemma`,
        # see module docstring), matched via a plain `word = lower($1)`
        # query against a plain btree index. Storing mixed case here would
        # need an ILIKE/functional-index lookup instead, which Postgres
        # can't use the index for -- caused a statement timeout on a live
        # 246k-row query during manual verification.
        "word": lemma.replace("+", "").lower(),
        "lemma": tags.combine_stress(lemma),
        "table_name": tags.POS_TABLE_NAME.get(pos_file),
        "rows": rows,
    }


def iter_records(xml_dir: Path, pos_files: list[str] | None = None) -> Iterator[dict]:
    for pos_file in pos_files or _POS_FILES:
        path = xml_dir / f"{pos_file}.xml"
        if not path.exists():
            print(f"skip {pos_file}: {path} not found", file=sys.stderr)
            continue
        context = etree.iterparse(str(path), events=("end",), tag="Paradigm")
        for _, el in context:
            record = _parse_paradigm(pos_file, el)
            if record is not None:
                yield record
            # free memory: drop this element and any now-empty preceding siblings
            el.clear()
            while el.getprevious() is not None:
                del el.getparent()[0]
        del context


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("xml_dir", type=Path)
    parser.add_argument("--sample", type=int, default=0, help="only print N records per POS file, don't write DB")
    parser.add_argument("--out", type=Path, default=None)
    args = parser.parse_args()

    out = args.out.open("w", encoding="utf-8") if args.out else sys.stdout
    try:
        if args.sample:
            for pos_file in _POS_FILES:
                count = 0
                for record in iter_records(args.xml_dir, [pos_file]):
                    print(f"=== {pos_file}: {record['word']} (pdg={record['source_pdg_id']}, table={record['table_name']}) ===", file=out)
                    for row in record["rows"]:
                        print(f"  [{row['title']}] {row['content']}", file=out)
                    count += 1
                    if count >= args.sample:
                        break
        else:
            total = 0
            for _ in iter_records(args.xml_dir):
                total += 1
            print(f"total records: {total}", file=out)
    finally:
        if args.out:
            out.close()


if __name__ == "__main__":
    main()
