# Review pass: developmental

**Agent:** `developmental-editor` · **Form:** both · **Spec:** §4.3, §7.1

## Trigger

| Rigour | When |
|---|---|
| `minimal` | On request (`/review developmental <target>`) |
| `standard` | At chapter milestones (fiction: a chapter's last scene card reaches `drafted`) and work milestones (non-fiction: every outlined section `drafted`), and on request |
| `full` | At "unit done", and on request |

Non-fiction: a developmental review of the **whole work** that approves it
completes the `revision` phase in `workflow.yaml`.

Target: fiction — a unit, a chapter or `manuscript`; non-fiction — a section
or a work.

## Context to pass

This file's path and the target path(s) only. The agent reads:

- Fiction: `bible/brief.md`, `outline/structure.md`, the target's scene
  cards, `bible/characters/` for the characters in play
- Non-fiction: `works/<work>/brief.md`, `works/<work>/outline.md`,
  `works/<work>/work.yaml` (word limit, `policy`), the claims and source
  notes the target relies on
- The pack's `style.md` (and `academic.md` for non-fiction) for register

## Prompt

**Fiction — does the story work?**

1. Stakes: are they clear, and do they rise?
2. Each scene: does something change (goal, conflict, outcome)? Scenes that
   change nothing are findings.
3. Arcs: does each character's arc move as the brief and their entry say,
   and do turns feel earned?
4. Promises and payoffs (`structure.md`): set-ups paid off, payoffs set up.
5. The premise's promise: is this the book the logline and comps promise?
6. Pacing at the scale of the target: where it drags, where it rushes.

**Non-fiction — does the argument land?**

1. Thesis: is it stated, does it answer the research question in force (the
   `vN` at the top of `brief.md`), and could a reader state it?
2. Structure: does each section advance the thesis in the order given? Note
   sections the outline assigns one role but the draft gives another.
3. Evidence: does the support carry the weight put on it? Single-source
   load-bearing claims, contested claims treated as settled.
4. Counter-arguments: are the strongest objections met, fairly stated?
5. Fit to the brief: the assignment and marking criteria (verbatim), scope,
   word limit.
6. Has the draft moved past the research question? If so, say so; the author
   decides whether to revise it.

Rank findings by consequence. Severity: `error` — the target fails at its
main job (no discernible thesis; the story's central promise broken);
`concern` — a weakness that matters to the whole; `note` — worth a look.
Findings name the problem and where; at `critic`/`coach` never rewritten
text. Doc density follows `modes.rigour`.

## Verdicts

- `**Verdict:** APPROVE` — the target works; no `error` or `concern`.
- `**Verdict:** CONCERNS [n]` — it works, with `n` `concern` findings worth
  addressing.
- `**Verdict:** REJECT [n]` — `n` `error` findings: it does not yet do its
  main job.

## Report

Template `.claude/templates/shared/review-report.md`, written to
`reviews/developmental-<target-slug>-<YYYY-MM-DD>.md` (fiction) or
`works/<work>/reviews/developmental-<target-slug>-<YYYY-MM-DD>.md`
(non-fiction) after "May I write?". For a whole work the target slug is the
work slug itself (`developmental-<work>-<date>.md`): `workflow.yaml` counts
only that name towards the `revision` phase, so a section report never
completes it.
