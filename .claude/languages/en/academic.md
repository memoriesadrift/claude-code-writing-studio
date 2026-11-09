# English — academic conventions

Part of the `en` language pack (spec §4.5). Read together with the overlay for
the tag in force (`variants/<tag>.md`), which wins wherever the two differ.
Option values in force (`pack.yaml` explains the order) win over both.

Used by the grammar editor, line editor, beta reader and developmental editor
on non-fiction works, and by `/draft` at `co-author`/`ghostwriter`. The work's
brief (`works/<work>/brief.md`) and its marking criteria outrank this file:
departments differ, so check the brief first.

## Voice and stance

- **First person:** *I argue*, *I will show* are standard in philosophy, the
  humanities and much of the social sciences; some sciences prefer impersonal
  constructions. Follow the brief; otherwise follow the author's practice and
  flag only inconsistency.
- **Hedging** in proportion to the evidence: *suggests*, *appears to*, *is
  likely*, *may*. Flag both over-claiming (*proves*, *clearly*, *obviously*
  for contested points) and hedge-stacking (*it might possibly be suggested
  that*).
- **Attribution:** keep the source's view and the author's view apart
  (spec §6.1). Reporting verbs carry stance: *argues*, *claims*, *contends*,
  *notes*, *concedes*, *shows* (only for something established). Flag
  *shows/proves* used of a contested claim.
- **Signposting:** each section opens by saying what it does and closes by
  saying how it advances the thesis. The introduction states the thesis and
  the route.

## Quotations

- Quote only from a source note's *Quotations* section (CLAUDE.md), word for
  word, with the locator.
- Omissions: … (or […] if the style guide asks); insertions in square
  brackets; *[sic]* for an error in the original.
- Emphasis: *emphasis added* or *emphasis in original*.
- A quotation the author translated: *(my translation)* — `pack.yaml`
  `translation_marker`.
- Block quotation for roughly 40 words or more (or four lines), without
  quotation marks; shorter quotations run in.

## Abbreviations

| Abbreviation | Use |
|---|---|
| *e.g.*, *i.e.* | In parentheses and notes; in running text prefer *for example*, *that is* |
| *et al.* | Three or more authors, per the citation style; never italicised in most styles |
| *cf.* | "compare"; not a synonym for "see" |
| *ibid.* | Only in note styles; never in author-date or numeric styles such as IEEE |
| *n.d.* | No date |
| *ed./eds*, *trans.* | Per variant (*eds* en-GB, *eds.* en-US) |
| *p./pp.* | Page/pages: *p. 12*, *pp. 12–19* |

## Citation locale

The CSL style (`citation_style`) decides the citation format; the locale
(`pack.yaml` → `variants.<tag>.csl_locale`) decides its words (*and*,
*edited by*, *accessed*). Never format citations by hand in the prose: write
Pandoc citekeys (`[@rawls1993, p. 137]`) and let `/publish` render them.

## Common marker comments to anticipate

- Description instead of argument: a section summarises sources without a
  claim of its own.
- The thesis drifts between the introduction and the conclusion.
- Counter-arguments are missing or are straw men.
- Key terms are used before they are defined, or in two senses.
