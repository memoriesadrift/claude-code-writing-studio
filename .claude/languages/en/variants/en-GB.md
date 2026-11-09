# en-GB overlay

Overlay for British English on the `en` pack (spec §4.5). Wins over the base
files wherever they differ; option values in force win over this file.

## Authority

Spelling: *Oxford English Dictionary* / *New Oxford Dictionary for Writers and
Editors*. Style: *New Hart's Rules* (Oxford).

## Spelling

- **-ise or -ize:** -ise by default (*organise*, *realise*, *recognise*).
  With option `ize_spelling: true` (Oxford spelling), use -ize
  (*organize*, *realize*) **except** for words where -ise is not a suffix,
  which keep -ise in every spelling: *advertise, advise, apprise, chastise,
  comprise, compromise, despise, devise, disguise, enterprise, excise,
  exercise, franchise, improvise, incise, merchandise, premise, revise,
  supervise, surmise, surprise, televise*.
- **-yse** always: *analyse*, *paralyse*, *catalyse* (also under Oxford
  spelling).
- British forms: *colour, honour, centre, metre, theatre, defence, offence,
  grey, travelled, cancelled, modelling, fulfil, enrol, skilful, programme*
  (but a computer *program*), *catalogue, dialogue, analogue, ageing,
  judgement* (but *judgment* in legal contexts), *aluminium, mould, plough,
  sceptical, tyre, kerb* (pavement edge), *cheque, manoeuvre, oestrogen*
  (medicine may prefer *estrogen*: follow the field).
- Noun/verb pairs: *licence/license*, *practice/practise*, *advice/advise*,
  *prophecy/prophesy*.
- *Whilst*, *amongst* and *towards* are correct; *while*, *among* are more
  usual in modern prose. Follow the author; flag mixing.

## Punctuation

- **Quotation marks:** single first (‘ ’), double inside (“ ”).
- **Order with other punctuation:** logical: a full stop or comma goes
  inside the closing quotation mark only if it belongs to the quoted
  material. *She called it ‘a triumph’.* / *‘It’s late,’ she said.* (dialogue
  keeps the comma inside).
- **Dashes:** spaced en dash for parenthesis – like this – not a closed em dash.
- **Serial comma:** off by default (`oxford_comma`); see `conventions.md`.
- **After e.g. and i.e.:** no comma.

## Abbreviations

- No full stop after contractions that end with the word's last letter:
  *Mr, Mrs, Ms, Dr, St, Ltd, eds, vols*. Full stop after truncations:
  *Prof.*, *ed.*, *vol.*, *p.*
- Time: *2.30 p.m.* or *14:30*; *9 a.m.*

## Numbers

- Non-fiction: spell out one to nine; figures from 10.

## Dates

- *9 November 2026* (no comma, no ordinal suffix); *Monday 9 November*.
- All-numeric: *09/11/2026* (day first), but prefer words in prose.

## Grammar

- Collective nouns may take a plural verb when the members are meant: *the
  government are divided*. Keep it consistent within a work.
- *Different from* or *different to*; *different than* is American.
- *Got* (not *gotten*), except in *ill-gotten*.
- *Should* in mandative clauses is normal (*insist that he should leave*);
  the subjunctive (*that he leave*) is also correct.
