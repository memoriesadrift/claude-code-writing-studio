# Gate: spine (fiction)

**Agent:** `structure-architect` · **Form:** fiction · **Spec:** development-flow §11

## Trigger

| Rigour | When |
|---|---|
| `minimal` | Not run; `/plot` prints `Spine gate skipped — minimal rigour.` |
| `standard` | Offered when the author marks the spine done in `/plot`; on request (`/review gate spine`) |
| `full` | When the author marks the spine done in `/plot`, and on request |

Target: `outline/structure.md`. Advisory: the author goes on regardless of
the verdict.

## Context to pass

This file's path and the target only. The agent reads:

- `outline/structure.md` — *Shape*, *Spine* (with any model beats),
  *Acts / movements*, *Promises and payoffs*
- `bible/brief.md` — stakes and ending intent, which the spine is tested
  against
- `bible/characters/*.md` — the protagonist's want, need and arc, and the
  opposition's, where a beat depends on them
- `bible/world/rules/*.md` where a beat depends on a world rule

Not the chapter list or the cards: the gate judges the spine. Sequencing is
`/outline`'s critique.

## Prompt

1. **Cause, not sequence.** Does each beat follow from the one before
   ("therefore" or "but", not "and then")? Name any beat that could be cut
   without the next one changing.
2. **The dramatic question.** Is it a yes/no question raised by the
   inciting incident, and does the climax answer it? An answer that arrives
   by coincidence or from outside the protagonist's choices is a finding.
3. **The protagonist drives.** Are the first turning point, the crisis and
   the climax the protagonist's choices? Does the crisis test the need the
   brief and the cast name?
4. **Stakes and ending.** Does the spine deliver the brief's stakes and
   ending intent? Name any drift between them.
5. **Promises and payoffs.** Does every promise listed have a payoff (or a
   deliberate `open`), and does the spine set up anything — a rule, a
   secret, a skill — that nothing pays off?
6. **Shape.** If a model is named, are its beats in place, and does the
   middle have a turn (the midpoint) rather than more of the same?
7. **World rules.** Does a beat need a rule to work in a way its *Statement*,
   limits or costs do not allow?

Severity: `error` — no dramatic question, or a climax that does not answer
it; `concern` — a beat without cause, a passive protagonist at a turning
point, a promise without payoff, drift from the brief, a beat that breaks a
world rule; `note` — worth a look. Findings name the problem and the beat;
never rewritten beats, never a plot of the gate's own.

## Verdicts

- `**Verdict:** APPROVE` — no `error` or `concern`.
- `**Verdict:** CONCERNS [n]` — `n` concerns.
- `**Verdict:** REJECT [n]` — `n` errors.
- `**Verdict:** NOT ASSESSED` — no `outline/structure.md`, no *Spine*
  section, or no brief; the report names which. Never read as a pass.

## Report

Template `.claude/templates/shared/review-report.md`, written to
`reviews/gate-spine-structure-<YYYY-MM-DD>.md` after "May I write?".
