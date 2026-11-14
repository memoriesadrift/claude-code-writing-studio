---
name: brainstorm
description: "Find the work - turns nothing, a seed or a rough idea into a brief. Fiction - who the writer is, three distinct premises built with named techniques, the chosen one deepened into bible/brief.md. Non-fiction - three candidate research questions, the chosen one handed to /new-work. Follows modes.ideas; every session is recorded in ideas/. Use when the author has no idea yet, a seed, wants alternatives to the current premise or question, or types /brainstorm."
argument-hint: "[open | <hint> | <work>]"
allowed-tools: Read, Glob, Grep, Agent, AskUserQuestion, Bash(bash .claude/scripts/flow-check.sh*), Bash(bash .claude/scripts/flow-mark.sh *)
---
# /brainstorm (development-flow §6)

You facilitate; the author decides. Each phase is shown and confirmed before
the next; nothing is generated silently, and nothing is written without
**"May I write this to `<path>`?"**.

If `studio.yaml` does not exist, say the project is not set up and offer
`/start`. Nothing else.

## Settings that shape the run

Read `studio.yaml`:

- **`modes.rigour`** sets the depth: `minimal` → the lean flow (§1);
  `standard`, `full` → the full flow (§2 fiction, §3 non-fiction). Doc density
  follows it (terse bullets · bullets + rationale · rationale + alternatives).
- **`modes.ideas`** sets what you contribute at each creative decision:

  | `ideas` | At a creative decision |
  |---|---|
  | `questions` | Ask open questions and reflect the author's answers back, naming the technique you are using ("let's try a what-if: what single thing is different about this world?"). **Never offer premises, characters, plot turns or research questions of your own.** The cards in §2.2 and §3.2 are built from the author's answers, one at a time |
  | `options` (default, also when unset) | 2–3 distinct alternatives, each from a different named technique; never one decided answer |
  | `proposals` | One complete proposal with the main alternative noted in a line; the author approves, edits or rejects |

- **`modes.automation`** never changes this: **choosing the creative
  direction is asked in every mode.**
- Talk in the interface language; the brief is written in the prose
  language.

Ask fixed choices with the question tool (pick, combine, fresh directions;
confirm a write); free answers in plain text. A dismissed question is not an
answer: ask again in plain text.

## The session file (every run)

Each run records itself in `ideas/<YYYY-MM-DD>-<slug>.md` (template
`.claude/templates/shared/ideas-session.md`; slug from the hint or topic,
`open` if none; add `-2` if it exists). **After each phase**, show what the
phase adds to the file (starting point, options offered labelled `(Claude)`,
what was chosen and why, what was not, open questions) and ask "May I write
this to `ideas/<file>`?"; the first write creates it. The author's words are
quoted, never paraphrased (`.claude/rules/ideas.md`). If the author declines,
say that phase lives only in this conversation. At the end, offer to copy
open questions to `ideas/questions.md` and any idea the author wants to keep
for later to `ideas/parked.md`.

## Start

- **Arguments:** `open` or nothing → from scratch. A hint (`lighthouse`,
  `grief and the sea`) → the seed. Non-fiction: a work slug → alternatives to
  that work's research question (§3.3).
- Read what exists: `ideas/writer.md`, earlier session files (`ideas/*.md`),
  `ideas/parked.md`, `ideas/questions.md`, and the brief (fiction
  `bible/brief.md`; non-fiction `works/<work>/brief.md`).
- **A brief already exists** (fiction): say so. Offer to revise it
  (`/premise`) or to explore alternatives without replacing it — this run then
  writes only a session file, and the brief changes only if the author later
  chooses an alternative and approves each section.
- **Assessed work** (non-fiction, `work.yaml` → `assessed: true`): show its
  `policy` verbatim before anything else. Whether brainstorming with Claude
  is allowed under it is the author's call; ask them to confirm before going
  on.

## 1. Lean flow (`minimal`)

A few exchanges, not fifteen.

1. **One creative question.** Fiction: from the hint, 2–3 one-line premises
   (at `questions`: questions that draw one out); the author picks or
   combines. Non-fiction: 2–3 one-line research questions the same way.
2. **Fiction:** fill the brief's sections in conversation, several per
   exchange — logline, protagonist want and need, stakes, ending intent
   (provisional is fine), comparable titles (only ones you are sure exist),
   form and target length. Show it whole; "May I write this to
   `bible/brief.md`?" (template `.claude/templates/fiction/brief.md`).
   **Non-fiction:** hand over (§3.3).
3. Hand off (§4).

## 2. Fiction, full flow (`standard`, `full`)

### 2.1 Discovery — the writer, not the book

Conversationally, a few at a time:

- stories (books, films, anything) that moved them, and what did it;
- the book they wish existed and have never found;
- what they want a reader to feel when they close it;
- genres and devices they love or avoid;
- the scale they have in mind (a story, a novel, a series) and the time they
  have;
- `full` only: how they work — planner or discoverer — and what has stalled
  them before.

Ask the open ones as plain text: they must be able to name anything. Sum up a
**writer's brief** in 3–5 sentences (emotional goals, taste, constraints),
read it back and confirm. Offer to save it to `ideas/writer.md` (template
`.claude/templates/shared/writer.md`; their words quoted). At `full` this is
a recommended step; at `standard` optional. If `ideas/writer.md` exists, read
it and ask whether it still holds instead of asking again.

### 2.2 Premises

Three distinct premises, each from a **different** technique, chosen to suit
the seed and the writer's brief:

| Technique | Starts from |
|---|---|
| What-if | an ordinary world plus one change |
| Character-first | a person with a want, a wound and a need, and the situation that tests them |
| Situation-first | the inciting collision: two forces that cannot both win |
| Mashup | genre × setting or theme, where the tension is the hook |
| Theme-first | a question the story argues with itself |

Each as a card:

```
1. <Working title> — <technique>
   Logline:        <one or two sentences: protagonist, goal, obstacle, stakes>
   Protagonist:    <who, and what they want>
   Conflict:       <what stands in the way, and why it matters>
   Hook:           like <X>, but <Y>
   Comparable:     <titles you are sure exist — or none>
   Promise:        <what the reader will feel>
   Why it works:   <one sentence>
   Biggest risk:   <one sentence>
```

Then one question, asked in every automation mode: "Which premise speaks to
you?" — `1 — <title>` / `2 — <title>` / `3 — <title>` / `Combine elements` /
`Fresh directions`. Do not push towards one. **Combine:** ask which elements,
show the combined card, confirm. **Fresh directions:** three new cards from
techniques not yet used, informed by what the author said about the first
three. Record the session file.

### 2.3 Deepen

For the chosen premise, one or two at a time:

- **Central dramatic question** — the yes/no question the ending answers.
- **Theme** — as a question the story explores, not a moral.
- **Stakes** — personal and wider; what is lost if the protagonist fails.
- **Ending intent** — how the author means it to end and the feeling it
  should leave; provisional is fine, say so.
- **Point of view and tense**, if still `null` in `studio.yaml` → `style`;
  if settled, offer the one-line `studio.yaml` change (with "May I write?").

Record the session file.

### 2.4 Write the brief

`bible/brief.md` from `.claude/templates/fiction/brief.md`: skeleton first
(title, `updated:`, *Form*; other sections as headings), then section by
section — logline, protagonist (want and need), stakes, ending intent,
comparable titles, form — each shown and approved before it is written.
`canon: provisional` (only the author promotes it). The dramatic question and
theme go under the logline and the ending intent respectively, in the
author's words. `.claude/rules/bible.md` applies.

### 2.5 Premise gate

- `full`: run it as `/review gate premise` does
  (`.claude/skills/review/SKILL.md`, *Gates*): `developmental-editor` reads
  `.claude/reviews/gates/premise.md` and the brief; show the verdict; ask
  whether to write the report; the step is marked done once the author has
  seen a verdict other than `NOT ASSESSED`. The verdict is advisory: on
  `CONCERNS` or `REJECT`, offer to revisit the section it names or to go on.
- `standard`: offer it ("Type `/review gate premise` any time").
- `minimal`: print `Premise gate skipped — minimal rigour.`

## 3. Non-fiction, full flow (`standard`, `full`)

### 3.1 Discovery

The author's interest and what sparked it; the assignment and marking
criteria if there is one (pasted, kept verbatim — they go to `/new-work`);
the scale (essay, paper, dissertation) and word limit; what they already
know and have read. Read `compendium/` (positions, claims, source notes) so
angles can start from what the author already holds.

### 3.2 Candidate questions

Three candidate research questions, each from a different technique:

| Technique | Starts from |
|---|---|
| Puzzle-first | something that should not be so |
| Debate-first | a live disagreement in the compendium's positions or the field |
| Case-first | a case that tests a general claim |
| Method-first | a way of looking not yet applied here |
| So-what-first | a consequence nobody has drawn |

Each as a card: question · thesis hunch · why it matters · sources it needs
(**named only from the compendium**, with citekeys; anything else "to find",
never an invented author or title) · fit to the marking criteria · biggest
risk (scope, evidence, word limit). Pick · combine · fresh directions, as in
§2.2. Record the session file.

### 3.3 Hand over

- **No work yet:** "Type `/new-work` to begin." — `/new-work` reads the most
  recent session file and offers the chosen question as v1 (it still asks
  every other question).
- **Existing work** (`/brainstorm <work>`): propose the chosen question as
  the next version in `works/<work>/brief.md` (`.claude/rules/works.md`: the
  old one moves to *History* with a one-line reason) and the outline's
  *Research question in force* line, each with "May I write?". Sections
  written under the old version keep their `question:` line; at `full`,
  `/next` lists them for re-reading.
- **Reading leads:** for each source the question needs that the compendium
  lacks, offer `/source` one by one. None is cited until it is a verified
  source note (v1 §6.3).
- **Question gate** — on the work, once it exists: `full` runs `/review gate
  question <work>` as in §2.5 (`developmental-editor`,
  `.claude/reviews/gates/question.md`); `standard` offers it; `minimal`
  prints `Question gate skipped — minimal rigour.`

## 4. Hand off

Rewrite the checkpoint if there is one (fiction `session/active.md`;
non-fiction the work's `checkpoint.md`) — no "May I write?" needed. Then run
`bash .claude/scripts/flow-check.sh [work]` and name the next recommended
step in one line of why, then exactly one line, and stop:

"Type `<command>` to begin." (fiction usually `/cast`, or `/draft` at
`minimal`; non-fiction `/new-work`). Never invoke it.

If the author stops early, say which phases were recorded in `ideas/` and
which live only in this conversation.
