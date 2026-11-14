---
name: start
description: "Onboarding - meets the author where they are (nothing yet, a seed, a clear idea, or existing material), sets up the project (form, languages, rigour, prose level, ideas mode; for non-fiction field, citation style and integrity cap), writes studio.yaml and the folders, installs jq with approval, shows the path ahead and hands off the first step. A returning author is sent to /next. Use when studio.yaml does not exist, the author is new, or types /start."
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, AskUserQuestion, Bash(bash .claude/scripts/flow-check.sh*), Bash(bash .claude/scripts/install-tool.sh check *), Bash(bash .claude/scripts/status.sh*)
---
# /start (v1 §8.1; development-flow §4)

Orientation first, configuration second. Follow the collaboration protocol
in `CLAUDE.md`: question → options → decision → draft → approval.

**Asking.** Fixed choices (where are you, form, rigour, prose level, ideas
mode, confirming a write) use the question tool, so they can be tapped; put
your recommendation first and mark it "(Recommended)". Free answers (title,
the idea itself, a work's field) are plain text. A dismissed question is not
an answer: ask again in plain text. Ask in the language the author writes
in until the interface language is settled.

**Hand off, never run.** `/start` ends by naming the first step; it never
invokes it (development-flow principle 4).

## Phase 0 — returning author

If `studio.yaml` exists, **ask nothing and change nothing.** Run `bash
.claude/scripts/flow-check.sh` and say in two or three lines: form, prose
level, ideas mode, and where the work stands (current phase; for drafting,
`drafted: n of m`). Settings are changed by editing `studio.yaml` (no
`/settings` in v1). End with: "Type `/next` to see the next step." Stop.

## Phase 1 — read the disk

Run `bash .claude/scripts/flow-check.sh disk` and keep its lines; do not show
them yet. They check the author's answer in Phase 3:

| Line | Means |
|---|---|
| `manuscript:`, `bible:`, `outline:` | an older or hand-made fiction project |
| `works:`, `compendium:` | an older or hand-made non-fiction project |
| `ideas:` | notes from an earlier start |
| `loose:` | writing outside the studio's folders (a draft, notes, a `.docx`) |

If studio folders exist without `studio.yaml`, `/start` will only create what
is missing and never overwrites a file; say so in Phase 3.

## Phase 2 — where are you?

If the author's first words already say what they are writing (a novel, a
short story, an essay, a dissertation…), take the form from them; otherwise
ask the form first: `novel` · `short` (short fiction) · `nonfiction` (essays,
papers, a dissertation; one compendium shared by several works) ·
`screenplay` (a v1 stub that behaves as `novel`, with no screenplay
templates; say so if chosen).

Then one question — "Where are you with it?":

| | Fiction | Non-fiction |
|---|---|---|
| A | **Nothing yet** — I want to write, but have no idea | **A field or interest** — no topic yet |
| B | **A seed** — an image, a character, a what-if, a genre | **A topic** — roughly what I want to write about |
| C | **A clear idea** — I can say it in a sentence or two | **An assignment or a thesis** — I have the brief, or I know my argument |
| D | **Existing material** — notes, a partial or finished draft | **Existing material** — a draft, notes, a bibliography |

B and C: ask for the seed or idea in their own words, as plain text, and
keep it verbatim.

## Phase 3 — check against the disk

If the answer contradicts Phase 1, say what was found once and ask again:

- A, B or C with prose or `loose:` writing on disk: "I found 14 files in
  `manuscript/` (or `draft.docx`); did you mean D?"
- D with nothing on disk: "This looks fresh — would A, B or C fit better? Or
  tell me where your material is."

If no option fits, let the author describe their situation and route from it.

## Phase 4 — configure

A few questions at a time, each with options and a recommendation; anything
not decided yet gets the default shown.

1. **Title** of the project (for non-fiction, the umbrella: a degree, a
   module, a research area). A working title is fine.
2. **Prose language** as a BCP 47 tag (`en-GB`, `en-US`, `de-DE`, `de-AT`,
   `de-CH`, …): the region carries spelling. **Interface language**
   (`language.interface`): the language the studio talks in; default the
   prose language's primary subtag.
3. **Rigour** — how much the studio tracks and checks as you write, and which
   development steps `/next` recommends; never what must exist before you
   start (v1 §4.3). **Suggest it from the author's own words**, with the
   reason:

   | The author mentions | Suggest |
   |---|---|
   | short story, flash, competition, a first try, "just to see" | `minimal` |
   | novel, novella, an essay or paper with a deadline | `standard` |
   | series, epic, big world, many characters, dissertation, thesis | `full` |
   | nothing that fits | `standard` |

   One line each: `minimal` — brief, then write; checks on request.
   `standard` — protagonist, opposition and a story spine recommended; checks
   at "unit done". `full` — everything in standard, plus world, full cast,
   style guide, all chapter cards and the advisory gates.
4. **Prose level** — what Claude may put in prose files (`CLAUDE.md`, *The
   prose ladder*); one line each for the five. Recommend `critic` if the
   author is unsure: raising it later is one line in `studio.yaml`, and
   per-chapter or per-work overrides can loosen it where wanted.
5. **Ideas mode** (`modes.ideas`) — how much Claude contributes to creative
   choices (premise, characters, plot; for non-fiction, angles and
   questions), independent of the prose level:
   - `options` (Recommended) — 2–3 distinct alternatives at each decision;
     you choose, combine or ask for fresh ones.
   - `questions` — Claude asks and reflects; every idea is yours.
   - `proposals` — Claude may propose a complete answer (a whole cast, a
     spine) with the main alternative; you approve or change it.
6. **Fiction:** point of view, tense and register; each may be "decide
   later" (`null`), settled in `/brainstorm` or the style guide.
7. **Non-fiction:** field (free text); citation style (a CSL id, default
   `ieee`; others are fetched by `/publish` on first use); integrity cap
   (`integrity.assessed_cap`, default `coach`: the ceiling on Claude's prose
   level for an assessed work — never suggest raising it); register.

`modes.automation` stays `collaborative`; mention that `guided` exists and is
a one-line edit.

## Phase 5 — write

Each write is shown first and asked for (question tool: `Yes — write it` /
`Change something first`).

1. **`studio.yaml`** from `.claude/templates/shared/studio.yaml`: replace
   every `{{…}}`; fiction sets `project.stage: premise` and drops `field`,
   `citation_style` and the `integrity` block (or leaves them `null`);
   non-fiction drops `stage`, `pov` and `tense`. Keep the comments; keep
   hook-read lines flat (`key: value`). `language.options` stays `{}` unless
   the author sets one: list the pack's options
   (`.claude/languages/<subtag>/pack.yaml` → `options`) with their defaults
   in one line and ask if any should change.
2. **Folders and seed files** — list every path, ask once: "May I create
   these?" Create directories with `mkdir -p` and files with Write; skip
   anything that exists and say so.

   | Path | Form | From |
   |---|---|---|
   | `bible/characters/`, `bible/world/places/`, `bible/world/rules/`, `outline/chapters/`, `manuscript/`, `reviews/` | fiction | — |
   | `bible/registry.yaml` | fiction | `.claude/templates/fiction/registry.yaml` |
   | `session/active.md` | fiction | `.claude/templates/shared/checkpoint.md`: scope "the book"; current task "Project set up"; next step the Phase 7 hand-off |
   | `compendium/sources/`, `concepts/`, `positions/`, `notes/`, `inbox/`, `archive/`; `works/` | non-fiction | — |
   | `compendium/library.bib`, `compendium/claims.yaml` | non-fiction | `.claude/templates/nonfiction/` |
   | `compendium/archive.sha256` | non-fiction | empty (`/source` adds a line per archived file) |
   | `session/` | both | — |
   | `ideas/parked.md`, `ideas/questions.md` | both | `.claude/templates/shared/ideas-parked.md`, `ideas-questions.md` |

   Non-fiction: remind the author that `compendium/archive/` is gitignored
   (it may hold copyrighted PDFs) and backing it up is their call; there is
   no project checkpoint (each work gets one at `/new-work`).
3. **C, "jump straight in" only** (Phase 7): offer to save the idea, verbatim,
   to `ideas/<YYYY-MM-DD>-start.md` (template
   `.claude/templates/shared/ideas-session.md`: skill `/start`, starting point
   = their words labelled `(author)`, no options), so it is not lost.

## Phase 6 — jq and the language pack

**jq** — hooks need it (v1 §10.1). Run `bash .claude/scripts/install-tool.sh
check jq`.

- `status: usable` → say which copy (path, version).
- `status: missing` → the guards (prose level, source verification) **deny**
  writes until jq exists, and the observers (provenance log, session status)
  switch off. Ask: **"May I download jq 1.8.2 for `<platform>` from
  github.com/jqlang/jq into `.claude/bin/`? It is checked against the SHA-256
  committed in `.claude/tools.yaml` and deleted if it does not match."** On
  yes, run `bash .claude/scripts/install-tool.sh install jq` and report the
  result lines. On no: how to install it themselves (`winget install
  jqlang.jq`, `brew install jq`, their package manager); `/start` can be
  re-run for the check.
- Exit 3 (`no-official-build`) → the same manual instructions.
- `checksum mismatch` → nothing was installed; do not retry automatically;
  suggest checking the network (a proxy rewriting downloads).

**Language pack** for `language.default` (v1 §4.5): no folder
`.claude/languages/<subtag>/` → no grammar review yet, offer `/language add
<tag>`; folder but no overlay for the tag → offer `/language add <tag>` for
the region; `support: user-defined` → checks are less reliable.

Run `bash .claude/scripts/status.sh`: any `error:` line means something
`/start` wrote is wrong — fix it (with approval) before going on.

## Phase 7 — the path, then hand off

**The path card** — the author's route at the chosen rigour (development-flow
§3), first step marked, each later step in one line with its command. For
example, fiction at `standard`:

```
Your path (rigour: standard — recommended steps; everything else is optional)
 → 1. /brainstorm   find the premise and write the brief
   2. /cast         protagonist and opposition
   3. /plot         the story spine
   4. /draft        the write loop: /next names each scene, card first
   5. /review milestone, then revise until it approves
   6. /publish      optional: LaTeX or PDF
 /next tells you where you are at any point. Drafting can start whenever
 the brief exists.
```

`minimal`: brief → write loop → milestone review → publish. `full`: add the
writer's brief, supporting cast, `/world`, the style guide, all chapter cards
and the gates. Non-fiction: `/brainstorm` (A, B) → `/new-work` → reading
plan (`/ask`, `/source`) → `/outline` → write loop → `/review developmental`
→ mark complete and `/cite-check` → `/publish`.

**The first step:**

| Answer | First step |
|---|---|
| Fiction A | `/brainstorm open` |
| Fiction B | `/brainstorm <their words>` |
| Fiction C | ask: `Formalise it first` (Recommended; `/brainstorm <their idea>` goes straight to the brief) / `Jump straight in` (`/draft`; the brief can come later — offer the Phase 5 save) |
| Fiction D | `/import <path>` (the material found in Phase 1 or named by the author) |
| Non-fiction A | `/brainstorm open` |
| Non-fiction B | `/brainstorm <their topic>` |
| Non-fiction C | `/new-work` (an assignment or a thesis in hand) |
| Non-fiction D | `/import <path>` |

Rewrite the checkpoint's next step to match (fiction `session/active.md`).
Then exactly one line, and stop: "Type `<command>` to begin." Do not invoke
it, even after a yes: the author types it.

If the author stopped before the end, say what was written and what was not.
