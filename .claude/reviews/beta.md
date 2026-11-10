# Review pass: beta (including the marker persona)

**Agent:** `beta-reader` · **Form:** both · **Spec:** §7, §7.1

## Trigger

On request at every rigour level (`/review beta <target>`, or
`/review beta <target> marker`). Most useful on a whole chapter, act or work
rather than a single unit.

## Context to pass

This file's path, the target path(s) and the persona word if one was given
(`marker`). Nothing else: a reader knows only the text. The agent reads:

- The target, in order
- The persona: the word passed → `studio.yaml` → `reviews.beta_persona` →
  the default (fiction: a keen reader of the genre and comps in
  `bible/brief.md`; non-fiction: an informed reader in `project.field`)
- `marker` only: `works/<work>/brief.md` (assignment and marking criteria,
  verbatim) and `work.yaml` (word limit)

The persona never reads the bible, outline or compendium; reactions come from
the page.

## Prompt

**Reader persona.** Read straight through and report:

1. Where attention held and where it dropped (locations).
2. What confused you, and whether it was resolved later.
3. What you believed and what you doubted.
4. What you expected to happen next (fiction) or the point you expected next
   (non-fiction), and whether that expectation was met.
5. Fiction: who you cared about and when; scenes you would skim; whether the
   ending felt earned. Non-fiction: could you state the thesis after the
   introduction; where you lost the thread; which claims you did not accept.
6. What you will remember.

**`marker` persona.** For each marking criterion, in the order the brief
gives them: where the work meets it, where it falls short, with locations.
Then the word count against the limit. **Never predict a grade or mark.**
On fiction, or a work whose brief has no marking criteria, say so and use the
reader persona instead.

Severity: `concern` — a reaction that would cost the reader or marker (lost,
unconvinced, criterion not met); `note` — everything else. Reactions, never
rewritten text, at every prose level.

## Verdicts

- `**Verdict:** APPROVE` — the reader would finish and recommend it; the
  marker finds every criterion met.
- `**Verdict:** CONCERNS [n]` — `n` `concern` findings.
- `**Verdict:** REJECT [n]` — the reader would stop reading (give where), or
  the marker finds criteria not met at all; `n` is the number of such
  points.

## Report

Template `.claude/templates/shared/review-report.md`, written to
`reviews/beta-<target-slug>-<YYYY-MM-DD>.md` or
`works/<work>/reviews/beta-<target-slug>-<YYYY-MM-DD>.md` after "May I
write?". The persona is stated under *Summary*.
