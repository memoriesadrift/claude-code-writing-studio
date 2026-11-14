---
name: cite-check
description: "Non-fiction - grep-first citation check of a work (or some of its sections) - unresolved citekeys, unverified sources, missing or altered archive copies (sha256sum -c), quotations not found in the note or the archived copy, claims cited without support - then a report with an advisory verdict. Use when the author asks to check citations, marks a work complete, or types /cite-check."
argument-hint: "[work] [section...]"
allowed-tools: Read, Glob, Grep, Bash(bash .claude/scripts/cite-scan.sh*), Bash(bash .claude/scripts/flow-check.sh*)
---
# /cite-check [work] [section...] (spec §8.3, §6.3, §6.4, §4.3)

No invented sources (spec §2, principle 7): every citation must resolve to a
source note, the source must be verified, its archived copy must be intact,
and every direct quotation must be found in the note and in the copy. The
helper script reports facts; you judge them.

If `studio.yaml` does not exist, say the project is not set up and offer
`/start`. On a fiction project, say this is a non-fiction check and point to
`/continuity-check`. Nothing else.

**The floor:** at every rigour level this check runs at least once before a
work is marked complete (§4.3). Its verdict is advisory: the author can mark
the work complete with outstanding errors; `/status` keeps reporting them and
the provenance statement mentions them.

This is the grep-first check, run in the main session. `/review citation
<target>` runs the same checks in `continuity-editor`'s own context, which is
better for a long work; offer it when the scan finds many quotations to
compare.

## 1. Scope

- `/cite-check` — the work in `session/current-work`, else ask (list the
  works). `/cite-check <work>` — all its sections. `/cite-check <work>
  <section…>` — those sections (`03-objections` or `03`, resolved against the
  outline; ask if ambiguous).
- An assessed work: show `work.yaml` → `policy` verbatim first.
- No section files: say there is nothing to check.

## 2. Run the scan

```bash
bash .claude/scripts/cite-scan.sh <work> [section...]
```

Blocks: `## cites` (every citation with file:line, key, locator, form),
`## keys` (per key: bib entry, note, status, archive kind, with `error:` /
`warning:` lines), `## archive` (`sha256sum -c` results for the cited
sources, unhashed files), `## quotes` (direct quotations of four or more
words and block quotes, with the citations in the same paragraph).

The script's `error:` lines are facts: an unresolved key, an unverified
source, a missing or changed archive file are errors as reported. Do not
soften them.

## 3. Judge what the script cannot

Read only what you need, section by section:

1. **Quotations.** For each `quote:` line, decide whether it is a direct
   quotation from a source (not scare quotes, a title or the author's own
   coinage — when unsure, ask). For each that is, using the citation that
   belongs to it:
   - it must appear **word for word** in the source note's *Quotations*,
     with the **same locator**; ellipses and square-bracket insertions must
     be marked as such;
   - and in the **archived copy** at that locator: read the PDF with `Read`
     and `pages` (the locator's page, mapped to the PDF's page if they
     differ; say how you mapped it), or the web capture, or the scan images.
     `kind: physical`: the note only, and say so.
   - a quotation in another language than the source's must carry the
     pack's `translation_marker` (`.claude/languages/<subtag>/pack.yaml`),
     with the original in the note.
   Not found → `error`. Never "correct" the quotation in the prose.
2. **Locators.** A citation supporting a specific statement or a quotation
   needs a locator in the pack's form (`academic.md`); missing → `concern`.
3. **Attribution.** What the prose says a source argues matches the note's
   *Summary* / *Key arguments*, not the *Author's assessment*;
   misattribution → `error`.
4. **Claims.** Read `compendium/claims.yaml` and the section's block in
   `works/<work>/outline.md`. A claim the section relies on with no `support`
   (or no locators) → `concern`; a `contested` claim presented as settled →
   `concern`; `used_in` missing this section, or listing a section that no
   longer relies on the claim → `concern`, with the fix.
5. **Captures.** `captured_by: claude` not confirmed by the author →
   `concern`. A web source with several captures and no `cited_capture` →
   `concern`.
6. **`full` rigour:** every factual assertion maps to a claim or a citation;
   list the ones that do not (`concern`).

## 4. Report (in conversation)

In the interface language: per finding, severity, location (`file:line`),
what is wrong and why. Severities as the citation pass
(`.claude/reviews/citation.md`): `error` — unresolved key, unverified source,
missing or failed archive copy, quotation not found, wrong locator,
misattribution; `concern` — the items above; `note` — `kind: physical`
warnings (on every run). Group repeats. Never rewrite the author's sentences;
at `editor` and above, a fix to a citation (a locator, a citekey) may be
offered as a numbered diff.

Then the verdict line as the pass defines it: `APPROVE` (no error or
concern), `CONCERNS [n]` or `REJECT [n]`. Advisory.

## 5. Afterwards

Offer, don't do:

- **Save the report** in the shape of
  `.claude/templates/shared/review-report.md` (agent line: "main session —
  /cite-check (grep-first)"), at
  `works/<work>/reviews/citation-<target-slug>-<YYYY-MM-DD>.md` (slug: the
  section, or the work slug for the whole work; `-2`, `-3` for a same-day
  re-run), after **"May I write this report to `<path>`?"**. A saved report
  counts as a citation review in `/status`, which keeps listing a work's
  non-`APPROVE` citation report until a later one approves.
- **`used_in` and claim fixes** as ready-to-add YAML, written to
  `compendium/claims.yaml` only after "May I write this to
  `compendium/claims.yaml`?".
- **Unverified sources:** say what verifying needs (the archived copy and its
  checksum line, or `held` for a physical copy) and that **only the author**
  marks a source verified; never offer to do it. `/source <citekey>` helps
  with the archive.
- **Changed or missing archive files:** never "fix" `archive.sha256` to match
  a changed file. The author restores the file, or captures again (a new
  capture is kept beside the old one, spec §6.4).

Rewrite the work's checkpoint `works/<work>/checkpoint.md` (no "May I
write?" needed) with the result and the next step.

Then name **one** next step: `/source <citekey>` for the first unverified or
unarchived source, the section to fix for an unresolved key or quotation,
or, with nothing outstanding, the step `bash .claude/scripts/flow-check.sh
<work>` recommends (usually `/publish <work>` once the work is complete).
End with exactly one line, "Type `<command>` to begin.", and never invoke
it.
