# Націск (Word Stress / Spelling) Feature Spec

## Overview

From the word details screen, user can tap "Націск" to see the full stress marking
and declension/conjugation table for a Belarusian word, sourced from starnik.by.

---

## User Flow

1. Word details screen loads a translation.
2. "Націск" button appears in toolbar **only** when candidate Belarusian words exist (see Step 1).
3. If 1 candidate → button taps directly.  
   If 2+ candidates → button opens a picker menu; user selects one word.
4. App fetches `wordId` from starnik.by (Step 2).
5. If resolved → push/navigate to stress table screen (Step 3).  
   If not resolved → silently do nothing.
6. Analytics: log "stress clicked" event with the word string.

---

## Step 1: Extract Candidate Belarusian Words

Source depends on dictionary type of the current word entry:

### bel→rus and bel_definition dictionaries
Use the headword directly.  
Discard if it contains a space (multi-word phrase → not eligible).  
Result: 0 or 1 word.

### rus→bel dictionary
Parse the translation HTML body.  
Extract Belarusian translations — typically appear as bold/colored text at the start of entries.  
Split on `,` → trim whitespace → discard any item containing a space.  
Result: 0–N single Belarusian words.

---

## Step 2: Resolve wordId

```
GET https://starnik.by/api/wordList?lemma={url-encoded-belarusian-word}
```

**Response JSON:**
```json
{
  "word_list": [
    {
      "lemma": "слова",
      "id": 12345,
      "table_name": "noun",
      "meaning": "..."
    }
  ],
  "form_list": [
    {
      "lemma": "слова",
      "id": 67890,
      "state": "..."
    }
  ]
}
```

- Use `word_list[0].id` as `wordId`.
- If `word_list` is empty → silently abort, show nothing.

---

## Step 3: Fetch and Display Stress/Declension Table

```
GET https://starnik.by/pravapis/{wordId}
```

Returns an HTML page. Parse it:

1. Find element with CSS class `wrapper`.
2. Inside it, find the first `<table>`.
3. For each `<tr>`: extract exactly 2 `<td>` cells.
   - `td[0]` → **title** (grammatical label, e.g. "Назоўны склон")
   - `td[1]` → **content** (word forms with stress marks)
4. Skip rows that don't have exactly 2 `<td>` cells.

Both cells contain inner HTML — render as HTML (stress marks use `<b>`, accented chars, etc.).

**Example parsed row:**
```
title:   "Назоўны склон адз. лік"
content: "сло́ва"
```

---

## UI: Stress Table Screen

- Title: localized equivalent of "Націск" / "Правапіс"
- Loading spinner while fetching.
- Error message (localized) on network/parse failure.
- On success: scrollable 2-column list.
  - Left column: title HTML (grammatical label)
  - Right column: content HTML (word forms, may include stress marks)
  - Columns equal width.
- Each cell renders inner HTML so stress diacritics display correctly.

---

## Notes

- No caching required (same as iOS implementation).
- Button is hidden (not disabled) when no candidate words exist.
- Only `word_list` is used; `form_list` is ignored.
- `wordId` is an integer, URL path segment: `.../pravapis/12345`
