# Review pass: line

**Agent:** `line-editor` · **Form:** both · **Spec:** §7, §7.1

## Trigger

On request at every rigour level (`/review line <target>`). `/draft` at
`editor` level may offer it for the unit being edited.

Target: a unit or section; a chapter or work for a pattern survey (findings
grouped by pattern, not every instance).

## Context to pass

This file's path and the target path(s) only. The agent reads:

- The pack's `style.md` (non-fiction: also `academic.md`) and the overlay
  `variants/<tag>.md`; options in force
- Fiction: `bible/style-guide.md`, voice profiles in `bible/characters/` for
  the characters who speak
- Non-fiction: `studio.yaml` → `style.register`; `compendium/concepts/` for
  terms the target uses

## Prompt

1. Rhythm and sentence variety; paragraphs that run one pace throughout.
2. Clarity: sentences a reader must reread; unclear reference.
3. Concision: redundancy, filter words, throat-clearing, stacked qualifiers.
4. Voice: narration against the style guide; dialogue against each speaker's
   voice profile.
5. Clichés and tics the author repeats (count them).
6. Non-fiction: terms used precisely and consistently with their concept
   entries; hedging that matches the evidence; signposting; register.

The author's voice is the standard. Severity: `concern` — works against the
author's evident intent or the style guide; `note` — a choice worth a second
look. (Line editing has no `error` severity: correctness is the grammar
pass.)

By prose level: `critic` — name the pattern, location and effect, no
rewritten text; `coach` — plus labelled illustrations on invented text;
`editor` and above — numbered diffs with location and one-line reason, not
applied.

## Verdicts

- `**Verdict:** APPROVE` — reads well; notes only.
- `**Verdict:** CONCERNS [n]` — `n` `concern` findings (count a grouped
  pattern once).
- `**Verdict:** REJECT [n]` — reserved for prose that cannot be line-edited
  usefully yet (for example, a draft whose structure is still moving);
  `n` is the number of passages affected, and the report recommends a
  developmental pass first.

## Report

Template `.claude/templates/shared/review-report.md`, written to
`reviews/line-<target-slug>-<YYYY-MM-DD>.md` or
`works/<work>/reviews/line-<target-slug>-<YYYY-MM-DD>.md` after "May I
write?". At `editor` and above the diffs go under *Findings*, numbered, for
the main session to apply one at a time on acceptance.
