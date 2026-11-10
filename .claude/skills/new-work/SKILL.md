---
name: new-work
description: "Non-fiction - create works/<work>/ from an assignment - the author pastes the brief and marking criteria (kept verbatim), sets kind, word limit, whether it is assessed and, if so, the AI-use policy and the integrity cap; Claude drafts a working research question or thesis as v1. Writes work.yaml, brief.md, an empty outline, the checkpoint and session/current-work. Use when the author starts a new essay, paper, dissertation or report, or types /new-work."
argument-hint: "[slug]"
allowed-tools: Read, Glob, Grep, Bash(bash .claude/scripts/status.sh*)
---
# /new-work [slug] (spec §8.3, §4.2, §5.4, §6.5)

A work is one essay, paper, dissertation or report; every work shares the
project's compendium. The brief, with a working research question, is the
only thing drafting needs.

If `studio.yaml` does not exist, say the project is not set up and offer
`/start`. On a fiction project, say works are non-fiction and point to
`/premise`. Nothing else.

Follow the collaboration protocol: a few questions at a time, with options
and a recommendation; every file only after **"May I write this to
`<path>`?"**; `.claude/rules/works.md` applies.

## 1. Paste first

Ask the author to paste the assignment and the marking criteria (as much as
they have; "none" is fine for a work that is not assessed or has no
criteria). Read them before asking anything else: most answers below are in
them. **Keep both verbatim** — never paraphrase, tidy or translate them.

## 2. The slug

Propose one from the title or topic: lower-case ASCII letters, digits and
hyphens, starting with a letter, at most 40 characters
(`public-reason-essay`). It is the folder name, the `prose.overrides` key
prefix and the word `/status`, `/draft`, `/review` and `/publish` take, so it
should be short and stable.

**Reserved words** — refuse these and suggest another, because skills read
them as sub-commands or targets and a work with that name would be ambiguous:

`provenance` · `statement` · `add` · `tex` · `pdf` · `done` · `summary` ·
`marker` · `manuscript` · `continuity` · `citation` · `developmental` ·
`line` · `grammar` · `beta` · `milestone`

Also refuse a slug that already exists under `works/` (offer to open that
work instead).

## 3. Ask

In one or two rounds:

1. **Title** (as it will appear on the work).
2. **Kind:** `essay` · `paper` · `article` · `dissertation` · `report` ·
   `other`. **Module** (optional, e.g. a course code), else `null`.
3. **Word limit** (`null` if none) and what does not count
   (`word_count_excludes`; default `[bibliography, footnotes]`; offer
   `citations` and `headings` if the assignment says so). Read the limit off
   the assignment if it states one, and confirm.
4. **Assessed?** If **yes**:
   - **Policy:** the AI-use rules that apply to this work, **verbatim** as the
     author gives them (a category name, a paragraph from the module
     handbook). If they do not have it, say the studio cannot know the rules
     and that the author is responsible for them; record what they say, even
     "unknown — check with module leader". Never summarise it.
   - **Integrity cap** (`assessed_cap`): the highest prose level Claude may
     use on this work. Offer the project default from `studio.yaml` →
     `integrity.assessed_cap` (written as `null` in `work.yaml`, meaning "use
     the project default"), and say a stricter cap can be set for a stricter
     module. The author may also set a **looser** cap; that is their call. If
     they do, accept it, and say plainly, once: this work will allow
     `<level>` although the project default is `<default>`; check it is
     consistent with the policy above. Never suggest a looser cap yourself.
5. **Language** of the work if it differs from `studio.yaml` →
   `language.default` (e.g. one essay in German), else `null`. If the tag has
   no pack, say so and offer `/language add <tag>`. **Citation style** if it
   differs from the project's (a CSL id), else `null`.

Then a summary of the answers in one block, for the author to confirm.

## 4. Research question v1

Draft a working research question **or** thesis from the assignment and what
the author has said: two or three alternatives that differ in scope or angle,
with a line each on what it commits the work to, and a recommendation. The
author chooses or rewrites. It is `**v1** (<date>)`; it is expected to change
(spec §6.5), and saying so here saves a worry later. *History* starts empty.

## 5. Write

One file per approval, in this order, each shown in full first:

1. `works/<slug>/work.yaml` — from `.claude/templates/nonfiction/work.yaml`:
   `status: brief`; the answers above; keep the comments. The hook-read lines
   (`assessed`, `assessed_cap`, `word_limit`) stay flat (`key: value`, quotes
   only around the whole value). `policy` is quoted as a whole; if it spans
   several paragraphs, use a YAML block scalar (`policy: |`) — that line is
   not hook-read.
2. `works/<slug>/brief.md` — from `.claude/templates/nonfiction/brief.md`:
   the research question v1 at the top; assignment and marking criteria
   verbatim as block quotes; constraints from `work.yaml`.
3. `works/<slug>/outline.md` — from `.claude/templates/nonfiction/outline.md`,
   title and *Research question in force: v1* only: headings, no section
   blocks yet (`/outline` fills it).
4. Create `works/<slug>/sections/` and `works/<slug>/reviews/`
   (`mkdir -p`, part of the same approval as the outline).

Then, without asking (session files):

- `works/<slug>/checkpoint.md` — from
  `.claude/templates/shared/checkpoint.md`, scope the work; current task
  "Work set up"; next step `/outline <slug>` or `/draft`; open questions from
  the conversation.
- `session/current-work` — the slug, one line (per-machine, gitignored).

## 6. Check and hand over

Run `bash .claude/scripts/status.sh <slug>`: any `error:` line about this
work means something written is wrong; fix it (with approval) before
finishing. Then name **one** next step:

- `/outline <slug>` to plan the sections, or `/draft` to start writing — the
  brief is all drafting needs at every rigour level.
- If the compendium has no sources yet, mention `/source` as the way to add
  them as the author reads.
