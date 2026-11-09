#!/usr/bin/env bash
# session-start — SessionStart (spec §2 principle 2, §10). Observer: never blocks.
#
# Re-injects the checkpoint so an abandoned session loses at most the step in
# progress, plus a one-line status (also shown to the author):
#   fiction       session/active.md
#   non-fiction   the current work's works/<work>/checkpoint.md, where the
#                 current work is the slug in session/current-work; if that
#                 file is absent or stale, each work's "Next step" instead
# Runs on startup, resume, /clear and after compaction alike. Needs no jq.

. "${BASH_SOURCE%/*}/lib.sh"
ws_init
ws_read_input     # drain stdin; nothing in it is needed

emit() {   # $1 context for Claude, $2 status line for the author
  local ctx sys
  ws_json_escape "$1"; ctx=$WS_JSON_STR
  ws_json_escape "$2"; sys=$WS_JSON_STR
  printf '{"systemMessage":"%s","hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$sys" "$ctx"
  exit 0
}

ws_load_studio
if [ "$WS_HAVE_STUDIO" != 1 ]; then
  emit "Writing Studio: studio.yaml does not exist, so this project has not been set up. Tell the author and offer /start; do nothing else first." \
       "Writing Studio: not set up yet — run /start."
fi

ws_find_jq
JQ_NOTE=""
[ -n "$WS_JQ" ] || JQ_NOTE=" · jq missing: prose and source writes will be denied until /start installs it"

# Print a markdown file without HTML comments and leading blank lines.
strip_comments() {
  awk '
    { sub(/\r$/, "") }
    incom { if (sub(/.*-->/, "")) incom = 0; else next }
    { while (match($0, /<!--/)) {
        pre = substr($0, 1, RSTART - 1); rest = substr($0, RSTART + 4)
        if (match(rest, /-->/)) $0 = pre substr(rest, RSTART + 3)
        else { $0 = pre; incom = 1; break }
      } }
    !started && /^[ \t]*$/ { next }
    { started = 1; print }
  ' "$1"
}

LANG_S=${WS_LANG:-unset}
FORM=${WS_FORM:-unset}

# ------------------------------------------------------------------ fiction
if [ "$FORM" != nonfiction ]; then
  ws_resolve "" ""
  NOV=0; [ -n "$WS_OVERRIDES" ] && NOV=$(printf '%s' "$WS_OVERRIDES" | grep -c .)
  STATUS="Writing Studio · $FORM · prose level $WS_LEVEL"
  [ "$NOV" -gt 0 ] && STATUS+=" (+$NOV override$([ "$NOV" = 1 ] || echo s))"
  STATUS+=" · language $LANG_S$JQ_NOTE"
  CP="$WS_ROOT/session/active.md"
  if [ -f "$CP" ]; then
    CTX="$STATUS"$'\n\n'"Checkpoint (session/active.md):"$'\n'"$(strip_comments "$CP")"
  else
    CTX="$STATUS"$'\n\n'"No checkpoint yet (session/active.md does not exist). Create it from .claude/templates/shared/checkpoint.md at the first milestone."
  fi
  emit "$CTX" "$STATUS"
fi

# ------------------------------------------------------------------ non-fiction
WORKS=()
for d in "$WS_ROOT"/works/*/; do
  [ -d "$d" ] || continue
  d=${d%/}; WORKS+=("${d##*/}")
done

# Approximate word counts for every work in one awk run: skips frontmatter,
# HTML comments, footnote definitions and everything from a bibliography /
# references heading on. /status gives the exact count.
WORDS=""
if [ "${#WORKS[@]}" -gt 0 ]; then
  set -- "$WS_ROOT"/works/*/sections/*.md
  if [ -e "$1" ]; then
    WORDS=$(awk '
      FNR == 1 { w = FILENAME; sub(/\/sections\/[^\/]*$/, "", w); sub(/.*\//, "", w)
                 fm = 0; incom = 0; skip = 0; first = 1 }
      { sub(/\r$/, "") }
      first { first = 0; sub(/^\357\273\277/, ""); if ($0 == "---") { fm = 1; next } }
      fm { if ($0 == "---") fm = 0; next }
      skip { next }
      /^#+[ \t]+(Bibliography|References|Works cited|Literaturverzeichnis|Literatur|Quellen)[ \t]*$/ { skip = 1; next }
      incom { if (sub(/.*-->/, "")) incom = 0; else next }
      { while (match($0, /<!--/)) {
          pre = substr($0, 1, RSTART - 1); rest = substr($0, RSTART + 4)
          if (match(rest, /-->/)) $0 = pre substr(rest, RSTART + 3)
          else { $0 = pre; incom = 1; break }
        } }
      /^\[\^[^]]*\]:/ { next }
      /^#/ { next }
      { n[w] += NF }
      END { for (k in n) print k "\t" n[k] }
    ' "$@")
  fi
fi

words_of() {   # $1 work → WC
  local k v
  WC=0
  while IFS=$'\t' read -r k v; do [ "$k" = "$1" ] && WC=$v; done <<< "$WORDS"
}

# Current work from the pointer file.
CUR="" CUR_NOTE=""
if [ -f "$WS_ROOT/session/current-work" ]; then
  IFS= read -r CUR < "$WS_ROOT/session/current-work" || true
  CUR=${CUR%$'\r'}; CUR=${CUR#"${CUR%%[![:space:]]*}"}; CUR=${CUR%"${CUR##*[![:space:]]}"}
  if [ -n "$CUR" ] && [ ! -d "$WS_ROOT/works/$CUR" ]; then
    CUR_NOTE="session/current-work names \`$CUR\`, which is not a work under works/; ignoring it."
    CUR=""
  fi
fi

STATUS="Writing Studio · nonfiction · language $LANG_S"
LINES=""
for w in "${WORKS[@]}"; do
  ws_resolve "$w" "$w"
  words_of "$w"
  L="$w: $WS_LEVEL"
  [ -n "$WS_CAP_NOTE" ] && L+=" (capped)"
  if [ -n "$WS_W_LIMIT" ] && [ "$WS_W_LIMIT" != null ]; then L+=", ~$WC/$WS_W_LIMIT words"
  else L+=", ~$WC words"; fi
  LINES+="$L; "
done
if [ -n "$LINES" ]; then STATUS+=" · ${LINES%; }"; else STATUS+=" · no works yet"; fi
STATUS+=$JQ_NOTE

POINTER_RULE="When the author starts work on a different work, overwrite session/current-work with that work's slug (one line; no \"May I write?\" needed, as for checkpoints)."

if [ -n "$CUR" ]; then
  CP="$WS_ROOT/works/$CUR/checkpoint.md"
  if [ -f "$CP" ]; then
    BODY="Current work: $CUR (from session/current-work). Checkpoint (works/$CUR/checkpoint.md):"$'\n'"$(strip_comments "$CP")"
  else
    BODY="Current work: $CUR (from session/current-work). It has no checkpoint yet; create works/$CUR/checkpoint.md from .claude/templates/shared/checkpoint.md at the first milestone."
  fi
elif [ "${#WORKS[@]}" -eq 0 ]; then
  BODY="No works yet. /new-work creates one."
else
  BODY="No current work is set. Next step of each work (ask the author which to continue, then read its checkpoint.md):"
  for w in "${WORKS[@]}"; do
    CP="$WS_ROOT/works/$w/checkpoint.md"
    if [ -f "$CP" ]; then
      NEXT=$(strip_comments "$CP" | awk '
        /^##[ \t]+Next step/ { on = 1; next }
        on && /^#/ { exit }
        on && NF { print }')
      BODY+=$'\n'"- $w: ${NEXT:-(checkpoint has no Next step)}"
    else
      BODY+=$'\n'"- $w: (no checkpoint yet)"
    fi
  done
fi
[ -n "$CUR_NOTE" ] && BODY="$CUR_NOTE"$'\n'"$BODY"

emit "$STATUS"$'\n\n'"$BODY"$'\n\n'"$POINTER_RULE" "$STATUS"
