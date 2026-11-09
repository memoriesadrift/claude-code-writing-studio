# German — conventions

Part of the `de` language pack (spec §4.5). Read together with the overlay for
the tag in force (`variants/<tag>.md`), which wins wherever the two differ.
Option values in force (`pack.yaml` explains the order) win over both.

These are house conventions for the author's text. Never apply them to
quotations from sources, which keep their original spelling (including
pre-1996 spelling) and punctuation.

## Authority

- Orthography: the official rules of the *Rat für deutsche Rechtschreibung*
  (amtliches Regelwerk, current edition). Reference dictionary: *Duden – Die
  deutsche Rechtschreibung*, unless the overlay names a national one.
- Where the rules allow variants (*Fotografie/Photographie*,
  *aufwendig/aufwändig*, *selbständig/selbstständig*), follow the author's
  first choice and flag only inconsistency. Duden's recommended variant
  (marked yellow) is the default for Claude-drafted text.
- If the author's style guide (`bible/style-guide.md`) says otherwise, the
  style guide wins.

## ß and ss

- ß after a long vowel or diphthong (*Straße*, *groß*, *heißen*, *außen*);
  ss after a short vowel (*Fluss*, *muss*, *dass*). Overlay `de-CH` replaces
  ß with ss throughout.
- In all capitals, ẞ or SS (*STRASSE* / *STRAẞE*): follow the author.

## Capitalisation

- Nouns and nominalisations: *das Laufen*, *im Allgemeinen*, *des Weiteren*,
  *im Folgenden*, *nichts Neues*, *beim Lesen*.
- Not nominalised: *ein bisschen*, *ein paar* (some), *recht haben* or
  *Recht haben* (both allowed), *heute Abend*, *zurzeit*.
- Polite address *Sie/Ihr/Ihnen* capitalised; *du/dein* lower case
  (capitalising in letters is allowed).
- Adjectives in fixed names capitalised (*der Erste Weltkrieg*, *das Rote
  Kreuz*); otherwise lower case (*die erste Seite*).

## Punctuation

- **Quotation marks:** „…“ (low-high) with ‚…‘ inside; in book typesetting
  also »…« with ›…‹ (pointing inwards). Overlay `de-CH` uses «…». Never
  straight " or English “…”.
- **Punctuation and closing quotes:** the full stop of the quoted sentence
  goes inside and the reporting sentence then takes none: *„Ich komme“, sagte
  sie.* / *Sie sagte: „Ich komme.“* A question mark of the quotation stays
  inside: *„Kommst du?“, fragte sie.*
- **Commas:** see `grammar.md`. No serial comma before *und/oder*.
- **Dashes:** spaced en dash (Halbgeviertstrich) as the Gedankenstrich –
  so –, and closed for ranges and *bis*: *S. 12–19*, *1914–1918*,
  *10–12 Uhr*. Never a hyphen for either.
- **Hyphen (Bindestrich):** in compounds with abbreviations, digits or for
  clarity (*US-Wahl*, *3-mal* or *dreimal*, *Ich-Erzähler*); never an open
  space inside a compound (*Lieblings Buch* → *Lieblingsbuch*).
- **Ellipsis:** …; with a space before when whole words are omitted
  (*Er dachte …*), without when part of a word is (*So ein Verfl…!*).
- **Apostrophe:** ’ only for omitted letters (*wie geht’s*, *’s war*) and for
  the genitive of names ending in s, ß, x, z (*Hans’ Buch*, *Marx’ Theorie*).
  No apostrophe in an ordinary genitive (*Annas Buch*) or plural (*die PCs*).

## Numbers

- Decimal comma (*3,5*); thousands separated by a (narrow) space or a full
  stop (*12 500* / *12.500*); four-digit numbers usually without. Overlay
  `de-CH` adds the apostrophe form.
- Spell out *eins* to *zwölf* in running text; figures from 13, and always
  for measurements, percentages, dates, page numbers. Consistency within a
  sentence wins.
- Space between number and unit or sign: *5 kg*, *20 %*, *3 €* (non-breaking).
- Ordinals with a full stop: *der 3. Mai*, *im 19. Jahrhundert*.

## Dates and times

- *9. November 2026*; *Montag, 9. November 2026*; numeric *09.11.2026*.
  Months per overlay (*Januar* / *Jänner*).
- *14:30 Uhr* or *14.30 Uhr*; *um 9 Uhr*.
- Decades: *die 1960er-Jahre* or *die 1960er Jahre*.

## Abbreviations

- With full stops and a (narrow, non-breaking) space between parts:
  *z. B.*, *d. h.*, *u. a.*, *s. o.*, *v. a.*, *bzw.*, *ca.*, *usw.*
- At the end of a sentence the abbreviation's full stop doubles as the
  sentence's.
- Acronyms without full stops: *EU*, *NATO*, *BGB*.

## Typography

- Italics for titles of works and for emphasis (sparingly); no underlining.
- Non-breaking spaces in *z. B.*, *S. 12*, *§ 5*, number + unit.
