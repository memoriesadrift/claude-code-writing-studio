# Templates

Skeletons the skills copy from. `{{name}}` marks a value the skill fills in;
`<!-- … -->` comments are guidance for Claude and are removed when the file is
written. Every document is written skeleton-first, then one approved section
at a time (spec §2).

| Template | Written by | Target |
|---|---|---|
| `shared/studio.yaml` | `/start` | `studio.yaml` |
| `shared/checkpoint.md` | `/start`, `/new-work`, every milestone | `session/active.md` (fiction), `works/<work>/checkpoint.md` (non-fiction) |
| `shared/review-report.md` | `/review`, `/continuity-check`, `/cite-check` | `reviews/` or `works/<work>/reviews/` |
| `shared/ideas-session.md` | `/brainstorm`, `/cast`, `/world`, `/plot`, `/start` | `ideas/<YYYY-MM-DD>-<slug>.md` |
| `shared/writer.md` | `/brainstorm` | `ideas/writer.md` |
| `shared/ideas-parked.md` | `/start` | `ideas/parked.md` |
| `shared/ideas-questions.md` | `/start` | `ideas/questions.md` |
| `fiction/brief.md` | `/premise` | `bible/brief.md` |
| `fiction/style-guide.md` | `/premise`, `/bible style-guide` | `bible/style-guide.md` |
| `fiction/character.md` | `/cast`, `/bible character` | `bible/characters/<slug>.md` |
| `fiction/place.md` | `/world`, `/bible place` | `bible/world/places/<slug>.md` |
| `fiction/world-rule.md` | `/world`, `/bible rule` | `bible/world/rules/<slug>.md` |
| `fiction/timeline.md` | `/bible timeline` | `bible/timeline.md` |
| `fiction/registry.yaml` | `/start` | `bible/registry.yaml` |
| `fiction/structure.md` | `/plot` (*Shape*, *Spine*, acts, promises), `/outline` (chapter list) | `outline/structure.md` |
| `fiction/chapter-card.md` | `/outline` | `outline/chapters/<chapter>.md` |
| `fiction/unit.md` | `/draft` | `manuscript/<chapter>/<unit>.md` |
| `nonfiction/work.yaml` | `/new-work` | `works/<work>/work.yaml` |
| `nonfiction/brief.md` | `/new-work` | `works/<work>/brief.md` |
| `nonfiction/outline.md` | `/outline <work>` | `works/<work>/outline.md` |
| `nonfiction/section.md` | `/draft` | `works/<work>/sections/<nn-slug>.md` |
| `nonfiction/source-note.md` | `/source` | `compendium/sources/<citekey>.md` |
| `nonfiction/concept.md` | `/compendium concept` | `compendium/concepts/<slug>.md` |
| `nonfiction/position.md` | `/compendium position` | `compendium/positions/<slug>.md` |
| `nonfiction/note.md` | `/compendium note` | `compendium/notes/<date>-<slug>.md` |
| `nonfiction/claims.yaml` | `/start` | `compendium/claims.yaml` |
| `nonfiction/library.bib` | `/start` | `compendium/library.bib` |

**Prose units** (`fiction/unit.md`, `nonfiction/section.md`) carry only
frontmatter and prose. In a `mixed` file, author-owned passages may be fenced
with `<!-- author -->` … `<!-- /author -->`; Claude never edits inside a fence,
and never edits a file with `locked: true` (spec §5.3).

Fields marked *hook-read* follow the flat subset in spec §10.1: `key: value`
on one line, block style, no flow collections, anchors or multi-line strings.
