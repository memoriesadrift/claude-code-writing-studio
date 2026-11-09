---
paths:
  - "outline/**"
  - "works/*/outline.md"
---
# Outlines (spec §4.3, §11)

Outlines are planning documents, not prose: Claude may write them at any
prose level, after "May I write this to `<path>`?". `/status` and
`.claude/workflow.yaml` read their structure, so keep it machine-readable.

- **One `### ` block per unit, in order.** Fiction: `### scNN-slug` in
  `outline/chapters/<chapter>.md`; non-fiction: `### NN-slug` in
  `works/<work>/outline.md`. The order of the blocks is the order `/publish`
  uses, and the slug is the unit's file name and override key.
- **Each block's first line is `status:`** — `planned`, `drafting`,
  `drafted` or `revised` — on its own line, unindented. The draft phase is
  complete when every block reads `drafted` or `revised`. Update it when a
  unit is approved and written.
- **Non-fiction blocks also carry `question: vN`**: the research-question
  version (from `brief.md`) the section was written under. Set it when the
  section is drafted; at `full` rigour, sections under an older version are
  listed for re-reading.
- **Departures:** when a draft departs from the outline, offer an update
  (`standard`), and at `full` rigour also an entry under *Departures from
  this outline*. The outline follows the draft, not the other way round.
- Templates: `.claude/templates/fiction/structure.md`,
  `.claude/templates/fiction/chapter-card.md`,
  `.claude/templates/nonfiction/outline.md`.
