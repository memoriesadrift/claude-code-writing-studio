---
name: premise
description: "Fiction - write or revise the brief, bible/brief.md - logline, protagonist want and need, stakes, ending intent, comparable titles, form and length. The brief is the only thing drafting needs. Use when a fiction project has no brief yet, when the author wants to pin down or rethink what the book is, or types /premise."
allowed-tools: Read, Glob, Grep, Bash(bash .claude/scripts/status.sh*)
---
# /premise (spec §8.2, §4.3, §11)

The brief is the one prerequisite for drafting at every rigour level, and the
artefact of the `premise` phase (`workflow.yaml`: `bible/brief.md` with a
`## Logline` heading). It is part of the bible: Claude may write it at any
prose level, only after **"May I write this to `bible/brief.md`?"**, and
`.claude/rules/bible.md` applies.

If `studio.yaml` does not exist, say the project is not set up and offer
`/start`. On a non-fiction project, say the equivalent is the work's brief and
point to `/new-work`. Nothing else.

## Ground rules

- **The author decides what the book is.** You draw each section out of what
  they say (and anything they have already written: `manuscript/`, notes they
  paste), propose wording, and they correct it. Never a form to fill in.
- **One section per round**, a few questions at a time, each with options and
  a recommendation where you have one. "Don't know yet" is fine: the section
  says so (`provisional — to decide`), and drafting can still start.
- Doc density follows `modes.rigour`: `minimal` terse bullets, `standard`
  bullets with a line of rationale, `full` rationale and the alternatives
  considered.
- Talk in the interface language (`studio.yaml` → `language.interface`); the
  brief is written in the prose language.

## 1. Look first

Read `studio.yaml` (title, form, `style` → pov, tense, register),
`bible/brief.md` if it exists, `session/active.md`, and glance at what exists
in `manuscript/` and `bible/` (titles, the first lines of the first unit) so
the questions start from what the author has.

- **Brief exists:** this is a revision. Show its sections in one line each and
  ask which to revisit; only those are rewritten (§4 below).
- **No brief:** go on.

## 2. Skeleton

Template `.claude/templates/fiction/brief.md`. Fill the title, `updated:`
(today) and the *Form* section from `studio.yaml` (form, POV and tense; ask
for a target length, offering a usual range for the form); every other section
is its heading with `<!-- to decide -->`. Keep `canon: provisional`. Show it,
ask **"May I write this to `bible/brief.md`?"**, write it.

## 3. Sections, in order

Each round: ask, propose the wording, revise until approved, then **"May I
write this to `bible/brief.md`?"** and write only that section.

1. **Logline** — one or two sentences: protagonist, goal, obstacle, stakes.
   Offer two or three versions that differ in emphasis.
2. **Protagonist** — *want* (the conscious goal) and *need* (what they must
   learn or become). If the two are the same, say that the arc may then be
   flat, and that a flat arc is a legitimate choice.
3. **Stakes** — what is lost if they fail, personal and wider.
4. **Ending intent** — how the author means it to end and the feeling it
   should leave. Often provisional; say so in the section.
5. **Comparable titles** — two or three, each with what it shares with this
   book. Suggest only titles you are sure exist; say when you are unsure, and
   the author confirms.
6. **Form** — review what the skeleton filled in.

If POV or tense in `studio.yaml` → `style` was left `null` at `/start` and the
author settles it here, offer the one-line change to `studio.yaml` (with "May
I write this to `studio.yaml`?").

## 4. Revising

Rewrite only the sections the author chose; leave the others byte for byte.
Update `updated:`. Never change `canon:` without asking; moving the brief to
`established` is the author's call. If the change affects things already
written (the outline's chapter list, a character's want and need in their
bible entry), list them and offer to update each, with approval; nothing is
changed silently.

## 5. Finish

- Run `bash .claude/scripts/status.sh` and check the `premise` phase is now
  complete (the brief has its `## Logline`).
- Offer the style guide (`/bible style`) if `bible/style-guide.md` does not
  exist: POV, tense, voice, register and dialogue in one place help every
  later review. Optional.
- Rewrite the checkpoint `session/active.md` (no "May I write?" needed):
  brief written; next step; open questions (anything left to decide).
- Name **one** next step: `/outline` to plan structure, or `/draft` to start
  writing straight away — at every rigour level, the brief is all drafting
  needs.
