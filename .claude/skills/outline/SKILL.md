---
name: outline
description: "Plan structure. Fiction - outline/structure.md (shape, acts, chapter list, promises and payoffs), then one chapter card per chapter with a ### block per scene. Non-fiction - works/<work>/outline.md, one ### block per section with its claim, claim ids and citekeys. Also updates an existing outline and records departures. Use when the author wants to plan or re-plan structure, or types /outline."
argument-hint: "[work] (non-fiction) | [chapter] (fiction)"
allowed-tools: Read, Glob, Grep, Agent, Bash(bash .claude/scripts/status.sh*)
---
# /outline (spec §8.1, §4.3, §11)

An outline is a planning document, not prose: Claude may write it at **any**
prose level, but every file is written only after **"May I write this to
`<path>`?"**. Follow `.claude/rules/outline.md` (block shape, `status:`
lines, departures) and the collaboration protocol in `CLAUDE.md`: question →
options → decision → draft → approval, skeleton first, then one approved
section at a time.

If `studio.yaml` does not exist, say the project is not set up and offer
`/start`. Nothing else.

**The outline is optional at `minimal` rigour and never a gate** (§4.3): the
only prerequisite for drafting is a brief. Say so if the author seems to think
they must finish an outline before writing.

**Who drafts:** you, in the main session, interactively. `structure-architect`
is called **once** for a critique when the skeleton is written, and again only
when the author asks (see *Critique*). Never ask the author to fill in a
template; propose from what they have said and written, and let them correct.

## Arguments

- Fiction: `/outline` works on the whole book; `/outline <chapter>` goes
  straight to that chapter's card (`ch03` or the full key `ch03-the-storm`;
  ask if a short form matches more than one).
- Non-fiction: `/outline <work>`; with no work, use `session/current-work`,
  else ask which work (list `works/*/`). An unknown slug: say so and list the
  works.
- Anything else: show the usage.

## Read first

- `studio.yaml` → form, rigour (`modes.rigour`: it sets doc density — terse
  bullets · bullets + rationale · rationale + alternatives), automation,
  interface language, `style`.
- The checkpoint (fiction `session/active.md`, non-fiction
  `works/<work>/checkpoint.md`) for where things stand.
- Everything the author has already written that the outline should follow:
  - **Fiction:** `bible/brief.md`, `bible/characters/`, `bible/timeline.md`,
    any existing `outline/` files, and the list of `manuscript/` units (an
    outline follows the draft, not the other way round).
  - **Non-fiction:** `works/<work>/brief.md` (assignment, marking criteria,
    research question in force and its version `vN`), `work.yaml`
    (`word_limit`, `word_count_excludes`, `kind`), `compendium/claims.yaml`,
    the source notes in `compendium/sources/` (status and *Quotations*),
    `compendium/positions/`, any existing `outline.md` and
    `works/<work>/sections/`.
- If there is no brief (fiction `bible/brief.md`, non-fiction
  `works/<work>/brief.md` with a research question), say that the brief is the
  one thing drafting needs and offer `/premise` (fiction) or `/new-work`
  (non-fiction) first. If the author wants to outline anyway, go on.

## Fiction

### 1. `outline/structure.md`

Template `.claude/templates/fiction/structure.md`.

1. **Shape.** Ask whether the author has a model in mind (three-act, Save the
   Cat, kishōtenketsu, a shape of their own, none). Offer two or three that
   fit the brief, with one line on what each would ask of this book, and a
   recommendation. "None" is a valid answer.
2. **Skeleton.** Propose the acts or movements (name, purpose, turning point)
   and the chapter list: one line per chapter with key, title, POV, purpose
   and `planned`. Show it whole. On approval, ask **"May I write this to
   `outline/structure.md`?"** and write the skeleton with the other sections
   as headings only.
3. **Critique** (below), once.
4. **Fill** *Promises and payoffs* and anything left empty, one section at a
   time, each shown and approved before it is written. *Departures from this
   outline* starts empty (delete the template's example line).

**Chapter keys** are `chNN-slug`: two digits, lower-case ASCII, hyphens
(`ch03-the-storm`). The key is the chapter's folder under `manuscript/`, its
card's file name and its `prose.overrides` key, so propose stable names. The
order of the chapter list is the order `/publish` uses.

### 2. Chapter cards — `outline/chapters/<chapter>.md`

Template `.claude/templates/fiction/chapter-card.md`. One chapter per round,
in order unless the author picks one:

1. Propose the chapter's purpose and its scenes: one `### scNN-slug` block per
   scene, `status: planned` as the block's **first line**, then POV (a
   character id from the bible or registry if one exists), where/when, goal,
   conflict, outcome (yes / no / yes-but / no-and), reveals/changes, notes.
   Facts the author has already settled come from the bible; new ones are
   marked as new ("registry candidate").
2. Show the whole card; on approval, **"May I write this to
   `outline/chapters/<chapter>.md`?"**
3. Ask whether to go on to the next chapter or stop. Cards can be written
   just ahead of the draft; the author does not need every card before
   drafting.

**Scene keys** are `scNN-slug`, unique within the chapter. `<chapter>/<scene>`
is the unit's override key and `manuscript/<chapter>/<scene>.md` its file.

## Non-fiction

### `works/<work>/outline.md`

Template `.claude/templates/nonfiction/outline.md`.

1. **Through-line.** Propose the argument in two or three sentences that
   answer the research question in force. If the brief's question does not
   yet admit a through-line, say so; suggesting a revision of the question is
   normal (`.claude/rules/works.md`), and the author decides.
2. **Skeleton.** Propose the sections in order: `### NN-slug` blocks with
   `status: planned` as the **first line**, then `question: vN` (the version
   in force now), the section's claim in one sentence, its role (introduce,
   define, argue, object, reply, conclude), and target words. The targets add
   up to the `word_limit` less a margin (say what you assumed, and which
   `word_count_excludes` apply). Show it whole; on approval, **"May I write
   this to `works/<work>/outline.md`?"**
3. **Critique** (below), once.
4. **Claims and sources**, one section at a time:
   - **Claims:** existing ids from `compendium/claims.yaml` that the section
     relies on. A needed claim that does not exist yet is listed as a
     *proposed* claim (statement, kind) in the conversation; writing it to
     `claims.yaml` is a separate approval, offered at `standard` and `full`
     rigour (at `minimal`, on request), and the new id goes in the block once
     written. Never reuse a retired id.
   - **Sources:** citekeys of source notes that exist in
     `compendium/sources/`. **Never name a source that has no note** — a gap
     is written as a gap in the conversation ("needs a source for the
     empirical claim; `/source` when you have one"), never as an invented
     citekey. Mark citekeys whose note is `status: unverified`; they may
     shape the plan but cannot be cited in prose until the author verifies
     them.
   - Show the section block, ask, write it, then the next.
5. *Departures from this outline* starts empty.

**Section keys** are `NN-slug` (two digits, lower-case ASCII, hyphens). The
`NN-` prefix gives `/publish` its order; `<work>/<section>` is the override
key and `works/<work>/sections/<section>.md` the file.

## Critique

When the skeleton has been written, launch `structure-architect` once with the
Agent tool. Pass paths, not content:

> Critique the structure in `<path>` (fiction: also read `bible/brief.md`;
> non-fiction: `works/<work>/brief.md` and `work.yaml`). Report the three to
> five findings that matter most, ranked, with locations. Do not write files.

Present its findings briefly, with your view of each. The author decides
what, if anything, changes; changes go through the same show → ask → write
cycle. Run it again only when the author asks.

## Updating an existing outline

When the file already exists, never start over. Read it, then:

- Show what you propose to change as a short list (added, moved, renamed,
  removed blocks), then the changed parts; ask, then write.
- **Never move a `status:` backwards** (`drafted` → `planned`) without saying
  so and asking.
- **Renaming or removing a key that has a prose file** (`manuscript/<chapter>/
  <scene>.md`, `works/<work>/sections/<section>.md`) or a `prose.overrides`
  entry: say what it breaks. The file must be renamed to match (at `critic` or
  `coach` the prose guard denies Claude's moves of prose files: the author
  moves it) and the override key in `studio.yaml` updated, with approval.
  `/status` reports an override key that matches nothing as an error.
- **Departures** — when the change follows what was drafted rather than a new
  plan: at `standard`, offer the outline update; at `full`, also an entry
  under *Departures from this outline*: `- <date> — <unit>: <what changed and
  why>`.
- Fiction: keep the chapter list in `structure.md` and the cards in step
  (keys, titles, order).

## After each write

Rewrite the checkpoint (no "May I write?" needed): fiction
`session/active.md`, non-fiction `works/<work>/checkpoint.md` — current task,
next step, open questions; at most 25 lines; template
`.claude/templates/shared/checkpoint.md`.

When the outline is done for now, name **one** next step: usually
`/draft <first planned unit>`.
