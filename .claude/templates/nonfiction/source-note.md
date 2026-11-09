---
citekey: {{citekey}}
status: unverified       # (hook-read) unverified | verified — only the AUTHOR sets verified
read: {{skimmed | partial | full}}
language: {{bcp47}}      # language of the source itself
tags: []
archive:
  kind: {{pdf | web | scan | physical}}   # (hook-read)
  files: []              # relative to archive/{{citekey}}/; hashes in compendium/archive.sha256
  retrieved: null        # required for kind: web (YYYY-MM-DD)
  url: null              # required for kind: web
  held: null             # (hook-read) required for kind: physical — where the print copy is
  captured_by: author    # author | claude — a Claude capture does not count until the author confirms it
  cited_capture: null    # kind: web with several captures: which file the citations use
---
# {{short reference, e.g. Rawls (1993), Political Liberalism}}

<!--
Everything above "Author's assessment" records what the SOURCE says.
The author's opinion goes only under "Author's assessment" (spec §6.1).
-->

## Summary
{{what the source argues, in the source's terms}}

## Key arguments
- {{argument}} ({{locator}})

## Quotations
<!--
Original language. Every quotation needs a locator (page, section or
paragraph); one without cannot be cited (spec §6.3). Direct quotation in
prose is only from this section (spec §9).
-->
- "{{quotation}}" — {{p. 137}}

## Author's assessment
{{what the author thinks of it: strengths, weaknesses, how it will be used}}

## Links
- **Concepts:** [[{{concept-slug}}]]
- **Claims:** {{C-014}}
- **Positions:** [[{{position-slug}}]]
- **Sources:** @{{other-citekey}} — {{relation: replies to, extends, criticises}}
