---
name: continuity-check
description: "Fiction - grep-first scan of the manuscript (or a chapter or unit) against bible/registry.yaml - where each entity is mentioned, registry problems (duplicate ids, shared aliases, missing bible entries, fact sources that don't exist), entities never mentioned - then a conflict report from reading only the passages the scan points to. Use when the author asks for a continuity check, or types /continuity-check."
argument-hint: "[unit | chapter]"
allowed-tools: Read, Glob, Grep, Bash(bash .claude/scripts/continuity-scan.sh*)
---
# /continuity-check [scope] (spec §8.2, §2 principles 4 and 6)

Canon is explicit: the manuscript is checked against `bible/registry.yaml`
and the bible, never against recollection. The helper script reports facts;
you judge them.

If `studio.yaml` does not exist, say the project is not set up and offer
`/start`. On a non-fiction project, say this is a fiction check and point to
`/cite-check`. Nothing else.

This is the quick, grep-first check. For a full judgement of a unit or chapter
(timeline, who knows what, world rules, POV) offer `/review continuity
<target>`, which runs `continuity-editor` in its own context.

## 1. Scope

- No argument: the whole manuscript (`manuscript`).
- A chapter or unit, resolved as `/draft` resolves it
  (`.claude/skills/draft/SKILL.md`, *Arguments*), turned into a path:
  `manuscript/<chapter>/` or `manuscript/<chapter>/<unit>.md`. Ask if
  ambiguous.
- No prose files in scope: say there is nothing to check.

## 2. Build the registry records

Read `bible/registry.yaml` yourself (it is full YAML). If it does not exist or
has no entities, say so: there is nothing to check against; offer `/bible`.
If it does not parse, say where and stop.

Turn it into tab-separated records, one per line:

```
entity<TAB><id><TAB><bible path, or ->
alias<TAB><id><TAB><text>                 one line for `name`, one per alias
source<TAB><id><TAB><fact key><TAB><source>   one per fact with a source
```

Pass the records exactly as the registry has them: do not add, drop or tidy
anything (a typo in an alias is a finding, not something to fix silently).
Tabs and newlines inside a value: replace with a space and say so.

## 3. Run the scan

```bash
bash .claude/scripts/continuity-scan.sh [summary] <path...> <<'EOF'
<records>
EOF
```

For the whole manuscript, run with `summary` first (counts only), then again
on the chapters or units you need to read. The output blocks:

- `## registry` — `error:` and `note:` lines about the registry itself:
  duplicate ids, ids not `<prefix>-<slug>`, one alias on two entities, a
  bible entry that does not exist, a fact whose source unit has no file.
- `## hits` — `entity: <id> <hits> <files>`, then `at: <id> <file>
  <lines> <aliases seen>`.
- `## absent` — entities with names or aliases and no hit in scope.

Matching is whole-word and case-sensitive (a lower-case alias also matches
capitalised); spelling variants the registry does not list are not found.

## 4. Read what the scan points to

For each entity with hits, read the lines given (with a few lines of context),
and compare what the text says with:

- the entity's registry facts and their canon level;
- its bible entry (`bible/characters/`, `bible/world/places/`,
  `bible/world/rules/`) and `bible/timeline.md`;
- other mentions in scope, in manuscript order (a fact stated two ways).

Look for: names and spellings (an alias used for the wrong entity, including
an alias the scan reports as shared), physical facts, relationships,
possessions, places and travel, ages and dates, and uses of world rules
against their limits. Read only what you need; never the whole manuscript in
one go.

Do **not** hunt for unregistered names by heuristic. Names the text uses that
are not in the registry are found by reading, at "unit done" and in `/review
continuity`; mention any you happen to see as registry candidates.

## 5. Report (in conversation)

In the interface language, with the review report's severities:

- `error` — contradicts an `established` fact or world rule, or the text
  contradicts itself; also registry errors from the scan (they make checks
  unreliable).
- `concern` — contradicts a `provisional` or `under-review` fact; a timeline
  strain; an alias shared by two entities.
- `note` — a registry candidate, an entity absent from the whole manuscript, a
  scan note.

Every finding gives **both locations**: the manuscript `file:line` and the
registry fact or bible line it conflicts with. Never resolve a conflict: the
author decides which version is canon. Group repeats (two or three instances
and a count).

Then the verdict as the continuity pass defines it
(`.claude/reviews/continuity.md`): `APPROVE` (no error or concern),
`CONCERNS [n]` or `REJECT [n]`. Advisory; nothing blocks the author.

## 6. Afterwards

Offer, don't do:

- **Save the report**, if the author wants it: in the shape of
  `.claude/templates/shared/review-report.md` (agent line: "main session —
  /continuity-check (grep-first)"), at
  `reviews/continuity-<target-slug>-<YYYY-MM-DD>.md` (slugs as `/review`
  names them: `manuscript`, `<chapter>`, `<chapter>-<unit>`; `-2`, `-3` for a
  same-day re-run), after **"May I write this report to `<path>`?"**. A saved
  report counts as a continuity review in `/status`.
- **Registry fixes and new lines** (aliases, facts, a corrected source):
  shown as ready-to-add YAML, written to `bible/registry.yaml` only after
  "May I write this to `bible/registry.yaml`?". A change to canon always
  asks, in every automation mode; never overwrite an `established` fact —
  record the conflict or mark the fact `under-review`, as the author decides.
- `/review continuity <target>` for the units with findings.

Rewrite the checkpoint `session/active.md` (no "May I write?" needed) if the
check changed what comes next.
