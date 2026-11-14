---
name: next
description: "What should I do next? Reads the workflow catalogue, the progress file and the checkpoint, says where the work stands and names one next step - a development step, the next unit to write at the prose level in force, a review, or publishing - then hands off with the command to type. Use when the author asks what to do next, is stuck, has just finished something, or types /next."
argument-hint: "[work] [write | done <step> | skip <step> | what I just finished]"
allowed-tools: Read, Glob, Grep, Bash(bash .claude/scripts/flow-check.sh*), Bash(bash .claude/scripts/flow-mark.sh *)
---
# /next (development-flow §8)

The conductor. It tells the author where they are and the **one** next step,
then hands off. **It never runs that step**: it ends with "Type `<command>`
to begin." and stops (development-flow principle 4 — the author running
each step builds their command of the studio). Its only write is a line in
the progress file, when the author says a step is done or skipped.

If `studio.yaml` does not exist, say the project is not set up and offer
`/start`. Nothing else.

Talk in the interface language. Keep it short: an orientation, not a report
(`/status` is the report). Match the author's tone: someone who says they
are lost gets one action, not a list.

## 1. Arguments (plain words)

- A work slug (non-fiction): that work. Without one: `session/current-work`;
  if none, one line per work and the next step for the work furthest along.
- `write` — the author wants to write now (§4).
- `done <step>` / `skip <step>` — record a step (§5).
- Anything else is what the author just did or is stuck on ("finished the
  cast", "stuck on chapter 3"): use it to read the facts, never to override
  them.

## 2. Read

1. `bash .claude/scripts/flow-check.sh [work]` — steps with their status
   (`rec` = recommended at this rigour, `opt` = available), phases, the
   current phase, the next step, and the write loop (`drafted:`,
   `next-unit:` with the prose level in force, `card-missing:`,
   `uncarded:`).
2. The checkpoint's *Current task*, *Next step* and *Open questions*
   (fiction `session/active.md`, non-fiction `works/<work>/checkpoint.md`),
   and `ideas/questions.md` if it exists.

The script reports facts; you decide what they mean. `NO_CHECK` never
means done.

## 3. Decide the one next step

In this order; the first that applies is the next step:

1. **Unfinished business.** The checkpoint names a task in progress that the
   facts do not show as finished (a unit drafted but no "unit done", a
   review not yet written): finish it.
2. **The first recommended step not done** (`next-step:`), unless the author
   has chosen to write (§4). Before naming a development step, check it
   against `stage-in-force` and the write loop: if the author is already
   drafting and the step is behind them (a premise gate in the middle of
   chapter 9), say so and offer to record it as skipped rather than
   sending them back.
3. **The write loop** (draft phase, or when the author chose to write):
   - `card-missing: <chapter>` at `standard` or `full` → `/outline
     <chapter>` (cards just in time). At `minimal` cards are optional: say
     the chapter has no card and offer both `/outline <chapter>` and
     writing it without one.
   - `next-unit: <key>` → by the level in force (say the level and where it
     came from, and any integrity cap):

     | Level | Hand-off |
     |---|---|
     | `critic`, `coach` | "Next: `<key>`. Type `/draft <key>` for your brief; write it; then `/draft <key> done`." |
     | `editor` | as above, then "`/draft <key>` again for line edits once you have a draft" |
     | `co-author` | "Type `/draft <key>` to draft it together." |
     | `ghostwriter` | "Type `/draft <chapter or work>` to draft it unit by unit." |
   - `next-unit: none` with no outline blocks → the author picks the unit;
     offer `/draft <unit>` for whichever they name, or `/outline` for cards.
   - `uncarded:` chapters → mention once that their units are not tracked.
4. **Revision** (every unit drafted): fiction `/review milestone`;
   non-fiction `/review developmental <work>`. After a review with findings,
   the next step is revising — the author revises (or `/draft <unit>` at
   `editor` and above) — then the same review again. When the author says
   the revision is done, record `revision` as done (§5).
5. **Complete** (non-fiction): marking the work complete is the author's
   edit to `work.yaml` → `status: complete`; then `/cite-check <work>`
   (the citation check runs at every rigour before completion).
6. **Finish**: `/publish` is optional. When every recommended step is done,
   say the work is finished; for non-fiction offer `/brainstorm` or
   `/new-work` for the next one.

## 4. "I want to write now"

At any point once a brief exists (`brief` is PRESENT), `/next write` (or the
author saying so) makes the write loop the next step. Then, for each
recommended development step before the draft phase that is not done, ask
once whether to record it as skipped so later `/next` runs stop naming it
(it moves to "Also available"). On yes, `flow-mark.sh <step> skipped
[work]`. Without a brief, say a brief is the one thing drafting needs, and
name `/brainstorm` (or `/premise`, `/new-work`).

## 5. Recording a step

`/next done <step>` or `/next skip <step>`, or the author saying a step is
finished (a step with a `done` artefact: cast, world, spine, gates, reading
plan, draft, revision):

- Confirm which step (ids from the `step:` lines) and that the author means
  it.
- Run `bash .claude/scripts/flow-mark.sh <step> done|skipped [work]` and
  say what was recorded. `clear` undoes it.
- A file-backed step (the brief, the style guide, cards) cannot be marked:
  it is done when its file is. Say which file.

## 6. Present

```
Where you are: <phase> — <one line: e.g. "drafting, 14 of 32 scenes">
In progress: <from the checkpoint, if any>
Done: <the current phase's finished steps, one line>
→ Next: <step> — <why, one line>
Also available: <up to three optional or skipped steps, with commands>
Coming up: <the next one or two recommended steps>

Type `<command>` to begin.
```

The last line is always the hand-off, alone. Do not invoke the skill, even
if the author says yes: they type it.

If the author seems lost or overwhelmed, add at most two lines: `/status`
for the full picture, and — only if the process feels too heavy or too
light for the project — that `modes.rigour` in `studio.yaml` changes what is
recommended (never what is allowed).
