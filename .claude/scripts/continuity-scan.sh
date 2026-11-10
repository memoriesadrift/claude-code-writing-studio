#!/usr/bin/env bash
# continuity-scan.sh — facts for /continuity-check (spec §8.2, §2 principle 6).
# Reports; never judges.
#
#   continuity-scan.sh [summary] [path...]  < registry.tsv
#
# `summary` leaves out the per-file `at:` lines (use it on a whole manuscript,
# then re-run on the units that matter).
#
# Paths are manuscript files or folders (default: manuscript). The registry is
# NOT parsed here: Claude reads bible/registry.yaml (full YAML) and passes what
# the scan needs on stdin, one tab-separated record per line:
#
#   entity <TAB> <id> <TAB> <bible path, or ->
#   alias  <TAB> <id> <TAB> <text>               (the name and every alias)
#   source <TAB> <id> <TAB> <fact key> <TAB> <source>
#
# Output, in `## section` blocks, one fact per line:
#   ## scope      files: <n>, then one `file:` line each
#   ## registry   error:/note: lines about the records themselves
#   ## hits       entity: <id> <TAB> <hits> <TAB> <files>
#                 at: <id> <TAB> <file> <TAB> <line,line,…> <TAB> <aliases seen>
#   ## absent     absent: <id>   (aliases given, no hit in scope)
#
# Matching is whole-word and case-sensitive; an alias that starts with a
# lower-case letter is also matched capitalised (sentence start).
#
# Exit: 0 done, 1 not set up, 2 usage. Bash 3.2-compatible. Writes nothing in
# the project (one temporary file, removed on exit).

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

if [ -t 0 ]; then
  echo "usage: continuity-scan.sh [summary] [path...] < registry.tsv   (records on stdin; see the header)" >&2
  exit 2
fi

TMPD=$(mktemp -d "$WS_TMP/ws-scan.XXXXXX") || { echo "error: cannot create a temporary directory"; exit 2; }
trap 'rm -r "$TMPD" 2>/dev/null' EXIT
IN=$TMPD/in.tsv
PAT=$TMPD/patterns
tr -d '\r' > "$IN"

# ------------------------------------------------------------------ scope
SUMMARY=0
if [ "${1:-}" = summary ]; then SUMMARY=1; shift; fi
[ "$#" -gt 0 ] || set -- manuscript
FILES=()
for p in "$@"; do
  p=${p//\\//}; p=${p#./}; p=${p%/}
  case $p in
    manuscript|manuscript/*) ;;
    *) echo "error: $p: not under manuscript/" >&2; exit 2 ;;
  esac
  if [ -d "$p" ]; then
    while IFS= read -r f; do FILES+=("$f"); done < <(find "$p" -type f -name '*.md' | LC_ALL=C sort)
  elif [ -f "$p" ]; then
    FILES+=("$p")
  else
    echo "error: $p does not exist" >&2; exit 2
  fi
done

echo "## scope"
echo "files: ${#FILES[@]}"
for f in ${FILES[@]+"${FILES[@]}"}; do echo "file: $f"; done

# --------------------------------------------------------------- registry
# Checks the records and writes the grep pattern file (one line per form).
echo "## registry"
awk -F '\t' -v pat="$PAT" '
  function exists(p,   l, r) { r = (getline l < p); close(p); return r >= 0 }
  function capfirst(s) { return toupper(substr(s, 1, 1)) substr(s, 2) }
  $1 == "" { next }
  $1 == "entity" {
    id = $2
    if (id in seen) printf "error: duplicate id %s\n", id
    seen[id] = 1
    if (id !~ /^(char|place|rule|item|org|event)-[a-z0-9]+(-[a-z0-9]+)*$/)
      printf "error: id %s: not <prefix>-<slug> (char|place|rule|item|org|event, lower-case ASCII)\n", id
    if ($3 != "" && $3 != "-" && !exists($3)) printf "error: %s: bible entry %s does not exist\n", id, $3
    next
  }
  $1 == "alias" {
    id = $2; a = $3
    if (a == "") { printf "error: %s: empty alias\n", id; next }
    aliased[id] = 1; refd[id] = 1
    k = tolower(a)
    if ((k in owner) && owner[k] != id && index(" " clash[k] " ", " " id " ") == 0) {
      clash[k] = clash[k] " " id
    } else if (!(k in owner)) { owner[k] = id; shown[k] = a }
    if (!((a SUBSEP id) in done)) {
      done[a SUBSEP id] = 1
      print a > pat
      if (a ~ /^[a-z]/) print capfirst(a) > pat
    }
    next
  }
  $1 == "source" {
    id = $2; refd[id] = 1; s = $4
    if (s == "" || s == "null") next
    if (s ~ /^bible\//) { if (!exists(s)) printf "error: %s.%s: source %s does not exist\n", id, $3, s }
    else if (s ~ /^[^\/]+\/[^\/]+$/) { if (!exists("manuscript/" s ".md")) printf "error: %s.%s: source unit %s has no file manuscript/%s.md\n", id, $3, s, s }
    else printf "note: %s.%s: source %s is neither <chapter>/<unit> nor a bible/ path\n", id, $3, s
    next
  }
  { printf "error: unknown record type \"%s\" (entity | alias | source)\n", $1 }
  END {
    for (k in clash) printf "error: alias \"%s\" belongs to %s%s\n", shown[k], owner[k], clash[k]
    for (id in refd) if (!(id in seen)) printf "error: %s: alias or fact for an id with no entity record\n", id
    for (id in seen) if (!(id in aliased)) printf "note: %s has no name or aliases to search for\n", id
    close(pat)
  }
' "$IN" | LC_ALL=C sort

# ------------------------------------------------------------------- hits
echo "## hits"
: >> "$PAT"
if [ "${#FILES[@]}" -gt 0 ] && [ -s "$PAT" ]; then
  # file:line:match — -H so a single file still prints its name.
  grep -H -n -o -w -F -f "$PAT" -- "${FILES[@]}" 2>/dev/null > "$TMPD/hits"
fi
: >> "$TMPD/hits"
tr -d '\r' < "$TMPD/hits" | awk -F '\t' -v in_f="$IN" '
  function capfirst(s) { return toupper(substr(s, 1, 1)) substr(s, 2) }
  BEGIN {
    while ((getline r < in_f) > 0) {
      n = split(r, x, "\t")
      if (x[1] == "alias" && x[3] != "") {
        ids[x[3]] = ids[x[3]] " " x[2]
        if (x[3] ~ /^[a-z]/) ids[capfirst(x[3])] = ids[capfirst(x[3])] " " x[2]
        hasalias[x[2]] = 1
      }
    }
    close(in_f)
  }
  {
    # Split "file:line:match" from the right of the file part: the file is
    # everything before ":<digits>:".
    if (!match($0, /:[0-9]+:/)) next
    f = substr($0, 1, RSTART - 1)
    ln = substr($0, RSTART + 1, RLENGTH - 2)
    m = substr($0, RSTART + RLENGTH)
    n = split(ids[m], list, " ")
    for (i = 1; i <= n; i++) {
      id = list[i]; key = id SUBSEP f
      hits[id]++
      if (!(key in lines)) { files[id]++; order[id] = order[id] SUBSEP f; lines[key] = ln }
      else if (index("," lines[key] ",", "," ln ",") == 0) lines[key] = lines[key] "," ln
      if (index("|" seenas[key] "|", "|" m "|") == 0) seenas[key] = (seenas[key] == "" ? m : seenas[key] "|" m)
    }
  }
  END {
    for (id in hits) {
      # Sort key (id, kind, file order) in front; cut off after sorting.
      printf "%s\t0\t0\tentity: %s\t%d\t%d\n", id, id, hits[id], files[id]
      n = split(substr(order[id], 2), fl, SUBSEP)
      for (i = 1; i <= n; i++) printf "%s\t1\t%d\tat: %s\t%s\t%s\t%s\n", id, i, id, fl[i], lines[id SUBSEP fl[i]], seenas[id SUBSEP fl[i]]
    }
    print "--absent--"
    for (id in hasalias) if (!(id in hits)) printf "absent: %s\n", id
  }
' > "$TMPD/out"
sed '/^--absent--$/,$d' "$TMPD/out" | LC_ALL=C sort -t "$(printf '\t')" -k1,1 -k2,2n -k3,3n | cut -f 4- |
  if [ "$SUMMARY" = 1 ]; then grep -v '^at: '; else cat; fi
echo "## absent"
sed '1,/^--absent--$/d' "$TMPD/out" | LC_ALL=C sort
exit 0
