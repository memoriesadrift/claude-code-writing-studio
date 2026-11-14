---
paths:
  - "reviews/**"
  - "works/*/reviews/**"
---
# Review reports (spec §7.1)

- **Template:** `.claude/templates/shared/review-report.md`. File name
  `<pass>-<target-slug>-<YYYY-MM-DD>.md`; a second run the same day appends
  `-2`, `-3`.
- **Header:** date, agent, language tag and pack with its support level,
  prose level in force (with any cap), rigour. A user-defined pack keeps the
  reliability notice. An assessed work shows its `policy` verbatim.
- **Verdict line**, exactly `**Verdict:** APPROVE`, `**Verdict:** CONCERNS [n]`
  or `**Verdict:** REJECT [n]` at the start of a line: `workflow.yaml`
  matches it. Development gates (`.claude/reviews/gates/`, file names
  `gate-<name>-<target>-<date>.md`) may also return
  `**Verdict:** NOT ASSESSED` — a missing input, never a pass. Verdicts are
  advisory; nothing hard-blocks the author.
- **Findings at `critic` and `coach`** name the problem, its location and why
  it matters, never rewritten text. `coach` may add a short technique
  illustration, labelled as such. At `editor` and above, suggested edits are
  numbered diffs, not applied.
- **Reports are never edited after writing.** A re-run writes a new report;
  the old one stays as history.
- Reports are not prose: Claude writes them at any level, after "May I write
  this to `<path>`?".
