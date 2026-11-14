---
name: publish
description: "Convert the manuscript (fiction) or one work (non-fiction) from Markdown to LaTeX or PDF with Pandoc and Tectonic - units in outline order, citations rendered with citeproc in the work's CSL style and language, the work's or project's LaTeX template. Installs Pandoc and Tectonic and fetches CSL styles only with approval; never changes prose. Use when the author wants a .tex or PDF, or types /publish."
argument-hint: "[work] <tex | pdf>"
allowed-tools: Read, Glob, Grep, Bash(bash .claude/scripts/publish.sh *), Bash(bash .claude/scripts/install-tool.sh check *), Bash(bash .claude/scripts/cite-scan.sh*), Bash(bash .claude/scripts/flow-check.sh*)
---
# /publish [work] <tex | pdf> (spec §8.4)

The author writes Markdown; `/publish` produces LaTeX or PDF from it into
`out/` (gitignored). Nothing else in the studio sees LaTeX. **`/publish` never
changes prose files** — not to fix a citation, not to make a compile pass.

If `studio.yaml` does not exist, say the project is not set up and offer
`/start`. Nothing else.

## 1. Arguments

- Fiction: `/publish tex` or `/publish pdf` — always the whole manuscript
  (`out/manuscript.tex`, `.pdf`).
- Non-fiction: `/publish <work> tex|pdf`; with no work, `session/current-work`,
  else ask. `out/<work>.tex`, `.pdf`.
- No format: ask (`tex` stops after Pandoc; `pdf` also compiles).

An assessed work: show `work.yaml` → `policy` verbatim first.

## 2. Before converting

**Non-fiction — the citation check** (spec §8.4: it runs first, never
blocks). Run `bash .claude/scripts/cite-scan.sh <work>` and list its `error:`
lines (unresolved keys, unverified sources, missing or changed archive
copies), grouped. Then ask whether to continue: publishing a draft for a
supervisor is normal. Mention that `/cite-check <work>` also matches the
quotations against the notes and archived copies, which the quick scan does
not.

**Author name.** If `studio.yaml` → `publish.author` is `null` or missing,
ask once for the name to print on the title page ("none" is fine) and write
it to `studio.yaml` after **"May I write this to `studio.yaml`?"** (one line
under `publish:`; add the key if an older `studio.yaml` lacks it).

**Template** — resolution: the work's `work.yaml` → `template` or
`works/<work>/template.tex` → `studio.yaml` → `publish.template` → Pandoc's
built-in. Fiction uses `publish.template` only. If none is set and this is
the first `/publish` (no `out/<target>.tex` yet), ask the spec's question:

1. a template for **this work** (e.g. a module's required layout) — the
   author puts it, with any `.cls`, `.sty` and logos, in `works/<work>/`;
2. a **project default** for every work without its own — e.g.
   `publish/default.tex`, set as `publish.template` (with approval);
3. **Pandoc's built-in** template for now.

**Converting an ordinary `.tex` template** (a university thesis template, not
a Pandoc one). Propose the Pandoc version as a diff, keeping the original
beside it (`template.orig.tex`); save only on approval:

- the placeholder body replaced by `$body$`; title, author and date by
  `$title$`, `$author$`, `$date$` (keep the template's own commands, e.g.
  `\title{$title$}`);
- `\usepackage{hyperref}` if the template lacks it (citeproc output uses
  `\phantomsection`);
- the citeproc preamble block: copy the `$if(csl-refs)$ … $endif$` block from
  the installed Pandoc's own template, so it matches the version —
  `pandoc --print-default-data-file templates/common.latex` (run the binary
  from `install-tool.sh check pandoc`'s `path:`);
- the babel block for `lang` from the same file, if the template sets no
  language;
- `\usepackage[utf8]{inputenc}` removed for Tectonic, XeLaTeX or LuaLaTeX
  (they read UTF-8 natively); say why.

## 3. Tools

Run `bash .claude/scripts/install-tool.sh check pandoc` (and `check tectonic`
for `pdf` with `publish.engine: tectonic`):

- `status: usable` → go on.
- `status: missing` → ask: **"May I download Pandoc 3.13 (Tectonic 0.17.0)
  for `<platform>` from its official GitHub release into `.claude/bin/`? It
  is checked against the SHA-256 in `.claude/tools.yaml` and deleted if it
  does not match."** On yes, run `bash .claude/scripts/install-tool.sh install
  <tool>` and report the result lines. On no, say how to install it
  (`winget`, `brew`, the package manager) and stop.
- Exit 3 (no official build, e.g. Windows on ARM) → the amd64 build runs
  under emulation; give manual instructions.
- Mention once that Tectonic's **first** compile downloads the TeX packages
  the document needs from its own servers and caches them, so it needs a
  network connection and can take a minute or two.

Other engines (`xelatex`, `lualatex`, `pdflatex`) are the author's own TeX
installation; the studio never installs them.

## 4. Run

```bash
bash .claude/scripts/publish.sh <work | manuscript> <tex | pdf>
```

Run it in the background for `pdf` (a first Tectonic compile can exceed two
minutes). It prints facts in blocks:

- `## inputs` — the order used (`chapter:` and `unit:` lines),
  `missing:` (outline blocks or chapters with no file yet) and `unlisted:`
  (files the outline does not list, appended at the end). Report both kinds:
  a draft with gaps is fine; an unlisted file is usually an outline to update
  (offer `/outline`).
- `## settings` — title, author, lang, template, CSL style (and its parent
  for a dependent style), engine.
- `## pandoc`, `## compile` — `output:` lines, or `error:` with `log:` lines.

**Exit 3 — `need:` lines:**

- `need: tool …` → §3.
- `need: csl <id>` → the style is not in `.claude/csl/`. Ask: **"May I fetch
  the CSL style `<id>` from the official CSL styles repository at the commit
  pinned in `.claude/tools.yaml` into `.claude/csl/`?"** On yes, run
  `bash .claude/scripts/csl-fetch.sh <id>` (a dependent style fetches its
  parent too). Then show its `record:` lines and ask **"May I write this to
  `.claude/tools.yaml`?"** — they go under `csl:` → `fetched:`, every other
  line untouched. `publish.sh` refuses a `.csl` without a recorded hash.
  Not found → say so and ask for the exact style id (it is the file name in
  the CSL repository, e.g. `harvard-cite-them-right`, `apa`,
  `chicago-author-date`, `oscola`). Then run `publish.sh` again.
- `need: pdflatex on PATH` (etc.) → the configured engine is not installed;
  offer `publish.engine: tectonic` (an edit to `studio.yaml`, with approval)
  or the author installs TeX.

**`error:` from the CSL check** (a `.csl` whose hash no longer matches
`tools.yaml`): say the file changed since it was recorded; never update the
hash to match. The author restores it, or it is fetched again (remove the
file — the author does that — and fetch).

## 5. When the compile fails

Read the `log:` lines (and `out/<target>.log` if more is needed) and explain
the **first** error in one or two sentences. Propose a fix **to the
template** (or to `studio.yaml`), as a diff, with approval — never to the
prose. Common cases:

| Log | Usual cause | Fix |
|---|---|---|
| `Undefined control sequence` at `\phantomsection` / `CSLReferences` | template lacks hyperref or the citeproc block | add them (§2) |
| `inputenc` / `fontenc` errors | pdfLaTeX-only package under XeTeX | remove `inputenc`; drop `fontenc` options |
| `File 'x.sty' not found` | the package is not in the template's folder or the TeX bundle | put it beside the template |
| `Missing $ inserted` | a `$` or `_` in a title or metadata | quote it in `work.yaml` or escape in the template |

If the problem is in the prose (e.g. raw LaTeX the author wrote), show the
line and let the author fix it.

## 6. Done

Report the output path(s), the order used, the style and language, and any
`missing:` / `unlisted:` lines and citation errors that still stand. The
PDF's bibliography has no heading unless the template or the last section
supplies one (`# References` / `# Literatur` at the end of the last section,
or `reference-section-title` in the template). Nothing is written outside
`out/` except the approved changes above.

Run `bash .claude/scripts/flow-check.sh` (non-fiction: `… <work>`). If a
phase other than *finish* is still incomplete, name **one** next step from
it — a draft is often published to read on paper mid-way — and end with
exactly one line, "Type `<command>` to begin.", never invoking it. If every
phase is complete, say that the book (or work) has finished the flow, with
no hand-off line: the one ending without one.
