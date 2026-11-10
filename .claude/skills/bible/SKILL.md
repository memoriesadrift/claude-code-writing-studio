---
name: bible
description: "Fiction - create or extend a story-bible entry (character, place, world rule, timeline, style guide) from its template, and keep bible/registry.yaml in step - ids, aliases, facts with canon levels. Items, organisations and events are registry entries only. Never overwrites established canon. Use when the author wants to record or develop a character, place, rule or the timeline, or types /bible."
argument-hint: "<character | place | rule | timeline | style | item | org | event> [name]"
allowed-tools: Read, Glob, Grep, Bash(bash .claude/scripts/status.sh*)
---
# /bible <kind> [name] (spec §8.2, §2 principle 4, §4.3, §9)

The bible and its registry are the canon that continuity is checked against.
Follow `.claude/rules/bible.md`. The bible is not prose: Claude may write it
at any prose level, but every file only after **"May I write this to
`<path>`?"**, and **every change to canon asks, in every automation mode**.

If `studio.yaml` does not exist, say the project is not set up and offer
`/start`. On a non-fiction project, say the equivalent is `/compendium`.
Nothing else.

## Kinds

| Kind | File | Template | Registry |
|---|---|---|---|
| `character` | `bible/characters/<slug>.md` | `character.md` | `char-<slug>` |
| `place` | `bible/world/places/<slug>.md` | `place.md` | `place-<slug>` |
| `rule` | `bible/world/rules/<slug>.md` | `world-rule.md` | `rule-<slug>` |
| `timeline` | `bible/timeline.md` | `timeline.md` | — (events may get `event-` ids) |
| `style` | `bible/style-guide.md` | `style-guide.md` | — |
| `item`, `org`, `event` | — (registry only) | — | `item-` / `org-` / `event-<slug>` |

Templates are in `.claude/templates/fiction/`. `timeline` and `style` take no
name. No kind, or an unknown one: list the kinds and ask. A kind and no name
(where one is needed): ask for it, or offer the candidates the registry and
manuscript suggest (names the text uses that have no entry yet).

**Slugs and ids:** lower-case ASCII, hyphens, from the name the author uses
(`Mara Venn` → `mara-venn`, `char-mara-venn`; transliterate accents:
`Ödön` → `odon`). Ids are permanent: they are linked from other entries
(`[[char-mara-venn]]`), the registry and reviews. Check the id is not taken.

## 1. Look first

Read `bible/registry.yaml` (the entity, if it exists), the entry file if it
exists, `bible/brief.md`, and what the manuscript says: grep it for the name
and every alias, and read the hits. Facts the author has already written are
the source; extract them and propose them, citing the unit (`<chapter>/<unit>`)
each comes from. **Never ask the author to fill in the template.**

- **Entry exists:** this is an extension. Ask what to develop (offer the
  sections that are empty or thin), and work only on those.
- **Registry entity exists but no file** (or the reverse): say so; the new
  file and the registry entry are brought into step as part of this run.
- **Same name, different id** (a duplicate in the making): say so and ask.

## 2. New entry: skeleton first

Fill the frontmatter (`id`, `canon: provisional`, `aliases` the manuscript
already uses, `updated:` today) and the headings; sections you can already
fill from the manuscript or conversation get a proposal, the rest
`<!-- to decide -->`. Show it; **"May I write this to `<path>`?"**; write it.

Then section by section, in the template's order, one round each (ask,
propose, revise, approve, write). Kind-specific care:

- **Character:** the *Voice profile*'s sample lines are **the author's own
  lines**, quoted from the manuscript with their location — never invented.
  If there are none yet, leave it to decide. *Secrets and mysteries* record
  the true answer even if the book never reveals it; if the author has not
  decided, say the mystery is open.
- **Place:** distances and travel times to other places are facts continuity
  checks rely on; ask for them when the story moves between places.
- **World rule:** the *Statement* is one or two unambiguous sentences a scene
  can be tested against. If the author's version is vague, show what a scene
  could do that it neither allows nor forbids, and ask. Limits, costs and
  exceptions are required (an exception may be "none").
- **Timeline:** rows, earliest first; *On the page* rows link the unit that
  shows the event. Relative dates are fine. Propose rows from the manuscript
  and the bible; flag rows that conflict (two dates for one event) instead of
  choosing.
- **Style:** from `studio.yaml` → `style` and from the author's own passages
  (quote them with locations as reference passages). Language conventions
  (spelling, punctuation, typography) belong to the language pack, not here;
  say so if the author starts listing them.

Doc density follows `modes.rigour` (terse bullets · bullets + rationale ·
rationale + alternatives).

## 3. Registry in step

Whenever an entry gains or changes **facts or aliases**, propose the matching
`bible/registry.yaml` change **in the same round**, as ready-to-add YAML:

```yaml
  - id: char-mara-venn
    name: "Mara Venn"
    aliases: ["Mara", "the Venn girl"]
    bible: bible/characters/mara-venn.md
    facts:
      - key: eye_colour
        value: grey
        canon: provisional
        source: ch01-arrival/sc02-the-dock
        note: null
```

Each file gets its own approval: first the entry, then **"May I write this to
`bible/registry.yaml`?"**. Keep the rest of the registry byte for byte; add
the entity in id order if the file is sorted, else at the end.

- `source` is the unit that first states the fact (`<chapter>/<unit>`), or
  the bible entry when the fact was settled in conversation.
- **Aliases:** every form the manuscript uses, since continuity checks search
  for them. Warn if an alias is already another entity's.
- **Registry-only kinds** (`item`, `org`, `event`): an entity with
  `bible: null`; a one-line description goes in a fact with key
  `description`. An `event` may also get a row in `bible/timeline.md`
  (offered, with approval).

## 4. Canon

- New entries and facts are `provisional`. **Only the author promotes**
  anything to `established`; ask when they say a fact is settled, and change
  only what they named.
- **Never overwrite an `established` fact.** If the author's new version
  contradicts one, or the manuscript does, show both versions with where each
  appears and ask: keep the established one (the new text is then a
  continuity problem), change it (the old value goes in the fact's `note`
  with the date), or mark the fact `under-review` until decided.
- Changing a `provisional` fact still asks; say which units state the old
  value (grep the aliases) so the author can see what the change touches.

## 5. Finish

- Rewrite the checkpoint `session/active.md` (no "May I write?" needed) if
  this was part of the current task or decided something.
- Offer `/continuity-check` when facts changed that the manuscript already
  states.
