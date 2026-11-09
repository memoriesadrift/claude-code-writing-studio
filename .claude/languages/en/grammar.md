# English — what grammar-editor checks

Part of the `en` language pack (spec §4.5). Read together with the overlay for
the tag in force (`variants/<tag>.md`), which wins wherever the two differ.
Option values in force (`pack.yaml` explains the order) win over both.

The grammar editor reports **correctness**, not taste: style belongs to the
line editor. Each finding gives the location, the problem and the rule it
breaks, at the prose level in force (`critic` and `coach`: name the problem
without rewriting the text; `editor`: a numbered diff).

## Severity

- **Error:** wrong by any standard (agreement, wrong word, broken syntax).
- **Inconsistency:** right in isolation, but at odds with the variant, an
  option or the rest of the text (*organise* and *realize* in one essay).
- **Query:** possibly deliberate. Ask; never "fix". In fiction, dialogue and
  close-POV narration may break rules on purpose: query only when the break
  looks accidental or inconsistent with the character's voice profile.

## Checklist, in order

1. **Spelling** per variant and options, including the consistency of
   variant spellings throughout the file and work.
2. **Commonly confused words** that a spellchecker misses: *its/it's*,
   *their/there/they're*, *affect/effect*, *complement/compliment*,
   *principal/principle*, *discreet/discrete*, *lead/led*, *lose/loose*,
   *loath/loathe*, *practice/practise* and *licence/license* (en-GB),
   *who's/whose*, *than/then*, *pore over*, *home in on*.
3. **Agreement:** subject and verb across intervening phrases
   (*the list of items is*), *each/every/neither … is*, collective nouns per
   variant, pronoun and antecedent.
4. **Sentence structure:** comma splices and run-ons (non-fiction: error;
   fiction: query), fragments (non-fiction: error unless clearly rhetorical),
   dangling and misplaced modifiers (*Walking home, the rain started*),
   faulty parallelism (*to read, writing and to think*), misplaced *only*
   when it creates ambiguity.
5. **Verb forms:** tense consistency with `style.tense` (fiction) and within
   a passage; past perfect for anterior events in past-tense narration; *lay/lie*,
   *sneaked/snuck* per variant; subjunctive after *if I were*, *insist that he be*
   (en-US expects it; en-GB accepts *should be*).
6. **Pronouns:** case (*between you and me*, *who/whom* in formal writing),
   ambiguous reference, singular *they* (correct; flag only inconsistency).
7. **Punctuation** per `conventions.md`, the overlay and options: quotation
   marks and their order with other punctuation, apostrophes, serial comma,
   dashes versus hyphens, restrictive and non-restrictive clauses
   (commas round non-restrictive *which*; *that* versus *which* per variant).
8. **Typography:** straight quotes, double spaces, hyphens used as dashes or
   ranges, missing non-breaking spaces.

## Do not report

- Split infinitives, sentence-final prepositions, *and*/*but* at the start of
  a sentence, singular *they*: all standard English.
- Anything inside a quotation from a source, except a transcription error
  against the source note (that is the citation pass's job; mention it).
- Style preferences (passive voice, word choice, rhythm): the line editor's.
