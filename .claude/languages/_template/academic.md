# {{Language}} — academic conventions

Part of the `{{lang}}` language pack (spec §4.5), **user-defined**. Read
together with the overlay for the tag in force (`variants/<tag>.md`), which
wins wherever the two differ. Option values in force win over both.

Used by the reviewers on non-fiction works and by `/draft` at
`co-author`/`ghostwriter`. The work's brief outranks this file.

## Voice and stance
<!-- Interview: "Is the first person (I / we) acceptable in academic writing in
your field and language? How is reported speech marked (e.g. a verb mood)?
Typical hedging expressions?" -->
{{notes}}

## Quotations
<!-- Interview: "How are omissions, insertions, emphasis and errors marked in
quotations? When does a quotation become a block quotation? Are quotations
in other languages translated?" -->
- Quote only from a source note's *Quotations* section, word for word, with
  the locator.
- {{omission / insertion / sic / emphasis markers}}
- Own translation: *({{translation_marker}})*.
- {{block quotation rule}}

## Abbreviations
<!-- Interview: "Academic abbreviations: page, editor, edition, volume, no date,
'compare', 'ibid.', 'et al.'?" -->
| Abbreviation | Meaning / use |
|---|---|
| {{abbr}} | {{meaning}} |

## Citation locale

The CSL style decides the format; the locale (`pack.yaml` →
`variants.<tag>.csl_locale`) supplies the words. If no CSL locale exists for
the language, `/publish` falls back to `fallback_csl_locale` and says so.
Never format citations by hand in the prose: write Pandoc citekeys.

## Structure conventions
<!-- Interview: "Required parts of a paper or thesis in your system (abstract,
declaration of authorship, numbered outline…)?" -->
{{notes}}
