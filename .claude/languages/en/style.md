# English — line-editing notes

Part of the `en` language pack (spec §4.5). Read together with the overlay for
the tag in force (`variants/<tag>.md`), which wins wherever the two differ.
Option values in force (`pack.yaml` explains the order) win over both.

The line editor works on sentences: clarity, rhythm, register and voice. The
author's voice and the style guide (`bible/style-guide.md`, `studio.yaml` →
`style`) outrank everything here: these are things to notice, not rules to
impose. Never flatten a deliberate voice towards a neutral norm.

## Clarity

- **Nominalisations** hiding the verb: *made a decision to* → *decided*;
  *the implementation of* → *implementing*. Common in academic drafts.
- **Passive voice** that hides who acted when it matters (*mistakes were
  made*). Passive is fine when the agent is unknown or unimportant.
- **Long noun stacks:** *student essay feedback form design* — unpack.
- **Distance between subject and verb:** long intervening clauses make the
  reader hold too much.
- **Pronoun drift:** *this* and *it* with no clear referent; prefer *this
  argument*.

## Economy

- **Filler and intensifiers:** *very*, *really*, *quite*, *just*, *actually*,
  *basically*, *in order to*, *the fact that*, *it is important to note that*.
- **Redundant pairs:** *each and every*, *first and foremost*, *end result*,
  *past history*, *future plans*.
- **Throat-clearing openings** to paragraphs and chapters.

## Rhythm

- Vary sentence length; flag runs of three or more sentences with the same
  length or the same opening (subject–verb, *The …*, *-ing* clause).
- Sentence ends carry stress: suggest moving the important word there.
- Read paragraph openings in sequence: they should not all start the same way.

## Fiction

- **Dialogue tags:** *said* is invisible; flag strings of
  *exclaimed/retorted/hissed* and adverb-laden tags (*said angrily*) where the
  line itself should carry the feeling.
- **Filter words** in close POV: *she saw*, *he felt*, *she noticed*, *he
  wondered* that distance the reader from the perception.
- **Clichés and stock phrases:** *heart pounding*, *let out a breath she
  didn't know she was holding*, *a shiver ran down his spine*.
- **Repetition** of a distinctive word within a page (common words are fine).
- **Voice adherence:** check each POV character against their voice profile
  in `bible/characters/`.

## Register

- `style.register` in `studio.yaml` is free text; interpret it here. *Formal*:
  no contractions in narration or argument, no colloquialisms. *Conversational*:
  contractions welcome, direct address allowed.
- Keep register consistent within a section; flag sudden shifts.
