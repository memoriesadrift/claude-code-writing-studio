#!/usr/bin/env bash
# csl-fetch.sh — fetch one CSL style from the pinned commit in .claude/tools.yaml
# (spec §8.4). Run only with the author's approval: it downloads from the
# network and writes .claude/csl/<id>.csl (and its parent, for a dependent
# style). It does NOT edit tools.yaml: it prints the lines /publish proposes
# to add under csl.fetched, after "May I write?".
#
#   csl-fetch.sh <style-id>
#
# Output:
#   fetched: <id> <TAB> .claude/csl/<id>.csl <TAB> sha256 <hash> [<TAB> dependent on <parent>]
#   exists: <id> <TAB> .claude/csl/<id>.csl   (already there; not fetched again)
#   record: <yaml line>                         lines to add under `csl.fetched:`
# Exit: 0 done, 1 failed (not found, not a CSL file, network), 2 usage.

set -u

root=${CLAUDE_PROJECT_DIR:-}
if [ -z "$root" ]; then
  root=$(cd "$(dirname "$0")/../.." && pwd) || { echo "error: cannot find the project root"; exit 2; }
fi
cd "$root" || exit 2

ID=${1:-}
case $ID in ''|*[!a-z0-9-]*|-*) echo "usage: csl-fetch.sh <style-id>   (lower-case letters, digits, hyphens)" >&2; exit 2 ;; esac

RAW=$(awk '{ sub(/\r$/, "") } /^csl:/ { on = 1; next } /^[^ \t#]/ { on = 0 }
  on && /^  raw_url:/ { v = $0; sub(/^  raw_url:[ \t]*/, "", v); sub(/[ \t]+#.*$/, "", v); print v; exit }' .claude/tools.yaml)
case $RAW in https://raw.githubusercontent.com/citation-style-language/styles/*) ;; *) echo "error: .claude/tools.yaml has no csl.raw_url on raw.githubusercontent.com"; exit 1 ;; esac

if command -v sha256sum >/dev/null 2>&1; then hash_of() { sha256sum "$1" | awk '{ print $1 }'; }
elif command -v shasum >/dev/null 2>&1; then hash_of() { shasum -a 256 "$1" | awk '{ print $1 }'; }
else echo "error: neither sha256sum nor shasum is available"; exit 1; fi

mkdir -p .claude/csl
TMP=".claude/csl/.download-$$"
trap 'rm -f "$TMP" 2>/dev/null' EXIT

# get <id> → writes .claude/csl/<id>.csl; sets KIND (independent|dependent), PARENT
get() {
  local id=$1 dest=".claude/csl/$1.csl" url
  KIND=""; PARENT=""
  if [ -f "$dest" ]; then
    printf 'exists: %s\t%s\n' "$id" "$dest"
  else
    for url in "$RAW/$id.csl" "$RAW/dependent/$id.csl"; do
      if curl -fsSL --proto '=https' --tlsv1.2 --retry 2 --max-time 30 -o "$TMP" "$url" 2>/dev/null; then break; fi
      rm -f "$TMP"
    done
    [ -f "$TMP" ] || { echo "error: $id not found at the pinned commit (neither $id.csl nor dependent/$id.csl)"; return 1; }
    grep -q '<style' "$TMP" || { echo "error: the download for $id is not a CSL style"; rm -f "$TMP"; return 1; }
    mv "$TMP" "$dest"
  fi
  PARENT=$(sed -n '/rel="independent-parent"/s/.*href="[^"]*\/styles\/\([a-z0-9-]*\)".*/\1/p' "$dest" | head -1)
  H=$(hash_of "$dest")
  if [ -n "$PARENT" ]; then
    printf 'fetched: %s\t%s\tsha256 %s\tdependent on %s\n' "$id" "$dest" "$H" "$PARENT"
  else
    printf 'fetched: %s\t%s\tsha256 %s\n' "$id" "$dest" "$H"
  fi
  REC="$REC    $id:"$'\n'"      file: $id.csl"$'\n'"      sha256: $H"$'\n'
  [ -n "$PARENT" ] && REC="$REC      parent: $PARENT"$'\n'
  return 0
}

REC=""
get "$ID" || exit 1
if [ -n "$PARENT" ]; then
  P=$PARENT
  get "$P" || exit 1
  [ -z "$PARENT" ] || { echo "error: $P is itself dependent; the chain is not supported"; exit 1; }
fi
printf '%s' "$REC" | sed 's/^/record: /'
exit 0
