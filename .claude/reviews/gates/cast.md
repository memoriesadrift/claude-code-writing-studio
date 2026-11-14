# Gate: cast (fiction)

**Agent:** `character-lead` · **Form:** fiction · **Spec:** development-flow §11

## Trigger

| Rigour | When |
|---|---|
| `minimal` | Not run; `/cast` prints `Cast gate skipped — minimal rigour.` |
| `standard` | Offered when the author marks `cast-core` or `cast-full` done; on request (`/review gate cast`) |
| `full` | When the author marks the cast done in `/cast`, and on request |

Target: `bible/characters/`. Advisory: the author goes on regardless of the
verdict.

## Context to pass

This file's path and the target only. The agent reads:

- `bible/brief.md` — logline, protagonist want and need, stakes, ending
  intent
- `bible/characters/*.md` — every character entry
- `bible/registry.yaml` — the `char-` entities and their facts
- `outline/structure.md` if it exists — the *Spine*, so arcs can be checked
  against the beats
- the latest `ideas/*.md` session file from `/cast`, if any — what the
  author said each character is for

Not the manuscript: the gate judges the cast as planned. Behaviour on the
page is the continuity and developmental passes' job.

## Prompt

1. **Arcs fit the brief.** Does the protagonist's arc run from the want to
   the need the brief names (or is a flat arc deliberate and stated)? Does
   the arc's end state fit the ending intent?
2. **Opposition with its own logic.** Does the opposition want something of
   its own, for reasons that hold from where it stands? An opposition that is
   only an obstacle is a finding.
3. **Every character has a function.** For each supporting character: what
   would the story lose without them? Two characters doing the same job, or
   one doing none, is a finding.
4. **Pressure on the protagonist.** Does someone in the cast press on the
   lie or wound the protagonist carries? Does each relationship want
   something from the protagonist and change over the story?
5. **Consistency.** Do entries contradict each other, the brief or the
   registry (ages, relationships, timelines)? Name both locations.
6. **Open answers.** Secrets and mysteries without a true answer, and arcs
   left `to decide`, are listed (not counted as errors).

Severity: `error` — the protagonist has no arc and the flat arc is not a
choice, or there is no opposition; `concern` — opposition without logic,
a character without a function, an arc that does not reach the ending
intent, a contradiction; `note` — worth a look. Findings name the problem
and the entry; never a rewritten entry, never a new character of the gate's
own.

## Verdicts

- `**Verdict:** APPROVE` — no `error` or `concern`.
- `**Verdict:** CONCERNS [n]` — `n` concerns.
- `**Verdict:** REJECT [n]` — `n` errors.
- `**Verdict:** NOT ASSESSED` — no brief, or no character entries; the
  report names which. Never read as a pass.

## Report

Template `.claude/templates/shared/review-report.md`, written to
`reviews/gate-cast-bible-<YYYY-MM-DD>.md` after "May I write?".
