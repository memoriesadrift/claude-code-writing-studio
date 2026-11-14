# Review pass: citation (non-fiction)

**Agent:** `continuity-editor` · **Form:** non-fiction · **Spec:** §4.3, §6.3,
§6.4, §7.1

## Trigger

| Rigour | When |
|---|---|
| `minimal` | When a work is marked `complete`, and on request (`/review citation`, `/cite-check`) |
| `standard` | At "unit done", when a work is marked `complete`, and on request |
| `full` | As `standard`, plus check 7 below |

**Floor:** this pass runs at least once before a work is marked complete, at
every rigour level (`workflow.yaml` → the `complete` step, which `/next`
hands off to `/cite-check`). Its verdict
stays advisory: the author can mark the work complete anyway; `/status` keeps
reporting outstanding errors and the provenance statement mentions them.

Target: a section (`works/<work>/sections/<section>.md`) or a work
(`works/<work>`).

## Context to pass

This file's path and the target path(s) only. The agent reads:

- `compendium/library.bib`, `compendium/sources/<key>.md` for every cited key
- `compendium/archive.sha256` and `compendium/archive/<key>/` (read and
  checksum only)
- `compendium/claims.yaml`
- `works/<work>/outline.md` (the claims each section relies on)
- `works/<work>/work.yaml` (`language`, `assessed`, `policy`) and the pack's
  `pack.yaml` (`translation_marker`) and `academic.md` (locator forms)

## Prompt

0. **Scan first:** `bash .claude/scripts/cite-scan.sh <work> [section...]`
   lists every citation, resolves keys, reads note status, runs
   `sha256sum -c` on the cited sources' archive lines and lists direct
   quotations. Its `error:` lines are facts; steps 1–3 below are then
   confirmation, and your reading goes into 4–7.
1. **Resolution.** Grep the target for citekeys (`@key`, inside `[…]` or
   bare). Each must have a `library.bib` entry and a source note whose
   `citekey` equals the key.
2. **Verification.** Each cited source has `status: verified`.
3. **Archive.** Each cited source's files exist under
   `compendium/archive/<key>/` and pass `sha256sum -c` (or `shasum -a 256 -c`)
   against their `archive.sha256` lines. A web source names `cited_capture`
   when it has several captures. `captured_by: claude` needs the author's
   confirmation. `kind: physical` is reported as a warning every time (no copy
   can be checked).
4. **Quotations.** Every direct quotation appears word for word in the note's
   *Quotations* section, with the same locator, and in the archived copy at
   that locator. A translated quotation carries the pack's
   `translation_marker`, and its original is in the note.
5. **Locators.** A citation that supports a specific statement carries a
   locator in the pack's form (*p.*, *S.*, *§*, para.).
6. **Attribution.** What the prose says a source argues matches the note's
   *Summary*/*Key arguments*, not the *Author's assessment*. A claim the
   outline assigns to the section has `support` with locators; a contested
   claim presented as settled is a finding. `used_in` lists the section for
   every claim it uses (propose additions and removals).
7. **`full` rigour only:** every factual assertion in the target maps to a
   claim or a citation; list the ones that do not.

Severity: `error` — unresolved key, unverified source, missing or failed
archive copy, quotation not found in the note or archive, wrong locator,
misattribution; `concern` — missing locator, contested claim presented as
settled, claim without support, `used_in` out of date, unconfirmed Claude
capture, unmapped assertion (`full`); `note` — `kind: physical` warning.

## Verdicts

- `**Verdict:** APPROVE` — no `error` or `concern` findings (physical-source
  warnings allowed).
- `**Verdict:** CONCERNS [n]` — no `error`; `n` `concern` findings.
- `**Verdict:** REJECT [n]` — `n` `error` findings.

## Report

Template `.claude/templates/shared/review-report.md`, written to
`works/<work>/reviews/citation-<target-slug>-<YYYY-MM-DD>.md` after "May I
write?". An assessed work's `policy` goes in the header verbatim.
