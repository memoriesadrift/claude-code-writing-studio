# Review pass: continuity (fiction)

**Agent:** `continuity-editor` · **Form:** fiction · **Spec:** §4.3, §7.1

## Trigger

| Rigour | When |
|---|---|
| `minimal` | On request (`/review continuity <target>`, `/continuity-check`) |
| `standard` | At "unit done", and on request |
| `full` | At "unit done", and on request |

Target: a unit (`manuscript/<chapter>/<unit>.md`), a chapter
(`manuscript/<chapter>/`) or `manuscript` (everything).

## Context to pass

The orchestrating skill passes this file's path and the target path(s), and
nothing else; the agent reads the rest in its own context:

- `bible/registry.yaml` — entities, aliases, facts with canon levels
- `bible/timeline.md`, `bible/style-guide.md` (POV, tense)
- the bible entries of every entity the target mentions
  (`bible/characters/`, `bible/world/places/`, `bible/world/rules/`)
- the target's scene cards (`outline/chapters/<chapter>.md`)
- earlier units, only where a grep hit needs them

## Prompt

1. List the entities the target mentions: grep the target for every alias in
   the registry. Report names in the text that look like entities but are not
   in the registry as registry candidates, not errors.
2. For each entity, check every statement in the target against its registry
   facts and bible entry: names and spellings, physical facts, relationships,
   who knows what at this point, possessions.
3. Timeline: dates, ages, durations, day/night, travel times against
   `timeline.md` and the previous units in order.
4. World rules: every use of a rule respects its statement, limits, costs and
   exceptions.
5. POV and tense against the style guide; a POV character never knows what
   they cannot know.
6. Within the target: internal contradictions (a character in two places,
   an object that changes hands without being passed).
7. Propose registry lines for new facts the target states (`key`, `value`,
   `canon: provisional`, `source: <chapter>/<unit>`) and new aliases.

Severity: `error` contradicts an `established` fact or world rule, or is an
internal contradiction; `concern` contradicts a `provisional` or
`under-review` fact, or is a timeline strain; `note` is a registry candidate
or something to keep an eye on. Every finding gives both locations: the
target line and the registry or bible line it conflicts with. A finding never
resolves the conflict — the author decides which version is canon.

## Verdicts

- `**Verdict:** APPROVE` — no `error` or `concern` findings (notes and
  registry proposals allowed).
- `**Verdict:** CONCERNS [n]` — no `error`; `n` `concern` findings.
- `**Verdict:** REJECT [n]` — `n` `error` findings: the target contradicts
  established canon or itself.

## Report

Template `.claude/templates/shared/review-report.md`, written to
`reviews/continuity-<target-slug>-<YYYY-MM-DD>.md` after "May I write?".
Registry proposals go under *Suggested next step*, as lines ready to add.
