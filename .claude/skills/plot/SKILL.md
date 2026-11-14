---
name: plot
description: "Fiction - build the story spine in outline/structure.md - a shape (three-act, Save the Cat, kishōtenketsu, the author's own, none), the dramatic question, the seven core beats (opening image, inciting incident, first turning point, midpoint, crisis, climax, resolution) plus a chosen model's own beats, the acts, and promises and payoffs. Each beat tested against the brief's stakes and ending intent; per modes.ideas. /outline then turns the spine into chapters. Use when the author wants to plan or rethink the plot, or types /plot."
allowed-tools: Read, Glob, Grep, Agent, AskUserQuestion, Bash(bash .claude/scripts/status.sh*), Bash(bash .claude/scripts/flow-check.sh*), Bash(bash .claude/scripts/flow-mark.sh *)
---
# /plot (development-flow §7.3, §11)

The `plan` phase's `spine` step. `/plot` owns these sections of
`outline/structure.md`: *Shape*, *Spine*, *Acts / movements* and *Promises
and payoffs*. `/outline` owns the *Chapter list* and the chapter cards, and
turns the spine into chapters. The outline is a planning document, not
prose: Claude may write it at any prose level, after **"May I write this to
`outline/structure.md`?"**. `.claude/rules/outline.md` applies.

If `studio.yaml` does not exist, say the project is not set up and offer
`/start`. On a non-fiction project, say the equivalent is the argument
outline and point to `/outline <work>`. Nothing else.

## Who does what

You facilitate and generate in the main session, per `modes.ideas`;
`structure-architect` critiques the spine once, when it is written
(*Critique*); the author decides every creative choice, in every
`modes.automation` setting.

## Settings

Read `studio.yaml`:

- **`modes.ideas`**:

  | `ideas` | At a creative decision |
  |---|---|
  | `questions` | Open questions that draw the beat out of the author; **no turns, reversals or endings of your own** |
  | `options` (default, also when unset) | Two or three distinct alternatives, each with what it commits the story to, and a recommendation |
  | `proposals` | One complete proposal and the main alternative in a line |

  Label your contributions `(Claude)`.
- **`modes.rigour`** sets doc density (terse bullets · bullets + rationale ·
  rationale + alternatives) and the gate (§ *Finish*).
- **`project.form`** (`short`): the step is optional for short fiction; say
  so once, and offer the core beats only.
- Talk in the interface language; the structure doc is written in the prose
  language.

Ask fixed choices with the question tool; free answers in plain text. A
dismissed question is not an answer: ask again in plain text.

## Start

Read `bible/brief.md` (logline, want and need, stakes, ending intent),
`bible/characters/*.md` (the protagonist's and the opposition's arcs),
`bible/world/rules/*.md`, `outline/structure.md` if it exists, the chapter
cards and the list of `manuscript/` units (a spine follows what is already
drafted, not the reverse), `ideas/writer.md` and earlier `/plot` session
files.

- **No brief:** the spine is tested against the brief's stakes and ending
  intent. Say so and suggest `/brainstorm`; if the author wants to go on, go
  on from what they tell you.
- **`structure.md` exists:** this is a revision. Show the *Shape* and the
  *Spine* in one line per beat, ask what to revisit, and work only on that.
  **The *Chapter list* and *Departures* are never touched** by `/plot`; if a
  spine change affects listed or drafted chapters, name them and suggest
  `/outline` afterwards.
- **Drafted material exists:** propose beats from what is on the page first,
  citing the units.

## 1. Shape

A structure model — three-act, Save the Cat, kishōtenketsu, a shape of the
author's own, or none — per `modes.ideas`, with one line on what each would
ask of this book. "None" is a valid answer: the seven core beats still apply.

## 2. The dramatic question

The yes/no question the inciting incident raises and the climax answers,
from the brief's want and stakes. Show it against the ending intent: if the
ending intent does not answer it, say so and ask which moves.

## 3. The spine

The seven core beats, each in one or two sentences, in three rounds:

1. **Opening image** and **inciting incident**.
2. **First turning point** and **midpoint**.
3. **Crisis**, **climax** and **resolution**.

Each round: per `modes.ideas`, tested against the brief's stakes and ending
intent and the protagonist's arc (the crisis tests the need; the climax
answers the dramatic question through the protagonist's choice). Name a
tension when you see one; the author decides.

**A named model's beats** (Save the Cat's fifteen, kishōtenketsu's four
parts) are added under the core ones as *Model beats*, after the three
rounds, in one round: most map onto core beats already settled; the rest
are proposed. A shape of the author's own takes their beats as they name
them.

## 4. Acts / movements

From the spine and the model: each act or movement with its purpose and the
turning point that ends it. *Chapters:* is left `to decide in /outline`.

## 5. Promises and payoffs

What the spine sets up that it must pay off — a rule, a secret, a skill, a
relationship, the dramatic question itself — each with where it is set up
and where it pays off (a beat now; a unit once `/outline` and the draft
place it), or `open`. Secrets recorded in the bible are candidates.

## Writing

- **No `structure.md`:** after §1–§2, write the skeleton from
  `.claude/templates/fiction/structure.md` — *Shape* and the dramatic
  question filled, the other *Spine* lines `<!-- to decide -->`, *Acts /
  movements* and *Promises and payoffs* headings only, the *Chapter list*
  heading with an empty table (the header rows only), *Departures* empty —
  `canon: provisional`, `updated:` today. Show it; "May I write this to
  `outline/structure.md`?".
- **Then one section per approval**, in order: the spine after each round,
  the model beats, the acts, the promises. Update `updated:`. Every other
  section stays byte for byte.

## Critique

When the core beats are written, launch `structure-architect` once with the
Agent tool:

> Critique the *Spine* in `outline/structure.md` against `bible/brief.md`
> and the protagonist's and opposition's entries in `bible/characters/`.
> Report the three to five findings that matter most, ranked, with the beat
> each concerns. Do not write files.

Present its findings with your view of each. The author decides what, if
anything, changes; changes go through the same show → ask → write cycle.
Run it again only when the author asks.

## The session file

Each run records itself in `ideas/<YYYY-MM-DD>-plot.md` (template
`.claude/templates/shared/ideas-session.md`, `skill: /plot`; add `-2` if it
exists). **After each of §1–§5**, show what it adds — the options as
offered, labelled `(Claude)`; the author's choice in their words; what was
not chosen; open questions — and ask "May I write this to `ideas/<file>`?".
If the author declines, say that part lives only in this conversation. At
the end, offer to copy open questions to `ideas/questions.md` and turns
worth keeping to `ideas/parked.md`.

## Finish

- **Done?** Ask **"Is the spine done for now?"** On yes, run `bash
  .claude/scripts/flow-mark.sh spine done` and say so; coming back later is
  always possible.
- **Spine gate** (development-flow §11), after the spine was marked done
  this run: at `full`, run it as `/review gate spine` does
  (`.claude/skills/review/SKILL.md`, *Gates*) and show the verdict; at
  `standard`, offer it ("Type `/review gate spine` any time"); at `minimal`,
  print `Spine gate skipped — minimal rigour.`
- Rewrite the checkpoint `session/active.md` (no "May I write?" needed).
- Run `bash .claude/scripts/flow-check.sh` and name **one** next step
  (usually `/outline` for the chapter list and cards at `full`, `/outline`
  or `/draft` at `standard`). End with exactly one line, "Type `<command>`
  to begin.", and never invoke it.
