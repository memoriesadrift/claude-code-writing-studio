---
paths:
  - "works/*/brief.md"
  - "works/*/work.yaml"
  - "works/*/checkpoint.md"
---
# Work files (non-fiction; spec §4.2, §5.4, §6.5)

## `brief.md`

- **Assignment and marking criteria are verbatim**, as the author gave them;
  never paraphrase or tidy them.
- **The research question is versioned.** The current question or thesis is
  always at the top as `**vN** (date): …`; each revision moves the old
  wording into *History* (newest first) with a one-line reason. Revising it
  is a normal step, never an error. Claude may suggest a revision when the
  drafting or research has moved past it; the author decides.
- When the version changes, the outline's *Research question in force* line
  is updated too (with approval).

## `work.yaml`

- Keys are fixed, British-spelt identifiers (`.claude/templates/nonfiction/work.yaml`);
  no new keys.
- **Prose levels are never set here**: they live only in `studio.yaml` →
  `prose`. `assessed` and `assessed_cap` are read here for the integrity cap.
- **Never raise `assessed_cap` or set `assessed: false` as a convenience.**
  Only the author changes these, deliberately; no skill offers it.
- `policy` is the author's AI-use policy, verbatim.
- Hook-read lines (`assessed`, `assessed_cap`, `word_limit`) stay flat:
  `key: value` on one line, no flow collections, quotes only around the
  whole value.
- `status` (`brief | draft | revision | complete`) is changed by the author
  or with their approval; marking a work `complete` triggers the citation
  check (advisory).

## `checkpoint.md`

The work's "where I am" note (≤ 25 lines; template
`.claude/templates/shared/checkpoint.md`), overwritten at every milestone.
No "May I write?" is needed. Also keep `session/current-work` naming the
work in progress.
