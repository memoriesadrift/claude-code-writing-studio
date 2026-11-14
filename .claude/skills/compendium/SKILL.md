---
name: compendium
description: "Non-fiction - create or extend a compendium entry - a concept (how authors use a term), a claim in claims.yaml (with support, objections and locators), a position (a debate, its sides and the author's own view) or a raw note (lecture, seminar, reading) - and keep links two-way between claims, source notes, concepts and positions. Use when the author wants to record a term, claim, debate or notes, or types /compendium."
argument-hint: "<concept | claim | position | note> [name]"
allowed-tools: Read, Glob, Grep, Agent
---
# /compendium <kind> [name] (spec §8.3, §6.1, §6.2)

The compendium is the shared knowledge base for every work. Follow
`.claude/rules/compendium.md`. Compendium files are not prose: this works at
every prose level, every file only after **"May I write this to `<path>`?"**.
For an assessed work, whether compendium help is allowed is the author's call
under its `policy`; if the entry is for one, show the policy verbatim.

If `studio.yaml` does not exist, say the project is not set up and offer
`/start`. On a fiction project, point to `/bible`. Nothing else.

## Kinds

| Kind | File | Template |
|---|---|---|
| `concept` | `compendium/concepts/<slug>.md` | `concept.md` |
| `claim` | an entry in `compendium/claims.yaml` | `claims.yaml` (header comment) |
| `position` | `compendium/positions/<slug>.md` | `position.md` |
| `note` | `compendium/notes/<YYYY-MM-DD>-<slug>.md` | `note.md` |

Templates are in `.claude/templates/nonfiction/`. No kind or an unknown one:
list the kinds and ask. Slugs are lower-case ASCII with hyphens; check the
slug is free (an existing entry means this is an extension: work only on the
sections the author wants to develop).

## Ground rules

- **Sources only from source notes.** Every citation in an entry is a citekey
  with a note in `compendium/sources/`, and every locator comes from the note
  (or from the archived copy, read for the purpose). A source that has no note
  is a gap: say so and offer `/source`; never invent a key, author or page.
  Unverified sources may appear in entries (mark them `unverified`): they
  cannot be cited in prose until the author verifies them.
- **What sources say versus what the author thinks:** keep the author's own
  view in its labelled place (a position's *Author's view*, a concept's
  *Working definition* as "the definition the author uses"), in their words.
- **Extract, then propose.** Draw entries from what the author said, their
  notes and their source notes; never ask them to fill in a template.
- **Two-way links.** Whenever an entry links to another, propose the matching
  link on the other side in the same round, each file with its own approval:
  - claim `support` / `against` `cite:` ↔ the source note's *Links → Claims*;
  - concept ↔ claims and positions that use it (*Links* on both sides);
  - position *Sides → Claims* ↔ the claim; position ↔ *Works using this*.
- For a large compendium, launch `librarian` with the Agent tool to gather
  what the source notes say on the entry's subject ("collect, with citekeys
  and locators, what the source notes say about <subject>; do not write
  files"), and draft from its answer.

Doc density follows `modes.rigour` (terse bullets · bullets + rationale ·
rationale + alternatives).

## Concept

*Working definition* (the author's, and which source it follows), *Usage by
author* (one line per source, with locator), *Distinctions and confusions*,
*Links*. Skeleton first, then a section per round.

## Claim

Read `compendium/claims.yaml`. Propose:

```yaml
- id: C-<nnn>            # next number after the highest id in the file
  statement: "<one sentence>"
  kind: source-claim     # source-claim | empirical | author-position
  support: [{cite: <key>, loc: "<locator>"}]
  against: []            # a contested claim lists both sides
  status: established    # established | contested | author-position
  used_in: []            # <work>/<section>; maintained by /draft and the citation check
```

- **Ids are never reused.** Take the highest `C-<nnn>` in the file plus one.
  Never delete a claim that a work has used (`used_in` non-empty): say what
  relies on it and let the author decide what to change.
- `status: contested` needs both `support` and `against`; if only one side is
  known, say so and keep it `established` or `contested` as the author decides.
- `kind: author-position` has the author's own argument as support (it may
  have no `cite:`); say that it is theirs to defend.
- Check for a near-duplicate statement first; offer to extend it instead.
- Append to the list (or replace the `[]` of an empty file), leaving every
  other line byte for byte. Then the two-way links.

## Position

The debate as a question; one block per side (*Held by* with citekeys and
locators, *Core argument*, *Claims*); *State of the debate*; *Author's view*
(theirs, or "undecided"); *Links*. A contested question lists **every** side
the source notes show, not only the one the author holds.

## Note

Raw notes, kept close to how the author gave them (pasted text, dictated
points). Front matter `date`, `kind` (`lecture` · `seminar` · `reading` ·
`idea` · `other`), `context`, `tags`. You may tidy layout (headings, bullet
indentation) but **add no content**. List what could become a claim, concept
or source under *To process* as unchecked boxes, and offer to process them
one by one with this skill or `/source`. Existing notes are edited only on
request.

## Finish

Say what was written and which links were made on both sides. Rewrite the
current work's checkpoint if this served its task (no "May I write?"
needed).

**Hand back** (a lookup skill: back to the work, not on to a new step): end
with exactly one line, "Type `<command>` to begin.", naming the way back to
the work in progress — the unit or step the checkpoint names (`/draft
<key>`, `/outline <work>`), or `/source` when a claim just written cites a
source that has no note yet. Never invoke it.
