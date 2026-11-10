# Review pass: milestone

**Agent:** `developmental-editor` · **Form:** both · **Spec:** §7.1, §11

## Trigger

- Fiction: offered when the `draft` phase completes (every scene card
  `drafted` or `revised`), and on request (`/review milestone`). An APPROVE on
  the whole manuscript completes the `revision` phase in `workflow.yaml`.
- Non-fiction: on request for a whole work (`/review milestone <work>`), as a
  last look before marking it complete. (The `revision` phase is completed by
  a developmental review of the whole work; a milestone report does not stand
  in for it.)

Target: `manuscript` (fiction) or a work (non-fiction) — always the whole.

## Context to pass

This file's path and the target only. The agent reads:

- Everything the developmental pass reads (`.claude/reviews/developmental.md`)
- The latest `continuity` (fiction) or `citation` (non-fiction) report for
  the whole target, if any, and the latest report of each other pass
- Findings still open: from each earlier report, the `error` and `concern`
  findings whose location has not changed since (check the files), or that
  the author has not dismissed in conversation
- `session/provenance.jsonl`, only to note units written since the last
  continuity or citation report

## Prompt

1. Run the developmental prompt on the whole target.
2. Collect open findings from earlier reports: list them with the report they
   came from. Do not re-judge them; say whether each still applies.
3. Say whether a fresh continuity or citation pass is needed (no report yet,
   or units written since the last one), and name it as the next step.
4. Non-fiction: word count against `word_limit`; the research question in
   force against the thesis the work actually argues.
5. Close with what stands between the target and done, in order.

Severity as the developmental pass. Open findings carry their original
severity.

## Verdicts

- `**Verdict:** APPROVE` — the whole works, and no `error` findings are open
  in any earlier report.
- `**Verdict:** CONCERNS [n]` — no open `error`; `n` `concern` findings (new
  and still open).
- `**Verdict:** REJECT [n]` — `n` `error` findings, new or still open from
  an earlier report.

## Report

Template `.claude/templates/shared/review-report.md`, written to
`reviews/milestone-manuscript-<YYYY-MM-DD>.md` (fiction) or
`works/<work>/reviews/milestone-<work>-<YYYY-MM-DD>.md` (non-fiction) after
"May I write?". Open findings go in their own table after *Findings*, with a
column naming the source report.
