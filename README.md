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

- **Claude Code**
- **Bash.** On Windows, install [Git for Windows](https://git-scm.com/download/win),
  which provides Git Bash. macOS and Linux have Bash already.
- **jq.** You don't need to install it yourself: `/start` downloads a pinned,
  checksum-verified copy into `.claude/bin/` if none is on your `PATH`.
- **Pandoc and Tectonic**, only for `/publish`. They are downloaded the same
  way on first use. Tectonic fetches the TeX packages a document needs on its
  first compile, so the first PDF needs a network connection.

## Getting started

1. Copy or clone this template, once per project.
2. Open Claude Code at the project root.
3. Run `/start`. It asks for the form, how much process you want (`rigour`),
   how much prose Claude may write (`prose.level`), and the language. For
   non-fiction it also asks for the field, the citation style and the
   academic-integrity cap. It then writes `studio.yaml` and names your next
   step.

## Principles

- **You decide.** Claude asks before every write to your bible, compendium,
  outline or prose.
- **The file is the memory.** A short checkpoint file carries "where I am"
  between sessions.
- **Canon is explicit.** Continuity and citations are checked against files,
  not against Claude's recollection.
- **No invented sources.** Claude cites only sources in your compendium. Every
  cited source has an archived copy, and only you can mark a source verified.

The full design is in [`docs/specs/2026-11-07-writing-studio-v1-design.md`](docs/specs/2026-11-07-writing-studio-v1-design.md).

## Your archive and copyright

`compendium/archive/` holds your copies of cited sources and is gitignored,
because copyrighted PDFs must not be pushed to a public remote. Back it up
however you like. `compendium/archive.sha256` is committed, so a restored
archive can be checked against it.

## Licence

MIT. See [LICENSE](LICENSE). `.claude/csl/ieee.csl` is CC BY-SA 3.0.
