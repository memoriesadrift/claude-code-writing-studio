# Writing Studio — v1 Design

**Status:** Draft for review · **Date:** 2026-11-07
**Inspiration:** Claude Code Game Studios (CCGS, MIT) — patterns borrowed, no files forked.

**Revisions**
- r1 — initial draft.
- r2 — non-fiction reworked as a **field compendium with multiple works**
  (essays, papers) per project; academic-integrity controls; citation model.
- r3 — every cited source must have an archived copy in the compendium
  (§6.3–6.4); quotation checks run against that copy.
- r4 — language separated from style: BCP 47 language tags, language packs
  (§4.5), `grammar-editor` agent, `/language add`, separate interface
  language; one checkpoint file per work; repository layout restored (§3.1).
- r5 — rigour reworked as continuous tracking, not upfront gates; living
  research question; citation check at every rigour; due dates removed;
  `rigor` → `rigour` (British-spelt keys); language variants nested in their
  base pack.
- r6 — default rigour `standard`; prose level `author` renamed `critic`;
  all prose overrides in `studio.yaml` with full `<work>/<section>` keys;
  dashless skill arguments; YAML chosen for configuration.
- r7 — shell-write guarding stays best effort; memoir and reference-manager
  integration dropped from v1.
- r8 — hooks in Bash + jq, reading only a flat hook-read subset of YAML
  (§10.1); archive hashes moved to a committed `archive.sha256` (§6.4).
- r9 — citation style chosen at `/start`, default `ieeetr`; integrity cap
  asked at `/start` and settable per work, default `coach`; archive backup
  left to the author; `kind: physical` allowed.
- r10 — prose is Markdown only; `/publish` (§8.4) converts to `.tex` and PDF
  via Pandoc and Tectonic, with author-supplied LaTeX templates; citations
  rendered by citeproc with CSL `ieee` by default (replaces `ieeetr`); `/start`
  downloads a pinned, hash-checked jq (§10.1).

---

## 1. Purpose

A project template that turns a Claude Code session into a small editorial
studio for long- and short-form writing. The author stays the creative
authority; the studio supplies structure, memory, continuity and critique, and
writes prose only to the degree the author allows.

Clone the template once per project and open Claude Code at the root, then run
`/start`. What a "project" is depends on the form:

- **Fiction** (`novel`, `short`): one project = one work.
- **Non-fiction**: one project = one **field** (e.g. a degree subject or
  research area). It holds a shared **compendium** of sources, concepts,
  claims, positions and notes, and any number of **works** (essays, papers,
  articles, a dissertation) drawing on it.

## 2. Principles (carried over from CCGS)

1. **Author decides.** Every interaction follows
   *Question → Options → Decision → Draft → Approval*. No write to `bible/`,
   `compendium/`, `outline/`, `manuscript/` or `works/` without
   "May I write this to `<path>`?".
2. **The file is the memory.** A checkpoint file holds an overwritten
   "where I am" note (≤25 lines: current task, next step, open questions) that
   Claude rewrites at each milestone — a section approved and written, a
   decision made — and a session-start hook re-injects. No closeout is needed:
   an abandoned session loses at most the step in progress. Fiction has one
   checkpoint (`session/active.md`); non-fiction has one per work
   (`works/<work>/checkpoint.md`), so sessions on different works never
   overwrite each other. Documents are written skeleton-first, one approved
   section at a time.
3. **Process is a dial.** `rigour: standard` is the default. CCGS defaults to
   `minimal` because, for code, its own measurement showed heavier process
   bought traceability, not quality. Writing differs on two counts: rigour here
   never front-loads documents (§4.3), so `standard` costs little before the
   first sentence; and what it buys — continuity and citation checks as you
   go — catches errors that are expensive to find by rereading a whole
   manuscript. `/start` still asks, and suggests `minimal` for short fiction.
4. **Canon is explicit.** Facts live in a registry (fiction) or the compendium
   (non-fiction); continuity and citations are checked against it, not against
   Claude's recollection.
5. **Reviews are files, not vibes.** Each editorial pass is a prompt file with
   fixed verdicts, run in the reviewer agent's own context.
6. **Helpers observe, never judge.** Scripts report facts (word counts,
   registry mismatches, unresolved citekeys); agents and the author judge.
7. **No invented sources.** (Non-fiction.) Claude never cites anything that is
   not a source note in the compendium, and never treats a source as verified
   until the author has confirmed it. Every cited source has an archived copy
   in the compendium — the downloaded PDF, a dated web capture, or scans of
   the cited pages — so every citation can be checked against the thing
   itself (§6.3–6.4).

## 3. Forms

| `form` | v1 status | Project contains | Unit of drafting | Canon store |
|---|---|---|---|---|
| `novel` | Supported | one work | scene (within chapter) | `bible/` + registry |
| `short` | Supported | one work | scene (single file by default) | slim `bible/` + registry |
| `nonfiction` | Supported | one compendium, many works | section (within a work) | `compendium/` |
| `screenplay` | **Stub** | — | — | — |

`screenplay` is a reserved value: `/start` recognises it, explains it is planned
for a later version, and offers to proceed as `novel` for planning purposes or
stop. No screenplay templates or rules ship in v1.

Memoir is not supported in v1 (§12).

### 3.1 Repository layout

```
CLAUDE.md                     # protocol, layout, checkpoint, prose contract
studio.yaml                   # §4.1
.claude/
  settings.json               # hooks, permissions
  agents/                     # §7
  skills/                     # §8
  rules/                      # §9
  hooks/                      # §10
  reviews/                    # review-pass prompt files (§7.1)
  languages/                  # language packs (§4.5)
  templates/                  # brief, character, place, source note, scene card…
  workflow.yaml               # phases + completion artefacts (§11)
  tools.yaml                  # pinned versions + SHA-256 of jq, Pandoc, Tectonic (§10.1, §8.4)
  csl/ieee.csl                # bundled default citation style (§8.4)
  bin/                        # downloaded tools; gitignored

publish/default.tex           # project default LaTeX template, if any (§8.4)
out/                          # /publish output; gitignored

# fiction
bible/                        # brief, style-guide, characters/, world/, timeline, registry.yaml
outline/                      # structure.md, chapters/<chapter>.md (scene cards)
manuscript/<chapter>/<unit>.md
reviews/
session/active.md             # checkpoint
session/provenance.jsonl

# non-fiction
compendium/                   # §6.1
works/<work>/                 # §6.5, incl. checkpoint.md
session/provenance.jsonl
```

`/start` creates only the folders relevant to the chosen form. `short` uses
`manuscript/story.md` by default; the author may split it into scenes.

## 4. Configuration

All configuration is YAML (§13, question 1).

Configuration keys are fixed identifiers spelt in British English (`rigour`,
`behaviour`, `colour`…), consistently across every file. There are no
American-spelling aliases: a misspelt key is reported as an unknown key, with
the nearest valid key suggested.

### 4.1 Project config — `studio.yaml`

```yaml
schema_version: 1

project:
  title: "Political Philosophy (BA)"
  form: nonfiction       # novel | short | nonfiction | screenplay (stub)
  field: "Political philosophy"     # nonfiction only
  stage: premise         # fiction only: premise | draft | revision

modes:
  rigour: standard       # minimal | standard | full
  automation: collaborative   # collaborative | guided

prose:
  level: critic          # critic | coach | editor | co-author | ghostwriter
  overrides:             # §5.1; keys are paths under the prose root, without extension
    # fiction:      ch07-the-storm: co-author        ch07-the-storm/sc03-wreck: editor
    # non-fiction:  public-reason-essay: coach       public-reason-essay/05-conclusion: editor

language:                # §4.5
  default: en-GB         # BCP 47 tag of the prose: en-GB, en-US, de-DE, de-AT, de-CH, …
  interface: en          # language skills and agents use to talk to the author
  options:               # declared by the language pack, not by the studio
    oxford_comma: false  # an `en` option
    # gendering: colon   # a `de` option: none | colon | asterisk | pair-forms

style:                   # language-independent craft choices
  pov: close-third       # fiction only
  tense: past            # fiction only
  register: formal       # free text; interpreted by the language pack
  citation_style: ieee   # nonfiction: CSL style id; chosen at /start; default ieee

publish:                 # §8.4
  template: null         # project default LaTeX template; null → Pandoc's built-in
  engine: tectonic       # tectonic | xelatex | lualatex | pdflatex (the latter need a TeX install)

integrity:               # nonfiction only — defaults for every work
  assessed_cap: coach    # asked at /start; default cap on an assessed work's prose level
```

### 4.2 Work config — `works/<work>/work.yaml` (non-fiction only)

```yaml
title: "Is Rawlsian public reason self-defeating?"
kind: essay              # essay | paper | article | dissertation | report | other
module: "PHIL2041 Contemporary Political Philosophy"   # optional
assessed: true           # true → integrity rules apply (§5.4)
assessed_cap: null       # cap for this work; null → integrity.assessed_cap
policy: "Category B: AI permitted for planning and feedback only; acknowledge use"
word_limit: 2500
page_limit: null         # pages, when the brief sets them; either limit, or both
word_count_excludes: [bibliography, footnotes]   # what doesn't count
words_per_page: null     # page estimate; null → from page_format, else style.words_per_page, else 250
page_format:             # the brief's format, for the estimate only (the PDF's comes from the template)
  fontsize: 12
  linestretch: 1.5
status: draft            # brief | draft | revision | complete
citation_style: null     # null → project default
template: null           # LaTeX template for /publish; null → publish.template
language: null           # BCP 47 tag; null → project default (e.g. de-DE for one essay)
language_options: {}     # overrides project language.options for this work
```

Prose levels are not set here: all prose-level choices live in one place,
`studio.yaml` → `prose` (§5.1). `assessed` and `assessed_cap` are read from
here to apply the integrity cap; the cap is a ceiling, not a level.

**Page counts** (added after v1). `/status` estimates pages from the counted
words (same exclusions) at a words-per-page figure: the work's
`words_per_page`; else derived from `page_format` (at 12pt, 500 single-spaced
to 250 double-spaced, linear between, scaled by (12/fontsize)²; a missing
fontsize is 12, a missing linestretch 2); else `studio.yaml`
`style.words_per_page`; else 250. `/publish` records the real page count of
each PDF in `out/<target>.pages` (from TeX's log), and `/status` reports it,
`stale` once a source has changed since. A page limit is checked against the
fresh PDF count, else the estimate. The PDF count is the whole document, and
it matches a brief only if the LaTeX template does. Fiction gets page totals,
no limit. `page_limit` is hook-read (the session-start status line shows
`~pages/limit`).

### 4.3 Rigour

**Rigour sets how much the studio tracks and checks *as you write*, never how
much must exist before you start.** At every level the only prerequisite for
drafting is a brief. Bibles, outlines, compendium entries and the research
question grow alongside the draft.

**Who does the work:** Claude proposes; the author approves. Bible entries,
registry lines, claims and outline updates are extracted by Claude from what
the author has written or said (drafts, notes, conversation) and offered for
approval at "unit done". The author is never asked to fill in a form by hand.

| | `minimal` | `standard` | `full` |
|---|---|---|---|
| Before drafting | brief | brief | brief |
| Fiction: bible upkeep | on request | at unit done, Claude proposes registry lines for new facts | as standard, plus full bible entries (character, place, world rule) for anything new |
| Non-fiction: compendium upkeep | on request | at unit done, Claude proposes claims for new assertions and links to existing sources | as standard, plus concept and position entries |
| Outline | optional | kept; Claude offers an update when the draft departs from it | as standard, and each departure is noted at unit done |
| Non-fiction: research question | living at every level (§6.5) | Claude asks at unit done whether the section moved the question | as standard, and sections written under an earlier version of the question are listed for re-reading |
| Fiction: continuity check | on request | at unit done | at unit done |
| Non-fiction: citation check | **when a work is marked complete**, and on request | at unit done, and when a work is marked complete | as standard, plus every factual assertion must map to a claim or citation |
| Developmental review | on request | at chapter / work milestones | at unit done |
| Doc density | terse bullets | bullets + rationale | rationale + alternatives |

**Citation checking has a floor.** For non-fiction it runs at every rigour
level, at least once before a work is marked complete; it is integral to
academic writing, not a process preference. As everywhere in the studio, its
verdict is advisory: the author can still mark a work complete with
outstanding errors, but `/status` keeps reporting them and the provenance
statement (§5.4) mentions them.

Rigour fronts these knobs; individual knobs are not exposed in v1.

### 4.4 Automation

`collaborative` (default) asks at every decision. `guided` asks only at major
decisions (structure, canon changes, compendium changes, any prose write). There
is no `autonomous` mode in v1. **Prose writes, canon changes and marking a source
verified always ask, in every mode.**

### 4.5 Languages

Configuration is language-independent: keys are fixed identifiers, and nothing
in `style` assumes a particular language. Everything language-specific lives in
a **language pack**.

**Language of the prose.** A BCP 47 tag. The region subtag carries what a
"spelling" switch would have (`en-GB` vs `en-US`, `de-CH` without ß vs
`de-DE`). Resolution for a prose file:

1. Non-fiction: `work.yaml` → `language`
2. `studio.yaml` → `language.default`

Per-passage language switching (e.g. multilingual fiction) is out of scope for
v1; quotations in another language are handled by the source note (§6.1).

**Interface language.** `language.interface` sets the language skills and
agents use when talking to the author. It is independent of the prose
language: discussing a German essay in English is normal. Default: the prose
language of the project.

**Language packs** — `.claude/languages/`:

```
.claude/languages/
  _template/             # scaffold used by /language add
  en/
    pack.yaml            # name, support level, declared options + defaults
    conventions.md       # orthography authority, punctuation, typography, numbers, dates
    grammar.md           # what the grammar-editor checks and how
    style.md             # language-specific line-editing notes (rhythm, register)
    academic.md          # academic conventions: abbreviations, hedging, citation locale
    variants/
      en-GB.md           # overlay: -ise/-ize policy, quotation marks, dates
      en-US.md
  de/
    pack.yaml · conventions.md · grammar.md · style.md · academic.md
    variants/
      de-DE.md · de-AT.md · de-CH.md
```

Everything for one language lives in one folder: adding or removing a language
is adding or removing that folder.

- A pack resolves by BCP 47 fallback. For tag `de-CH`: the folder is the
  primary language subtag (`de/`); the overlay is `de/variants/de-CH.md` if it
  exists. A tag with no overlay uses the base pack alone; a language with no
  folder has **no** grammar review and `/status` says so, pointing at
  `/language add`.
- `pack.yaml` declares the pack's `options` with allowed values and defaults
  (e.g. `de`: `gendering: none | colon | asterisk | pair-forms`; `en`:
  `oxford_comma: true | false`). `language.options` and a work's
  `language_options` are validated against it; an unknown option is an error.
- `support:` is `supported` (ships with the studio) or `user-defined`.
- **v1 ships:** `en` (+ `en-GB`, `en-US`) and `de` (+ `de-DE`, `de-AT`,
  `de-CH`), all `supported`.

**Who uses a pack:** `grammar-editor` (correctness), `line-editor` (style),
`beta-reader` and `developmental-editor` (register and academic conventions),
`/draft` at `co-author`/`ghostwriter` (so drafted prose follows the
conventions), and the citation tooling (CSL locale follows the work's language,
so a German essay in Harvard style gets *S.*, *ebd.*, *Hrsg.* automatically).

**Unsupported languages.** `/language add <tag>` interviews the author —
orthography authority (Duden, Oxford, RAE…), quotation marks and typography,
formal/informal address, inclusive-language conventions, academic
abbreviations and citation locale, known pitfalls — and writes a pack from
`_template/`, marked `support: user-defined`. Every review run with a
user-defined pack says so in its report header, and reports note that Claude's
grammar checking is less reliable in lower-resource languages.

## 5. The prose ladder

| Level | Claude's role | What Claude may put in prose files |
|---|---|---|
| `critic` | Critic, planner, bible/compendium keeper; the author writes every word | Nothing. Feedback goes in `reviews/` as notes that name the problem, not rewritten text |
| `coach` | As above, plus short illustrations of a technique | Nothing. Illustrations stay in conversation or `reviews/`, labelled as illustrations |
| `editor` | Line-level suggestions on the author's prose | Edits presented as diffs, accepted or rejected one at a time. No new passages |
| `co-author` | Drafts units from the author's card/outline | Whole units, each approved before writing. Author-owned passages are never touched |
| `ghostwriter` | Drafts chapters or whole works from the outline | Whole chapters/works; author directs and approves unit by unit |

Level names describe **Claude's** role. "Author" always means the human; it is
used that way in frontmatter (`prose: author`) and fences (`<!-- author -->`),
and is deliberately not a level name.

"Prose files" means `manuscript/**` (fiction) and `works/*/sections/**`
(non-fiction). Compendium and bible files are not prose: Claude may write them
at any level, with approval.

### 5.1 Resolution

All prose levels resolve from `studio.yaml` → `prose` alone. Override keys are
**full paths from the prose root, without extension, with structural folder
names dropped** — one derivation, used by every skill and hook, so a key always
names every level above it:

| Form | Target file | Keys checked, most specific first |
|---|---|---|
| Fiction | `manuscript/<chapter>/<unit>.md` | `<chapter>/<unit>` → `<chapter>` → `prose.level` |
| Non-fiction | `works/<work>/sections/<section>.md` | `<work>/<section>` → `<work>` → `prose.level` |

(`works/` is the prose root; `sections/` is a fixed structural folder and does
not appear in keys.) For non-fiction, if the work's `work.yaml` has
`assessed: true`, the resolved level is then **capped** at
`integrity.assessed_cap` (§5.4).

An override key that matches no file or directory is reported as an error by
`/status` (CCGS: "a key that matches no system is an error, not a no-op").

### 5.2 Enforcement

A `PreToolUse` hook on `Write|Edit` targeting prose files:

- `critic`, `coach` → **deny** (exit 2; message names the level in force, where
  it came from, and — if an integrity cap applied — says so).
- `editor`, `co-author`, `ghostwriter` → allow, with a reminder of the level's
  contract injected into context.

The same hook inspects `Bash`/`PowerShell` commands for redirections or
file-writing commands that mention a prose root and denies them at
`critic`/`coach`. This is **best effort**: a shell command can always obscure
its target. The rules files and agent prompts carry the same contract, so the
hook is a backstop, not the only guard.

Subagents' tool calls pass through the same hooks, so delegated work is covered.

### 5.3 Ownership and provenance

- Every prose unit carries frontmatter:
  ```yaml
  ---
  prose: author          # author | claude | mixed
  locked: false          # true → no Claude edits at any level
  ---
  ```
  Within a `mixed` file, author-owned passages may be fenced with
  `<!-- author -->` … `<!-- /author -->`; Claude never edits inside a fence.
- A `PostToolUse` hook appends one JSON line per Claude write to
  `session/provenance.jsonl`: timestamp, file, work (if any), level in force,
  tool, characters added/removed. An observation log; it never blocks.
- `/status provenance [work]` summarises it per chapter or per work.

### 5.4 Academic integrity (non-fiction, `assessed: true`)

Universities set their own rules on AI use, often per module. The studio can't
know them, so it makes the author state them and then holds to them:

- `/new-work` asks whether the work is assessed and, if so, for the policy text
  or category, recorded verbatim in `work.yaml` → `policy`.
- The prose level for an assessed work is capped at the work's
  `assessed_cap`, or `integrity.assessed_cap` if that is null (default
  `coach`). `/start` asks for the project default; `/new-work` asks for an
  assessed work's cap, offering the project default, so a stricter module can
  be set at creation. Raising a cap later is a deliberate edit to `work.yaml`
  or `studio.yaml`; no skill offers to do it as a convenience.
- Compendium work (summarising sources, organising notes, critiquing the
  argument) is unaffected by the cap; whether *that* is permitted is also the
  author's call under their policy, and the `policy` field is shown at the top
  of every `/draft` and `/review` run on the work as a reminder.
- `/status provenance statement <work>` drafts an AI-use acknowledgement from
  the provenance log and the review reports, for the author to edit. It
  describes what happened; it does not assert compliance.

## 6. Non-fiction: the compendium

One shared knowledge base per field, used by every work in the project.

### 6.1 Contents

```
compendium/
  library.bib            # canonical bibliography (BibTeX/BibLaTeX), keyed by citekey
  sources/<citekey>.md   # one note per source
  concepts/<slug>.md     # terms and how different authors use them
  claims.yaml            # claim registry (§6.2)
  positions/<slug>.md    # debates: who argues what, and the author's own view
  notes/<date>-<slug>.md # lecture/seminar/reading notes, raw
  archive/<citekey>/     # the archived copy of each source (§6.4); gitignored
  archive.sha256         # checksums of every archived file (§6.4); committed
  inbox/                 # unprocessed captures: PDFs, links, pasted text
```

**Source note** (`sources/<citekey>.md`):

```yaml
---
citekey: rawls1993
status: verified         # unverified | verified
read: full               # skimmed | partial | full
language: en             # BCP 47 tag of the source itself
tags: [public-reason, liberalism]
archive:
  kind: pdf              # pdf | web | scan | physical
  files: [rawls1993.pdf]          # relative to archive/<citekey>/; hashes in archive.sha256 (§6.4)
  retrieved: 2026-11-07  # required for kind: web; optional otherwise
  url: null              # required for kind: web
  held: null             # required for kind: physical: where the print copy is
---
```
Sections: *Summary* · *Key arguments* · *Quotations* (each with locator: page,
section or paragraph) · *Author's assessment* · *Links* (concepts, claims,
positions, other sources).

Quotations are stored in the source's original language. A work in another
language may quote the original or a translation; a translation is marked as
the author's own (per the work's language pack, e.g. *eigene Übersetzung*,
*my translation*) unless the note records a published translation as its own
source.

The note body records what the **source** says; the *Author's assessment*
section records what the **author** thinks of it. Keeping the two apart is what
lets the citation check (§7.1) distinguish attribution from opinion.

### 6.2 Claims

`claims.yaml` — the non-fiction equivalent of the fiction registry:

```yaml
- id: C-014
  statement: "Public reason requires justification acceptable to all reasonable citizens."
  kind: source-claim       # source-claim | empirical | author-position
  support:   [{cite: rawls1993, loc: "p. 137"}]
  against:   [{cite: wall2002, loc: "pp. 385-9"}]
  status: contested        # established | contested | author-position
  used_in:   [public-reason-essay/03-the-asymmetry]
```

`used_in` is maintained by `/draft` and the citation check, so a change to a
claim can be traced to every work and section that relies on it.

### 6.3 Source verification

- Any source Claude finds (web search, a DOI, a reference inside another
  source) enters as `status: unverified` with whatever metadata was retrieved.
- Only the author marks a source `verified`, after checking it exists and says
  what the note claims. This is an always-ask decision.
- An unverified source may be discussed but not cited in a prose file; the
  citation check reports it as an error.
- A source cannot be marked `verified` without an archived copy (§6.4), or,
  for `kind: physical`, the author's attestation in `held`.
- Quotations in a source note must have a locator; a quotation without one
  cannot be cited.

### 6.4 Source archive

**Every cited source must exist in the compendium as a copy the author holds**,
not just as metadata. The rule: if it is cited in a work, `archive/<citekey>/`
contains it.

| `kind` | What is stored | Required metadata |
|---|---|---|
| `pdf` | The downloaded article, chapter or book PDF | checksum entry |
| `web` | A dated capture of the page: PDF print or single-file HTML (e.g. SingleFile), plus the URL | `url`, `retrieved`, checksum entry |
| `scan` | Photos or scans of the cited pages of a print source (at least each page a locator points to) | checksum entry per file |
| `physical` | Nothing stored; the author attests they hold the print copy | `held: <where>` (e.g. "university library, shelfmark JC423 .R38"); no checksum entry; the citation check reports it as a warning on every run, and quotations from it are checked against the source note only |

**Checksums.** Hashes live in one committed file,
`compendium/archive.sha256`, in the standard `sha256sum` format — one line per
archived file, path relative to `compendium/`:

```
9f2c…e1  archive/rawls1993/rawls1993.pdf
4b7a…03  archive/wall2002/wall2002-p385.jpg
```

Verifying the whole archive (or one source's lines) is `sha256sum -c`; no
parser is involved. A source note is matched to its lines by the
`archive/<citekey>/` prefix.

Behaviour:

- **Capture is the author's job.** `/source` tells the author what to save and
  where, and adds its line to `archive.sha256` once the file is present. Claude may fetch a web
  page as a convenience draft of the note, but a Claude-fetched capture is
  marked `captured_by: claude` and does not count towards verification until
  the author confirms it matches what they read.
- **Web captures are frozen.** The citation refers to the page as it was on
  `retrieved`. If the author re-captures, the old capture is kept alongside
  with its own date; the note says which one the citations use.
- **The citation check reads the copy.** `/cite-check` and the `citation`
  review pass confirm, for each citation in a prose file: the citekey has a
  note, the note is `verified`, the archive files exist and pass
  `sha256sum -c`, and every direct quotation appears in the archived copy at (or near)
  the stated locator. A quotation that cannot be found is an error, not a
  warning.
- **Storage and copyright.** `archive/` is gitignored by default: copyrighted
  PDFs must not be pushed to a public remote. The author chooses how the
  archive is backed up, if at all; the studio does not manage it.
  `archive.sha256` *is* committed, so a restored archive can be checked
  against it.

### 6.5 Works

```
works/<work>/
  work.yaml              # §4.2
  brief.md               # assignment text verbatim, marking criteria, research question
  outline.md             # sections → claim + claim ids + citekeys
  sections/<nn-slug>.md  # prose units
  reviews/               # pass reports for this work
  checkpoint.md          # this work's checkpoint (§2, principle 2)
  template.tex           # optional per-work LaTeX template (§8.4)
```

**The research question is expected to change.** `brief.md` keeps the current
working question (or thesis) at the top and a dated history beneath it: each
revision with a one-line reason ("narrowed to public reason after reading
Wall"). Revising it is a normal step, never an error. Claude may suggest a
revision when drafting or research has moved past the current wording; the
author decides. Outline sections record which version of the question they
were written under, which is what lets `full` rigour list sections to re-read.

**Citation syntax in prose:** Pandoc citekeys — `[@rawls1993, p. 137]`,
`@wall2002 argues…`. Style-independent, checkable by grep, and rendered into
any CSL style (IEEE, Harvard, APA, OSCOLA, Chicago…) by `/publish` (§8.4). The
bibliography is generated from the keys used, never written by hand. Prose is
always Markdown; there are no `.tex` sources to check.

## 7. Agents

Eight agents, no hierarchy. Each declares `model:` in frontmatter and the
collaboration protocol in its body. Each reads the resolved prose level for its
target and changes **what it produces**, never whether it runs.

| Agent | Fiction role | Non-fiction role |
|---|---|---|
| `structure-architect` | Acts, plot, scene sequencing, pacing | Argument architecture per work: thesis, section logic, through-line |
| `character-lead` | Arcs, motivations, voice profiles | Inactive |
| `librarian` | Inactive | Owns the compendium: ingests sources, writes notes, links concepts/claims/positions, answers "what do my sources say about X?" |
| `continuity-editor` | Owns `registry.yaml`; timeline, names, facts | Citation checker: every citekey resolves, every source verified, quotations match notes and locators, claims attributed correctly |
| `developmental-editor` | Does the story work? stakes, arc payoff, promise | Does the argument land? thesis, structure, evidence, counter-arguments, fit to brief |
| `line-editor` | Sentence-level style: rhythm, clarity, voice adherence; uses the pack's `style.md` | Same, plus precision, hedging, register |
| `grammar-editor` | Correctness: grammar, spelling, punctuation, typography, per the language pack in force (§4.5) | Same, plus the pack's `academic.md` conventions |
| `beta-reader` | Reader reaction from a configured persona | Persona configurable; **marker** persona reads the brief's marking criteria and reports against them |

Drafting at `co-author`/`ghostwriter` is done by the main session via `/draft`,
using structure cards, voice profiles (fiction) or outline claims and source
notes (non-fiction) as inputs. One place generates prose; one place enforces
the ladder.

### 7.1 Review passes

Files under `.claude/reviews/`, each with: trigger, context to pass, prompt,
verdicts (`APPROVE` / `CONCERNS [...]` / `REJECT [...]`). The orchestrating
skill passes the file **path** to the agent; the agent reads it in its own
context (CCGS pattern — keeps the main context small).

v1 passes: `continuity` (fiction), `citation` (non-fiction), `developmental`,
`line`, `grammar`, `beta` (incl. `marker` persona), `milestone`. Every report
header names the language and pack (with its support level) it ran under.

## 8. Skills (v1)

### 8.1 Shared

| Skill | Purpose |
|---|---|
| `/start` | Detect state, ask form, rigour, prose level, prose and interface language (and for non-fiction: field, citation style, integrity cap); download jq if not installed, with approval (§10.1); write `studio.yaml`; create folders; offer `/language add` if the language has no pack; name the one next step |
| `/language add <tag>` | Interview the author and write a user-defined language pack (§4.5) |
| `/outline [work]` | Fiction: structure doc then chapter cards. Non-fiction: section outline for a work, each section with its claim, claim ids and citekeys |
| `/draft <unit>` | Behaviour depends on resolved prose level (below) |
| `/review <pass> <target>` | Runs one review pass; writes report to `reviews/` (or `works/<work>/reviews/`) |
| `/status [provenance [statement]] [work]` | Where am I, what's next, word counts (vs. limits for works), outstanding checks, override errors; `provenance` adds the provenance summary; `provenance statement` drafts the AI-use acknowledgement (§5.4) |
| `/publish [work] <tex \| pdf>` | Convert the manuscript or a work to LaTeX or PDF (§8.4) |

**Arguments are plain words, not flags.** Skills take positional sub-commands
(`/status provenance statement public-reason-essay`), never `--flags`.
Sub-command words are reserved: `/new-work` refuses a work slug that collides
with one (`provenance`, `statement`, `add`, `tex`, `pdf`, and each review pass name), so a
trailing work name is never ambiguous.

### 8.2 Fiction only

| Skill | Purpose |
|---|---|
| `/premise` | Brief: logline, protagonist want/need, stakes, ending intent, comps |
| `/bible <kind> [name]` | Create or extend a bible entry from template; registers entities |
| `/continuity-check [scope]` | Grep-first scan of manuscript against registry; conflict report |

### 8.3 Non-fiction only

| Skill | Purpose |
|---|---|
| `/new-work` | Create `works/<work>/` from an assignment: paste brief and marking criteria, set kind, limit, assessed + policy + cap; draft a working research question or thesis |
| `/source <doi \| url \| file \| citekey>` | Add or update a source: fetch metadata, add to `library.bib`, create note skeleton, help fill it from the author's reading (unverified until the author confirms) |
| `/compendium <concept \| claim \| position \| note> [name]` | Create or extend a compendium entry; keeps links two-way |
| `/ask <question>` | Query the compendium: what do my sources say, where do they disagree, which claims are thin. Answers cite source notes; never answers from outside the compendium without saying so |
| `/cite-check [work]` | Grep-first: unresolved citekeys, unverified sources, missing or altered archive copies, quotations not found in the archived copy, claims cited without support |

`/draft` per level:

- `critic` — assembles a brief for the author: card or outline section, relevant
  bible entries or source notes and claims; offers `/review` when done.
- `coach` — as `critic`, plus targeted technique illustrations on request.
- `editor` — reads the author's unit, proposes changes as a numbered list of
  diffs; applies only the accepted ones.
- `co-author` — drafts the unit in conversation; writes it on approval; sets
  `prose: claude` (or `mixed` if the file had author text).
- `ghostwriter` — drafts each unit of a chapter or work in turn, approval per unit.

All levels finish with a short "unit done" checklist: registry/claims updated
(including `used_in`), card or outline status set, word count vs. limit
(non-fiction), checkpoint updated.

Deferred to v2: `/propagate-canon-change` (and its non-fiction twin: a claim or
source changed → affected sections), `/settings`, DOCX and EPUB output from
`/publish`, reference-manager sync, reader-persona library, skill tests.

### 8.4 Publishing

The author writes Markdown; `/publish` produces LaTeX or PDF from it. Nothing
else in the studio sees LaTeX, so hooks, rules, fences, word counts and the
citation check stay Markdown-only.

**Pipeline.** Pandoc joins the units in outline order (fiction: chapter and
unit order; non-fiction: the work's `sections/` in `nn-` order), renders
citations with citeproc against `compendium/library.bib` and the resolved CSL
style, and fills the LaTeX template. `tex` stops there and writes
`out/<work>.tex`; `pdf` also compiles it with the configured engine and writes
`out/<work>.pdf`. The CSL locale and LaTeX language (babel) follow the work's
language, so a German work gets German citation terms and hyphenation. Raw
LaTeX written in the Markdown (an equation, a table) passes through unchanged.

**Citation style.** Citations are formatted by Pandoc (citeproc) in both
outputs, so `.tex` and PDF always agree and no BibTeX run is needed. The
default is CSL `ieee`, bundled in `.claude/csl/`. Any other style id from the
official CSL styles repository may be set in `studio.yaml` or `work.yaml`;
`/publish` fetches it once from a pinned commit of that repository, with the
author's approval, and keeps it in `.claude/csl/`.

**Templates.** Resolution: the work's `template.tex` → `publish.template` →
Pandoc's built-in LaTeX template. On the first `/publish` for which no
template is set, the skill asks the author to:

1. supply a template for this work (e.g. a module's required layout),
2. supply a project default used by every work without its own, or
3. use Pandoc's built-in template for now.

A supplied template may be an ordinary `.tex` document, such as a university
thesis template, rather than a Pandoc template. `/publish` then proposes the
Pandoc version: placeholder content replaced by `$body$`, the title, author and
date replaced by their variables, and the preamble block Pandoc's citeproc
output needs (`CSLReferences`) added. It shows this as a diff and saves it
only on approval, keeping the original beside it. Supporting files (`.cls`,
`.sty`, logos) live in the same folder as the template. Fiction uses
`publish.template` only.

**Before converting.** For non-fiction, `/publish` runs the citation check
first and lists any errors. It asks whether to continue rather than refusing,
since publishing a draft for a supervisor is normal; nothing hard-blocks. It
never changes the prose.

**Tools.** Pandoc and Tectonic are needed only by `/publish`. On first use the
skill downloads the versions pinned in `.claude/tools.yaml` (Pandoc 3.13,
Tectonic 0.17.0 at the time of writing) from their official GitHub releases,
with the author's approval. It verifies each against the SHA-256 committed in
`tools.yaml` and puts it in `.claude/bin/`. A copy already on `PATH` is used if
it is the pinned version or newer. Tectonic downloads the TeX packages a
document needs on its first compile and caches them, so the first PDF needs a
network connection.

**Why Tectonic.** Author templates are LaTeX, which rules out Typst. Tectonic
is one binary with no TeX distribution, Perl or `latexmk` to install, and
reruns the compile until references settle. It is XeTeX-based, so a template
written for pdfLaTeX (e.g. `\usepackage[utf8]{inputenc}`, some `microtype`
options) may need small changes; `/publish` reports the failing log line and
proposes the fix. An author with TeX Live or MiKTeX can set `publish.engine`
to `xelatex`, `lualatex` or `pdflatex` instead.

## 9. Rules (path-scoped)

- `manuscript/**`, `works/*/sections/**` — prose contract for the resolved level;
  respect the style guide, the language pack in force (§4.5) and its options,
  and (fiction) POV/tense; never edit
  `locked: true` files or `<!-- author -->` fences; no unrequested rewrites at
  any level.
- `bible/**` — every entry has a canon level (Established / Provisional /
  Under Review); mysteries record their true answer; world rules stated
  explicitly; new facts registered in `registry.yaml`.
- `compendium/**` — source notes separate what the source says from the
  author's assessment; every quotation has a locator; nothing is marked
  `verified` by Claude; no source is `verified` without an archived copy and
  its line in `archive.sha256` (or, for `kind: physical`, a `held` entry); web sources carry URL and retrieval date; claims link to sources
  in both directions; contested claims list both sides.
- `works/*/sections/**` (additionally) — every citation is a Pandoc citekey that
  resolves in `library.bib`; no citation of unverified sources; direct quotation
  only from a source note's *Quotations* section.

## 10. Hooks

| Hook | Event | Behaviour |
|---|---|---|
| `session-start` | SessionStart | Fiction: inject `session/active.md`. Non-fiction: inject the named work's `checkpoint.md`, or if none is named, each work's next step. Plus a one-line status (form, prose level, language; non-fiction: words vs. limit) |
| `prose-guard` | PreToolUse (Write, Edit, Bash, PowerShell) | §5.2, including the integrity cap |
| `provenance-log` | PostToolUse (Write, Edit) | §5.3 |
| `read-guard` | PreToolUse (Read) | Whole-file read of a prose, bible or compendium file over a threshold returns its headings instead, so the retry reads one section |
| `verify-guard` | PreToolUse (Write, Edit) on `compendium/sources/**` | Warns if a write changes `status:` to `verified` (the author must do this, or confirm it explicitly); **denies** it if the source's files are missing or fail `sha256sum -c` against `archive.sha256` (`kind: physical`: denies if `held` is empty) |

### 10.1 Implementation

- **Bash + jq.** Bash is present wherever Claude Code runs (Git Bash is
  required on Windows; built in on macOS and Linux). `jq` is the one extra
  tool, a single static binary, used to read the JSON hooks receive on
  stdin and to write `provenance.jsonl`. Text processing uses tools Git Bash
  ships: `awk`, `grep`, `sed`, `sha256sum`.
- **`/start` installs jq.** If no `jq` is on `PATH`, `/start` asks, then
  downloads the official release pinned in `.claude/tools.yaml` (jq 1.8.2) for
  the platform (Windows, macOS or Linux; amd64 or arm64) from the jqlang
  GitHub releases into `.claude/bin/`. It checks the file against the SHA-256
  committed in `tools.yaml`, copied from that release's `sha256sum.txt` when
  the version is pinned, and deletes it on a mismatch. The hash is never
  fetched alongside the binary, which is what makes the check worth having.
  Hooks use `.claude/bin/jq` first, then `jq` on `PATH`.
- **Missing jq fails closed for guards.** If `jq` is absent, `prose-guard` and
  `verify-guard` deny with a message saying to run `/start` or install jq; observers
  (`session-start`, `provenance-log`, `read-guard`) degrade with a one-line
  warning. A guard that silently disables itself is not a guard.
- **Hooks never parse general YAML.** They read only a **hook-read subset**
  that is deliberately flat — `key: value` on one line, block style, no flow
  collections (`{…}`, `[…]`), no anchors, no multi-line strings:
  - `studio.yaml`: `prose.level`, every line of the `prose.overrides` map,
    `integrity.assessed_cap`
  - `work.yaml`: `assessed`, `assessed_cap`
  - prose frontmatter: `locked`
  - source frontmatter: `status`, `archive.kind`, `archive.held`

  Everything else in any YAML file is read by Claude, not hooks, and may use
  full YAML. `/status` validates the hook-read subset and reports any line a
  hook could not read reliably as an error.
- **Small and few processes.** Process start-up is slow under Git Bash on
  Windows, so each hook exits early when the event is not relevant (wrong
  path, wrong command) and avoids pipelines of many subprocesses on the hot
  path.

## 11. Workflow phases (`workflow.yaml`)

**Fiction:** `premise` → `draft` → `revision`.

**Non-fiction, per work:** `brief` → `draft` → `revision` → `complete`.

Bible, outline, compendium and research are not phases: they run alongside
drafting at the depth rigour sets (§4.3). Each phase lists the artefact that
proves completion (glob + optional pattern). Entering `complete` triggers the
citation check (§4.3). `/status` reads this; nothing hard-blocks — verdicts are
advisory, as in CCGS.

## 12. Out of scope for v1

- Screenplay templates, formatting and rules (stub only).
- DOCX and EPUB output — v2. `/publish` (§8.4) covers `.tex` and PDF in v1;
  the other formats are further Pandoc targets and need no migration.
- Writing prose directly in LaTeX — not planned; LaTeX is an output (§8.4).
- Reference-manager integration (Zotero/Better BibTeX sync) — v2. In v1 the
  studio owns `library.bib` and `/source` maintains it.
- Memoir (as a form, or as non-fiction with `character-lead` active).
- Multi-work fiction (series, collections sharing a bible) — the non-fiction
  compendium shape would extend to this; not in v1.
- Multi-author projects / per-author local overrides.
- Per-passage language switching within a prose file; language packs beyond
  `en` and `de` (users add their own via `/language add`).
- Agent teams, parallel orchestration skills.
- Framework self-tests (CCGS `studio-tests/` equivalent).

## 13. Open questions

1. ~~**Config file format.**~~ **Resolved (r6): YAML**, for readability and hand
   editing — `studio.yaml`, `work.yaml`, `claims.yaml`, `pack.yaml` and all
   frontmatter. Hooks read only a flat subset of it (§10.1).
2. ~~**Hook runtime.**~~ **Resolved (r8): Bash + jq** (§10.1). Chosen over
   Node, Python and Elixir because it adds the least for other users to
   install and starts fastest on a hook that runs on nearly every tool call.
3. ~~**Shell-write guarding.**~~ **Resolved (r7): best effort**, as in §5.2.
4. ~~**Memoir.**~~ **Resolved (r7): not in v1** (§12).
5. ~~**Default citation style.**~~ **Resolved (r9):** the author chooses at
   `/start`; the offered default is CSL `ieee` (r10; `ieeetr` in r9 does not
   localise for German). Per-work override in `work.yaml`.
6. ~~**Reference manager.**~~ **Resolved (r7): none in v1.** The studio owns
   `library.bib`; `/source` writes entries to it with approval (§12).
7. ~~**Default integrity cap.**~~ **Resolved (r9):** asked at `/start`
   (default `coach`) and per assessed work at `/new-work` (§5.4).
8. ~~**Archive backup.**~~ **Resolved (r9): left to the author** (§6.4).
9. ~~**Print-only sources.**~~ **Resolved (r9): `kind: physical` allowed**,
   with a permanent warning (§6.4).
10. ~~**Prose format.**~~ **Resolved (r10): Markdown only**, with LaTeX and
    PDF produced by `/publish` (§8.4), so non-fiction carries no LaTeX
    overhead while drafting.
11. ~~**Installing jq.**~~ **Resolved (r10): `/start` downloads a pinned,
    hash-checked official release** (§10.1), rather than committing binaries
    or using a submodule.
