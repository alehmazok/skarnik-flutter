"""Decode GrammarDB Paradigm/Form tags into Starnik-style stress-table rows.

Row shape (title/content HTML) matches starnik.by's /pravapis/{id} output
byte-for-byte in structure (same CSS classes: .sklon .pytanne .skarot .anim
.numeral .gen), so the app's existing StressHtmlCell widget renders these
rows with zero client-side changes.

Tag scheme reference: https://github.com/Belarus/GrammarDB
  reader/src/main/java/org/alex73/grammardb/tags/BelarusianTags.java
Stress marker reference (StressUtils.java): '+' is placed immediately after
the stressed vowel in Form/lemma text; combine_stress() below converts that
to the combining acute (U+0301) already used elsewhere in the app for
display (see ObjectboxTranslationWord.stress).

Verified empirically against live starnik.by output for: noun (рука,
id=64993), adjective (добры, id=109281), pronoun (мой, id=233971), verb
imperfective (рукаблудзіць, id=211645) and perfective (зрабіць, id=185219).
Adverb degree labels and the adjective "R" (adjective-as-adverb) row title
are NOT verified against a live sample -- flagged below. Review before
trusting blindly for those two.

Known simplifications (acceptable for a fallback data source, not a
line-for-line mirror):
  - Substantivized noun forms (3-char Form tags on N1/N2/N3/NP, e.g. the
    "ад'ектыўнае скланенне" branch) are folded into the plain case rows,
    dropping the gender distinction Starnik would show separately.
  - Numeral forms with gender in the plural (rare, e.g. "абодва/абедзве")
    are folded into the single "мн." line as extra comma-joined forms
    rather than broken out per gender.
"""
from __future__ import annotations

COMBINING_ACUTE = "́"


def combine_stress(text: str) -> str:
    return text.replace("+", COMBINING_ACUTE)


def render_forms(forms: list[dict]) -> str:
    """Join same-slot forms the way Starnik does: numeral/animacy annotations
    are per-Form attributes in GrammarDB (`type="numeral"`, `options="anim"`/
    `"inanim"`), not a derived linguistic rule -- so this is a direct,
    order-preserving translation of the source XML, not a guess."""
    if not forms:
        return "—"  # em dash, matches Starnik's placeholder for missing forms
    parts = []
    for f in forms:
        text = combine_stress(f["text"])
        if f.get("type") == "numeral":
            text = f'<span class="numeral">(2, 3, 4) </span>{text}'
        elif f.get("options") == "anim":
            text = f'{text}<span class="anim"> (адуш.)</span>'
        elif f.get("options") == "inanim":
            text = f'{text}<span class="anim"> (неадуш.)</span>'
        parts.append(text)
    return ", ".join(parts)


CASE_ORDER = ["N", "G", "D", "A", "I", "L"]
CASE_INFO = {
    "N": ("Назоўны", "хто? што?"),
    "G": ("Родны", "каго? чаго?"),
    "D": ("Давальны", "каму? чаму?"),
    "A": ("Вінавальны", "каго? што?"),
    "I": ("Творны", "кім? чым?"),
    "L": ("Месны", "у кім? у чым?"),
}
GENDER_ORDER = ["F", "M", "N"]
GENDER_LABEL = {"F": "ж.", "M": "м.", "N": "н."}


def _case_title(case: str) -> str:
    name, question = CASE_INFO[case]
    return f'{name}<br><span class="pytanne">{question}</span>'


def _by_tag(forms_by_tag: dict[str, list[dict]], tag: str) -> list[dict]:
    return forms_by_tag.get(tag, [])


# ---------------------------------------------------------------------------
# Noun (N1/N2/N3/NP): Form tag is 2-char [case][number], vocative is "VS"
# only (no plural vocative in the tag scheme). Substantivized adjectival
# nouns use a 3-char [gender][case][number] tag -- folded in, see module
# docstring.
# ---------------------------------------------------------------------------
def build_noun_rows(forms_by_tag: dict[str, list[dict]]) -> list[dict]:
    rows = []
    for case in CASE_ORDER:
        sing, plur = [], []
        for tag, forms in forms_by_tag.items():
            if len(tag) == 2 and tag[1] == "S" and tag[0] == case:
                sing += forms
            elif len(tag) == 2 and tag[1] == "P" and tag[0] == case:
                plur += forms
            elif len(tag) == 3 and tag[2] == "S" and tag[1] == case:
                sing += forms
            elif len(tag) == 3 and tag[2] == "P" and tag[1] == case:
                plur += forms
        if not sing and not plur:
            continue
        content = (
            f"<b> {render_forms(sing)} </b><br><br>"
            f'<span class="skarot">мн.</span>&nbsp;<b> {render_forms(plur)} </b>'
        )
        rows.append({"title": _case_title(case), "content": content})

    vs = _by_tag(forms_by_tag, "VS")
    rows.append(
        {
            "title": "Клічная форма",
            "content": (
                f"<b> {render_forms(vs)} </b><br><br>"
                f'<span class="skarot">мн.</span>&nbsp;<b> — </b>'
            ),
        }
    )
    return rows


# ---------------------------------------------------------------------------
# Gendered declension (adjective A1/A2, participle P, pronoun S, numeral M):
# Form tag is 3-char [gender][case][number]. Gender is one of M/F/N (real
# gender, singular), P (plural, adjective/participle/numeral convention) or
# 0 (plural for pronoun/numeral, OR singular for genderless pronouns like
# хто/што/сябе -- both reuse gender code '0', disambiguated by the number
# char alone).
# ---------------------------------------------------------------------------
def build_gendered_rows(forms_by_tag: dict[str, list[dict]]) -> list[dict]:
    rows = []
    for case in CASE_ORDER:
        gendered_lines = []
        for g in GENDER_ORDER:
            forms = _by_tag(forms_by_tag, f"{g}{case}S")
            if forms:
                gendered_lines.append(
                    f'<span class="skarot">{GENDER_LABEL[g]}</span>&nbsp;<b> {render_forms(forms)} </b>'
                )
        ungendered_sing = _by_tag(forms_by_tag, f"0{case}S")
        if ungendered_sing:
            gendered_lines.append(f"<b> {render_forms(ungendered_sing)} </b>")

        plur = list(_by_tag(forms_by_tag, f"P{case}P"))
        plur += _by_tag(forms_by_tag, f"0{case}P")
        for g in GENDER_ORDER:  # numeral: rare gendered plural, folded in (see docstring)
            plur += _by_tag(forms_by_tag, f"{g}{case}P")

        if not gendered_lines and not plur:
            continue
        content = "<br>\n".join(gendered_lines)
        if gendered_lines:
            content += "<br><br>"
        content += f'<span class="skarot">мн.</span>&nbsp;<b> {render_forms(plur)} </b>'
        rows.append({"title": _case_title(case), "content": content})

    # Participle short form ("кароткая форма"): case slot repurposed as 'H'.
    short_lines = []
    for g in GENDER_ORDER:
        forms = _by_tag(forms_by_tag, f"{g}HS")
        if forms:
            short_lines.append(
                f'<span class="skarot">{GENDER_LABEL[g]}</span>&nbsp;<b> {render_forms(forms)} </b>'
            )
    if short_lines:
        rows.append({"title": "Кароткая форма", "content": "<br>\n".join(short_lines)})

    return rows


# ---------------------------------------------------------------------------
# Adverb (R): Form tag is the comparison degree only. NOT verified against a
# live Starnik sample -- standard grammar terms, review before trusting.
# ---------------------------------------------------------------------------
ADVERB_DEGREE_TITLES = {
    "P": "Звычайная ступень",
    "C": "Вышэйшая ступень",
    "S": "Найвышэйшая ступень",
}


def build_adverb_rows(forms_by_tag: dict[str, list[dict]]) -> list[dict]:
    rows = []
    for code in ["P", "C", "S"]:
        forms = _by_tag(forms_by_tag, code)
        if forms:
            rows.append(
                {"title": ADVERB_DEGREE_TITLES[code], "content": f"<b> {render_forms(forms)} </b>"}
            )
    return rows


# ---------------------------------------------------------------------------
# Verb (V): boilerplate question text is fixed per aspect (Трыванне, position
# 2 of the Paradigm tag: M=imperfective uses "рабіць" glosses, P=perfective
# uses "зрабіць" glosses) -- verified against both a real imperfective
# (рукаблудзіць) and perfective (зрабіць) sample; the literal question
# wording below is copied verbatim from those two live responses. The
# imperfective past-gerund question (PG under aspect M) is NOT verified --
# no imperfective sample with a PG form was found; templated by analogy.
# ---------------------------------------------------------------------------
PRESENT_FUTURE_QUESTION = {
    "M": (
        "1-я асоба:<br>я што раблю? <br> мы што робім? <br> "
        "2-я асоба:<br>ты што робіш? <br> вы што робіце? <br> "
        "3-я асоба:<br>ён-яна-яно што робіць? <br> яны што робяць?"
    ),
    "P": (
        "1-я асоба:<br>я што зраблю? <br> мы што зробім? <br> "
        "2-я асоба:<br>ты што зробіш? <br> вы што зробіце? <br> "
        "3-я асоба:<br>ён-яна-яно што зробіць? <br> яны што зробяць?"
    ),
}
PRESENT_FUTURE_TITLE = {"M": "Цяперашні час", "P": "Будучы час"}
PRESENT_FUTURE_PREFIX = {"M": "R", "P": "F"}

PAST_QUESTION = {
    "M": "што рабіла? <br> што рабіў? <br> што рабілі?",
    "P": "што зрабіла? <br> што зрабіў? <br> што зрабілі?",
}
IMPERATIVE_QUESTION = {
    "M": "2-я асоба: <br> ты што рабі? <br> вы што рабіце?",
    "P": "2-я асоба: <br> ты што зрабі? <br> вы што зрабіце?",
}
GERUND_PRESENT_QUESTION = "цяперашні час: <br> што робячы?"
GERUND_PAST_QUESTION = {
    "M": "прошлы час: <br> што рабіўшы?",  # unverified, see docstring
    "P": "прошлы час: <br> што зрабіўшы?",
}


def _render_person_block(forms_by_tag: dict[str, list[dict]], prefix: str) -> str:
    def f(person: str, number: str) -> str:
        return render_forms(_by_tag(forms_by_tag, f"{prefix}{person}{number}"))

    return (
        f'<span class="skarot">я</span>&nbsp;<b> {f("1", "S")} </b><br>'
        f'<span class="skarot">мы</span>&nbsp;<b> {f("1", "P")} </b><br><br>'
        f'<span class="skarot">ты</span>&nbsp;<b> {f("2", "S")} </b><br>'
        f'<span class="skarot">вы</span>&nbsp;<b> {f("2", "P")} </b><br><br>'
        f'<span class="skarot">ён, яна, яно</span>&nbsp;<b> {f("3", "S")} </b><br>'
        f'<span class="skarot">яны</span>&nbsp;<b> {f("3", "P")} </b>'
    )


def _render_past_block(forms_by_tag: dict[str, list[dict]]) -> str:
    def f(gender: str, number: str) -> str:
        return render_forms(_by_tag(forms_by_tag, f"P{gender}{number}"))

    return (
        f'<span class="skarot">ж.</span>&nbsp;<b> {f("F", "S")} </b><br>'
        f'<span class="skarot">м.</span>&nbsp;<b> {f("M", "S")} </b><br>'
        f'<span class="skarot">н.</span>&nbsp;<b> {f("N", "S")} </b><br><br>'
        f'<span class="skarot">мн.</span>&nbsp;<b> {f("X", "P")} </b>'
    )


def _render_imperative_block(forms_by_tag: dict[str, list[dict]]) -> str:
    def f(number: str) -> str:
        return render_forms(_by_tag(forms_by_tag, f"I2{number}"))

    return (
        f'<span class="skarot">ты</span>&nbsp;<b> {f("S")} </b><br>'
        f'<span class="skarot">вы</span>&nbsp;<b> {f("P")} </b>'
    )


def build_verb_rows(forms_by_tag: dict[str, list[dict]], aspect: str) -> list[dict]:
    aspect = aspect if aspect in ("M", "P") else "M"
    rows = []

    inf = _by_tag(forms_by_tag, "0")
    rows.append({"title": "Пачатковая форма", "content": f"<b> {render_forms(inf)} </b>"})

    prefix = PRESENT_FUTURE_PREFIX[aspect]
    if any(tag.startswith(prefix) and len(tag) == 3 for tag in forms_by_tag):
        rows.append(
            {
                "title": f"{PRESENT_FUTURE_TITLE[aspect]}<br>"
                f'<span class="pytanne">{PRESENT_FUTURE_QUESTION[aspect]}</span>',
                "content": _render_person_block(forms_by_tag, prefix),
            }
        )
    if any(tag.startswith("P") and tag != "PG" for tag in forms_by_tag):
        rows.append(
            {
                "title": f'Прошлы час<br><span class="pytanne">{PAST_QUESTION[aspect]}</span>',
                "content": _render_past_block(forms_by_tag),
            }
        )
    if any(tag.startswith("I2") for tag in forms_by_tag):
        rows.append(
            {
                "title": f'Загадны лад<br><span class="pytanne">{IMPERATIVE_QUESTION[aspect]}</span>',
                "content": _render_imperative_block(forms_by_tag),
            }
        )
    if "RG" in forms_by_tag:
        rows.append(
            {
                "title": f'Дзеепрыслоўе<br><span class="pytanne">{GERUND_PRESENT_QUESTION}</span>',
                "content": f'<b> {render_forms(forms_by_tag["RG"])} </b>',
            }
        )
    if "PG" in forms_by_tag:
        rows.append(
            {
                "title": f'Дзеепрыслоўе<br><span class="pytanne">{GERUND_PAST_QUESTION[aspect]}</span>',
                "content": f'<b> {render_forms(forms_by_tag["PG"])} </b>',
            }
        )
    return rows


# POS file -> table_name, using the exact English keys already present in
# lib/strings.dart Strings.partOfSpeech so the UI needs zero changes.
# Z (pabocnaje/parenthetical) and W (predykatyu/predicative) have no key
# there -- table_name stays null for them, same as Starnik does when a
# word's tableName is absent (StressPage just omits the subtitle).
POS_TABLE_NAME = {
    "N1": "Nouns",
    "N2": "Nouns",
    "N3": "Nouns",
    "NP": "Nouns",
    "A1": "Adjectives",
    "A2": "Adjectives",
    "V": "Verbs",
    "P": "Participles",
    "S": "Pronouns",
    "M": "Numerals",
    "R": "Adverbs",
    "C": "Conjunctions",
    "I": "Prepositions",
    "E": "Particles",
    "Y": "Interjections",
    "Z": None,
    "W": None,
}

# POS files with no <Form> elements at all -- the paradigm's lemma IS the
# only form. build_rows() short-circuits these before touching Form data.
INDECLINABLE_POS = {"C", "I", "E", "Y", "Z", "W"}


def build_rows(pos_file: str, paradigm_tag: str, forms_by_tag: dict[str, list[dict]]) -> list[dict]:
    if pos_file in ("N1", "N2", "N3", "NP"):
        return build_noun_rows(forms_by_tag)
    if pos_file in ("A1", "A2"):
        rows = build_gendered_rows(forms_by_tag)
        r = _by_tag(forms_by_tag, "R")
        if r:
            rows.append({"title": "Прыслоўная форма", "content": f"<b> {render_forms(r)} </b>"})
        return rows
    if pos_file in ("P", "S"):
        return build_gendered_rows(forms_by_tag)
    if pos_file == "M":
        if set(forms_by_tag.keys()) == {"0"}:
            return [{"title": "Форма", "content": f'<b> {render_forms(forms_by_tag["0"])} </b>'}]
        return build_gendered_rows(forms_by_tag)
    if pos_file == "R":
        return build_adverb_rows(forms_by_tag)
    if pos_file == "V":
        aspect = paradigm_tag[2] if len(paradigm_tag) > 2 else "M"
        return build_verb_rows(forms_by_tag, aspect)
    return []
