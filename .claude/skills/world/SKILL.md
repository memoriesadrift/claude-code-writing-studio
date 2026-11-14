---
name: world
description: "Fiction - develop the setting as pressure on the characters - first how much world the story needs; then the places it needs and the distances between them, world rules stated so a scene can be tested against them (with limits and costs), the social order, and what the world takes from the protagonist. Light for realist fiction - the places that matter and the facts the story depends on. Writes place and world-rule entries and registry lines, per modes.ideas. Use when the author wants to build or rethink the setting, or types /world."
argument-hint: "[place | rule | <name>]"
allowed-tools: Read, Glob, Grep, AskUserQuestion, Bash(bash .claude/scripts/status.sh*), Bash(bash .claude/scripts/flow-check.sh*), Bash(bash .claude/scripts/flow-mark.sh *)
---
# /world [place | rule | name] (development-flow §7.2)

The `develop` phase's `world` step. Setting is pressure on the characters,
not scenery: every place, rule and institution here is in the bible because
a scene will lean on it. Everything is written in v1 formats — place entries
(`.claude/templates/fiction/place.md`), world-rule entries
(`world-rule.md`) and `bible/registry.yaml` lines. `.claude/rules/bible.md`
applies, and every file is written only after **"May I write this to
`<path>`?"**.

If `studio.yaml` does not exist, say the project is not set up and offer
`/start`. On a non-fiction project, say the setting is fiction's and point to
`/compendium`. Nothing else.

## Settings

Read `studio.yaml`:

- **`modes.ideas`** sets what you contribute at each creative decision:

  | `ideas` | At a creative decision |
  |---|---|
  | `questions` | Open questions that draw the answer out of the author; **no places, rules or institutions of your own** |
  | `options` (default, also when unset) | Two or three distinct alternatives, each with what it would make possible or impossible in a scene, and a recommendation |
  | `proposals` | One complete proposal and the main alternative in a line |

  Label your contributions `(Claude)`. Choosing is the author's in every
  `modes.automation` setting.
- **`modes.rigour`** sets doc density (terse bullets · bullets + rationale ·
  rationale + alternatives); the *depth* is the author's answer in §1.
- **`project.form`** (`short`): the step is optional for short fiction; say
  so once.
- Talk in the interface language; entries are written in the prose language.

Ask fixed choices with the question tool; free answers in plain text. A
dismissed question is not an answer: ask again in plain text.

## Start

Read `bible/brief.md`, `bible/characters/*.md`, `bible/world/**`,
`bible/registry.yaml`, `outline/structure.md` if it exists, `ideas/writer.md`
and earlier `/world` session files. Grep the manuscript for the place and
rule names the registry knows, and note the places the text uses that have no
entry: their facts come from the page.

- **Arguments:** none → §1, then the parts not yet done; `place` or `rule` →
  straight to §2 or §3; `<name>` → that place or rule (an existing entry is
  extended — ask which sections; work only on those).
- **Existing entries are never started over**; `established` facts follow
  `/bible`'s canon rules (`.claude/skills/bible/SKILL.md` §4).

## 1. How much world

Ask first, with a suggestion from the brief, the comparable titles and the
genre:

- **Light** (realist fiction): the places that matter and the facts the
  story depends on (a period, an institution, a trade, a journey's length).
  §2 and §4 only, briefly.
- **Full** (speculative fiction, or a realist world the story turns on):
  §2–§5.
- **In between:** the author names what the story needs.

Their answer sets this run; say what it covers.

## 2. Places

1. **Which places.** The places the story needs — where the brief's conflict
   happens, where the protagonist starts and ends, where the opposition holds
   power — not every place the world has.
2. **Each place**, one round: what it does to the people in it, the
   *Facts* (location, physical description, sensory detail), its *History*
   where it matters, and who is found there.
3. **Distances and travel times** between the places the story moves
   between: continuity checks rely on them. Ask for them; never assume.

Each place is a `place-<slug>` entry, skeleton-first then section by section
(`/bible` §2), *Secrets and mysteries* with their true answer or marked open.

## 3. Rules (full)

The rules that make this world different, and the ones a scene could break:

- **Statement:** one or two unambiguous sentences. Test each by asking what
  a scene could do that it neither allows nor forbids; if there is such a
  scene, the statement is not done.
- **Limits and costs:** what it cannot do, and what using it costs —
  required. A rule without a cost solves every problem.
- **Exceptions:** known exceptions and why, or "none".

Each rule is a `rule-<slug>` entry.

## 4. Facts the story depends on

Period, technology, law, a trade's practice, a calendar: whatever a scene
will be checked against. Each fact goes in the registry on the entity it
belongs to (a place, an `org-`, an `item-`), or, if it constrains what scenes
can do, becomes a rule entry. Say plainly when a fact is real-world and
needs the author's checking; never present an unchecked real-world detail as
settled.

## 5. Social order and cost (full)

1. **Social order:** who holds power, what is forbidden, what breaking it
   costs. Institutions become `org-` registry entities (`bible: null`, a
   `description` fact); a law that scenes test becomes a rule.
2. **What the world takes from the protagonist:** what this setting costs
   them in particular. Offer it as a line in the protagonist's entry
   (*Arc* or *Facts*), with its own approval.

## Registry in step

Whenever an entry gains facts or aliases, propose the matching
`bible/registry.yaml` lines in the same round, exactly as `/bible` does
(`.claude/skills/bible/SKILL.md` §3), with their own approval: **"May I write
this to `bible/registry.yaml`?"**.

## The session file

Each run records itself in `ideas/<YYYY-MM-DD>-world[-<name>].md` (template
`.claude/templates/shared/ideas-session.md`, `skill: /world`; add `-2` if it
exists). **After each section** (§2–§5), show what it adds — options as
offered, labelled `(Claude)`; the author's choice in their words; what was
not chosen; open questions — and ask "May I write this to `ideas/<file>`?".
If the author declines, say that part lives only in this conversation. At
the end, offer to copy open questions to `ideas/questions.md` and ideas to
keep for later to `ideas/parked.md`.

## Finish

- **Done?** Ask **"Is the world done for now?"** On yes, run `bash
  .claude/scripts/flow-mark.sh world done` and say so; coming back later is
  always possible.
- Rewrite the checkpoint `session/active.md` (no "May I write?" needed).
- Offer `/continuity-check` when facts changed that the manuscript already
  states.
- Run `bash .claude/scripts/flow-check.sh` and name **one** next step
  (usually `/bible style`, `/review gate cast` at `full`, or `/plot`). End
  with exactly one line, "Type `<command>` to begin.", and never invoke it.
