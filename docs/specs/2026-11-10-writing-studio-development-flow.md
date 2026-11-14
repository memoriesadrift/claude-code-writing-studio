# Writing Studio — Development Flow

**Status:** Draft for review · **Date:** 2026-11-10
**Amends:** `2026-11-07-writing-studio-v1-design.md` (r10), cited here as
"v1 §n". Where this document and v1 disagree, this document wins; the two
will be folded into one document later.
**Inspiration:** CCGS `/start`, `/brainstorm`, `/help`, `/project-stage-detect`,
`/adopt`, `/reverse-document` and its director gates — patterns borrowed, no
files forked.

**Revisions**
- d1 — initial draft.

---

## 1. Purpose

v1 is good at recording, structuring and checking a piece of writing, and weak
at developing one. An author who arrives with nothing, a seed or a clear idea
gets a configured project and a brief interview; nothing helps them find the
story or the argument, nothing says what to develop next, and ideas that do
not fit a template are lost between sessions.

This amendment adds a **directed flow**: it meets the author where they are,
helps them develop the work, hands each step to them, and repeats the write
loop until the work is finished. It applies to fiction and non-fiction.

```
Orient → Discover → Develop → Plan → Write loop → Revise → Finish
            ↑                         (prepare unit → author writes, or
            └── /next at every point   Claude drafts → unit done → next)
```

## 2. Principles

In addition to v1 §2:

1. **Meet the author where they are.** Nothing, a seed, a clear idea or
   existing material are all valid starts; the studio reads the disk and
   checks what the author says against it.
2. **The author holds creative direction.** Every creative choice (which
   premise, which ending, who the antagonist is) is asked, in every
   automation mode. How much Claude contributes to that choice is the
   author's setting (`modes.ideas`, §5), independent of the prose level.
3. **Facilitate with options.** At each creative decision Claude offers
   distinct alternatives built with named techniques, and the author picks,
   combines, rejects or asks for fresh ones.
4. **Hand off; never auto-run.** A skill ends by naming the one next step and
   the command for it — "Type `/cast` to begin." — and never invokes it. The
   author running each step themselves builds their command of the studio,
   their confidence in the process and their autonomy.
5. **One next step.** `/next` names exactly one primary step, plus optional
   steps available now and what comes after.
6. **Advisory, never front-loaded.** v1 §4.3 stands: the only thing drafting
   needs is a brief. The flow *recommends* development steps at a rigour; it
   never requires them. "I want to write now" is always a valid answer, and
   `/next` honours it.
7. **Nothing lives only in the conversation.** Brainstorm sessions, unchosen
   options, parked ideas and open questions are written to the ideas store
   (§9), with approval.
8. **A skipped step says so.** A gate or phase that does not run prints a
   line naming it and why (CCGS skill-authoring obligation 3).

## 3. The flow at a glance

### 3.1 Fiction

| Phase | Steps (skill) | `minimal` | `standard` | `full` |
|---|---|---|---|---|
| `premise` | writer's brief (`/brainstorm`) | — | optional | recommended |
| | brief (`/brainstorm`, or `/premise` to revise) | recommended | recommended | recommended + premise gate |
| `develop` | protagonist and opposition (`/cast`) | optional | recommended | recommended |
| | supporting cast (`/cast`) | optional | optional | recommended + cast gate |
| | world (`/world`) | optional | optional | recommended |
| | style guide (`/bible style`) | optional | optional | recommended |
| `plan` | story spine (`/plot`) | optional | recommended | recommended + spine gate |
| | chapter list and cards (`/outline`) | optional | cards just in time (§7.3) | all cards before drafting |
| `draft` | write loop (`/draft`, §8.4) | recommended | recommended | recommended |
| `revision` | milestone review until it approves (`/review milestone`) | recommended | recommended | recommended |
| `finish` | publish (`/publish`) | optional | optional | optional |

"Recommended" means `/next` names it as the next step when it is the first
incomplete one. "Optional" steps are listed as available, never as next.
Nothing is ever required: `/next` always offers drafting as an alternative
once a brief exists.

### 3.2 Non-fiction

Project level (before or between works): `/brainstorm` explores a field or
topic and proposes candidate research questions (§6.2).

| Phase (per work) | Steps (skill) | `minimal` | `standard` | `full` |
|---|---|---|---|---|
| `brief` | assignment, criteria, research question v1 (`/new-work`) | recommended | recommended | recommended + question gate |
| `research` | reading plan: the sources the question needs (`/ask`, `/source`) | optional | recommended | recommended |
| `plan` | argument outline (`/outline <work>`) | optional | recommended | recommended + argument gate |
| `draft` | write loop (`/draft`, §8.4) | recommended | recommended | recommended |
| `revision` | developmental review of the whole work approves | recommended | recommended | recommended |
| `complete` | marked complete; citation check runs (v1 §4.3) | recommended | recommended | recommended |
| `finish` | publish (`/publish <work>`) | optional | optional | optional |

## 4. Orientation — `/start` (replaces v1 §8.1's `/start` flow)

`/start` becomes orientation first, configuration second. It keeps every
configuration question v1 asks; what changes is the order, the first
question, and the ending.

**Phase 0 — returning author.** If `studio.yaml` exists, ask nothing: say
form, prose level, ideas mode and where the work stands (from
`flow-check.sh`, §8.2), and hand off to `/next`.

**Phase 1 — read the disk.** Run `flow-check.sh` (it works without
`studio.yaml`, reporting what exists: manuscript files, bible, outline,
works, compendium, ideas, loose Markdown or `.docx` files at the root). Do
not show it yet.

**Phase 2 — where are you?** One question, in the author's language:

| | Fiction | Non-fiction |
|---|---|---|
| A | **Nothing yet** — I want to write, but have no idea | **A field or interest** — no topic yet |
| B | **A seed** — an image, a character, a what-if, a genre | **A topic** — I know roughly what I want to write about |
| C | **A clear idea** — I can say it in a sentence or two | **An assignment or a thesis** — I have the brief, or I know my argument |
| D | **Existing material** — notes, a partial draft, a finished draft | **Existing material** — a draft, notes, a bibliography |

The form question (novel, short, non-fiction) is asked first only when the
author's opening words do not settle it.

**Phase 3 — check against the disk.** If the answer contradicts Phase 1,
say what was found once and ask again ("I found 14 files in `manuscript/`;
did you mean D?"; D on an empty folder: "this looks fresh — A or B?").

**Phase 4 — configure.** v1's questions (title, languages, prose level,
non-fiction field, citation style, integrity cap), plus:

- **Rigour, suggested from the author's words** and shown with the reason;
  the author confirms or changes it:

  | The author mentions | Suggest |
  |---|---|
  | short story, flash, competition, a first try, "just to see" | `minimal` |
  | novel, novella, an essay or paper with a deadline | `standard` |
  | series, epic, big world, many characters, dissertation, thesis | `full` |
  | nothing that fits | `standard` (v1 default) |

- **Ideas mode** (`modes.ideas`, §5), one line each, default `options`.

Then the writes v1 already makes (`studio.yaml`, folders, jq), each with
approval, plus the ideas store (§9).

**Phase 5 — the path card.** Show the path at the chosen rigour (§3), with
the first step marked, and what each later step is for in one line.

**Phase 6 — hand off.** Exactly one line: "Type `<skill>` to begin."

| Answer | First step |
|---|---|
| Fiction A | `/brainstorm open` |
| Fiction B | `/brainstorm <their words>` |
| Fiction C | ask: formalise it (`/brainstorm <idea>`, which goes straight to the brief) or jump in (`/draft`, brief later) |
| Fiction D | `/import <path>` (§10) |
| Non-fiction A | `/brainstorm open` |
| Non-fiction B | `/brainstorm <topic>` |
| Non-fiction C | `/new-work` |
| Non-fiction D | `/import <path>` |

## 5. Ideas mode — `modes.ideas`

How much Claude contributes to **creative and intellectual choices** (story
content, characters, plot, world; for non-fiction, angles, questions,
arguments). Independent of the prose level, which governs only the text of
prose files.

| Value | What Claude does at a creative decision |
|---|---|
| `questions` | Asks questions and reflects the author's answers back; names techniques; never proposes content (no premises, characters or plot turns of its own) |
| `options` (default) | Offers 2–3 distinct alternatives, each built with a named technique; never a single decided answer |
| `proposals` | May propose a complete answer (a whole cast, a full spine), with the main alternative noted; the author approves, edits or rejects |

At every value: the author decides; nothing becomes canon or outline without
approval; Claude never presents its own idea as the author's. Facts already
in the author's files are never "ideas" — extracting and recording them is
v1 behaviour and unaffected.

`studio.yaml`:

```yaml
modes:
  rigour: standard
  automation: collaborative
  ideas: options          # questions | options | proposals
```

## 6. Discover — `/brainstorm [hint | open]`

Turns nothing, or a seed, into a brief. Depth follows rigour; contribution
follows `modes.ideas`. Each phase is shown and confirmed before the next;
nothing is generated silently.

### 6.1 Fiction

**`minimal` (lean):** one creative question — 2 or 3 one-line premises from
the hint (at `questions`: questions that draw one out) — then the brief's
fields in a few exchanges, then "May I write this to `bible/brief.md`?".

**`standard` and `full`:**

1. **Discovery — the writer, not the book.** Conversationally: stories that
   moved them and what did it; the book they wish existed; what they want a
   reader to feel at the end; genres they love or avoid; the scale they have
   in mind (a story, a novel, a series) and the time they have. At `full`,
   also their habits: planner or discoverer, what has stalled them before.
   Summarise as a **writer's brief** (3–5 sentences), read it back, confirm,
   and offer to save it (`ideas/writer.md`). The beta-reader's default persona
   may draw on it.
2. **Premises.** Three distinct premises, each from a different technique:
   - *What-if* — an ordinary world plus one change;
   - *Character-first* — a person with a want, a wound and a need, and the
     situation that tests them;
   - *Situation-first* — the inciting collision;
   - *Mashup* — genre × setting or theme, where the tension is the hook;
   - *Theme-first* — a question the story argues with itself.

   Each as a card: working title · logline · protagonist and want · central
   conflict · hook ("like X, but Y") · comparable titles (only ones Claude is
   sure exist) · the emotional promise · why it could work · biggest risk.
   Ask: pick one · combine · fresh directions. Asked in every automation
   mode. The unchosen cards go to the session file (§9).
3. **Deepen.** For the chosen premise: the central dramatic question; theme
   (as a question, not a moral); stakes, personal and wider; ending intent
   (provisional is fine); point of view and tense if still open.
4. **Write.** The brief (`bible/brief.md`, v1 template), skeleton first then
   section by section, each after "May I write?". The session file goes to
   `ideas/` on approval.
5. **Premise gate** (`full`; §11).
6. **Hand off.** Path card from here; "Type `/cast` to begin." (or the next
   recommended step).

A brief that already exists: read it and offer to revisit it (`/premise`) or
to explore alternatives without replacing it (new session file only).

### 6.2 Non-fiction

1. **Discovery.** The author's interest and what sparked it; the assignment
   and its criteria if there is one (verbatim, as v1); the scale (essay,
   paper, dissertation); what they already know and have read.
2. **Angles.** Three candidate research questions, each from a technique:
   *puzzle-first* (something that should not be so), *debate-first* (a live
   disagreement in the compendium or the field), *case-first* (a case that
   tests a general claim), *method-first* (a way of looking that has not been
   applied here), *so-what-first* (a consequence nobody has drawn). Each as a
   card: question · thesis hunch · why it matters · sources it needs (named
   only from the compendium; otherwise "to find") · fit to the criteria ·
   biggest risk (scope, evidence). Pick · combine · fresh directions.
3. **Hand over** to `/new-work` with the chosen question as v1, or, for an
   existing work, propose it as the next version in `brief.md` (v1 rules for
   versioned questions). Reading leads are offered to `/source` one by one;
   none is ever cited until it is a verified source note (v1 §6.3).

**Assessed work:** show the work's `policy` before any brainstorming on it;
see §14, question 1, on capping `modes.ideas`.

## 7. Develop and Plan (fiction)

All three skills write only into v1 formats (bible entries, registry,
`outline/structure.md`), so everything downstream — continuity checks,
`/draft` inputs, reviews — works unchanged. They follow `modes.ideas` at every
creative decision and v1's "May I write?" for every file.

### 7.1 `/cast [name | all]`

1. **Protagonist depth:** want, need, wound (ghost), the lie they believe,
   the arc from lie to truth (or a deliberate flat arc), and what they would
   never do.
2. **Opposition:** who or what stands in the way, and why they are right
   from where they stand.
3. **Supporting cast by function:** ally, mentor, foil, love interest,
   catalyst, mirror — proposed only where the premise needs them.
4. **Relationships:** what each relationship wants from the protagonist, and
   how it changes.

Each character becomes a v1 character entry (`/bible`'s format and canon
rules) with registry lines; voice profiles stay empty until the author has
written the character (v1). Cast gate at `full` (§11).

### 7.2 `/world [place | rule | name]`

Setting as pressure on the characters: the places the story needs (and the
distances between them), the rules of the world (stated so a scene can be
tested against them, with limits and costs), the social order, and what the
world takes from the protagonist. For realist fiction this is light: the
places that matter and any facts the story depends on. Writes v1 place and
world-rule entries and registry lines.

### 7.3 `/plot`

1. **Shape:** a structure model (three-act, Save the Cat, kishōtenketsu,
   the author's own, none), offered per `modes.ideas`.
2. **Spine:** the central dramatic question and the beats — opening image,
   inciting incident, first turning point, midpoint, crisis, climax,
   resolution — each in one or two sentences, tested against the brief's
   stakes and ending intent.
3. **Promises and payoffs:** what the spine sets up that it must pay off.

Writes `outline/structure.md`: *Shape*, a new *Spine* section (template
change), *Acts / movements* and *Promises and payoffs*. `/outline` keeps the
*Chapter list* and the chapter cards (v1), and turns the spine into chapters.
Spine gate at `full` (§11).

**Cards just in time** (`standard`): `/next` recommends `/outline <chapter>`
for the next chapter when it has no card, rather than all cards up front.
At `full`, every card before drafting. At `minimal`, cards are optional.

## 8. The conductor — `/next [what I just did]`

Read-only. Tells the author where they are and the one next step, then hands
off. Separate from `/status` (v1), which stays the detailed report.

### 8.1 Catalogue — `workflow.yaml` schema 2

`workflow.yaml` becomes a step catalogue (CCGS `workflow-catalog.yaml`): per
form, phases → steps. Each step has `id`, `name`, `skill`, `recommended` per
rigour (`minimal | standard | full`, each `true | false`), an `artifact` (v1's
`glob` / `pattern` / `require`, plus `any_of` alternatives), `repeatable`, and
an optional `note` when completion cannot be detected. Phase completion
artefacts from v1 §11 stay (the `draft` and `revision` checks are unchanged).

### 8.2 Helper — `.claude/scripts/flow-check.sh [work]`

Evaluates every step's artefact against the working tree and prints one line
per step: `PRESENT`, `ABSENT`, `PATTERN_MISS` or `NO_CHECK` (CCGS
`artifact-check.sh`). For the draft phase it also prints the next unit in
publish order (first `planned` or `drafting` block), whether its chapter has
a card, and drafted/total counts. Facts only; `/next` and `/start` judge.

### 8.3 What `/next` says

1. **In progress** — from the checkpoint, if any.
2. **Done** — completed steps of the current phase.
3. **Next (one)** — the first incomplete recommended step at this rigour;
   in the draft phase, the write loop (§8.4).
4. **Also available** — optional steps now, at most three.
5. **Coming up** — the next one or two recommended steps.
6. **Hand-off** — "Type `<command>` to begin."

If the author says they want to write now, the next step is the write loop,
whatever is incomplete. A step without a detectable artefact (`NO_CHECK`) is
asked about, never assumed done.

### 8.4 The write loop

`/next` in the draft phase names the next unit and what to do at its prose
level (resolved per v1 §5.1, with any integrity cap):

| Level | `/next` hands off |
|---|---|
| `critic`, `coach` | "Next: `ch02-storm/sc03-wreck`. Type `/draft ch02-storm/sc03-wreck` for your brief; write it; then `/draft ch02-storm/sc03-wreck done`." |
| `editor` | as above, then "`/draft … ` again for line edits when you have a draft" |
| `co-author` | "Type `/draft ch02-storm/sc03-wreck` to draft it together." |
| `ghostwriter` | "Type `/draft ch02-storm` to draft the chapter unit by unit." |

Before the unit: if its chapter has no card at `standard`/`full`, the next
step is `/outline <chapter>` instead. After the unit, "unit done" (v1 §8.3)
runs as before. When every unit is drafted, the next step is the revision
phase.

### 8.5 Revision and finish

The revision loop: `/review milestone` (fiction) or `/review developmental
<work>` (non-fiction) → the author revises (or `/draft` at `editor` and
above) → review again, until it approves or the author decides it is done.
Then `/publish` (optional) and, for non-fiction, marking the work complete
(citation check, v1 §4.3). `/next` then says the work is finished, and for
non-fiction offers `/brainstorm` or `/new-work` for the next one.

## 9. The ideas store — `ideas/`

Not canon, not prose, not outline. Claude may write it at any prose level,
after "May I write?".

```
ideas/
  writer.md                  # the writer's brief (§6.1)
  <YYYY-MM-DD>-<slug>.md     # one per brainstorm session: options offered,
                             # what was chosen and why, what was not
  parked.md                  # ideas set aside for later, one line each, dated
  questions.md               # open questions, ticked off when answered
```

Templates: `fiction/` and `nonfiction/` share `shared/ideas-session.md`,
`shared/writer.md`. Rule: `.claude/rules/ideas.md` — record the author's
choice and Claude's options separately and label who proposed what; never
promote an idea to the bible, outline or compendium without the usual
approval. `/next` mentions open questions that block the next step.

## 10. Existing material — `/import <path>`

For answer D. Read-only first: list what was found and propose a plan; then
each step on approval.

1. **Notes** (Markdown, text) → `ideas/` (fiction) or `compendium/inbox/`
   (non-fiction), copied verbatim.
2. **A draft** → prose files. `.claude/scripts/import-draft.sh` copies the
   author's text **verbatim** into `manuscript/<chapter>/<unit>.md` or
   `works/<work>/sections/<nn-slug>.md`, splitting at the boundaries Claude
   proposed and the author approved (headings or line numbers), adding only
   the frontmatter `prose: author`, `locked: false`. It never overwrites a
   file, never changes a character of the text (it checks the concatenated
   output against the source and deletes its output on a mismatch), and
   appends one provenance line per file with `tool: import`. The prose guard
   allows exactly this script at every level (§12); everything else about
   the guard is unchanged.
   `.docx` and other formats: the author converts them to Markdown first
   (`/import` says how, e.g. with Pandoc, which `/publish` already installs);
   v1 has no DOCX input.
3. **Extract** (CCGS `/reverse-document`): from the imported draft, Claude
   proposes the brief, bible entries, registry lines and the outline (cards
   with `status: drafted`), each marked `canon: provisional` and with a
   provenance line `Extracted from <path> on <date>`; non-fiction: the
   outline and claims (citations still need source notes, v1 §6). Each file
   after approval.
4. **Hand off** to `/next`: usually the revision phase for a finished draft,
   or the write loop for a partial one.

## 11. Gates (`full` rigour; advisory)

Review passes in v1 shape (trigger, context, prompt, verdicts), run by the
named agent in its own context, under `.claude/reviews/gates/`:

| Gate | Agent | Checks |
|---|---|---|
| `premise` | `developmental-editor` | the brief promises a story: a want that meets resistance, stakes, a dramatic question the ending can answer |
| `cast` | `character-lead` | arcs consistent with the brief; opposition with its own logic; no character without a function |
| `spine` | `structure-architect` | beats cause each other; the climax answers the dramatic question; promises have payoffs |
| `question` (non-fiction) | `developmental-editor` | answerable, arguable, in scope for the limit, fits the criteria |
| `argument` (non-fiction) | `structure-architect` | each section advances the thesis; the strongest objection is met |

Verdicts: `APPROVE`, `CONCERNS [n]`, `REJECT [n]`, and **`NOT ASSESSED`**
(a needed input is missing — named, never read as a pass). Advisory: the
author can go on regardless. At `standard` a gate is offered, not run; at
`minimal` the skill prints `<gate> gate skipped — minimal rigour`.

## 12. Changes to v1 components

| Component | Change |
|---|---|
| `/start` | orientation flow (§4); `modes.ideas`; ideas store; ends with a hand-off, not a next-step suggestion |
| `/premise` | revises the brief; first-time briefs are written by `/brainstorm` (`/premise` still works on its own) |
| `/outline` | owns the chapter list and cards; reads the *Spine* from `/plot`; still writes a minimal `structure.md` if `/plot` was skipped |
| `/bible character` | launches `character-lead` for proposals and arc critique (v1 omission) |
| `/new-work` | accepts a research question handed over by `/brainstorm` |
| `/status` | "Next step" line comes from the catalogue (same logic as `/next`) |
| every skill's ending | names one next step as "Type `<command>` to begin."; never invokes it |
| `workflow.yaml` | schema 2 (§8.1); fiction phases `premise → develop → plan → draft → revision → finish`; `project.stage` takes these values (`premise`, `draft`, `revision` keep their meaning) |
| `status.sh` | reads schema 2 for its `## phases` block |
| `session-start` hook | its one-line status adds the next step from `flow-check.sh` |
| `prose-guard` hook | allows `bash .claude/scripts/import-draft.sh …` (exact script path, no other command in the line) |
| templates | `structure.md` gains *Spine*; new `shared/ideas-session.md`, `shared/writer.md`; `ideas/parked.md`, `ideas/questions.md` seeds |
| rules | new `ideas.md` (paths `ideas/**`) |
| `CLAUDE.md` | the flow in three lines; "First session? Type `/start`."; `modes.ideas` |
| reserved words | `open` (for `/brainstorm open`) added to `/new-work`'s list |

## 13. Out of scope

- Series and multi-book planning (v1 §12 stands).
- DOCX import (convert first, §10).
- Automatic chaining of skills (Principle 4).
- Screenplay development (still a stub).
- A creative "director" hierarchy as in CCGS; the three existing agents
  review, the main session facilitates.

## 14. Open questions

1. **Ideas mode on assessed work.** Should an assessed work cap
   `modes.ideas` (e.g. `assessed_ideas_cap`, default `questions`), as the
   integrity cap does for prose, or is showing the policy enough?
2. **Writer's brief and the beta-reader.** Should `ideas/writer.md` feed the
   default beta persona (§6.1), or stay private to brainstorming?
3. **Short fiction.** Should `form: short` collapse `develop` and `plan`
   into one optional step (`/plot` with a single-scene spine), or keep the
   novel path with everything optional?

## 15. Build order (proposed)

Each task: propose → build → review → commit, as for v1.

1. Catalogue schema 2, `flow-check.sh`, `/next`; `status.sh` and `/status`
   read schema 2.
2. `/start` orientation, `modes.ideas`, ideas store (templates, rule).
3. `/brainstorm` (fiction and non-fiction) and the premise and question
   gates.
4. `/cast`, `/world`, `/plot`, the `structure.md` *Spine*, the cast, spine
   and argument gates; `/bible character` and `/outline` changes.
5. `/import`, `import-draft.sh`, the prose-guard allowance.
6. Hand-off endings across existing skills; `CLAUDE.md`.
7. Then v1's pending steps: hook wiring (with the `session-start` change) and
   the end-to-end check.
