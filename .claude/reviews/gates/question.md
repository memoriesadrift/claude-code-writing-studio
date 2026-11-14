# Gate: question (non-fiction)

**Agent:** `developmental-editor` · **Form:** non-fiction · **Spec:** development-flow §11

## Trigger

| Rigour | When |
|---|---|
| `minimal` | Not run; `/brainstorm` prints `Question gate skipped — minimal rigour.` |
| `standard` | Offered once the work's brief has its research question; on request (`/review gate question <work>`) |
| `full` | Once the work's brief has its research question (`/brainstorm` §3.3, `/new-work`), and on request |

Target: a work (`works/<work>/`). Advisory: the author goes on regardless.

## Context to pass

This file's path and the work only. The agent reads:

- `works/<work>/brief.md` — the research question in force (`vN`), the
  assignment and marking criteria (verbatim), constraints
- `works/<work>/work.yaml` — `kind`, `word_limit`, `assessed`, `policy`
- `compendium/positions/`, `compendium/claims.yaml` and the source notes the
  question touches — what the author already holds on it

## Prompt

1. **Answerable.** Could evidence and argument within the author's reach
   settle it, or at least take a defensible side?
2. **Arguable.** Does it admit more than one reasonable answer? A question
   with an obvious answer, or none, is a finding.
3. **In scope.** Can it be answered well within the word limit and the kind
   of work? Name what would have to be cut, or what is missing.
4. **Fit to the brief.** Does it answer the assignment as set, and could the
   work meet each marking criterion while answering it?
5. **Sources.** Does the compendium hold enough to start, or what kinds of
   source are needed (never invent a title or author; name kinds, or
   citekeys that exist)?
6. **Wording.** Are its key terms clear enough that two readers would take
   it the same way?

Severity: `error` — unanswerable, unarguable or off the assignment;
`concern` — scope, fit or source weaknesses that will cost the work;
`note` — worth a look. Findings name the problem; never a replacement
question of the gate's own (the author may ask `/brainstorm <work>` for
alternatives).

## Verdicts

- `**Verdict:** APPROVE` — no `error` or `concern`.
- `**Verdict:** CONCERNS [n]` — `n` concerns.
- `**Verdict:** REJECT [n]` — `n` errors.
- `**Verdict:** NOT ASSESSED` — no research question in the brief, or no
  `work.yaml`; the report names which. Never read as a pass.

## Report

Template `.claude/templates/shared/review-report.md`, written to
`works/<work>/reviews/gate-question-<work>-<YYYY-MM-DD>.md` after "May I
write?". An assessed work's `policy` goes in the header verbatim.
