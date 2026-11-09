# German — academic conventions

Part of the `de` language pack (spec §4.5). Read together with the overlay for
the tag in force (`variants/<tag>.md`), which wins wherever the two differ.
Option values in force (`pack.yaml` explains the order) win over both.

Used by the grammar editor, line editor, beta reader and developmental editor
on non-fiction works, and by `/draft` at `co-author`/`ghostwriter`. The work's
brief (`works/<work>/brief.md`) and the department's *Leitfaden für
wissenschaftliches Arbeiten* outrank this file: check the brief first.

## Voice and stance

- **Ich, wir or impersonal:** the traditional *Ich-Verbot* has weakened;
  *ich* is now common in philosophy and the humanities for the author's own
  moves (*Ich argumentiere, dass …*). Many departments still prefer
  impersonal constructions (*Es wird gezeigt, dass …*, *Im Folgenden wird …*).
  *Wir* as a pluralis auctoris is dated. Follow the brief; otherwise the
  author's practice; flag inconsistency.
- **Hedging:** *dürfte*, *scheint*, *lässt sich vermuten*, *legt nahe*,
  *möglicherweise*. Flag over-claiming (*beweist*, *zweifellos*,
  *offensichtlich* for contested points) and hedge-stacking.
- **Reported speech:** Konjunktiv I marks the source's view, separating it
  from the author's (spec §6.1): *Rawls zufolge sei …* / *Rawls behauptet,
  … sei …*. Indicative after *Rawls zeigt, dass …* commits the author to the
  claim; flag it where the claim is contested.
- **Reporting verbs** carry stance: *behaupten, argumentieren, vertreten,
  einwenden, einräumen, zeigen* (only for the established).
- **Gendering** follows option `gendering`; universities and departments
  often prescribe one form: check the brief.

## Quotations

- Quote only from a source note's *Quotations* section (CLAUDE.md), word for
  word, with the locator.
- Direct quotations in „…“ (or the overlay's marks); quotation inside a
  quotation ‚…‘.
- Omissions *[…]*; insertions and changes in square brackets
  (*[der Staat]*); *[sic]* for errors; *Hervorhebung im Original* /
  *Hervorhebung d. Verf.*; *Anm. d. Verf.*
- A quotation the author translated: *(eigene Übersetzung)* — `pack.yaml`
  `translation_marker`. English quotations are often left untranslated in
  German academic work; other languages usually translated with the
  original in a note. Follow the brief.
- Block quotation from about three lines (or 40 words), indented, often
  smaller type, without quotation marks.
- Pre-1996 spelling in a quotation stays as it is; no *[sic]* for it.

## Abbreviations

| Abbreviation | Meaning / use |
|---|---|
| *vgl.* | "compare" — for indirect references in note styles; not used in IEEE |
| *ebd.* | Same source as the previous citation (note styles only) |
| *S.*, *f.*, *ff.* | Page, and following page(s): *S. 12 f.*; prefer exact ranges *S. 12–19* |
| *Hrsg.*, *hrsg. v.* | Editor(s), edited by |
| *Aufl.*, *Bd.*, *Jg.* | Edition, volume, annual volume |
| *o. J.*, *o. O.* | No date, no place |
| *zit. n.* | Quoted after (secondary citation; use only when the original is unavailable) |
| *u. a.* / *et al.* | Further authors: per the citation style and locale |
| *Anm.* | Note |

## Citation locale

The CSL style decides the format; the locale (`pack.yaml` →
`variants.<tag>.csl_locale`) supplies *S.*, *ebd.*, *Hrsg.*, *u. a.*,
*abgerufen am*. Never format citations by hand in the prose: write Pandoc
citekeys (`[@rawls1993, p. 137]`; Pandoc also recognises the locale's own
locator terms such as `S.` when the document language is German) and let
`/publish` render them.

## Structure conventions

- *Einleitung* states *Fragestellung*, *These* and *Vorgehen*; *Fazit*
  answers the question and names limits and *Ausblick*.
- Seminar papers (*Hausarbeiten*) often require a *Gliederung* with decimal
  numbering and an *Eigenständigkeitserklärung*: check the brief.
