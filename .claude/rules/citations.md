---
paths:
  - "works/*/sections/**"
---
# Citations in non-fiction prose (spec §6, §9)

Applies on top of the prose rule. Sources and quotations come only from the
compendium, never from memory.

- **Pandoc citekeys only:** `[@rawls1993, p. 137]`, `[@rawls1993; @wall2002]`,
  `@wall2002 argues …`. Never a hand-formatted citation, footnote reference
  or bibliography: `/publish` renders them in the work's CSL style.
- **Every citekey resolves:** an entry in `compendium/library.bib` **and** a
  note at `compendium/sources/<citekey>.md`. Never cite anything else, and
  never invent a key, an author, a title or a page.
- **No unverified sources:** a note with `status: unverified` may be
  discussed with the author but not cited in a prose file. Never set
  `status: verified` yourself.
- **Direct quotations** only from the source note's *Quotations* section,
  word for word, with its locator. A quotation without a locator cannot be
  cited. A translation by the author carries the pack's
  `translation_marker` (e.g. *(my translation)*, *(eigene Übersetzung)*).
- **Locators** match the note: page, section or paragraph.
- **Attribution:** what a source argues is reported as the source's view
  (in German, typically Konjunktiv I); the author's own view is marked as
  theirs. Keep to the note's *Summary* / *Key arguments* for the former and
  *Author's assessment* only as the author's.
- **Claims:** an assertion that depends on a source maps to a claim in
  `compendium/claims.yaml`. When drafting a section, add its key to the
  claim's `used_in` (`<work>/<section>`, with approval).
- **`kind: physical` sources** can be cited, but the citation check warns on
  every run; quotations from them are checked against the note only.

At `full` rigour every factual assertion must map to a claim or a citation
(spec §4.3).
