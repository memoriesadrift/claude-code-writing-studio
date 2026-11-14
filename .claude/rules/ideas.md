---
paths:
  - "ideas/**"
---
# The ideas store (development-flow §9)

`ideas/` holds what the development flow produces before it is decided:
brainstorm sessions, the options not chosen, the writer's brief, parked
ideas and open questions. It exists so nothing lives only in the
conversation.

- **Not canon, not prose, not outline.** Nothing here binds the work.
  Moving an idea into the bible, the registry, the outline or the
  compendium is a separate write, with its own "May I write this to
  `<path>`?". Claude may write `ideas/` at any prose level, after asking.
- **Label who proposed what.** Every idea, option or answer carries
  `(author)` or `(Claude)`. Never present Claude's idea as the author's, and
  never rewrite the author's words when recording them: quote them.
- **Record choices separately from options.** A session file keeps the
  options as they were offered, what the author chose (and why, if they
  said), and what was not chosen. Do not delete unchosen options; the author
  may come back to them.
- **`modes.ideas` governs content, not records.** At `questions`, session
  files hold the author's answers and Claude's questions, never Claude's
  own premises, characters or plot turns.
- **Files:** `writer.md` (the writer's brief), `<YYYY-MM-DD>-<slug>.md` (one
  per session), `parked.md` (one dated line per idea, newest first),
  `questions.md` (checkboxes; tick and note where it was settled). Templates:
  `.claude/templates/shared/ideas-session.md`, `writer.md`,
  `ideas-parked.md`, `ideas-questions.md`.
- An assessed non-fiction work's `policy` applies to brainstorming on it as
  to everything else: show it before a session about that work.
