#!/usr/bin/env bash
# provenance-log — PostToolUse on Write, Edit (spec §5.3). Observer: never blocks.
#
# Appends one JSON line per Claude write to session/provenance.jsonl for every
# studio content file: prose (manuscript/**, works/*/sections/**) and also
# bible/, outline/, compendium/, reviews/ and the other files under works/
# (checkpoints excepted), so /status provenance can tell prose help apart from
# planning and compendium help. Non-prose lines record level "n/a".
#
# Line: {ts, session, file, area, work, level, level_source, capped, tool,
#        added, removed}  — added/removed are characters. A Write replaces the
# whole file, so it counts the old length as removed and the new as added; the
# old length comes from prose-guard's stash, since PostToolUse cannot see it.

. "${BASH_SOURCE%/*}/lib.sh"
ws_init
ws_read_input

ws_mentions_studio || exit 0

ws_find_jq
if [ -z "$WS_JQ" ]; then
  ws_warn "jq is not installed, so this write was not recorded in session/provenance.jsonl. Run /start to install jq."
  exit 0
fi

{
  IFS= read -r -d '' TOOL
  IFS= read -r -d '' FILE
  IFS= read -r -d '' TUID
  IFS= read -r -d '' SESSION
  IFS= read -r -d '' REPLACE_ALL
  IFS= read -r -d '' CONTENT_LEN
  IFS= read -r -d '' OLD_LEN
  IFS= read -r -d '' NEW_LEN
  IFS= read -r -d '' RESP_TYPE
} < <(printf '%s' "$WS_IN" | "$WS_JQ" -j '
  [ .tool_name, (.tool_input.file_path // ""), (.tool_use_id // ""), (.session_id // ""),
    (.tool_input.replace_all // false), (.tool_input.content // "" | length),
    (.tool_input.old_string // "" | length), (.tool_input.new_string // "" | length),
    (.tool_response.type? // "") ]
  | map(tostring + "\u0000") | add')

case $TOOL in Write|Edit) ;; *) exit 0 ;; esac
[ -n "$FILE" ] || exit 0
ws_relpath "$FILE"
[ -n "$WS_REL" ] || exit 0
ws_classify "$WS_REL"
[ "$WS_AREA" != other ] || exit 0

STASH_LEN=0 STASH_COUNT=1
STASH="$WS_TMP/ws-prov-$TUID"
if [ -n "$TUID" ] && [ -f "$STASH" ]; then
  read -r STASH_LEN STASH_COUNT < "$STASH"
  STASH_COUNT=${STASH_COUNT%$'\r'}
  rm -f "$STASH"
fi

if [ "$TOOL" = Write ]; then
  ADDED=$CONTENT_LEN
  if [ "$RESP_TYPE" = create ]; then REMOVED=0; else REMOVED=${STASH_LEN:-0}; fi
else
  N=1
  [ "$REPLACE_ALL" = true ] && N=${STASH_COUNT:-1}
  ADDED=$(( NEW_LEN * N )); REMOVED=$(( OLD_LEN * N ))
fi

LEVEL="n/a" SRC="" CAPPED=false
if [ "$WS_AREA" = prose ]; then
  ws_load_studio
  ws_resolve "$WS_KEY" "$WS_WORK"
  LEVEL=$WS_LEVEL SRC=$WS_SRC
  [ -n "$WS_CAP_NOTE" ] && CAPPED=true
fi

[ -d "$WS_ROOT/session" ] || mkdir -p "$WS_ROOT/session"
"$WS_JQ" -nc \
  --arg session "$SESSION" --arg file "$WS_REL" --arg area "$WS_AREA" \
  --arg work "$WS_WORK" --arg level "$LEVEL" --arg src "$SRC" \
  --argjson capped "$CAPPED" --arg tool "$TOOL" \
  --argjson added "${ADDED:-0}" --argjson removed "${REMOVED:-0}" '
  { ts: (now | strftime("%Y-%m-%dT%H:%M:%SZ")), session: $session, file: $file,
    area: $area, work: (if $work == "" then null else $work end),
    level: $level, level_source: (if $src == "" then null else $src end),
    capped: $capped, tool: $tool, added: $added, removed: $removed }' \
  >> "$WS_ROOT/session/provenance.jsonl"

exit 0
