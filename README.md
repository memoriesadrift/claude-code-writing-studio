# Writing Studio

A project template that turns a [Claude Code](https://claude.com/claude-code)
session into a small editorial studio for long- and short-form writing:
novels, short stories, and non-fiction fields with many essays or papers
drawing on one shared compendium of sources.

You stay the author. The studio supplies structure, memory, continuity and
citation checks, and critique. It writes prose only to the degree you allow,
from `critic` (Claude never writes a word of your prose) up to `ghostwriter`.

## Forms

| Form | One project is… | You draft in… |
|---|---|---|
| `novel` | one book | scenes within chapters (`manuscript/`) |
| `short` | one story | `manuscript/story.md`, or scenes |
| `nonfiction` | one field (a degree subject, a research area) | sections of works (`works/<work>/sections/`) |

`screenplay` is reserved for a later version.

## Requirements

- **Claude Code**, in a terminal or in the Code tab of the Claude desktop app.
- **Bash.** On Windows, install [Git for Windows](https://git-scm.com/download/win),
  which provides Git Bash, even if you only use the desktop app (which asks
  for Git only for worktrees). The studio's hooks and scripts run in Git Bash;
  without it the hooks cannot run, and nothing enforces the prose level.
  Restart the desktop app after installing Git: it reads `PATH` only at
  launch. macOS and Linux have Bash already.
- **jq.** You don't need to install it yourself: `/start` downloads a pinned,
  checksum-verified copy into `.claude/bin/` if none is on your `PATH`.
- **Pandoc and Tectonic**, only for `/publish`. They are downloaded the same
  way on first use. Tectonic fetches the TeX packages a document needs on its
  first compile, so the first PDF needs a network connection.

## Getting started

1. Copy or clone this template, once per project.
2. Open the project:
   - **Desktop app:** in the Code tab, choose this folder with the project
     folder control, and leave **Worktree** off. A worktree session works in
     a separate checkout on its own branch: your writing stays there until
     it is merged, and per-machine files (the work in progress, downloaded
     tools, your source archive) are not copied into it.
   - **Terminal:** run `claude` at the project root and accept the trust
     prompt. The studio's read-only status scripts run without asking only
     once the folder is trusted.
3. Run `/start`. It meets you where you are — nothing yet, a seed, a clear
   idea, or material you have already written — and asks for the form, how
   much process you want (`rigour`), how much prose Claude may write
   (`prose.level`), how much Claude contributes to creative choices
   (`modes.ideas`), and the language. For non-fiction it also asks for the
   field, the citation style and the academic-integrity cap. It writes
   `studio.yaml`, shows your path, and names the first step.
4. After that, `/next` always says where you are and what comes next.

Every command ends by naming one next step ("Type `/cast` to begin.") and
never runs it for you: you type it.

## The flow

Orient → Discover → Develop → Plan → Write loop → Revise → Finish. Rigour
decides which steps are recommended; none is a gate, and you can start
drafting as soon as you have a brief.

| Phase | Fiction | Non-fiction |
|---|---|---|
| Orient | `/start`, `/import` | `/start`, `/import` |
| Discover | `/brainstorm`, `/premise` | `/brainstorm`, `/new-work` |
| Develop / research | `/cast`, `/world`, `/bible` | `/ask`, `/source`, `/compendium` |
| Plan | `/plot`, `/outline` | `/outline <work>` |
| Write loop | `/draft <unit>`, then `/draft <unit> done` | the same |
| Revise | `/review milestone`, `/continuity-check` | `/review developmental <work>`, `/cite-check` |
| Finish | `/publish` | `/publish <work>` |

At `full` rigour, development gates (`/review gate premise`, `cast`, `spine`,
`question`, `argument`) give an advisory verdict before you build on a step.
`/status` shows the whole project at once, with word counts and page counts
(estimated while you draft, exact from the last PDF; a work can have a word
limit, a page limit or both); `/status provenance` summarises
what Claude wrote, and drafts an AI-use statement for assessed work.

## How much Claude writes

| `prose.level` | Claude in your prose files |
|---|---|
| `critic` | nothing: feedback only |
| `coach` | nothing: feedback, plus short labelled illustrations |
| `editor` | line edits you accept one at a time |
| `co-author` | whole units drafted from your outline, each approved |
| `ghostwriter` | whole chapters or works, unit by unit, each approved |

The level can differ per chapter, unit, work or section. Assessed
non-fiction is capped (`coach` by default). Hooks enforce this in every
permission mode, Auto and Bypass included: at `critic` and `coach`, Claude
cannot write to your prose files at all.

## Principles

- **You decide.** Claude asks before every write to your bible, compendium,
  outline or prose.
- **The file is the memory.** A short checkpoint file carries "where I am"
  between sessions.
- **Canon is explicit.** Continuity and citations are checked against files,
  not against Claude's recollection.
- **No invented sources.** Claude cites only sources in your compendium. Every
  cited source has an archived copy, and only you can mark a source verified.

The full design is in [`docs/specs/2026-11-07-writing-studio-v1-design.md`](docs/specs/2026-11-07-writing-studio-v1-design.md),
amended by [`docs/specs/2026-11-10-writing-studio-development-flow.md`](docs/specs/2026-11-10-writing-studio-development-flow.md).

## Your archive and copyright

`compendium/archive/` holds your copies of cited sources and is gitignored,
because copyrighted PDFs must not be pushed to a public remote. Back it up
however you like. `compendium/archive.sha256` is committed, so a restored
archive can be checked against it.

## Licence

MIT. See [LICENSE](LICENSE). `.claude/csl/ieee.csl` is CC BY-SA 3.0.
