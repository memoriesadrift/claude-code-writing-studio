---
paths:
  - "compendium/**"
---
# Compendium (non-fiction; spec §6, §9)

One shared knowledge base for every work in the project. The compendium is
not prose: Claude may write it at any prose level, but only after "May I
write this to `<path>`?". Whether compendium help is allowed for an assessed
work is the author's call under its policy.

## Source notes (`sources/<citekey>.md`)

- **Source versus author:** *Summary*, *Key arguments* and *Quotations*
  record what the **source** says; only *Author's assessment* records what
  the **author** thinks. Never mix them.
- **Every quotation has a locator** (page, section or paragraph) and is
  copied word for word in the source's original language.
- **Never set `status: verified`.** Only the author does that, after checking
  the source exists and says what the note claims (the verify-guard hook asks
  them). A source Claude found (web search, a DOI, a reference in another
  source) starts as `unverified`.
- **Archived copy:** a source can be verified only with its files under
  `archive/<citekey>/` and one line per file in `archive.sha256`
  (`sha256sum` format, path relative to `compendium/`), or, for
  `kind: physical`, `held` saying where the print copy is. Capture is the
  author's job; `/source` tells them what to save and adds the checksum line
  once the file is present.
- **Web sources** carry `url` and `retrieved`. Captures are frozen: a
  re-capture is kept beside the old one, and `cited_capture` says which one
  the citations use. A capture Claude fetched is `captured_by: claude` and
  does not count until the author confirms it.
- Keep the note's `citekey` equal to its file name and its entry in
  `library.bib`. Hook-read fields (`status`, `archive.kind`, `archive.held`)
  stay flat: one `key: value` per line.

## Claims (`claims.yaml`)

- Ids `C-<nnn>`, never reused.
- **Two-way links:** every `cite:` in a claim has a source note whose
  *Links* lists the claim id, and vice versa.
- **Contested claims list both sides:** `support` and `against`, each with
  locators.
- `used_in` lists `<work>/<section>` keys and is kept current by `/draft`
  and the citation check.

## Elsewhere

- `concepts/`, `positions/`: record how each author uses a term or where they
  stand, with citations; the author's own view is labelled as theirs.
- `notes/<date>-<slug>.md`: raw notes; edit only on request.
- `inbox/`: unprocessed captures; ingest via `/source`, then leave the file
  for the author to delete or archive.
- `archive/` is gitignored (copyright); never commit its contents, and never
  delete or modify archived files.
