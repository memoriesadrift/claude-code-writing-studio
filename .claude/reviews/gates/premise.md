# Gate: premise (fiction)

**Agent:** `developmental-editor` · **Form:** fiction · **Spec:** development-flow §11

## Trigger

| Rigour | When |
|---|---|
| `minimal` | Not run; `/brainstorm` prints `Premise gate skipped — minimal rigour.` |
| `standard` | Offered after the brief is written; on request (`/review gate premise`) |
| `full` | After the brief is written (`/brainstorm` §2.5), and on request |

Target: `bible/brief.md`. Advisory: the author goes on regardless of the
verdict.

## Context to pass

This file's path and the target only. The agent reads:

- `bible/brief.md` — logline, protagonist want and need, stakes, ending
  intent, comparable titles, form
- `ideas/writer.md` if it exists — what the author wants the book to do
- the latest `ideas/*.md` session file — the dramatic question and theme as
  the author put them, if the brief does not hold them

Nothing else: the gate judges whether the brief promises a story, not
whether later material delivers it.

## Prompt

1. **A want that meets resistance.** Is there a protagonist who wants
   something specific, and something that stands in the way with enough force
   that the outcome is in doubt?
2. **Stakes.** Is it clear what is lost if they fail — for them, and beyond
   them? Would a reader care?
3. **A dramatic question the ending can answer.** Can the central question be
   put as yes/no, and does the ending intent answer it (even provisionally)?
4. **Want and need.** If they differ, is the gap the arc; if they are the
   same, is a flat arc a deliberate choice?
5. **Promise.** Do the logline, the comparable titles and the writer's brief
   promise the same book? Name any mismatch (a cosy logline with grimdark
   comps).
6. **Scope.** Does the premise fit the form and target length (a short story
   carrying a saga; a novel with one scene's worth of conflict)?

Severity: `error` — the brief has no story engine (no want, no opposition,
or no question the ending answers); `concern` — a weakness that will cost the
draft (vague stakes, a mismatched promise, scope out of proportion); `note` —
worth a look. Findings name the problem and the section of the brief; never
rewritten text, never a different premise of the gate's own.

## Verdicts

- `**Verdict:** APPROVE` — the brief promises a story; no `error` or
  `concern`.
- `**Verdict:** CONCERNS [n]` — it does, with `n` concerns worth addressing
  before drafting far.
- `**Verdict:** REJECT [n]` — `n` errors: no story engine yet.
- `**Verdict:** NOT ASSESSED` — the brief is missing or a section the
  questions need is empty; the report names which. Never read as a pass.

## Report

Template `.claude/templates/shared/review-report.md`, written to
`reviews/gate-premise-brief-<YYYY-MM-DD>.md` after "May I write?".
