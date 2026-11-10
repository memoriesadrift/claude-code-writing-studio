#!/usr/bin/env bash
# archive-hash.sh — checksum lines for one source's archived copy (spec §6.4).
# Reports; never writes. /source shows the `new:` lines to the author and adds
# them to compendium/archive.sha256 only after "May I write?".
#
#   archive-hash.sh <citekey>
#
# Compares the files under compendium/archive/<citekey>/ with that key's lines
# in compendium/archive.sha256 (path relative to compendium/):
#   new: <sha256sum line>    a file with no line yet: the line to add
#   ok: <path>               recorded and matching
#   changed: <path> <TAB> recorded <hash> <TAB> now <hash>
#                            the file differs from what was recorded: never
#                            replace the line; the author decides (a changed
#                            capture is kept beside the old one, spec §6.4)
#   missing: <path>          recorded, but the file is gone
#   none: <folder>           the folder does not exist or is empty
#
# Exit: 0 done, 1 not set up, 2 usage. Bash 3.2-compatible.

set -u

root=${CLAUDE_PROJECT_DIR:-}
if [ -z "$root" ]; then
  root=$(cd "$(dirname "$0")/../.." && pwd) || { echo "error: cannot find the project root"; exit 2; }
fi
cd "$root" || exit 2
[ -f studio.yaml ] || { echo "error: studio.yaml does not exist: the project is not set up (run /start)"; exit 1; }

KEY=${1:-}
case $KEY in
  ''|*/*|*\\*|.*|*..*) echo "usage: archive-hash.sh <citekey>" >&2; exit 2 ;;
esac

if command -v sha256sum >/dev/null 2>&1; then hash_of() { sha256sum "$1" | awk '{ print $1 }'; }
elif command -v shasum >/dev/null 2>&1; then hash_of() { shasum -a 256 "$1" | awk '{ print $1 }'; }
else echo "error: neither sha256sum nor shasum is available"; exit 1
fi

cd compendium 2>/dev/null || { echo "error: compendium/ does not exist"; exit 1; }
DIR="archive/$KEY"
SUMS=archive.sha256
[ -f "$SUMS" ] || echo "note: compendium/$SUMS does not exist yet; it is created with the first line"

# Recorded lines for this key: path<TAB>hash
REC=""
if [ -f "$SUMS" ]; then
  REC=$(awk -v p="$DIR/" '{ sub(/\r$/, ""); f = $0; h = $1; sub(/^[0-9A-Fa-f]+ [ *]/, "", f)
                            if (index(f, p) == 1) print f "\t" tolower(h) }' "$SUMS")
fi

FOUND=0
if [ -d "$DIR" ]; then
  while IFS= read -r f; do
    FOUND=1
    case $f in *$'\t'*|*$'\n'*) echo "error: compendium/$f: tab or newline in the file name; rename it"; continue ;; esac
    h=$(hash_of "$f")
    r=$(printf '%s\n' "$REC" | awk -F '\t' -v f="$f" '$1 == f { print $2; exit }')
    if [ -z "$r" ]; then printf 'new: %s  %s\n' "$h" "$f"
    elif [ "$r" = "$h" ]; then printf 'ok: %s\n' "$f"
    else printf 'changed: %s\trecorded %s\tnow %s\n' "$f" "$r" "$h"
    fi
  done < <(find "$DIR" -type f | LC_ALL=C sort)
fi
[ "$FOUND" = 1 ] || echo "none: compendium/$DIR/"

# Recorded files that are gone.
printf '%s\n' "$REC" | while IFS=$'\t' read -r f h; do
  [ -n "$f" ] && [ ! -f "$f" ] && echo "missing: $f"
done
exit 0
