# ASO / Store Listing Change Log

Tracks changes to store listing text (descriptions, keywords) so underperforming changes can be rolled back to a known-good previous version.

Status values: `testing`, `kept`, `rolled back`.

---

## App Store — Keywords field

### 2026-07-20 — v2 (testing, 89/100 chars)

**New:**
```
словарь,перевод,словы,мова,беларуская,тлумачальны,vocabulary,dictionary,belarusian,націск
```

**Previous (v1, baseline):**
```
словарь,переводчик,шрифт,gg,google,type,перевод,книги,litres,слоўнікавыя,словы,мова,прафесіі,say,by
```

**Why changed:** v1 had irrelevant/junk tokens (шрыфт, gg, google, type, книги, litres, прафесіі, say, by) diluting keyword budget (~99/100 chars used on low-value terms) and brand-name keywords (google, litres) risking App Store rejection. v2 keeps only relevant terms and adds ones matching actual features (націск = stress lookup, беларуская/belarusian/dictionary/vocabulary for broader match).

First v2 draft (словарь,переводчик,перевод,слоўнікавыя,словы,мова,беларуская,скарнік,тлумачальны,vocabulary,dictionary,belarusian,націск) measured at 120 chars — over limit. Trimmed further: dropped **переводчик** (redundant with перевод stem), **слоўнікавыя** (unnatural search term), **скарнік** (brand name already indexed via app title, wasted slot). Final 89/100 leaves buffer for future tweaks.

**Rollback:** if impressions/downloads drop after v2 goes live, revert keyword field to v1 string above.

---

## Full description (Google Play + App Store — same text both platforms)

### 2026-07-20 — v2 (testing)

**New:**
```
Гэтая праграма — афіцыйны кліент сайта Skarnik.by.

1. Руска-беларускі слоўнік змяшчае больш за 100 тысяч слоў. За аснову ўзяты акадэмічны слоўнік пад рэдакцыяй Я. Коласа, К. Крапівы і П. Глебкі.
2. Беларуска-рускі слоўнік таксама змяшчае больш за 100 тысяч слоў. Гэта «адваротны» слоўнік ад руска-беларускага.
3. Тлумачальны слоўнік беларускай мовы змяшчае больш за 95 тысяч слоў. Створаны на аснове акадэмічнага выдання пад рэдакцыяй К. Крапівы — пяцітомніка 1977-1984 гг.

Асноўныя магчымасці:
• Хуткі пошук слоў — працуе нават без інтэрнэту дзякуючы поўнаму афлайн доступу да слоўнікаў
• Пастаноўка націску для беларускіх слоў
• Захаванне слоў у абраныя і гісторыя пошуку
• Абмен словамі праз спасылкі

Скарнік дапрацаваны з улікам сучаснай практыкі і ўвесь час абнаўляецца (дадаюцца новыя словы, выпраўляюцца памылкі, недакладнасці і г. д.).
Дзякуем усім за водгукі і прапановы.
```

**Previous (v1, baseline):**
```
Гэтая праграма — афіцыйны андроід-кліент сайта Skarnik.by. Працуе ў рэжыме анлайн.
1. Руска-беларускі слоўнік змяшчае больш за 100 тысяч слоў. За аснову ўзяты акадэмічны слоўнік пад рэдакцыяй Я. Коласа, К. Крапівы і П. Глебкі.
2. Беларуска-рускі слоўнік таксама змяшчае больш за 100 тысяч слоў. Гэта «адваротны» слоўнік ад руска-беларускага.
3. Тлумачальны слоўнік беларускай мовы змяшчае больш за 95 тысяч слоў. Створаны на аснове акадэмічнага выдання пад рэдакцыяй К. Крапівы — пяцітомніка 1977-1984 гг.
Скарнік дапрацаваны з улікам сучаснай практыкі і ўвесь час абнаўляецца (дадаюцца новыя словы, выпраўляюцца памылкі, недакладнасці і г. д.).
Дзякуем усім за водгукі і прапановы.
```

**Why changed:** v1 said "Працуе ў рэжыме анлайн" (works online only) which is now false/outdated since offline dictionary download shipped. v1 also omitted stress lookup, favorites, history, and word-sharing features entirely. v2 fixes the online-only claim and adds a short feature bullet list (kept short — full feature list not appropriate for store description, see reasoning below).

**Rollback:** if conversion rate or ASO performance regresses after v2 goes live, revert description text to v1 string above (on both Google Play and App Store listings).

---

## Notes

- Decided against listing every app feature in the store description — search/discovery text should highlight top differentiators (offline access, stress lookup, favorites) rather than reading like a changelog. Minor features (deep-link sharing detail, exact history mechanics) intentionally left out.
- When adding a new entry: copy the previous "New" block into "Previous", write the new text as "New", set status to `testing`, note the date and reason.
- Update status to `kept` or `rolled back` once results are in, and note the outcome/metric that drove the decision.
