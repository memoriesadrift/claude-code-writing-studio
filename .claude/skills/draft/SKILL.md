---
name: draft
description: "Work on one prose unit (a scene, or a section of a non-fiction work) at the prose level in force - critic/coach assemble a brief for the author, editor proposes numbered diffs, co-author drafts the unit for approval, ghostwriter drafts a chapter or work unit by unit. /draft <unit> done runs the unit-done checklist (registry lines or claims, outline status, word count, the checks rigour calls for, checkpoint). Use when the author wants to write, edit or finish a unit, or types /draft."
argument-hint: "<unit | chapter | work> [done]"
allowed-tools: Read, Glob, Grep, Agent, Bash(bash .claude/scripts/status.sh*), Bash(bash .claude/scripts/flow-check.sh*)
---
# /draft (spec §8.1, §8.3, §5, §4.3)

One place generates prose — this skill, in the main session — and one place
enforces the ladder. Read `.claude/rules/prose.md` before anything else; it is
the contract this skill carries out. The prose guard hook is a backstop, not
the plan: never attempt a write the level does not allow.

If `studio.yaml` does not exist, say the project is not set up and offer
`/start`. Nothing else.

## Arguments

`/draft <target>` or `/draft <target> done`. Plain words; `done` is a
reserved sub-command word (`/new-work` refuses it as a work slug).

**Resolve the target to unit keys**, ask if ambiguous, never guess:

| Form | Accepted | Resolves to |
|---|---|---|
| Fiction | `ch03-the-storm/sc02-the-dock` (full key) | that unit |
| | `sc02-the-dock`, `ch03/sc02` | that unit, if exactly one card block matches |
| | `ch03-the-storm`, `ch03` | the chapter: every scene block in its card, in order |
| Non-fiction | `<work>/03-objections` (full key) | that section |
| | `03-objections`, `03` | that section of `session/current-work`, else of the only work it matches |
| | `<work>` | the work: every section block in its outline, in order |
| Both | a path (`manuscript/…/x.md`, `works/…/sections/x.md`) | that unit |

Units are found in the outline (fiction `outline/chapters/*.md`, non-fiction
`works/*/outline.md`, `### ` blocks) and in the prose files that exist. A unit
with a prose file but no block is still a unit (the author may write ahead of
the outline). No argument: propose the checkpoint's next step, else the first
`planned` or `drafting` block in outline order, and ask.

A chapter or work target is a **ghostwriter** operation. At any other level,
say so and ask which unit to start with.

Non-fiction: when the work differs from `session/current-work`, write the
work's slug to `session/current-work` (a per-machine pointer, gitignored; no
"May I write?" needed).

## 1. Level, policy, language

For each unit, resolve and **say** (one line):

- **Prose level** and where it came from (CLAUDE.md, *The prose ladder*;
  `prose.overrides` key, else `prose.level`). Non-fiction with
  `work.yaml` → `assessed: true`: cap at `assessed_cap`, else
  `integrity.assessed_cap`, else `coach`, and say the cap applied. The cap is
  a ceiling; never offer to raise it, never suggest an override to get round
  it.
- **Assessed work:** show `policy` from `work.yaml`, verbatim, at the top of
  the run.
- **Language:** non-fiction `work.yaml` → `language`, else `studio.yaml` →
  `language.default`. Pack `.claude/languages/<subtag>/` with the overlay
  `variants/<tag>.md` and the options in force (precedence in `pack.yaml`).
  No pack: say there is no grammar review for this language and offer
  `/language add <tag>`; drafting can go on.

**Stop** if the unit's file has `locked: true` in its frontmatter — at every
level, including `done` (which only reads, so it may go on: say the file is
locked and that nothing in it will be touched).

## 2. Inputs (read before any level's step)

- **Fiction:** the unit's scene block and its chapter card, `outline/
  structure.md` (purpose, promises the scene sets up or pays off),
  `bible/brief.md`, `bible/style-guide.md`, `studio.yaml` → `style` (POV,
  tense, register), `bible/registry.yaml` (entries for every entity the card
  names), the bible entries and voice profiles of the characters in the
  scene, and the end of the previous unit (last ~40 lines) for continuity.
- **Non-fiction:** the section's block in `works/<work>/outline.md`
  (claim, claim ids, citekeys, target words), the through-line,
  `works/<work>/brief.md` (research question in force, marking criteria),
  each listed claim in `compendium/claims.yaml`, and the source note of each
  citekey (status, summary, *Quotations*). `.claude/rules/citations.md`
  applies.
- The unit's file, if it exists: frontmatter (`prose`, `locked`) and any
  `<!-- author -->` … `<!-- /author -->` fences.

## 3. By level

### `critic` — a brief for the author

Claude writes **nothing** in the prose file (the guard denies it). Assemble,
in conversation, the brief the author writes from:

- What the unit must do (the card's goal, conflict, outcome; or the section's
  claim and role in the argument) and where it sits (what comes before and
  after, promises in play).
- The facts it must respect: registry facts and canon levels, voice-profile
  notes for the characters on stage, POV and tense; or the claims with their
  support and objections, and the source notes' locators.
- Non-fiction: which citekeys are `verified` and may be cited, and which are
  not yet (discuss, don't cite), and the target words against what is left of
  the limit.
- Open questions the card or outline leaves.
- The file to create and the frontmatter to start it with:
  ```yaml
  ---
  prose: author
  locked: false
  ---
  ```

No sample sentences, no openings, no rewritten text. End with: "When you've
written it, `/draft <unit> done` runs the checklist and the checks." Offer
`/review` for feedback on what they write.

### `coach` — as critic, plus illustrations on request

As `critic`. When the author asks how to do something (enter a scene late, a
cleaner signpost, a fairer statement of an objection), give a **short
illustration of the technique on invented material**, labelled
*Illustration*, never a version of the author's own sentence or of the unit
itself. Illustrations stay in the conversation (or a `reviews/` report);
never in a prose file.

### `editor` — numbered diffs, applied one at a time on acceptance

The unit must exist and be the author's text; if it does not exist, give the
`critic` brief instead and say why.

1. Ask what to look at, offering a default: line (rhythm, clarity, voice)
   and correctness together, or one passage. Read the pack's `style.md` and
   `conventions.md` (+ overlay) and the style guide.
2. Propose a batch of **numbered diffs** (about ten to fifteen per batch),
   one change each, in the line-editor's format, with location and a
   one-line reason:
   ```
   3. ch02-arrival/sc01-the-dock.md:14 — filter word slows the reveal
      - She saw that the boat was gone.
      + The boat was gone.
   ```
   Line-level only: **no new passages**, no reordering of paragraphs, nothing
   inside an `<!-- author -->` fence (in a `mixed` file), no change to
   frontmatter, quotations from sources left exactly as they are.
3. Ask: **"Which of these may I apply to `<path>`?"** (numbers, "all",
   "all but 4", "none"). That answer is the approval for those diffs only.
4. Apply each accepted diff as **one Edit**, in file order, re-reading the
   line first if earlier edits moved it. If a diff no longer matches the
   text, skip it and say so. Leave `prose:` as it is: accepted line edits do
   not change who drafted the unit (the provenance log records them).
5. Offer the next batch, or `/review line` / `/review grammar` for a full
   pass on the unit.

### `co-author` — the unit, drafted for approval

Draft only from a card or outline section; **never draft a unit that has
neither** — offer `/outline` (or a quick block for this one unit, written to
the outline with approval) first.

1. **Plan in one breath:** say in three to five lines what the draft will do
   (beats or argument steps), from the card or section, and anything you
   would change; ask before departing from the card.
2. **Draft the whole unit in the conversation**, following the language pack
   and options, the style guide, POV/tense/register, the voice profiles and
   registry (fiction), or the claims and source notes (non-fiction):
   - cite only with Pandoc citekeys of source notes that exist; **cite only
     `status: verified` sources** — where the outline names an unverified
     one, say so and ask whether to leave that support out for now;
   - quote directly only from a note's *Quotations*, with its locator;
   - keep to the section's target words; say the draft's count.
3. Revise on the author's notes until they approve.
4. Ask **"May I write this to `<path>`?"** and write it:
   - **New file:** frontmatter `prose: claude`, `locked: false`, then the
     text.
   - **File with the author's text already in it:** never replace it. Ask
     where the draft goes (e.g. after their opening paragraphs). Their text
     stays byte for byte; offer to fence it with `<!-- author -->` …
     `<!-- /author -->` so later edits cannot touch it; set `prose: mixed`.
     Show the combined result before writing.
5. Go to **unit done** (§4) for this unit.

### `ghostwriter` — a chapter or a work, unit by unit

1. List the units in order with their status; confirm which to draft
   (`planned` and `drafting` by default; `drafted` units are skipped unless
   the author names them).
2. For **each unit in turn**: the `co-author` steps 1–4, then **unit done**
   (§4) for that unit, before the next. Approval is per unit; never write two
   units on one approval.
3. After each unit, ask whether to go on. The checkpoint always names the
   next unit, so stopping at any point loses nothing.

## 4. Unit done — `/draft <unit> done`

Runs after every unit Claude wrote (`co-author`, `ghostwriter`), after
`editor` work when the author says the unit is finished, and whenever the
author runs `/draft <unit> done` (at `critic` and `coach` they wrote the unit
themselves, possibly in another session). If the author says the unit is done
in conversation, run it too.

Read the unit as it stands. Then go through the checklist **in this order**,
showing all findings first and then asking for each write separately (each
file gets its own "May I write this to `<path>`?"). What runs depends on
`modes.rigour`; at `minimal`, the items marked *standard+* are mentioned in
one line as available on request, not done.

1. **Registry or claims** — extracted by you from the text, never asked of the
   author as a form.
   - Fiction, *standard+*: new facts and new aliases as ready-to-add
     `bible/registry.yaml` lines (`key`, `value`, `canon: provisional`,
     `source: <chapter>/<unit>`). A registry change is a canon change: it
     always asks, in every automation mode. *full*: also name each new
     entity that needs a bible entry and offer `/bible <kind> <name>`.
   - Non-fiction, every rigour: add `<work>/<section>` to `used_in` of each
     existing claim the section relies on. *standard+*: propose new claims
     (statement, kind, support with locators, status) for assertions the
     section makes that `claims.yaml` lacks, linked to existing source notes
     only; an assertion with no source is listed as a gap, never given an
     invented one. *full*: offer concept and position entries
     (`/compendium`).
2. **Outline** — the unit's block: `status: drafted` (or `revised` if it
   was already `drafted`); non-fiction also `question: vN`, the version in
   force now. If the draft departed from the block: *standard* offers to
   update the block; *full* also offers a *Departures from this outline*
   entry. A unit with no block: offer one (*standard+*). Fiction: keep the
   chapter's line in `structure.md` in step (`drafting` → `drafted` when its
   last scene is).
3. **Words** — run `bash .claude/scripts/status.sh` (non-fiction:
   `status.sh <work>`). Fiction: the unit's and the chapter's words.
   Non-fiction: the section against its target words, and the work against
   `word_limit` with the exclusions that applied; flag an overrun.
4. **Checks rigour calls for** (§4.3), run as `/review` runs them (read
   `.claude/skills/review/SKILL.md` and follow it: agent, verdict shown, then
   "May I write the report to `<path>`?"):

   | Rigour | Fiction | Non-fiction |
   |---|---|---|
   | `minimal` | none (mention `/review continuity`) | none (the citation check still runs when the work is marked complete) |
   | `standard` | `continuity` on the unit; `developmental` on the chapter when this was its last scene to reach `drafted` | `citation` on the section; `developmental` on the work when every section is `drafted` |
   | `full` | `continuity` and `developmental` on the unit | `citation` and `developmental` on the section |

   Run them **without asking first** (that is what rigour is for); show each
   verdict and its findings briefly. Verdicts are advisory; nothing blocks the
   author. Fiction: when the draft phase completes (every scene block
   `drafted` or `revised`), offer `/review milestone`.
5. **Research question** (non-fiction, *standard+*): ask whether the section
   moved the question. If the author wants to revise it, propose the new
   `**vN+1**` wording and the *History* line for `brief.md`, and the
   outline's *Research question in force* line (`.claude/rules/works.md`),
   each with approval. *full*: list the sections whose `question:` is older
   than the version in force, for re-reading.
6. **Stage** — if this is the first unit drafted and `studio.yaml` →
   `project.stage` (fiction) is still `premise`, or `work.yaml` → `status`
   (non-fiction) is still `brief`, offer to move it to `draft`. When the draft
   phase is complete, say what the next phase needs (`/status` shows it).
7. **Checkpoint** — rewrite it (no "May I write?" needed): fiction
   `session/active.md`, non-fiction `works/<work>/checkpoint.md`; template
   `.claude/templates/shared/checkpoint.md`, at most 25 lines: what was just
   done, the **next step** (usually the next unit), open questions, decisions
   made.

## 5. Hand off (development-flow §8.4)

After unit done, say in one line what was written and which checks ran,
with their verdicts. Then run `bash .claude/scripts/flow-check.sh`
(non-fiction: `… flow-check.sh <work>`) and name **one** next step from its
`## write` block, worded by the level in force exactly as `/next` does
(`.claude/skills/next/SKILL.md` §3, *The write loop*):

- `next-unit: <key>` at `critic` or `coach`: "Write `<path>`, then type
  `/draft <key> done`." (`/draft <key>` first gives the brief, if the
  author wants one); at `editor` and above: "Type `/draft <key>` to
  begin." (`ghostwriter`: the chapter or work).
- `card-missing: <chapter>` at `standard` or `full`: `/outline <chapter>`
  (cards just in time); at `minimal`, say the chapter has no card and name
  `/draft` for its first unit.
- Every unit drafted: fiction `/review milestone`, non-fiction `/review
  developmental <work>`.

After a step that was not unit done (a brief, a set of diffs, a drafted unit
awaiting `done`), the next step is that unit's `/draft <key> done`.
End with exactly one line, "Type `<command>` to begin." (or the `critic` /
`coach` line above), and never invoke it.

## Never

- Write prose at `critic` or `coach`, or a new passage at `editor`.
- Touch a `locked: true` file or anything inside an author fence; drop or
  alter fenced text in a whole-file write.
- Rewrite what was not asked for, or apply a diff that was not accepted.
- Cite a source without a note, an unverified source, or a quotation not in a
  note's *Quotations*.
- Raise, suggest raising, or route round an integrity cap.
