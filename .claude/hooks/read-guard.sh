#!/usr/bin/env bash
# read-guard — PreToolUse on Read (spec §10).
#
# A whole-file Read (no offset/limit) of a prose, bible or compendium file over
# MAX_LINES lines or MAX_BYTES bytes is denied, and the denial lists the file's
# headings with line numbers so the retry reads one section with offset/limit.
# Small files, ranged reads, files with no headings, compendium/archive/ and
# compendium/inbox/ always pass. Without jq it passes with a warning.

MAX_LINES=400
MAX_BYTES=32768
MAX_LISTED=150

. "${BASH_SOURCE%/*}/lib.sh"
ws_init
ws_read_input

ws_mentions_studio || exit 0

ws_find_jq
if [ -z "$WS_JQ" ]; then
  ws_warn "jq is not installed, so read-guard cannot check this Read; run /start to install jq."
  exit 0
fi

{
  IFS= read -r -d '' TOOL
  IFS= read -r -d '' FILE
  IFS= read -r -d '' RANGED
} < <(printf '%s' "$WS_IN" | "$WS_JQ" -j '
  [ .tool_name, (.tool_input.file_path // ""),
    ((.tool_input.offset != null) or (.tool_input.limit != null) or (.tool_input.pages != null)) ]
  | map(tostring + "\u0000") | add')

[ "$TOOL" = Read ] && [ "$RANGED" = false ] && [ -n "$FILE" ] || exit 0
ws_relpath "$FILE"
[ -n "$WS_REL" ] || exit 0
ws_classify "$WS_REL"
REL_LC=$WS_REL; [ "$WS_WINDOWS" = 1 ] && REL_LC=${REL_LC,,}
case $WS_AREA in
  prose|bible) ;;
  compendium) case $REL_LC in compendium/archive/*|compendium/inbox/*) exit 0 ;; esac ;;
  *) exit 0 ;;
esac
case $REL_LC in
  *.md) KIND=md ;; *.yaml|*.yml) KIND=yaml ;; *.bib) KIND=bib ;; *) exit 0 ;;
esac
ABS="$WS_ROOT/$WS_REL"
[ -f "$ABS" ] || exit 0

# One awk pass: size, and the headings if the file is too large.
OUT=$(awk -v kind="$KIND" -v maxl="$MAX_LINES" -v maxb="$MAX_BYTES" -v maxlist="$MAX_LISTED" '
  { b += length($0) + 1; line = $0; sub(/\r$/, "", line) }
  NR == 1 { sub(/^\357\273\277/, "", line); if (line == "---") { fm = 1; next } }
  fm { if (line == "---") fm = 0; next }
  kind == "md" && line ~ /^(```|~~~)/ { code = !code; next }
  code { next }
  kind == "md"   && line ~ /^#{1,6}[ \t]/                 { h[++n] = NR "\t" line; next }
  kind == "yaml" && line ~ /^-[ \t]+id:/                  { h[++n] = NR "\t" line; next }
  kind == "yaml" && line ~ /^[A-Za-z_][A-Za-z0-9_ -]*:/   { t[++m] = NR "\t" line; next }
  kind == "bib"  && line ~ /^@[A-Za-z]+[ \t]*[{(]/        { h[++n] = NR "\t" line; next }
  END {
    if (NR <= maxl && b <= maxb) exit
    if (n == 0) { for (i = 1; i <= m; i++) h[i] = t[i]; n = m }
    if (n == 0) exit
    print NR "\t" b "\t" n
    for (i = 1; i <= n && i <= maxlist; i++) print h[i]
  }' "$ABS")

[ -n "$OUT" ] || exit 0

IFS=$'\t' read -r NLINES NBYTES NHEAD <<< "${OUT%%$'\n'*}"
LIST=${OUT#*$'\n'}
LIST=${LIST//$'\t'/  }
MORE=""
[ "$NHEAD" -gt "$MAX_LISTED" ] && MORE=$'\n'"… and $((NHEAD - MAX_LISTED)) more; read further with offset past line ${LIST##*$'\n'}"
MORE=${MORE%%  *}

ws_deny "$WS_REL is $NLINES lines (~$((NBYTES / 1024)) KB), too large to read whole. Read only the part you need with Read offset/limit: offset = the heading's line, limit = lines up to the next heading. (To read the whole file anyway, read it in ranges.) Headings, by line:
$LIST$MORE"
