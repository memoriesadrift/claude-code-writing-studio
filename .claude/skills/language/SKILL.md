---
name: language
description: "/language add <tag> - interview the author and write a user-defined language pack (or, for a new region of a language that already has a pack, a regional overlay) under .claude/languages/. Use when a prose language has no pack, or the author types /language add."
argument-hint: add <bcp47-tag>
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Bash(bash .claude/scripts/status.sh*)
---
# /language add <tag> (spec §4.5)

Language packs hold everything language-specific: orthography, punctuation,
typography, grammar checks, style notes and academic conventions. A pack is
one folder, `.claude/languages/<primary subtag>/`; a region is an overlay,
`variants/<tag>.md`, that wins where it differs.

The only sub-command is `add`. Anything else: say so and show the usage.

## 1. Read the tag

- Must be a BCP 47 tag: a 2–3 letter primary subtag, optionally a region or
  script (`es`, `es-MX`, `pt-BR`, `sr-Latn`, `gsw-CH`). Primary subtag in
  lower case, region in upper case. If it is not a tag, suggest the likely
  one and ask.
- `<subtag>` = the primary subtag; the folder is
  `.claude/languages/<subtag>/`.

Then pick the path:

| Folder | Overlay `variants/<tag>.md` | Do |
|---|---|---|
| exists | exists (or the tag has no region) | Nothing to add: say which files apply and stop |
| exists | missing | **Overlay only** (§3) |
| missing | — | **New pack** (§2), plus an overlay if the tag has a region |

## Ground rules

- **The author is the authority.** Everything in the pack comes from the
  interview. Claude may suggest what is usual (a well-known dictionary, the
  quotation marks in common use), labelled as a suggestion for the author to
  confirm, and must say plainly when it is unsure. Never invent an authority,
  a rule or an example.
- Claude's grammar checking is less reliable in lower-resource languages.
  Say so at the start, and keep the pack `support: user-defined`; every
  review run with it says so in its header.
- Interview in the interface language (`studio.yaml` →
  `language.interface`); examples stay in the pack's language.
- A few questions at a time, never a form. "Don't know" or "skip" is fine:
  the section then says "No house convention; follow the authority." Never
  ask the author to fill in a template by hand.
- Write **one file at a time**, skeleton first: show the file, ask **"May I
  write this to `<path>`?"**, write it, then move on. Remove the `<!-- … -->`
  interview comments from the written files and fill or delete every
  `{{placeholder}}`.

## 2. New pack

Source: `.claude/languages/_template/`. The interview follows the comments
in each template file; cover at least:

1. **Authority:** the dictionary or orthography authority that settles
   spelling (RAE, Académie française, Treccani, …), and a style guide if any.
2. **Spelling:** reforms or allowed variants where the author prefers one
   form.
3. **Quotation marks and typography:** primary and nested quotation marks,
   dashes, spacing (e.g. a space before `:;?!` in French), ellipses,
   apostrophes.
4. **Numbers and dates:** decimal and thousands separators, date order,
   when to spell out numbers.
5. **Address and register:** formal and informal address (tu/vous,
   du/Sie/Ihr…), and when each is used in the author's genre.
6. **Inclusive language:** the convention the author uses, if any. If the
   community is split, make it a pack **option** with the author's choice as
   the default.
7. **Academic conventions** (always ask; non-fiction depends on them):
   abbreviations (ibid., et al., p./pp. equivalents), how locators are
   written, the CSL locale for citations (`csl_locale`; check it exists at
   github.com/citation-style-language/locales — say if unsure), and how a
   self-translated quotation is marked (`translation_marker`).
8. **Known pitfalls:** errors the author knows they or others make, and
   false friends; these drive `grammar.md`.
9. **Style:** rhythm and register notes for the line-editor (`style.md`).

Write, in order:

1. `pack.yaml` — `language`, `name`, `support: user-defined`,
   `translation_marker`, `options` (omit the block if none), one `variants`
   entry per regional tag the author uses, and `fallback_csl_locale`.
2. `conventions.md`, `grammar.md`, `style.md`, `academic.md`.
3. `variants/<tag>.md` for each regional tag (from
   `_template/variants/_variant.md`). Do not copy `_variant.md` itself.

## 3. Overlay only (a new region of an existing pack)

Read the pack's `pack.yaml` and base files first so the interview asks only
about **differences**: spelling, punctuation, quotation marks, vocabulary an
editor from elsewhere might wrongly correct, dates and numbers, and the CSL
locale.

Write, in order:

1. `variants/<tag>.md` from `_template/variants/_variant.md` (marked
   **user-defined** in its opening paragraph).
2. One new entry under `variants:` in the existing `pack.yaml`, leaving every
   other line untouched:
   ```yaml
     <tag>:
       overlay: variants/<tag>.md
       csl_locale: <locale or the pack's fallback>
       support: user-defined    # this overlay was written by /language add
       defaults: {}             # option defaults for this region, if any
   ```
   Show the exact edit and ask before making it. A shipped pack (`en`, `de`)
   stays `support: supported`; the variant's own `support: user-defined` is
   what reviews report for this tag.

## 4. Finish

- Read `pack.yaml` back and check: every `variants.<tag>.overlay` file
  exists; every option's `default` is one of its `values`; any
  `language.options` already in `studio.yaml` or a `work.yaml` names an
  option the pack declares. Report anything that does not fit.
- Run `bash .claude/scripts/status.sh` and confirm the `## language` block
  lists the pack.
- Tell the author which reviews can now run (`/review grammar`, `/review
  line`) and that pack files are plain Markdown they can edit at any time.
