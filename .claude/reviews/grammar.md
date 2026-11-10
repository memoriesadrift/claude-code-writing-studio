# Review pass: grammar

**Agent:** `grammar-editor` · **Form:** both · **Spec:** §4.5, §7, §7.1

## Trigger

On request at every rigour level (`/review grammar <target>`). Usually last,
once structure and line edits have settled.

**No pack, no pass:** if the prose language has no folder under
`.claude/languages/`, the pass does not run; the agent says so and points to
`/language add <tag>`.

Target: a unit, section, chapter or work.

## Context to pass

This file's path and the target path(s) only. The agent reads:

- The pack: `pack.yaml`, `conventions.md`, `grammar.md` (non-fiction: also
  `academic.md`), the overlay `variants/<tag>.md`
- Options in force: `work.yaml` `language_options` → `studio.yaml`
  `language.options` → variant defaults → option defaults
- Source notes, only to check that a direct quotation was not altered

## Prompt

1. Grammar and agreement.
2. Spelling, per the variant (`-ise`/`-ize`, ß/ss) and options in force;
   inconsistent spellings of one word.
3. Punctuation and typography as `conventions.md` and the overlay set them:
   quotation marks, dashes, ellipses, spacing, numbers, dates, capitalisation.
4. Options in force (e.g. `oxford_comma`, `gendering`) applied consistently.
5. Non-fiction: `academic.md` conventions — abbreviations, locator forms,
   translation marking.
6. Skip deliberate non-standard usage (dialect in dialogue, a voice) unless
   it looks unintended; never correct inside a quotation from a source.

Severity: `error` — breaks a rule of the pack; `concern` — inconsistency;
`note` — a choice worth checking. Each finding cites the pack file and rule.
By prose level: `critic` — the rule, the location and the text quoted as-is,
no corrected text; `coach` — plus labelled illustrations on invented text;
`editor` and above — numbered diffs, not applied.

## Verdicts

- `**Verdict:** APPROVE` — no `error` or `concern` findings.
- `**Verdict:** CONCERNS [n]` — `n` findings of severity `error` or
  `concern`, all fixable line by line. Grammar slips are concerns, not
  rejections, however many.
- `**Verdict:** REJECT [n]` — the target is not in the pack's language or
  variant it claims (for example, a de-CH work written with ß throughout, or
  an en-GB work in US spelling); `n` is the number of systematic mismatches.

## Report

Template `.claude/templates/shared/review-report.md`, written to
`reviews/grammar-<target-slug>-<YYYY-MM-DD>.md` or
`works/<work>/reviews/grammar-<target-slug>-<YYYY-MM-DD>.md` after "May I
write?". The header lists the options in force. A `user-defined` pack keeps
the template's reliability notice.
