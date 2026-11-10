#!/usr/bin/env bash
# cite-scan.sh — facts for /cite-check and the citation pass (spec §6.3, §6.4,
# §8.3, §2 principle 6). Reports; never judges.
#
#   cite-scan.sh [work [section...]]
#
# No work: every work. Sections are slugs (`03-objections`) or file names.
#
# Output, in `## section` blocks, one fact per line (tab-separated fields):
#   ## scope     files: <n>, then `file:` lines
#   ## cites     cite: <file>:<line> <key> <locator or -> <bracketed|textual>
#   ## keys      key: <key> <cites> bib=<yes|no> note=<yes|no> status=<…> kind=<…>
#                plus error:/warning:/note: lines per key
#   ## archive   error:/note: lines from `sha256sum -c` on the cited sources'
#                lines in compendium/archive.sha256, and unhashed files
#   ## quotes    quote: <file>:<line> <words> <cites in the paragraph> <text>
#                (quotations of 4+ words and block quotes: candidates for
#                Claude to compare with the note and the archived copy)
#
# Citekeys follow Pandoc: [@key, p. 3], [-@key], [@a; @b], @key, @{key}.
# Frontmatter, HTML comments and fenced code are skipped. Source-note fields
# read: status, archive.kind, archive.held (the flat hook-read subset).
#
# Exit: 0 done, 1 not set up, 2 usage. Bash 3.2-compatible. Read-only (one
# temporary directory, removed on exit).

set -u

root=${CLAUDE_PROJECT_DIR:-}
if [ -z "$root" ]; then
  root=$(cd "$(dirname "$0")/../.." && pwd) || { echo "error: cannot find the project root"; exit 2; }
fi
export CLAUDE_PROJECT_DIR=$root
# shellcheck source=../hooks/lib.sh
. "$root/.claude/hooks/lib.sh"
ws_init
cd "$WS_ROOT" || exit 2

[ -f studio.yaml ] || { echo "error: studio.yaml does not exist: the project is not set up (run /start)"; exit 1; }

TMPD=$(mktemp -d "$WS_TMP/ws-cite.XXXXXX") || { echo "error: cannot create a temporary directory"; exit 2; }
trap 'rm -r "$TMPD" 2>/dev/null' EXIT

# ------------------------------------------------------------------ scope
FILES=()
if [ "$#" -eq 0 ]; then
  for f in works/*/sections/*.md; do [ -f "$f" ] && FILES+=("$f"); done
else
  W=$1; shift
  case $W in */*|''|.*) echo "error: $W: not a work slug" >&2; exit 2 ;; esac
  [ -d "works/$W" ] || { echo "error: works/$W does not exist" >&2; exit 2; }
  if [ "$#" -eq 0 ]; then
    for f in "works/$W"/sections/*.md; do [ -f "$f" ] && FILES+=("$f"); done
  else
    for s in "$@"; do
      s=${s%.md}
      case $s in */*|.*|'') echo "error: $s: not a section slug" >&2; exit 2 ;; esac
      f="works/$W/sections/$s.md"
      [ -f "$f" ] || { echo "error: $f does not exist" >&2; exit 2; }
      FILES+=("$f")
    done
  fi
fi

echo "## scope"
echo "files: ${#FILES[@]}"
for f in ${FILES[@]+"${FILES[@]}"}; do echo "file: $f"; done

# ------------------------------------------------- citations and quotations
# Paragraph by paragraph (lines joined with "\n"), byte-wise (LC_ALL=C), so
# multi-byte quotation marks are matched as strings with index().
: > "$TMPD/scan"
if [ "${#FILES[@]}" -gt 0 ]; then
LC_ALL=C awk '
  function trim(s) { sub(/^[ \t\n]+/, "", s); sub(/[ \t\n]+$/, "", s); return s }
  function nl_before(pos,   s) { s = substr(par, 1, pos - 1); return gsub(/\n/, "", s) }
  function cleankey(k) {
    sub(/^-/, "", k); sub(/^@/, "", k)
    if (k ~ /^\{/) { sub(/^\{/, "", k); sub(/\}.*$/, "", k); return k }
    sub(/[:.#$%&+?<>~\/-]+$/, "", k)    # trailing punctuation is not part of the key
    return k
  }
  function emit_cite(pos, key, loc, form) {
    key = cleankey(key)
    if (key == "") return
    gsub(/[\t\n]+/, " ", loc)
    printf "cite\t%s:%d\t%s\t%s\t%s\n", cur, pstart + nl_before(pos), key, (loc == "" ? "-" : loc), form
    pcites = pcites (pcites == "" ? "" : "; ") key (loc == "" ? "" : " " loc)
  }
  function nwords(s,   t, a) { t = s; gsub(/[\n\t]/, " ", t); t = trim(t); return (t == "" ? 0 : split(t, a, / +/)) }
  function emit_quote(pos, text) {
    text = trim(text); gsub(/[\n\t]+/, " ", text)
    if (nwords(text) < 4) return
    nq++; qpos[nq] = pos; qtext[nq] = text
  }
  function isletter(c) { return c ~ /[A-Za-z0-9]/ || c > "\177" }
  # Paired marks found with index(); op and cl may be multi-byte.
  function pairs(op, cl,   from, i, j, rest) {
    from = 1
    while (1) {
      rest = substr(par, from); i = index(rest, op)
      if (!i) return
      i += from - 1
      rest = substr(par, i + length(op)); j = index(rest, cl)
      if (!j) return
      emit_quote(i, substr(rest, 1, j - 1))
      from = i + length(op) + j - 1 + length(cl)
    }
  }
  # Single marks: opens after space or bracket; an apostrophe (a letter
  # follows) is not a cl.
  function singles(op, cl,   p, n, c, prev, start, inq, lo, lc) {
    n = length(par); inq = 0; lo = length(op); lc = length(cl)
    for (p = 1; p <= n; p++) {
      if (inq && substr(par, p, lc) == cl) {
        c = substr(par, p + lc, 1)
        if (c == "" || !isletter(c)) { emit_quote(start - lo, substr(par, start, p - start)); inq = 0; p += lc - 1; continue }
      }
      if (!inq && substr(par, p, lo) == op) {
        prev = (p == 1 ? " " : substr(par, p - 1, 1))
        if (prev ~ /[ \t\n(\[]/) { inq = 1; start = p + lo; p += lo - 1 }
      }
    }
  }
  function flush(   s, m, grp, inner, n, parts, k, part, key, loc, i, blank) {
    if (par == "") return
    pcites = ""; nq = 0
    s = par
    # Bracketed groups holding a citekey; blanked out of s once read.
    while (match(s, /\[[^][]*@[^][]*\]/)) {
      grp = substr(s, RSTART, RLENGTH); m = RSTART; blank = RLENGTH
      inner = substr(grp, 2, length(grp) - 2)
      n = split(inner, parts, ";")
      for (k = 1; k <= n; k++) {
        part = parts[k]
        if (match(part, /(^|[^A-Za-z0-9_])-?@(\{[^}]*\}|[A-Za-z0-9_][A-Za-z0-9_:.#$%&+?<>~\/-]*)/)) {
          key = substr(part, RSTART, RLENGTH); loc = trim(substr(part, RSTART + RLENGTH))
          if (key !~ /^-?@/) key = substr(key, 2)
          sub(/^,[ \t\n]*/, "", loc)
          emit_cite(m, key, loc, "bracketed")
        }
      }
      s = substr(s, 1, m - 1) sprintf("%" blank "s", "") substr(s, m + blank)
    }
    # Textual citations: @key not preceded by a word character (not an e-mail).
    i = 0
    while (match(substr(s, i + 1), /(^|[^A-Za-z0-9_])-?@(\{[^}]*\}|[A-Za-z0-9_][A-Za-z0-9_:.#$%&+?<>~\/-]*)/)) {
      m = i + RSTART; key = substr(s, m, RLENGTH); i = m + RLENGTH - 1
      if (key !~ /^-?@/) { key = substr(key, 2); m++ }
      loc = ""
      if (match(substr(s, i + 1), /^[ \t]*\[[^]@]*\]/)) { loc = trim(substr(s, i + 1, RLENGTH)); sub(/^\[/, "", loc); sub(/\]$/, "", loc) }
      emit_cite(m, key, loc, "textual")
    }
    if (isblock) emit_quote(1, blocktext)
    pairs("\342\200\234", "\342\200\235")     # “ ”
    pairs("\342\200\236", "\342\200\234")     # „ “
    pairs("\302\273", "\302\253")             # » «
    pairs("\302\253", "\302\273")             # « »
    singles("\342\200\230", "\342\200\231")   # ‘ ’
    singles("\342\200\232", "\342\200\230")   # ‚ ‘
    singles("\047", "\047")                    # ASCII single quote
    # ASCII double quotes: alternate open and close.
    i = 0; k = 0
    while ((m = index(substr(par, i + 1), "\"")) > 0) {
      m += i
      if (!k) k = m; else { emit_quote(k, substr(par, k + 1, m - k - 1)); k = 0 }
      i = m
    }
    for (k = 1; k <= nq; k++)
      printf "quote\t%s:%d\t%d\t%s\t%s\n", cur, pstart + nl_before(qpos[k]), nwords(qtext[k]), (pcites == "" ? "-" : pcites), qtext[k]
    par = ""; isblock = 0; blocktext = ""
  }
  FNR == 1 { flush(); cur = FILENAME; inFM = 0; inCode = 0; inCom = 0 }
  { sub(/\r$/, "") }
  FNR == 1 { sub(/^\357\273\277/, "") }
  FNR == 1 && /^---[ \t]*$/ { inFM = 1; next }
  inFM { if (/^(---|\.\.\.)[ \t]*$/) inFM = 0; next }
  /^[ \t]*(```|~~~)/ { flush(); inCode = !inCode; next }
  inCode { next }
  inCom { c = index($0, "-->"); if (c) { inCom = 0; $0 = substr($0, c + 3) } else next }
  {
    while ((c = index($0, "<!--")) > 0) {
      e = index(substr($0, c + 4), "-->")
      if (e) $0 = substr($0, 1, c - 1) substr($0, c + 4 + e + 2)
      else { $0 = substr($0, 1, c - 1); inCom = 1; break }
    }
  }
  /^[ \t]*$/ { flush(); next }
  {
    if (par == "") { pstart = FNR; isblock = ($0 ~ /^[ \t]*>/) }
    else if (isblock && $0 !~ /^[ \t]*>/) isblock = 0
    if (isblock) { b = $0; sub(/^[ \t]*>[ \t]?/, "", b); blocktext = blocktext (blocktext == "" ? "" : "\n") b }
    par = par (par == "" ? "" : "\n") $0
  }
  END { flush() }
' "${FILES[@]}" > "$TMPD/scan" || echo "error: the citation scan failed; the results below are incomplete"
fi

echo "## cites"
awk -F '\t' '$1 == "cite" { print "cite: " $2 "\t" $3 "\t" $4 "\t" $5 }' "$TMPD/scan" | LC_ALL=C sort -t : -k2,2 -k3,3n -s

# ------------------------------------------------------------------- keys
# library.bib keys, source-note fields, and per-key findings. Writes the
# keys needing an archive check to $TMPD/archkeys.
echo "## keys"
BIB=compendium/library.bib
[ -f "$BIB" ] || echo "error: $BIB does not exist"
: >> "$TMPD/archkeys"
awk -F '\t' -v bib="$BIB" -v ak="$TMPD/archkeys" '
  function fm(key,   f, l, n, inA, k, v) {
    f = "compendium/sources/" key ".md"
    st[key] = "-"; kd[key] = "-"; hd[key] = ""; nk[key] = ""
    if ((getline l < f) < 0) { note[key] = 0; return }
    note[key] = 1; n = 0; inA = 0
    do {
      sub(/\r$/, "", l); n++
      if (n == 1) { sub(/^\357\273\277/, "", l); if (l !~ /^---[ \t]*$/) break; continue }
      if (l ~ /^---[ \t]*$/) break
      if (l ~ /^[^ \t#]/) inA = (l ~ /^archive:/)
      if (match(l, /^[ \t]*[A-Za-z_]+:/)) {
        k = substr(l, RSTART, RLENGTH - 1); v = substr(l, RSTART + RLENGTH)
        sub(/^[ \t]+/, "", k); sub(/[ \t]+#.*$/, "", v); sub(/^[ \t]+/, "", v); sub(/[ \t]+$/, "", v)
        if (v ~ /^".*"$/ || v ~ /^\047.*\047$/) v = substr(v, 2, length(v) - 2)
        if (l ~ /^[^ \t]/ && k == "status") st[key] = v
        if (l ~ /^[^ \t]/ && k == "citekey") nk[key] = v
        if (inA && l ~ /^[ \t]/ && k == "kind") kd[key] = v
        if (inA && l ~ /^[ \t]/ && k == "held") hd[key] = v
      }
    } while ((getline l < f) > 0)
    close(f)
  }
  BEGIN {
    while ((getline l < bib) > 0) {
      sub(/\r$/, "", l)
      if (match(l, /^[ \t]*@[A-Za-z]+[ \t]*[{(][ \t]*[^ \t,]+/)) {
        k = substr(l, RSTART, RLENGTH); sub(/^[^{(]*[{(][ \t]*/, "", k)
        if (tolower(k) ~ /^(comment|string|preamble)$/) continue
        if (l ~ /^[ \t]*@(comment|string|preamble|COMMENT|STRING|PREAMBLE)/) continue
        if (k in inbib) dupbib[k] = 1
        inbib[k] = 1
      }
    }
  }
  $1 == "cite" { n[$3]++; if (!($3 in first)) { first[$3] = $2; order[++nkeys] = $3 } }
  END {
    for (k in dupbib) printf "error: %s: more than one entry for %s\n", bib, k
    for (i = 1; i <= nkeys; i++) {
      key = order[i]; fm(key)
      printf "key: %s\t%d\tbib=%s\tnote=%s\tstatus=%s\tkind=%s\n", key, n[key], ((key in inbib) ? "yes" : "no"), (note[key] ? "yes" : "no"), st[key], kd[key]
      if (!(key in inbib)) printf "error: %s: no entry in %s (first cited at %s)\n", key, bib, first[key]
      if (!note[key]) { printf "error: %s: no source note compendium/sources/%s.md (first cited at %s)\n", key, key, first[key]; continue }
      if (nk[key] != "" && nk[key] != key) printf "error: %s: the note says citekey: %s\n", key, nk[key]
      if (st[key] != "verified") printf "error: %s: status is %s, not verified; cited %d time(s)\n", key, st[key], n[key]
      if (kd[key] == "physical") {
        if (hd[key] == "" || hd[key] == "null" || hd[key] == "~") printf "error: %s: kind physical but archive.held is empty\n", key
        else printf "warning: %s: kind physical (held: %s): no copy can be checked; quotations are checked against the note only\n", key, hd[key]
      } else if (kd[key] ~ /^(pdf|web|scan)$/) print key > ak
      else printf "error: %s: archive.kind is %s, not pdf, web, scan or physical\n", key, kd[key]
    }
    close(ak)
  }
' "$TMPD/scan"

# ---------------------------------------------------------------- archive
echo "## archive"
SUMS=compendium/archive.sha256
if [ -s "$TMPD/archkeys" ]; then
  if [ ! -f "$SUMS" ]; then
    echo "error: $SUMS does not exist: no cited source has an archived copy on record"
  else
    # Lines of the cited keys; keys without any line are errors.
    awk -v ak="$TMPD/archkeys" -v out="$TMPD/lines" '
      BEGIN { while ((getline k < ak) > 0) want["archive/" k "/"] = k }
      { sub(/\r$/, ""); f = $0; sub(/^[0-9A-Fa-f]+ [ *]/, "", f)
        if (f ~ /(^|\/)\.\.(\/|$)/) { for (p in want) if (index(f, p) == 1) printf "error: %s: path leaves the archive: %s\n", FILENAME, f; next }
        for (p in want) if (index(f, p) == 1) { print > out; has[want[p]] = 1 } }
      END { for (p in want) if (!(want[p] in has)) printf "error: %s: no line in compendium/archive.sha256 (nothing archived on record)\n", want[p]; close(out) }
    ' "$SUMS"
    if [ -s "$TMPD/lines" ]; then
      if command -v sha256sum >/dev/null 2>&1; then SHA=(sha256sum -c)
      elif command -v shasum >/dev/null 2>&1; then SHA=(shasum -a 256 -c)
      else SHA=(); echo "error: neither sha256sum nor shasum is available; archive copies not checked"
      fi
      if [ "${#SHA[@]}" -gt 0 ]; then
        (cd compendium && "${SHA[@]}" - < "$TMPD/lines" 2>&1) | tr -d '\r' | awk '
          /: OK$/ { ok++; next }
          /: FAILED open or read$/ { f = $0; sub(/: FAILED open or read$/, "", f); printf "error: compendium/%s: missing (listed in archive.sha256)\n", f; next }
          /: FAILED$/ { f = $0; sub(/: FAILED$/, "", f); printf "error: compendium/%s: checksum does not match archive.sha256 (file changed)\n", f; next }
          /WARNING:/ { next }
          /No such file/ { next }
          { printf "note: %s\n", $0 }
          END { printf "checked: %d file(s) OK\n", ok + 0 }'
      fi
    fi
    # Files under a cited key's folder with no checksum line.
    while IFS= read -r k; do
      [ -d "compendium/archive/$k" ] || { echo "note: compendium/archive/$k/ does not exist"; continue; }
      find "compendium/archive/$k" -type f | sed 's|^compendium/||' | while IFS= read -r f; do
        awk -v f="$f" '{ sub(/\r$/, ""); g = $0; sub(/^[0-9A-Fa-f]+ [ *]/, "", g); if (g == f) { found = 1; exit } } END { exit !found }' "$SUMS" \
          || echo "note: compendium/$f has no line in archive.sha256"
      done
    done < "$TMPD/archkeys"
  fi
fi

echo "## quotes"
awk -F '\t' '$1 == "quote" { print "quote: " $2 "\t" $3 "\t" $4 "\t" $5 }' "$TMPD/scan" | LC_ALL=C sort -t : -k2,2 -k3,3n -s
exit 0
