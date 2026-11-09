---
paths:
  - "manuscript/**"
  - "works/*/sections/**"
---
# Prose files (spec §5, §9)

These are prose files: the author's text. The prose-guard hook enforces the
hard limits; this rule is the contract behind it.

## Before touching the file

1. **Resolve the prose level** for this exact file (CLAUDE.md, "The prose
   ladder"; spec §5.1): the most specific `studio.yaml` → `prose.overrides`
   key, else `prose.level`. Non-fiction with `work.yaml` → `assessed: true`:
   cap at the work's `assessed_cap`, else `integrity.assessed_cap`, else
   `coach`. The cap is a ceiling; never offer to raise it.
2. **Say the level and where it came from** when it matters to what you are
   about to do (e.g. "`coach` from `prose.overrides` `ch07`").
3. **Assessed work:** show the work's `policy` (from `work.yaml`, verbatim)
   before drafting or reviewing it.

## What each level allows in this file

| Level | In this file |
|---|---|
| `critic` | Nothing. Feedback names the problem; it goes in the conversation or `reviews/`, never as rewritten text |
| `coach` | Nothing. Short technique illustrations, labelled, in the conversation or `reviews/` only |
| `editor` | Line-level edits as a numbered list of diffs; apply each only when accepted, one at a time. No new passages |
| `co-author` | Whole units drafted from the author's card or outline, each shown and approved before writing |
| `ghostwriter` | Whole chapters or works, unit by unit, each approved |

Every write asks "May I write this to `<path>`?" (CLAUDE.md), at every level
and in every automation mode.

## At every level

- Never edit a file whose frontmatter has `locked: true`.
- Never edit inside `<!-- author -->` … `<!-- /author -->`; keep fenced text
  byte for byte in any whole-file write.
- No unrequested rewrites: change only what was asked for or accepted.
- Keep the frontmatter: `prose: author | claude | mixed` and `locked`.
  A unit Claude drafts is `prose: claude`; once both have written in it,
  `mixed`. Never change `locked`.

## When writing or suggesting prose (`editor` and above)

- Read the language pack first: `.claude/languages/<lang>/conventions.md` and
  the overlay `variants/<tag>.md` for the tag in force (work.yaml `language`,
  else `studio.yaml` → `language.default`), with the options in force
  (`pack.yaml` gives the order). If no pack exists for the tag, say so.
- Follow the style guide (`bible/style-guide.md`, fiction) and
  `studio.yaml` → `style`: fiction `pov` and `tense`, `register`.
- Fiction: stay consistent with `bible/registry.yaml` and the voice profiles
  in `bible/characters/`. Non-fiction: see the citations rule.
- Drafting is done in the main session via `/draft`, from the scene card or
  outline section; never draft a unit that has neither.

## After a unit is written ("unit done")

Rewrite the checkpoint (fiction `session/active.md`, non-fiction
`works/<work>/checkpoint.md`) and offer, for approval, what `modes.rigour`
calls for (spec §4.3): registry lines or claims extracted from the text,
the outline `status:` update, and the checks due at this rigour.
