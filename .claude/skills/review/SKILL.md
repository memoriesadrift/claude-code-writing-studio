---
name: review
description: "Run one review pass (continuity, citation, developmental, line, grammar, beta, milestone) on a unit, chapter, section, work or the manuscript - the pass's agent reads the pass file in its own context and returns a report with an advisory verdict, which is written to reviews/ (or works/<work>/reviews/) on approval. With no arguments, lists the passes and suggests one. /review gate <name> runs a development gate (premise, cast, spine, question, argument). Use when the author asks for feedback or a check, or types /review."
argument-hint: "<pass> <target> [marker] | gate <name> [target]"
allowed-tools: Read, Glob, Grep, Agent, Bash(bash .claude/scripts/status.sh*), Bash(bash .claude/scripts/flow-check.sh*), Bash(bash .claude/scripts/flow-mark.sh *)
---
# /review <pass> <target> [marker] (spec §7.1, §4.3, §5.4)

Runs one pass from `.claude/reviews/`. The pass file holds the trigger, the
context, the prompt and the verdicts; **the agent reads it in its own
context**: you pass the file's path, the target and nothing else. That keeps
the main context small and the review independent of this conversation.

If `studio.yaml` does not exist, say the project is not set up and offer
`/start`. Nothing else.

## Passes

| Pass | Agent | Form | Target |
|---|---|---|---|
| `continuity` | `continuity-editor` | fiction | unit, chapter, `manuscript` |
| `citation` | `continuity-editor` | non-fiction | section, work |
| `developmental` | `developmental-editor` | both | unit/section, chapter, `manuscript`/work |
| `line` | `line-editor` | both | unit/section; chapter or work as a pattern survey |
| `grammar` | `grammar-editor` | both | unit/section, chapter, work |
| `beta` | `beta-reader` | both | chapter, `manuscript`, work (a unit works but says little) |
| `milestone` | `developmental-editor` | both | `manuscript` (fiction) or a work: always the whole |

`/cite-check` and `/continuity-check` are the grep-first scans; this skill
runs the agent passes.

## 1. Arguments

- **No arguments:** list the passes for this form with one line each, and
  suggest one from where things stand (run `bash .claude/scripts/status.sh`:
  the first incomplete phase's `next`, and any check due at this rigour).
  Ask; do nothing else.
- **`<pass>`** must be one of the seven. A pass for the other form
  (`continuity` on non-fiction, `citation` on fiction): say which pass does
  that job here and stop.
- **`<target>`** — resolved as `/draft` resolves it (`.claude/skills/draft/
  SKILL.md`, *Arguments*), plus `manuscript` (fiction, everything) and a
  chapter or work slug. Ask if ambiguous; never guess. Omitted: `milestone`
  takes `manuscript` (fiction) or `session/current-work`; any other pass
  proposes the unit in the checkpoint and asks.
  - `milestone` on anything less than the whole: say it always reviews the
    whole and offer it on the whole.
  - A target with no prose yet (no unit files): say there is nothing to
    review.
- **`marker`** — only with `beta`, only on a non-fiction work whose
  `brief.md` has marking criteria; otherwise say so (the agent falls back to
  the reader persona). Any other third word: say `marker` is the only
  persona word in v1 and that `studio.yaml` → `reviews.beta_persona` sets a
  standing persona.

## 2. Before launching

1. **Assessed work** (`work.yaml` → `assessed: true`): show `policy`,
   verbatim, first (§5.4). The cap limits what reviews may *suggest*, never
   whether they run.
2. **Prose level** for the target, with source and any cap, in one line: it
   decides what the agent produces (no rewritten text at `critic`/`coach`,
   numbered diffs at `editor` and above).
3. **`grammar` and `line`:** resolve the language pack for the target's
   language. No folder under `.claude/languages/`: there is no `grammar`
   pass; say so, offer `/language add <tag>`, and stop. `line` can still run
   (it uses the pack's `style.md` when there is one; say it has none).
4. **Locked or fenced text** in the target: say that findings there will be
   notes only.

## 3. Run the agent

Launch the pass's agent (the table above) with the Agent tool,
`subagent_type` = the agent's name. The prompt is only this:

> Run the review pass in `.claude/reviews/<pass>.md` on: `<target path(s)>`.
> Today's date: `<YYYY-MM-DD>`. [Persona: `marker`.]
> Return the complete report as Markdown in the shape of
> `.claude/templates/shared/review-report.md`. Do not write any files.

Target paths: a unit's or section's file; a chapter's folder
(`manuscript/<chapter>/`); `manuscript/`; a work's folder (`works/<work>/`).
Do not paste file contents, your own opinions or this conversation into the
prompt.

## 4. Check what came back

- Exactly one verdict line at the start of a line: `**Verdict:** APPROVE`,
  `**Verdict:** CONCERNS [n]` or `**Verdict:** REJECT [n]` — gates may also
  return `**Verdict:** NOT ASSESSED` (`workflow.yaml` and `/status` match
  them). If it is missing or malformed, send the agent a
  follow-up asking for the corrected line; never set a verdict yourself.
- The header has the date, agent, language and pack with support level
  (user-defined: the reliability notice kept), prose level with any cap,
  rigour, and an assessed work's policy.
- At `critic`/`coach`, no rewritten text in the findings (a labelled
  *Illustration* on invented text is allowed at `coach`). If there is any,
  ask the agent to remove it.

Otherwise the report is the agent's: do not edit its findings or verdict.

## 5. Present, then write

Show the verdict, the summary and the findings (severity, location, one
line each); offer the full report if it is long. Verdicts are **advisory**:
say what they mean, never that the author must act.

**File name:** `<pass>-<target-slug>-<YYYY-MM-DD>.md`; if that exists, append
`-2`, `-3`, … (the next free number). Reports are never overwritten or edited
after writing.

| Target | Folder | `<target-slug>` |
|---|---|---|
| fiction unit `ch03-the-storm/sc02-the-dock` | `reviews/` | `ch03-the-storm-sc02-the-dock` |
| fiction chapter | `reviews/` | `ch03-the-storm` |
| whole manuscript | `reviews/` | `manuscript` |
| non-fiction section `<work>/03-objections` | `works/<work>/reviews/` | `03-objections` |
| whole work | `works/<work>/reviews/` | `<work>` |

The whole-work slug is the work slug itself: `workflow.yaml` counts only
`developmental-<work>-<date>.md` towards the `revision` phase, so a section
report never completes it.

Ask **"May I write this report to `<path>`?"** and write it exactly as
returned. If the author declines, nothing is written; the findings stay in
the conversation.

## 6. Afterwards

Offer, don't do:

- **Numbered diffs** (`line`, `grammar` at `editor` and above): offer to apply
  the ones the author accepts, as `/draft` does at `editor` level — "Which of
  these may I apply to `<path>`?", then one Edit per accepted diff. Never at
  `critic`/`coach`, never in a locked file or an author fence.
- **Registry lines** (`continuity`) or **claims and `used_in` updates**
  (`citation`): offer each as a write to `bible/registry.yaml` or
  `compendium/claims.yaml`, with approval (a canon change always asks).
- **Next pass:** the one the report names, if any.

Rewrite the checkpoint (fiction `session/active.md`, non-fiction
`works/<work>/checkpoint.md`; no "May I write?" needed) with the review and
its verdict.

Then name **one** next step:

- `milestone` or whole-work `developmental` with `CONCERNS` or `REJECT`:
  revising what the report names first — the unit it ranks highest, as
  `/draft <key>` (at `critic`/`coach`: "Revise `<path>`, then type
  `/draft <key> done`.") — then the same review again.
- Any other pass: the next pass the report names, if any, else the step
  `bash .claude/scripts/flow-check.sh` (non-fiction: `… <work>`)
  recommends.

End with exactly one line, "Type `<command>` to begin.", and never
invoke it.

## Gates — `/review gate <name> [target]` (development-flow §11)

Development gates are review passes under `.claude/reviews/gates/`, run
exactly as above (§2–§5) with these differences:

| Gate | Form | Agent | Target | Report | Progress step |
|---|---|---|---|---|---|
| `premise` | fiction | `developmental-editor` | `bible/brief.md` | `reviews/gate-premise-brief-<date>.md` | `premise-gate` |
| `cast` | fiction | `character-lead` | `bible/characters/` | `reviews/gate-cast-bible-<date>.md` | `cast-gate` |
| `spine` | fiction | `structure-architect` | `outline/structure.md` | `reviews/gate-spine-structure-<date>.md` | `spine-gate` |
| `question` | non-fiction | `developmental-editor` | `works/<work>/` | `works/<work>/reviews/gate-question-<work>-<date>.md` | `question-gate` |
| `argument` | non-fiction | `structure-architect` | `works/<work>/outline.md` | `works/<work>/reviews/gate-argument-<work>-<date>.md` | `argument-gate` |

- **Name and target.** No name, or a gate for the other form: list the gates
  for this form. Non-fiction takes the work as target (default
  `session/current-work`); fiction gates have a fixed target. A gate file
  that does not exist: say so and stop.
- **Rigour.** Gates are recommended at `full` and run on request at any
  rigour; say so if the author runs one below `full`, then run it.
- **Prompt:** "Run the gate in `.claude/reviews/gates/<name>.md` on: `<target>`.
  Today's date: `<YYYY-MM-DD>`. Return the complete report as Markdown in the
  shape of `.claude/templates/shared/review-report.md`. Do not write any
  files."
- **`NOT ASSESSED`** is not a pass and not a failure: name the missing input
  the report gives and how to supply it (usually the skill that writes it).
- **Recording the step.** Once the author has seen a verdict other than
  `NOT ASSESSED` — whatever it is; gates are advisory — run `bash
  .claude/scripts/flow-mark.sh <progress step> done [work]` and say so, whether
  or not the report is written. On `CONCERNS` or `REJECT`, offer to revisit
  what the report names; going on anyway is the author's call.
- Then hand off as every skill does: the next step from `flow-check.sh`,
  "Type `<command>` to begin."
