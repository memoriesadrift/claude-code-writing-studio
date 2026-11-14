#!/usr/bin/env bash
# import-draft.sh — copy the author's own text into the studio, verbatim
# (development-flow §10). The only way /import puts prose on disk: Claude never
# retypes the author's text. The prose guard allows exactly this script at
# every prose level (§12).
#
#   import-draft.sh draft <source> [--omit N[,N…]] [--lock] <target>:<from>-<to> …
#   import-draft.sh note  <source> <dest>
#
# draft  Splits <source> at the given line ranges into prose files:
#        manuscript/chNN-slug/scNN-slug.md (fiction) or
#        works/<work>/sections/NN-slug.md (non-fiction; the work must exist).
#        The ranges, in the order given, must cover lines 1..N of the source
#        exactly (contiguous, no overlap). --omit drops lines that are not
#        prose: headings (#…), scene breaks (***, * * *, ---, ~~~, #), blank
#        lines, or a leading YAML frontmatter block; any other line is
#        refused. Each file gets only the frontmatter `prose: author` and
#        `locked: false` (`true` with --lock), then a blank line, then its
#        lines.
# note   Copies <source> to ideas/<name> (fiction) or compendium/inbox/<name>
#        (non-fiction).
#
# Both: the source is normalised (a UTF-8 BOM removed, CRLF → LF, a final
# newline added) and the output says so; nothing else about the text changes.
# Never overwrites: any existing target refuses the whole run before anything
# is written. Files are built in a temporary folder and checked — their
# bodies joined must equal the normalised source minus the omitted lines —
# then moved into place and checked again; on any mismatch the run's output
# is deleted. One line per file is appended to session/provenance.jsonl with
# tool "import", added 0 and the word count as imported_words: imported text
# is the author's, never counted as Claude's.
#
# Output: `normalised:`, `omitted: <line>\t<text>`, `imported: <path>\tlines
# <a>-<b>\t<n> words`, `provenance: <n> line(s)`; errors as `error: …`
# (exit 1). Run from the project root. Bash 3.2-compatible; no jq.

set -u
export LC_ALL=C

die() { printf 'error: %s\n' "$1"; exit 1; }

[ -f studio.yaml ] || die "studio.yaml not found: run from the project root of a set-up studio"
. "$(dirname "$0")/lib-units.sh"
FORM=$(wu_yget studio.yaml project form)
case $FORM in nonfiction) NF=1 ;; ''|null) die "studio.yaml has no project.form" ;; *) NF=0 ;; esac

MODE=${1:-}; [ $# -ge 1 ] && shift
case $MODE in
  draft|note) ;;
  *) die "usage: import-draft.sh draft <source> [--omit N[,N…]] [--lock] <target>:<from>-<to> … | note <source> <dest>" ;;
esac

SRC=${1:-}; [ $# -ge 1 ] && shift
[ -n "$SRC" ] || die "no source file given"
[ -f "$SRC" ] || die "source not found or not a file: $SRC"
[ -r "$SRC" ] || die "source not readable: $SRC"
case $SRC in *[[:cntrl:]]*) die "the source path contains a control character" ;; esac
if [ "$(tr -d '\000' < "$SRC" | wc -c)" -ne "$(wc -c < "$SRC")" ]; then
  die "$SRC is not a text file (it contains NUL bytes). Convert it to Markdown first"
fi

TMP=$(mktemp -d "${TMPDIR:-/tmp}/ws-import.XXXXXX") || die "could not create a temporary folder"
trap 'rm -f "$TMP"/* 2>/dev/null; rmdir "$TMP" 2>/dev/null' EXIT

# ---- normalise: BOM, CRLF, final newline
awk '{ if (NR == 1) sub(/^\357\273\277/, ""); sub(/\r$/, ""); print }' "$SRC" > "$TMP/src"
if ! cmp -s "$SRC" "$TMP/src"; then
  WHAT=""
  [ "$(head -c 3 "$SRC" | od -An -tx1 | tr -d ' \n')" = efbbbf ] && WHAT="$WHAT BOM removed;"
  [ "$(tr -cd '\r' < "$SRC" | wc -c)" -gt 0 ] && WHAT="$WHAT CRLF → LF;"
  [ -s "$SRC" ] && [ "$(tail -c 1 "$SRC" | od -An -tx1 | tr -d ' \n')" != 0a ] && WHAT="$WHAT final newline added;"
  printf 'normalised:%s\n' "${WHAT%;}"
fi
N=$(wc -l < "$TMP/src" | tr -d ' ')
[ "$N" -gt 0 ] || die "$SRC is empty"

json_str() { # JSON string for a path (control characters already refused)
  local s=${1//\\/\\\\}; s=${s//\"/\\\"}; printf '"%s"' "$s"
}
NOW=$(date -u +%Y-%m-%dT%H:%M:%SZ)
PROV=""
prov_line() { # <file> <area> <work or ""> <words>
  local w=null; [ -n "$3" ] && w="\"$3\""
  PROV="$PROV{\"ts\":\"$NOW\",\"session\":null,\"file\":$(json_str "$1"),\"area\":\"$2\",\"work\":$w,\"level\":\"n/a\",\"level_source\":null,\"capped\":false,\"tool\":\"import\",\"added\":0,\"removed\":0,\"imported_words\":$4,\"source\":$(json_str "$SRC")}
"
}
write_prov() {
  mkdir -p session || die "could not create session/"
  printf '%s' "$PROV" >> session/provenance.jsonl || die "the files were imported, but session/provenance.jsonl could not be written"
  printf 'provenance: %s line(s)\n' "$(printf '%s' "$PROV" | grep -c .)"
}

# ================================================================== note
if [ "$MODE" = note ]; then
  DEST=${1:-}
  [ $# -eq 1 ] || die "note takes exactly one destination"
  if [ "$NF" = 1 ]; then ROOT=compendium/inbox AREA=compendium; else ROOT=ideas AREA=ideas; fi
  case $DEST in
    "$ROOT"/*) NAME=${DEST#"$ROOT"/} ;;
    *) die "a note goes to $ROOT/<name> in this project, not $DEST" ;;
  esac
  printf '%s' "$NAME" | grep -Eq '^[A-Za-z0-9][A-Za-z0-9._-]{0,99}$' \
    || die "note name must be letters, digits, dot, hyphen or underscore (no folders): $NAME"
  [ -e "$DEST" ] && die "$DEST already exists; the import never overwrites. Choose another name"
  mkdir -p "$ROOT" || die "could not create $ROOT/"
  cp "$TMP/src" "$TMP/out" && cmp -s "$TMP/src" "$TMP/out" || die "could not copy the source"
  [ -e "$DEST" ] && die "$DEST appeared during the run; nothing was written"
  mv "$TMP/out" "$DEST" || die "could not write $DEST"
  if ! cmp -s "$TMP/src" "$DEST"; then rm -f "$DEST"; die "$DEST did not match the source after writing and was deleted"; fi
  printf 'imported: %s\tlines 1-%s\t%s words\n' "$DEST" "$N" "$(wc -w < "$DEST" | tr -d ' ')"
  prov_line "$DEST" "$AREA" "" "$(wc -w < "$DEST" | tr -d ' ')"
  write_prov
  exit 0
fi

# ================================================================== draft
OMIT=" " LOCK=false TARGETS=""
while [ $# -gt 0 ]; do
  case $1 in
    --omit)  [ $# -ge 2 ] || die "--omit needs a list of line numbers"
             printf '%s' "$2" | grep -Eq '^[0-9]+(,[0-9]+)*$' || die "--omit takes line numbers separated by commas: $2"
             OMIT="$OMIT$(printf '%s' "$2" | tr ',' ' ') "; shift 2 ;;
    --omit=*) V=${1#--omit=}
             printf '%s' "$V" | grep -Eq '^[0-9]+(,[0-9]+)*$' || die "--omit takes line numbers separated by commas: $V"
             OMIT="$OMIT$(printf '%s' "$V" | tr ',' ' ') "; shift ;;
    --lock)  LOCK=true; shift ;;
    -*)      die "unknown option: $1" ;;
    *)       TARGETS="$TARGETS$1
"; shift ;;
  esac
done
[ -n "$TARGETS" ] || die "no targets given (<target>:<from>-<to>)"

# ---- omitted lines: in range, and not prose
FM_END=0
if [ "$(sed -n 1p "$TMP/src")" = "---" ]; then
  FM_END=$(awk 'NR > 1 && /^(---|\.\.\.)$/ { print NR; exit }' "$TMP/src")
  FM_END=${FM_END:-0}
fi
for L in $OMIT; do
  L=$((10#$L))
  { [ "$L" -ge 1 ] && [ "$L" -le "$N" ]; } || die "--omit line $L is outside the source (1-$N)"
  T=$(sed -n "${L}p" "$TMP/src")
  if [ "$FM_END" -gt 0 ] && [ "$L" -le "$FM_END" ]; then continue; fi
  printf '%s\n' "$T" | grep -Eq '^(#{1,6}([[:space:]].*)?|[[:space:]]*|[[:space:]]*(\*[[:space:]]*){3,}|[[:space:]]*(-[[:space:]]*){3,}|[[:space:]]*(~[[:space:]]*){3,}|[[:space:]]*#[[:space:]]*)$' \
    || die "line $L is prose, not a heading, scene break, blank line or frontmatter, and cannot be omitted: $T"
done
OMIT_SORTED=$(printf '%s\n' $OMIT | awk 'NF { print $1 + 0 }' | sort -n -u | tr '\n' ' ')

# ---- targets: shape, form, existence, ranges
EXPECT=1 SEEN=" " i=0 LIST=""
while IFS= read -r T; do
  [ -n "$T" ] || continue
  i=$((i + 1))
  case $T in *:*-*) ;; *) die "target must be <path>:<from>-<to>: $T" ;; esac
  P=${T%:*} R=${T##*:}
  A=${R%-*} B=${R#*-}
  printf '%s %s' "$A" "$B" | grep -Eq '^[0-9]+ [0-9]+$' || die "bad line range in $T"
  A=$((10#$A)) B=$((10#$B))
  WORK=""
  if [ "$NF" = 1 ]; then
    printf '%s' "$P" | grep -Eq '^works/[a-z][a-z0-9-]{0,39}/sections/[0-9]{2}-[a-z0-9]+(-[a-z0-9]+)*\.md$' \
      || die "not a section path (works/<work>/sections/NN-slug.md): $P"
    WORK=${P#works/}; WORK=${WORK%%/*}
    [ -f "works/$WORK/work.yaml" ] || die "works/$WORK does not exist; create the work with /new-work first"
  else
    printf '%s' "$P" | grep -Eq '^manuscript/ch[0-9]{2}-[a-z0-9]+(-[a-z0-9]+)*/sc[0-9]{2}-[a-z0-9]+(-[a-z0-9]+)*\.md$' \
      || die "not a unit path (manuscript/chNN-slug/scNN-slug.md): $P"
  fi
  case $SEEN in *" $P "*) die "target named twice: $P" ;; esac
  SEEN="$SEEN$P "
  [ -e "$P" ] && die "$P already exists; the import never overwrites. Nothing was written"
  [ "$A" -le "$B" ] || die "range $A-$B in $T runs backwards"
  [ "$A" -eq "$EXPECT" ] || die "ranges must be contiguous from line 1: $T starts at $A, expected $EXPECT"
  [ "$B" -le "$N" ] || die "range in $T ends at $B, past the end of the source ($N lines)"
  EXPECT=$((B + 1))
  LIST="$LIST$i	$P	$A	$B	$WORK
"
done <<EOF
$TARGETS
EOF
[ "$EXPECT" -eq $((N + 1)) ] || die "ranges end at line $((EXPECT - 1)), but the source has $N lines: every line must be imported or omitted"

# ---- build in the temporary folder
keep() { # <from> <to>: the lines of the range, minus omitted ones
  awk -v a="$1" -v b="$2" -v om="$OMIT_SORTED" '
    BEGIN { n = split(om, o, " "); for (k = 1; k <= n; k++) skip[o[k]] = 1 }
    NR >= a && NR <= b && !(NR in skip)' "$TMP/src"
}
: > "$TMP/joined"
while IFS='	' read -r i P A B WORK; do
  [ -n "$i" ] || continue
  keep "$A" "$B" > "$TMP/body.$i"
  [ -s "$TMP/body.$i" ] || die "$P would be empty after omitting lines $A-$B"
  { printf -- '---\nprose: author\nlocked: %s\n---\n\n' "$LOCK"; cat "$TMP/body.$i"; } > "$TMP/out.$i"
  tail -n +6 "$TMP/out.$i" >> "$TMP/joined"
done <<EOF
$LIST
EOF
keep 1 "$N" > "$TMP/expected"
cmp -s "$TMP/expected" "$TMP/joined" || die "the split files do not join back to the source; nothing was written"

for L in $OMIT_SORTED; do printf 'omitted: %s\t%s\n' "$L" "$(sed -n "${L}p" "$TMP/src")"; done

# ---- move into place, check, roll back on mismatch
WRITTEN=""
rollback() {
  local f
  while IFS= read -r f; do [ -n "$f" ] && rm -f "$f" && rmdir "${f%/*}" 2>/dev/null; done <<EOF
$WRITTEN
EOF
  die "$1; the files this run wrote were deleted"
}
while IFS='	' read -r i P A B WORK; do
  [ -n "$i" ] || continue
  [ -e "$P" ] && rollback "$P appeared during the run"
  mkdir -p "${P%/*}" || rollback "could not create ${P%/*}"
  mv "$TMP/out.$i" "$P" || rollback "could not write $P"
  WRITTEN="$WRITTEN$P
"
done <<EOF
$LIST
EOF
: > "$TMP/check"
while IFS='	' read -r i P A B WORK; do
  [ -n "$i" ] || continue
  tail -n +6 "$P" >> "$TMP/check"
done <<EOF
$LIST
EOF
cmp -s "$TMP/expected" "$TMP/check" || rollback "the written files do not match the source"

while IFS='	' read -r i P A B WORK; do
  [ -n "$i" ] || continue
  W=$(wc -w < "$TMP/body.$i" | tr -d ' ')
  printf 'imported: %s\tlines %s-%s\t%s words\n' "$P" "$A" "$B" "$W"
  prov_line "$P" prose "$WORK" "$W"
done <<EOF
$LIST
EOF
write_prov
