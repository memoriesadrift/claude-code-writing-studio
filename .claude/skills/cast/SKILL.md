---
name: cast
description: "Fiction - develop the cast from the brief - the protagonist in depth (want, need, wound, the lie they believe, the arc, what they would never do), the opposition with its own logic, supporting characters by the function the story needs, and how each relationship changes. character-lead generates the options each round per modes.ideas; the author chooses; each character becomes a bible entry with registry lines. Use when the author wants to build or rethink characters, or types /cast."
argument-hint: "[name | all]"
allowed-tools: Read, Glob, Grep, Agent, AskUserQuestion, Bash(bash .claude/scripts/status.sh*), Bash(bash .claude/scripts/flow-check.sh*), Bash(bash .claude/scripts/flow-mark.sh *)
---
# /cast [name | all] (development-flow §7.1, §11)

The `develop` phase's cast steps: `cast-core` (protagonist and opposition)
and `cast-full` (supporting cast and relationships). Everything is written in
v1 formats — character entries (`.claude/templates/fiction/character.md`)
and `bible/registry.yaml` lines — so continuity checks, `/draft` and the
reviews work unchanged. `.claude/rules/bible.md` applies, and every file is
written only after **"May I write this to `<path>`?"**.

If `studio.yaml` does not exist, say the project is not set up and offer
`/start`. On a non-fiction project, say characters are fiction and point to
`/compendium`. Nothing else.

## Who does what

- **`character-lead` generates** the options for each round, in its own
  context (*The round*, below). It reads the brief and the bible itself; you
  pass it paths, the round's topic and the author's words.
- **You facilitate:** present what it returns, take the author's choice,
  draft the entry sections from the choice, keep the registry in step, and
  record the session. You do not add options of your own to its set; if the
  author asks for more, run the round again with their steer.
- **The author decides** every creative choice, in every `modes.automation`
  setting.

## Settings

Read `studio.yaml`:

- **`modes.ideas`**, passed to `character-lead` each round:

  | `ideas` | What a round returns |
  |---|---|
  | `questions` | Two to four open questions that draw the answer out of the author; **no characters, wounds or arcs of Claude's own**. The entry is built from the author's answers |
  | `options` (default, also when unset) | Two or three distinct alternatives, each with what it commits the story to, and a recommendation |
  | `proposals` | One complete proposal and the main alternative in a line |

- **`modes.rigour`** sets the depth: `minimal` — the protagonist and the
  opposition only, in one round each, terse entries; `standard` — the
  protagonist and opposition in depth, supporting cast offered; `full` —
  everything below, rationale and alternatives in the entries, and the cast
  gate. Doc density follows it (terse bullets · bullets + rationale ·
  rationale + alternatives).
- **`project.form`** (`short`): the cast steps are optional for short
  fiction; say so once, then go on if the author wants.
- Talk in the interface language; entries are written in the prose language.

Ask fixed choices with the question tool (pick, combine, run again with a
steer; confirm a write); free answers in plain text. A dismissed question is
not an answer: ask again in plain text.

## Start

Read `bible/brief.md`, `bible/characters/*.md`, `bible/registry.yaml`,
`ideas/writer.md`, earlier `/cast` session files (`ideas/*.md` with
`skill: /cast`), `outline/structure.md` if it exists, and
`session/progress.yaml`. Grep the manuscript for the names the bible knows,
and note names it uses that have no entry: those characters already exist on
the page, and their facts come from there.

- **No brief:** the cast is built against the brief's want, need, stakes and
  ending intent. Say so and suggest `/brainstorm` (or `/premise`); if the
  author wants to go on, go on from what they tell you.
- **Arguments:**
  - none → the first part not yet done, in the order below (§1–§4), judged by
    the entries and `session/progress.yaml`; say where you are starting;
  - `<name>` → that character: an existing entry is extended (ask which
    sections; work only on those), a new one starts at the round that fits
    its role;
  - `all` → show the cast as it stands (name, role, function, what is to
    decide, one line each) and ask what to work on.
- **Existing entries are never started over.** Sections already written stay
  byte for byte unless the author asks to revise them; `established` facts
  follow `/bible`'s canon rules (`.claude/skills/bible/SKILL.md` §4).

## The round

Each creative decision is one round:

1. Launch `character-lead` with the Agent tool:

   > Cast round for `/cast`. Read `studio.yaml`, `bible/brief.md`,
   > `bible/characters/`, `bible/registry.yaml`, `ideas/writer.md`
   > [and `<session file>`]. Round: `<topic>`. The author has said, quoted:
   > `<their words, or "nothing yet">`. `modes.ideas` is `<mode>`: return
   > [questions → two to four open questions, no content of your own |
   > options → two or three distinct alternatives, each a short card with
   > what it commits the story to, and your recommendation | proposals → one
   > complete proposal and the main alternative in a line]. Check each
   > against the brief's want, need, stakes and ending intent. Do not write
   > files.

2. Show what it returns, labelled `(Claude)`. The author picks, combines,
   rewrites, or asks for another run with a steer.
3. Draft the entry section(s) from the choice — the author's words where they
   gave them — and show them.

Keep rounds few: a round can cover several sections when they hang together
(want, need and wound; lie, truth and path).

## 1. Protagonist (`cast-core`)

The entry in the brief's protagonist (`char-<slug>`, from the name the
author uses; ask for a name if there is none, or offer that it stays a
working name).

1. **Want, need, wound.** The want and need start from the brief — confirm
   or deepen them, never contradict the brief silently (offer the brief
   change instead, with `/premise`'s approval). The wound: what happened
   before the story that still shapes them.
2. **Lie, truth, path.** The lie the wound left, the truth the story makes
   them face, and the path from one to the other across the story — or a
   **flat arc** (the protagonist holds a truth and changes others), which is
   a legitimate choice; say so when want and need coincide.
3. **Would never.** What they would never do — and whether the story makes
   them.

Write the entry skeleton-first (`/bible`'s §2: frontmatter, `canon:
provisional`, aliases the manuscript already uses), then the *Role*, *Want
and need* and *Arc* sections, each after "May I write this to
`bible/characters/<slug>.md`?". **The voice profile stays `<!-- to decide
-->`** until the author has written the character: sample lines are the
author's own, never invented.

## 2. Opposition (`cast-core`)

Who or what stands in the way, **and why they are right from where they
stand**: what they want, what they believe, what they would never do, and
how they press on the protagonist's lie. One round for who (or what), one for
their logic.

- A person: a character entry, as §1, with *Role* `antagonist` (or
  `opposition`) and their own want and need.
- Not a person (a society, an institution, nature, the protagonist's own
  nature): say what it becomes — an `org-` registry entity, a world rule
  (`/world rule`), or the protagonist's *Arc* — and ask. A faceless force
  usually needs a face: offer a character who embodies it.

**Done?** When the protagonist and the opposition have their entries, ask
**"Is the protagonist and opposition work done for now?"** On yes, run `bash
.claude/scripts/flow-mark.sh cast-core done` and say so; coming back later is
always possible. On no, go on with what is left.

## 3. Supporting cast (`cast-full`)

1. **Functions.** One round: which functions this premise needs — ally,
   mentor, foil, love interest, catalyst, mirror, or another the author
   names — and **only those it needs**; a function nobody needs is not
   filled. Characters the manuscript already has are matched to functions
   first.
2. **Each character**, one at a time: a round for who they are, what they
   want, and what the story loses without them. *Role* names the function.
   Their arc is as deep as rigour asks (`minimal`: none; `standard`: a line;
   `full`: want, need and path).

## 4. Relationships (`cast-full`)

For each relationship that matters to the spine: what the other wants from
the protagonist, and how the relationship changes (start → turn → end). One
round for the set. Each relationship is written to **both** entries'
*Relationships* sections (`[[char-<other>]] — <relationship and its
change>`), one file per approval.

**Done?** Ask **"Is the supporting cast done for now?"** On yes, run `bash
.claude/scripts/flow-mark.sh cast-full done` and say so.

## Registry in step

Whenever an entry gains facts or aliases, propose the matching
`bible/registry.yaml` lines in the same round, exactly as `/bible` does
(`.claude/skills/bible/SKILL.md` §3): one `facts` line per fact with `key`,
`value`, `canon: provisional` and `source` (the entry, since it was settled
in conversation, or the unit that first states it), every alias the
manuscript uses, the entity with `bible:` pointing at the entry. Its own
approval: **"May I write this to `bible/registry.yaml`?"**. Wants, needs and
arcs are not registry facts; ages, relationships, appearance and history
are.

## The session file

Each run records itself in `ideas/<YYYY-MM-DD>-cast[-<name>].md` (template
`.claude/templates/shared/ideas-session.md`, `skill: /cast`; add `-2` if it
exists). **After each character** (and after the functions round), show what
it adds — the options as offered, labelled `(Claude)`; the author's choice in
their words; what was not chosen; open questions — and ask "May I write this
to `ideas/<file>`?"; the first write creates it. If the author declines, say
that part lives only in this conversation. At the end, offer to copy open
questions to `ideas/questions.md` and any character the author wants to keep
for later to `ideas/parked.md`.

## Finish

- **Cast gate** (development-flow §11), after a done marker was set this run:
  at `full`, run it as `/review gate cast` does (`.claude/skills/review/
  SKILL.md`, *Gates*) and show the verdict; at `standard`, offer it ("Type
  `/review gate cast` any time"); at `minimal`, print `Cast gate skipped —
  minimal rigour.`
- Rewrite the checkpoint `session/active.md` (no "May I write?" needed):
  what the cast now holds; the next step; open questions.
- Run `bash .claude/scripts/flow-check.sh` and name **one** next step
  (usually `/cast` again for what is left, `/world` at `full`, or `/plot`).
  End with exactly one line, "Type `<command>` to begin.", and never invoke
  it.
