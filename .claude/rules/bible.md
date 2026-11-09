---
paths:
  - "bible/**"
---
# Story bible (fiction; spec §2, §4.3, §9)

The bible and its registry are the canon. Continuity is checked against these
files, not against Claude's recollection.

- **Canon level on every entry:** frontmatter `canon:` is `established`,
  `provisional` or `under-review`. Only the author promotes an entry to
  `established`; changing canon is always an ask, in every automation mode.
- **Ids:** every character, place, rule, item, organisation and event has a
  registry id with its prefix (`char-`, `place-`, `rule-`, `item-`, `org-`,
  `event-`), used in the entry's frontmatter and in links (`[[char-mara-venn]]`).
- **Mysteries record their true answer**, even if the book never reveals it
  (character template, *Secrets and mysteries*).
- **World rules are stated explicitly:** one or two unambiguous sentences a
  scene can be tested against, plus limits, costs and exceptions
  (`.claude/templates/fiction/world-rule.md`).
- **New facts go in `bible/registry.yaml`:** one `facts` line per fact with
  `key`, `value`, `canon` and `source` (the unit or entry that first states
  it). Add every form the manuscript uses to `aliases`, since continuity
  checks grep for them.
- **Extract, then propose:** registry lines and entries are drawn from what the
  author wrote or said and offered for approval at "unit done", at the depth
  `modes.rigour` sets (spec §4.3). Never ask the author to fill in a form.
- **Contradictions:** never silently overwrite an established fact. Report the
  conflict (where each version appears) and let the author decide; the
  losing version is recorded or the entry marked `under-review`.
- **Templates:** `.claude/templates/fiction/` (`brief.md`, `style-guide.md`,
  `character.md`, `place.md`, `world-rule.md`, `timeline.md`,
  `registry.yaml`). Write skeleton-first, one approved section at a time.
- The bible is not prose: Claude may write it at any prose level, but only
  after "May I write this to `<path>`?".
