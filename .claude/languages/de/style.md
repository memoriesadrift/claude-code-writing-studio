# German — line-editing notes

Part of the `de` language pack (spec §4.5). Read together with the overlay for
the tag in force (`variants/<tag>.md`), which wins wherever the two differ.
Option values in force (`pack.yaml` explains the order) win over both.

The line editor works on sentences: clarity, rhythm, register and voice. The
author's voice and the style guide outrank everything here: these are things
to notice, not rules to impose.

## Clarity

- **Nominalstil:** chains of *-ung/-heit/-keit* nouns with *Funktionsverben*
  (*zur Durchführung bringen* → *durchführen*; *eine Entscheidung treffen*
  → *entscheiden*). The main problem in German academic drafts.
- **Long middle field (Mittelfeld):** when the second part of the verb
  bracket comes after a long stretch (*Er hat das Buch, das …, gestern
  … zurückgegeben*), the reader waits too long for the verb. Suggest moving
  material to the front field or after the bracket.
- **Nested subordinate clauses** (*Schachtelsätze*): more than two levels
  deep, or a relative clause inside a *dass* clause inside another. Split.
- **Passive** that hides the agent when it matters (*Es wurde beschlossen*).
  The *Vorgangspassiv* is normal in academic method sections.
- **Genitive chains:** *die Analyse der Kritik der Theorie des Autors*.

## Economy

- **Füllwörter:** *eigentlich, halt, eben, quasi, sozusagen, gewissermaßen,
  irgendwie, im Prinzip, an sich*, *ja* outside dialogue.
- **Redundancy:** *bereits schon*, *zusammen gemeinsam*, *weiterhin
  fortsetzen*, *neu renoviert*.
- **Modal particles** (*doch, mal, ja, denn*) belong in dialogue and
  informal registers; flag them in formal non-fiction.

## Rhythm and repetition

- German style traditionally avoids repeating a word in close succession,
  but **not** for technical terms in non-fiction: a defined term must stay
  the same word. Never suggest a synonym for a key term.
- Vary sentence openings: the front field allows it (object, adverbial,
  subordinate clause first).

## Fiction

- **Redebegleitsätze:** *sagte* is invisible; flag strings of *zischte,
  erwiderte, entgegnete* and adverbial tags.
- **Filter verbs** in close POV: *sie sah, er spürte, sie bemerkte*.
- **Du/Sie** between characters must follow the relationship and change only
  at a deliberate moment (*das Du anbieten*); flag unmotivated switches.
- **Anglicisms and calques:** *Sinn machen* (standard: *Sinn ergeben*,
  though now common), *in 2026* (→ *2026* / *im Jahr 2026*), *am Ende des
  Tages*, *realisieren* for *bemerken*. Flag in narration; in dialogue they
  may be voice.
- **Tempus:** narration in Präteritum is the norm; Perfekt in narration reads
  as spoken. Check against `style.tense`.

## Register

- `style.register` is free text: *formell* → no colloquialisms, no
  contractions such as *geht's* outside dialogue; *umgangssprachlich* →
  allowed.
- Keep the form of address towards the reader (*Sie*, *du*, none) consistent
  throughout a work.
