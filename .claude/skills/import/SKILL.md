---
name: import
description: "Bring existing material into the studio - notes copied verbatim to ideas/ (fiction) or compendium/inbox/ (non-fiction); a draft split into units or sections and copied verbatim by import-draft.sh (never retyped, checked against the source, never overwriting); .docx and similar converted with Pandoc first, with approval. Then extraction - brief, bible entries, registry lines, chapter list and cards (fiction) or outline and claims (non-fiction), each provisional and stamped with its source. Use when the author has notes or a draft already, or types /import."
argument-hint: "<path>"
allowed-tools: Read, Glob, Grep, Agent, AskUserQuestion, Bash(bash .claude/scripts/import-draft.sh *), Bash(bash .claude/scripts/install-tool.sh check *), Bash(bash .claude/scripts/status.sh*), Bash(bash .claude/scripts/flow-check.sh*), Bash(bash .claude/scripts/cite-scan.sh*), Bash(bash .claude/scripts/flow-mark.sh *)
---
# /import <path> (development-flow §10)

For the author who arrives with material: notes, a partial draft, a finished
draft. **Read-only first:** look, list what was found, propose a plan; then
each step only on the author's approval. The author's text is **never
retyped**: `.claude/scripts/import-draft.sh` copies it, checks it against the
source and refuses to overwrite anything. Everything extracted from it is
`canon: provisional` and offered one file at a time after **"May I write
this to `<path>`?"**.

If `studio.yaml` does not exist, say the project is not set up and offer
`/start` (which asks where the author is, and sends answer D here). Nothing
else.

## 1. Look

`<path>` is a file or a folder (no path: ask; or offer what `/start` found
loose in the project — `bash .claude/scripts/flow-check.sh disk` lists
`loose:` files). Read-only:

- List the files with their type and size (words for text), and sort each
  into **notes** (ideas, research, plans, character sketches), **draft**
  (prose meant for the book or work) or **skip** (binaries, images,
  duplicates), with a line of reason. The author corrects the sorting.
- `.md` and `.txt` are read directly. **Other formats** (`.docx`, `.odt`,
  `.rtf`, `.html`, `.epub`): §2.
- **Non-fiction:** a draft belongs to a work. If `works/` has none, or the
  author names a new one, say that `/new-work` comes first (the assignment,
  the research question and the integrity cap decide what may happen to the
  draft); offer to come back with `/import <path>` afterwards, and stop. For
  an **assessed** work, show its `policy` verbatim before anything else.
- Show the plan: what goes where, in what order (notes, then the draft, then
  extraction), and ask to go on.

## 2. Convert (other formats)

The import works on Markdown. For another format, offer to convert it with
Pandoc (development-flow §10):

1. `bash .claude/scripts/install-tool.sh check pandoc`. Missing: ask as
   `/publish` does ("May I download Pandoc … into `.claude/bin/`? It is
   checked against the SHA-256 committed in `.claude/tools.yaml` …"), then
   `install-tool.sh install pandoc` on yes. On no: say how to convert by hand
   (save as Markdown or plain text from the word processor, or Pandoc
   installed their own way), and go on with what is Markdown already.
2. Convert to `out/import/<name>.md` (`out/` is gitignored), with the path
   from `check`'s `path:` line:
   `"<pandoc>" "<source>" -t markdown-smart --wrap=none -o "out/import/<name>.md"`.
   `-smart` keeps the author's typographic quotes and dashes as characters;
   `--wrap=none` keeps one paragraph per line. Images and comments are not
   imported; say so if the source had them.
3. Ask the author to look the converted file over (headings, italics,
   footnotes). The verbatim check that follows is against **this** file, not
   the original document; say so.

## 3. Notes

Each notes file is copied verbatim, one approval each (or one approval for a
listed batch):

```
bash .claude/scripts/import-draft.sh note "<source>" ideas/<name>              # fiction
bash .claude/scripts/import-draft.sh note "<source>" compendium/inbox/<name>   # non-fiction
```

`<name>`: the file's own name, lower-cased, spaces as hyphens (`Plot ideas
v2.md` → `plot-ideas-v2.md`); a name that exists gets `-2`. Non-fiction inbox
files are processed later with `/source` and `/compendium`
(`.claude/rules/compendium.md`).

## 4. The draft

### 4.1 Propose the split

Read the draft and propose where it divides:

- **Fiction:** chapters (`chNN-slug`) and, within each, units (`scNN-slug`)
  — at the chapter headings and scene breaks the author used. A chapter with
  no scene breaks is one unit (`sc01-<slug>`). Keys from the chapter titles
  where there are any (`Chapter 3: The Storm` → `ch03-the-storm`), else from
  the first lines; the author can rename.
- **Non-fiction:** sections (`NN-slug`) at the draft's headings, into
  `works/<work>/sections/`.

Show the split as a table: target path, source lines `<from>-<to>`, the first
words of the unit, its word count. Then the **omitted lines**: the chapter
headings, scene-break markers and blank lines at the boundaries, and a
leading frontmatter block, which are not prose and would duplicate what the
outline and `/publish` supply (chapter titles come from the chapter list).
Only those kinds of line can be omitted; the script refuses any other.
Every other line is imported, so the ranges cover the file from line 1 to
the end.

Ask about **locking**: imported files are `prose: author`; at `editor` and
above Claude may propose edits to them. Offer `--lock` (`locked: true`: no
Claude edits at any level until the author unlocks a file), recommended if
the author wants the original untouchable; the default is unlocked.

### 4.2 Import

On approval, run the script with the whole split on one line, exactly in
this shape (no `;`, `&&`, pipes or redirects: the prose guard allows only
this command line, at every prose level):

```
bash .claude/scripts/import-draft.sh draft "<source>" --omit 1,2,57 manuscript/ch01-arrival/sc01-the-dock.md:1-56 manuscript/ch01-arrival/sc02-the-inn.md:57-130 …
```

Report its output: `normalised:` (BOM, line endings, final newline — the
only changes), `omitted:` lines, one `imported:` line per file with its word
count, `provenance:`. An `error:` line means nothing was written (or what was
written was deleted): explain it, fix the split and ask again. The script
never overwrites; a target that exists means the split must change, not the
file.

The provenance log gets one `tool: import` line per file: `/status
provenance` lists them as the author's text, never as Claude's.

## 5. Extract

From the imported text — Claude reads it and proposes; the author approves
each file. Everything is `canon: provisional`, and each written file carries
`<!-- Extracted from <source path> on <YYYY-MM-DD> -->` on the line after its
title (registry facts carry the unit as `source:`). Follow `modes.rigour` for
depth and the protocol of the skill that owns each file (`/premise`,
`/bible`, `/outline`, `/compendium`). Never ask the author to fill anything
in; say what the text does not settle and leave it `<!-- to decide -->`.

Work **one chapter (or section) at a time**: read it, collect what it
establishes, and carry it forward; for a long draft, say how far you have
read.

**Fiction**, in this order (skip what exists; extend rather than replace):

1. **Brief** (`bible/brief.md`): logline, want and need, stakes, ending
   intent (from the ending if the draft has one), form and length.
2. **Characters:** for each character the draft gives weight to, launch
   `character-lead` ("Draft a character entry from `.claude/templates/
   fiction/character.md` for <name>, from the units <list>; every fact cites
   its unit; the voice profile's sample lines are quoted from the text with
   their location; return text, do not write files"). Then places and world
   rules the text depends on (`/bible`'s formats).
3. **Registry** (`bible/registry.yaml`): ids, every alias the text uses,
   facts with `source: <chapter>/<unit>`.
4. **Chapter list and cards** (`outline/structure.md`, `outline/chapters/`):
   one `### scNN-slug` block per imported unit with `status: drafted` as its
   first line, then what the scene does. Launch `structure-architect` once
   on the chapter list ("Critique the structure of the imported draft in
   `outline/structure.md` against `bible/brief.md`; three to five findings,
   ranked; do not write files") and present its findings.

**Non-fiction:** the outline (`works/<work>/outline.md`, one `### NN-slug`
block per section with `status: drafted` and `question: v<n in force>`, the
section's claim and role), then proposed claims for `compendium/claims.yaml`
(offered as `/outline` does). Citations in the draft: run `bash
.claude/scripts/cite-scan.sh <work>` if the draft cites, and list the
citekeys with no source note as gaps for `/source` — never invent a source
note for them.

## 6. Finish

- Rewrite the checkpoint (fiction `session/active.md`, non-fiction
  `works/<work>/checkpoint.md`; no "May I write?" needed): what was imported
  and extracted, what is left to decide.
- If the draft is finished and the author says so, offer to mark the draft
  step done (`bash .claude/scripts/flow-mark.sh draft done [work]`) and say
  that revision comes next.
- Run `bash .claude/scripts/status.sh` and fix any `error:` line about what
  was written (with approval).
- Hand off to `/next`, which reads what is now on disk: usually the revision
  phase for a finished draft, or the write loop for a partial one. End with
  exactly one line, "Type `/next` to begin.", and never invoke it.
