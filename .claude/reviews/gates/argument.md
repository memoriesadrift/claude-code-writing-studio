# Gate: argument (non-fiction)

**Agent:** `structure-architect` · **Form:** non-fiction · **Spec:** development-flow §11

## Trigger

| Rigour | When |
|---|---|
| `minimal` | Not run; `/outline` prints `Argument gate skipped — minimal rigour.` |
| `standard` | Offered once the outline has its section blocks; on request (`/review gate argument <work>`) |
| `full` | Once the outline has its section blocks (`/outline <work>`), and on request |

Target: `works/<work>/outline.md`. Advisory: the author goes on regardless.

## Context to pass

This file's path and the work only. The agent reads:

- `works/<work>/outline.md` — the through-line and every `### ` section
  block (claim, role, claim ids, citekeys, target words)
- `works/<work>/brief.md` — the research question in force (`vN`), the
  assignment and marking criteria (verbatim)
- `works/<work>/work.yaml` — `kind`, `word_limit`, `word_count_excludes`,
  `assessed`, `policy`
- `compendium/claims.yaml` — the claims the blocks name, with their support
  and objections
- `compendium/positions/` — the debates the question sits in

Not the sections' prose: the gate judges the plan.

## Prompt

1. **Each section advances the thesis.** For each block: what does it add
   to the answer? A section that restates, or that the conclusion does not
   need, is a finding.
2. **The through-line answers the question in force.** Does the outline
   answer the research question as worded now (`vN`), and do the blocks
   carry the version they were planned under?
3. **The strongest objection is met.** Which objection would a marker raise
   first (from `positions/` and the claims' objections)? Is there a section
   or a part of one that meets it, before the conclusion?
4. **Support.** Does each section's claim have claims and citekeys behind
   it? Name the sections whose support is a gap, and the citekeys whose
   note is `unverified`. Never name a source that has no note.
5. **Proportion.** Do the target words add up to the limit less the
   exclusions, and does each section's share fit its weight in the argument?
6. **Fit to the criteria.** Could the work, built this way, meet each
   marking criterion? Name a criterion no section addresses.

Severity: `error` — the outline does not answer the research question, or
no section meets any objection; `concern` — a section that does not advance
the thesis, unsupported claims, an objection met too weakly or too late,
proportions that cannot fit the limit, a criterion not addressed; `note` —
worth a look. Findings name the problem and the section; never rewritten
blocks, never an argument of the gate's own.

## Verdicts

- `**Verdict:** APPROVE` — no `error` or `concern`.
- `**Verdict:** CONCERNS [n]` — `n` concerns.
- `**Verdict:** REJECT [n]` — `n` errors.
- `**Verdict:** NOT ASSESSED` — no outline, no section blocks, or no
  research question in the brief; the report names which. Never read as a
  pass.

## Report

Template `.claude/templates/shared/review-report.md`, written to
`works/<work>/reviews/gate-argument-<work>-<YYYY-MM-DD>.md` after "May I
write?". An assessed work's `policy` goes in the header verbatim.
