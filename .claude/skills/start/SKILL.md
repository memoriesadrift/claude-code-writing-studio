---
name: start
description: Set up a Writing Studio project - ask form, rigour, prose level and languages (and for non-fiction field, citation style and integrity cap), write studio.yaml, create the folders, install jq with approval, and name the one next step. Use when studio.yaml does not exist, or when the author types /start.
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Bash(bash .claude/scripts/install-tool.sh check *), Bash(bash .claude/scripts/status.sh*)
---
# /start (spec §8.1, §4, §10.1)

Set the project up in one conversation. Follow the collaboration protocol in
`CLAUDE.md`: question → options → decision → draft → approval.

## 0. Already set up?

If `studio.yaml` exists, **change nothing**. Run
`bash .claude/scripts/status.sh`, give a short summary (form, prose level,
language, errors, next phase) and point to `/status` for detail. Settings are
changed by editing `studio.yaml` by hand (there is no `/settings` in v1).
Stop here.

## 1. Look before asking

Glob the project root. If `manuscript/`, `bible/`, `outline/`, `works/` or
`compendium/` already exist without `studio.yaml` (an older or hand-made
project), say so: `/start` will only create what is missing and never
overwrites a file. Suggest the form those folders imply.

## 2. Ask

Ask in the language the author writes in until the interface language is
settled. Ask a few questions at a time, each with options and a
recommendation; never a form to fill in. Anything the author does not decide
yet gets the default shown.

1. **Form:** `novel` · `short` (short fiction) · `nonfiction` (essays,
   papers, a dissertation; one compendium shared by several works) ·
   `screenplay`. Screenplay is a v1 stub: it behaves as `novel`, with no
   screenplay templates or formatting rules; say so if chosen.
2. **Title** of the project (for non-fiction, the umbrella: a degree, a
   module, a research area).
3. **Prose language** as a BCP 47 tag (`en-GB`, `en-US`, `de-DE`, `de-AT`,
   `de-CH`, …): the region carries spelling (`en-GB` vs `en-US`, `de-CH`
   without ß). **Interface language** (`language.interface`): the language
   the studio talks in; default the prose language's primary subtag.
4. **Rigour** — how much the studio tracks and checks *as you write*, never
   what must exist before you start (§4.3). Default `standard`; suggest
   `minimal` for short fiction. Show the three in one line each:
   - `minimal`: checks on request; citation check when a work is marked
     complete.
   - `standard`: at "unit done" Claude proposes registry lines or claims,
     runs the continuity or citation check, offers outline updates.
   - `full`: as standard, plus full bible or compendium entries, every
     departure noted, every factual assertion mapped to a source.
5. **Prose level** — what Claude may put in prose files (`CLAUDE.md`, *The
   prose ladder*). Show the five levels with one line each. Recommend
   `critic` if the author is unsure: raising a level later is one line in
   `studio.yaml`, and per-chapter or per-work overrides can loosen it where
   wanted.
6. **Fiction:** point of view (`first`, `close-third`, `omniscient`, …),
   tense (`past`, `present`) and register (free text). Each may be "decide
   later", which leaves it `null` for `/premise` and the style guide.
7. **Non-fiction:**
   - **Field** (free text, e.g. "Political philosophy").
   - **Citation style:** a CSL style id; default `ieee` (bundled). Others
     (`apa`, `harvard-cite-them-right`, `chicago-author-date`, `oscola`,
     `modern-language-association`, …) are fetched by `/publish` on first
     use. Per-work overrides go in `work.yaml`.
   - **Integrity cap** (`integrity.assessed_cap`, §5.4): the highest prose
     level Claude may use on an *assessed* work, whatever the overrides say.
     Default `coach`. Each assessed work can set a stricter cap at
     `/new-work`. This is a ceiling the author sets; never suggest raising it.
   - **Register** (free text, e.g. "formal academic").

`modes.automation` stays `collaborative` (asks at every decision); mention
that `guided` exists (asks only at major decisions) and is a one-line edit.

## 3. Write `studio.yaml`

Fill `.claude/templates/shared/studio.yaml`: replace every `{{…}}`; for
fiction drop `field`, `citation_style` and the `integrity` block (or leave
them `null`); for non-fiction drop `stage`, `pov` and `tense`. Keep the
comments. Keep hook-read lines flat (`key: value`, no `{…}`/`[…]`).
`language.options` stays `{}` unless the author sets one: list the pack's
options (`.claude/languages/<subtag>/pack.yaml` → `options`) with their
defaults in one line and ask if any should change.

Show the whole file, then ask **"May I write this to `studio.yaml`?"**

## 4. Create the folders and seed files

List every path, then ask once: **"May I create these?"** Create directories
with `mkdir -p` and files with Write. Skip anything that already exists and
say so.

**Fiction (`novel`, `short`, `screenplay`):**

| Path | From |
|---|---|
| `bible/characters/`, `bible/world/places/`, `bible/world/rules/` | — |
| `outline/chapters/`, `manuscript/`, `reviews/`, `session/` | — |
| `bible/registry.yaml` | `.claude/templates/fiction/registry.yaml` |
| `session/active.md` | `.claude/templates/shared/checkpoint.md`, scope "the book"; current task "Project set up"; next step `/premise`; no open questions |

**Non-fiction:**

| Path | From |
|---|---|
| `compendium/sources/`, `compendium/concepts/`, `compendium/positions/`, `compendium/notes/`, `compendium/inbox/`, `compendium/archive/` | — |
| `works/`, `session/` | — |
| `compendium/library.bib` | `.claude/templates/nonfiction/library.bib` |
| `compendium/claims.yaml` | `.claude/templates/nonfiction/claims.yaml` |
| `compendium/archive.sha256` | empty file (`/source` adds one line per archived file) |

Remind the author that `compendium/archive/` is gitignored (it may hold
copyrighted PDFs) and that backing it up is their call (§6.4).
Non-fiction has no project checkpoint: each work gets its own at
`/new-work`.

## 5. jq

Hooks need `jq` (§10.1). Run `bash .claude/scripts/install-tool.sh check jq`.

- `status: usable` → say which copy (path, version) and move on.
- `status: missing` → explain: the guards (prose level, source verification)
  **deny** writes until jq exists, and the observers (provenance log,
  session status) switch off. Ask: **"May I download jq 1.8.2 for
  `<platform>` from github.com/jqlang/jq into `.claude/bin/`? It is checked
  against the SHA-256 committed in `.claude/tools.yaml` and deleted if it
  does not match."** On yes, run
  `bash .claude/scripts/install-tool.sh install jq` and report the result
  lines. On no, tell them how to install it themselves (`winget install
  jqlang.jq`, `brew install jq`, their package manager) and that `/start`
  can be re-run for the check.
- Exit status 3 (`no-official-build`) → the platform has no official
  build; give the same manual instructions.
- `checksum mismatch` → say nothing was installed, do not retry
  automatically, and suggest checking the network (a proxy rewriting
  downloads) before trying again.

## 6. Language pack

Resolve the pack for `language.default` (§4.5): folder
`.claude/languages/<primary subtag>/`, overlay `variants/<tag>.md`.

- No folder → there is no grammar review for this language yet. Offer
  `/language add <tag>`.
- Folder but no overlay for the tag → the base pack applies alone; offer
  `/language add <tag>` to add a regional overlay.
- `support: user-defined` → mention that checks are less reliable.

## 7. Check and hand over

Run `bash .claude/scripts/status.sh`. Any `error:` line means something
`/start` wrote is wrong: fix it (with approval) before finishing.

End with **one** next step:

- Fiction: `/premise` — the brief (logline, want/need, stakes, ending
  intent, comps) is the only thing needed before drafting.
- Non-fiction: `/new-work` — paste the assignment and marking criteria; a
  working research question is the only thing needed before drafting.

`session/active.md` (fiction) is the checkpoint; no closeout is ever needed.
