# {{Language}} — what grammar-editor checks

Part of the `{{lang}}` language pack (spec §4.5), **user-defined**. Read
together with the overlay for the tag in force (`variants/<tag>.md`), which
wins wherever the two differ. Option values in force win over both.

> Claude's grammar checking is less reliable in lower-resource languages.
> Every report produced with this pack says so in its header (spec §4.5), and
> findings should be phrased as queries unless the rule is certain.

The grammar editor reports **correctness**, not taste. Each finding gives the
location, the problem and the rule it breaks, at the prose level in force
(`critic` and `coach`: name the problem without rewriting; `editor`: a
numbered diff). Report in the interface language; quote the text exactly.

## Severity

- **Error:** wrong under the authority in `conventions.md`.
- **Inconsistency:** an allowed variant mixed with another, or a departure
  from the overlay or an option.
- **Query:** possibly deliberate (dialogue, voice, dialect), or a rule the
  editor is not certain of.

## Checklist, in order
<!-- Interview: "What mistakes do you, or writers in this language, most often
make? Which grammar areas are hardest (agreement, cases, verb moods,
accents, word order)?" Turn the answers into an ordered checklist. -->
1. **Spelling and diacritics:** {{notes}}
2. **Commonly confused words:** {{pairs}}
3. **Agreement:** {{notes}}
4. **Verb forms and moods:** {{notes}}
5. **Punctuation and typography** per `conventions.md`.
6. {{further areas from the interview}}

## Inclusive language
<!-- Interview: "Does your language have inclusive-language conventions
(e.g. gender-neutral forms)? Which do you use, if any?" If there is a choice,
it becomes an option in pack.yaml; describe here how to check it. -->
{{rule, or "Follow the author's practice; report only inconsistency."}}

## Do not report

- Anything inside a quotation from a source.
- Style preferences: the line editor's.
- {{author's explicit exceptions}}
