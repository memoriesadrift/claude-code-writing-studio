<!--
Review report (spec §7.1). File name: <pass>-<target-slug>-<YYYY-MM-DD>.md
(a second run on the same day appends -2, -3…). Reports are never edited
after writing; a re-run writes a new report.
-->
# {{pass}} review — {{target}}

**Date:** {{date}}
**Agent:** {{agent}}
**Language:** {{language_tag}} · pack `{{pack}}` ({{support_level}})
**Prose level in force:** {{prose_level}}{{cap_note}}
**Rigour:** {{rigour}}
**Verdict:** {{verdict}}

<!-- Verdict is exactly one of: APPROVE · CONCERNS [n] · REJECT [n] -->
<!-- If the pack is user-defined, keep the next line; otherwise delete it. -->
> Language pack is user-defined. Grammar checking is less reliable in
> lower-resource languages; treat findings as prompts to check, not rulings.

<!-- Non-fiction, assessed work: the work's policy, verbatim. -->
> **Policy:** {{policy}}

## Summary
{{summary}}

## Findings

| # | Severity | Location | Finding |
|---|---|---|---|
| 1 | {{error \| concern \| note}} | {{file:line or section}} | {{what is wrong and why — never rewritten text at critic/coach}} |

## Strengths
- {{strength}}

## Suggested next step
{{next_step}}
