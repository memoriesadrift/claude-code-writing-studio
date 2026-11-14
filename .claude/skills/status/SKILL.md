---
name: status
description: "Where the project stands - phase and next step, word counts (against limits for works), latest review verdicts and outstanding checks, config errors. /status provenance [work] summarises what Claude wrote; /status provenance statement <work> drafts an AI-use acknowledgement. Use when the author asks where they are, what's next, or for a provenance summary."
argument-hint: "[provenance [statement]] [work]"
allowed-tools: Read, Glob, Grep, Bash(bash .claude/scripts/status.sh*)
---
# /status (spec §8.1, §5.3, §5.4, §11)

Arguments are plain words: `/status`, `/status <work>`,
`/status provenance [work]`, `/status provenance statement <work>`. A trailing
word that is not a sub-command is a work slug (`/new-work` reserves the
sub-command words, so this is never ambiguous). On a fiction project a work
slug is an error.

If `studio.yaml` does not exist, say the project is not set up and offer
`/start`. Nothing else.

**Helpers report; you judge.** `status.sh` prints facts; you turn them into
a short report and decide what matters. Never edit anything from `/status`:
fixes are offered, and made only after "May I write this to `<path>`?".

## `/status [work]`

Run `bash .claude/scripts/status.sh [work]`, then read what it cannot judge:

1. **Language options.** For `studio.yaml` → `language.options` and each
   `work.yaml` → `language_options`, check every option against the pack's
   `pack.yaml` → `options`: an unknown option, or a value not in its
   `values`, is an **error** (§4.5). Name the pack file.
2. **Checkpoint.** Fiction: `session/active.md`. Non-fiction: the current
   work's `works/<work>/checkpoint.md` (from `session/current-work`, or the
   work named). Use its *Next step* when it is more specific than the phase.
3. **Outstanding findings.** For each latest review the script lists with
   `CONCERNS` or `REJECT`, say which pass and target, and that it is open
   unless a later report on the same target approves it. For non-fiction,
   any citation report that is not `APPROVE` is outstanding and stays listed
   until a later citation report approves (§4.3: the verdict is advisory,
   but `/status` keeps reporting it). A work marked `complete` with no
   citation report at all: say the citation check has not run.
4. **Rigour.** At `standard` and `full`, a unit drafted since its last
   continuity or citation report (compare dates with the provenance log or
   the report date) is "check due". At `full`, outline sections whose
   `question: vN` is older than the brief's current version are "re-read
   due".

Then report, in the interface language, in this order and briefly:

- **One line:** form · prose level (+ overrides) · language · rigour.
- **Where you are:** the phase in force (`stage-in-force`), the
  `current-phase` and its `missing:` steps (recommended at this rigour, not
  yet done), `skipped:` steps, and for drafting `drafted: n of m`. The
  `## phases` block comes from `flow-check.sh`, the same facts `/next`
  uses. If the stage and the current phase disagree, say so: e.g.
  `project.stage` says `revision` but scene cards are still `planned`.
  Nothing hard-blocks; it is information.
- **Words:** fiction — total and per chapter; non-fiction — per work against
  `word_limit` (say which exclusions applied), over-limit flagged.
- **Outstanding checks** from points 3–4.
- **Errors:** every `error:` line from the script and point 1, grouped by
  file, each with what to change. Hook-read lines a hook would misread
  (§10.1) come first: a guard may be acting on the wrong value.
- **Next step:** one, worked out as `/next` does (`.claude/skills/next/
  SKILL.md`, §3) from the same facts, and handed off the same way: "Type
  `<command>` to begin." Never run it. Point to `/next` for the guided
  version.

Non-fiction with several works and no work named: one line per work (status,
words/limit, next phase), then detail only for the current work.

## `/status provenance [work]`

Run `bash .claude/scripts/status.sh provenance [work]`. Summarise per
chapter (fiction) or per work and section (non-fiction): number of Claude
writes, characters added and removed, prose levels in force, and how many
writes were under the integrity cap. Separate prose from everything else
(bible, compendium, outline, reviews): only prose writes say anything about
authorship. If the log does not exist, say that nothing has been recorded
yet. The log records Claude's writes, never the author's — except
`imported:` lines: files `/import` copied verbatim from the author's own
draft or notes (`tool: import`). List them separately as the author's text,
with their word counts and source; they are never Claude's writing and never
count towards what Claude added.

## `/status provenance statement <work>`

Non-fiction only; the work is required. Draft an AI-use acknowledgement for
the author to edit, from:

- the provenance summary for the work (above);
- the work's review reports (`works/<work>/reviews/`): which passes ran and
  when;
- `work.yaml` → `assessed`, `policy` (quote it verbatim), the cap in force;
- compendium help (source notes and claims written by Claude, from the
  provenance log).
- imported files (`imported:` lines): the author's own text, brought in
  with `/import`; say so if it matters ("the draft was written by me before
  I used the studio"), never as Claude's contribution.

The draft **describes what happened**, in plain first-person sentences the
author can sign (e.g. "I used Claude to give feedback on structure and to
check citations; it did not write any of the submitted text."). It never
asserts that the work complies with the policy: that judgement is the
author's. If outstanding citation errors exist, the draft says so (§4.3).
Present it in conversation; write it to a file only if the author asks, and
only after "May I write this to `<path>`?".
