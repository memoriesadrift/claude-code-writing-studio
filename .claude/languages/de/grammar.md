# German — what grammar-editor checks

Part of the `de` language pack (spec §4.5). Read together with the overlay for
the tag in force (`variants/<tag>.md`), which wins wherever the two differ.
Option values in force (`pack.yaml` explains the order) win over both.

The grammar editor reports **correctness**, not taste: style belongs to the
line editor. Each finding gives the location, the problem and the rule it
breaks, at the prose level in force (`critic` and `coach`: name the problem
without rewriting the text; `editor`: a numbered diff). Report in the
interface language; quote the German text exactly.

## Severity

- **Error (Fehler):** wrong under the official rules or standard grammar.
- **Inconsistency (Uneinheitlichkeit):** an allowed variant mixed with
  another, or a departure from the overlay or an option.
- **Query (Rückfrage):** possibly deliberate. In fiction, dialogue and close
  POV may use colloquial forms (*wegen dem*, *weil* + main-clause order) on
  purpose: query only when it looks accidental or breaks the voice profile.

## Checklist, in order

1. **Spelling:** ß/ss (per overlay), capitalisation of nominalisations,
   *Getrennt- und Zusammenschreibung* (*kennenlernen*, *zu Hause/zuhause*,
   *irgendwas*, *so dass/sodass*), consistency of allowed variants.
2. **Commonly confused words:** *das/dass*, *seit/seid*, *wider/wieder*,
   *Tod/tot*, *Stadt/statt*, *end-/ent-* (*endgültig*, *entgegen*),
   *scheinbar/anscheinend*, *lehren/lernen*, *Leid/leid*, *Mal/mal*,
   *derselbe/der gleiche* (formal texts), *nämlich* (not *nähmlich*).
3. **Commas (Kommasetzung):**
   - Subordinate clauses are always set off (*Ich weiß, dass …*).
   - Infinitive groups: comma required when introduced by *um, ohne, statt,
     anstatt, außer, als*; when dependent on a noun (*die Absicht, zu
     gehen*); or when announced by a pointer word (*Daran, zu gehen, dachte
     er nicht.*). Otherwise optional: flag only inconsistency.
   - Comma before *aber, sondern, doch, jedoch* joining clauses or phrases;
     none before *und/oder* in a list. Before *und/oder* joining two main
     clauses it is optional.
   - Appositions and parenthetical insertions set off on both sides;
     a missing closing comma is the most frequent error.
   - Comparison with *als/wie*: no comma unless a clause follows.
4. **Case (Kasus):** after prepositions (*wegen*, *trotz*, *während* +
   genitive in standard written German; dative only colloquial), adjective
   endings after articles (*mit einem großen Hund*), apposition in the same
   case (*mit Herrn Müller, dem Leiter*), weak nouns (*den Studenten*,
   *dem Menschen*, *des Herrn*).
5. **Agreement:** subject–verb across long middle fields, relative pronoun
   gender/number with antecedent, *eine Reihe von … ist* (singular is
   standard; plural accepted by meaning).
6. **Verb forms:** Konjunktiv I in reported speech in non-fiction (*Rawls
   behauptet, die Vernunft sei …*); Konjunktiv II where Konjunktiv I equals
   the indicative (*sie hätten*); *würde*-forms acceptable in speech;
   perfect auxiliary *haben/sein* per overlay; tense consistency with
   `style.tense` in fiction.
7. **Sentence structure:** verb-final in subordinate clauses (fiction
   dialogue: query), *Satzklammer* not broken by unnecessary
   *Ausklammerung* in formal text, *als* (not *wie*) after comparatives
   (*größer als*).
8. **Punctuation and typography** per `conventions.md`: quotation marks,
   Gedankenstrich vs. hyphen, missing spaces in *z. B.*, *20 %*, apostrophe
   misuse.
9. **Gendering:** follow option `gendering` exactly and report
   inconsistency (two forms mixed, or a marker missing where the option
   requires one). With `none`, do not insert any form and do not report the
   author's own neutral forms (*Studierende*). The Council's official rules
   do not include gender characters (*:*, *\**); with `colon` or `asterisk`
   they are the author's choice, never an error.

## Do not report

- Correct allowed variants (*aufwendig/aufwändig*), unless mixed.
- Anything inside a quotation from a source, except a transcription error
  against the source note (the citation pass's job; mention it).
- Style preferences (Nominalstil, passive, word choice): the line editor's.
