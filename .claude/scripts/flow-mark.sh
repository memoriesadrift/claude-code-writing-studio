#!/usr/bin/env bash
# flow-mark.sh — record a flow step as done or skipped (development-flow §8).
# Called by the skill that did the work, or by /next when the author says a
# step is finished or that they are going on without it. Writes one line in
# the progress file; nothing else.
#
#   flow-mark.sh <step-id> <done | skipped | clear> [work]
#
# Progress file: fiction session/progress.yaml; non-fiction (work required)
# works/<work>/progress.yaml. Line format: `<step-id>: <done|skipped> <date>`.
# The step id must exist in .claude/workflow.yaml for the project's form.
#
# Output: `marked: <step> <state> <file>` or `cleared: …`. Exit: 0 done,
# 1 failed, 2 usage. Bash 3.2-compatible.

set -u

root=${CLAUDE_PROJECT_DIR:-}
if [ -z "$root" ]; then
  root=$(cd "$(dirname "$0")/../.." && pwd) || { echo "error: cannot find the project root"; exit 2; }
fi
cd "$root" || exit 2
# shellcheck source=lib-units.sh
. "$root/.claude/scripts/lib-units.sh"
[ -f studio.yaml ] || { echo "error: studio.yaml does not exist: the project is not set up (run /start)"; exit 1; }

STEP=${1:-}; STATE=${2:-}; WORK=${3:-}
usage() { echo "usage: flow-mark.sh <step-id> <done | skipped | clear> [work]" >&2; exit 2; }
case $STEP in ''|*[!a-z0-9-]*) usage ;; esac
case $STATE in done|skipped|clear) ;; *) usage ;; esac

FORM=$(wu_yget studio.yaml project form)
case $FORM in
  nonfiction)
    SEC=nonfiction
    case $WORK in ''|*/*|.*) echo "error: non-fiction needs a work slug"; exit 2 ;; esac
    [ -d "works/$WORK" ] || { echo "error: works/$WORK does not exist"; exit 1; }
    PROG="works/$WORK/progress.yaml" ;;
  novel|short|screenplay)
    SEC=fiction
    [ -z "$WORK" ] || { echo "error: fiction has no works; leave the work out"; exit 2; }
    PROG=session/progress.yaml ;;
  *) echo "error: studio.yaml project.form is \"$FORM\""; exit 1 ;;
esac

# The step must exist in the catalogue for this form.
awk -v sec="$SEC" -v id="$STEP" '
  { sub(/\r$/, "") }
  /^[^ #]/ { cur = $0; sub(/:.*/, "", cur) }
  cur == sec && $0 ~ "^        - id:[ \t]*" id "[ \t]*$" { found = 1 }
  END { exit !found }' .claude/workflow.yaml \
  || { echo "error: \"$STEP\" is not a $SEC step in .claude/workflow.yaml"; exit 1; }

mkdir -p "$(dirname "$PROG")"
if [ ! -f "$PROG" ]; then
  printf '%s\n' "# Flow progress (development-flow §8): steps the author finished or chose" \
    "# to go on without. Written by skills and /next; safe to edit by hand." \
    "schema_version: 1" > "$PROG"
fi

TMP="$PROG.tmp.$$"
trap 'rm -f "$TMP" 2>/dev/null' EXIT
LINE=""
[ "$STATE" = clear ] || LINE="$STEP: $STATE $(date +%Y-%m-%d)"
awk -v id="$STEP" -v line="$LINE" '
  { sub(/\r$/, "") }
  index($0, id ":") == 1 { if (line != "" && !done) { print line; done = 1 }; next }
  { print }
  END { if (line != "" && !done) print line }' "$PROG" > "$TMP" && mv "$TMP" "$PROG" \
  || { echo "error: could not write $PROG"; exit 1; }

if [ "$STATE" = clear ]; then echo "cleared: $STEP	$PROG"; else echo "marked: $STEP	$STATE	$PROG"; fi
exit 0
