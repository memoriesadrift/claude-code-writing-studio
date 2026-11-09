# shellcheck shell=bash
# Shared helpers for Writing Studio hooks (spec §10.1). Sourced, never run.
#
# Constraints: Bash 3.2-compatible (macOS); POSIX awk; as few subprocesses as
# possible on the hot path (process start-up is slow under Git Bash).
#
# Hooks read only the flat "hook-read subset" of YAML (spec §10.1):
#   studio.yaml   prose.level, prose.overrides (one `key: level` per line),
#                 integrity.assessed_cap, project.form, language.default
#   work.yaml     assessed, assessed_cap, word_limit
#   frontmatter   locked; source notes: status, archive.kind, archive.held

WS_LEVELS="critic coach editor co-author ghostwriter"

# ---------------------------------------------------------------- setup

ws_init() {
  WS_ROOT=${CLAUDE_PROJECT_DIR:-$PWD}
  WS_ROOT=${WS_ROOT//\\//}
  WS_ROOT=${WS_ROOT%/}
  case ${OSTYPE:-} in msys*|cygwin*|win*) WS_WINDOWS=1 ;; *) WS_WINDOWS=0 ;; esac
  WS_TMP=${TMPDIR:-${TEMP:-/tmp}}
  WS_TMP=${WS_TMP//\\//}
}

# Sets WS_JQ to the jq to use, or empty if none. .claude/bin/ first, then PATH.
ws_find_jq() {
  if [ -x "$WS_ROOT/.claude/bin/jq.exe" ]; then WS_JQ="$WS_ROOT/.claude/bin/jq.exe"
  elif [ -x "$WS_ROOT/.claude/bin/jq" ]; then WS_JQ="$WS_ROOT/.claude/bin/jq"
  else WS_JQ=$(command -v jq 2>/dev/null) || WS_JQ=""
  fi
}

# Read all of stdin into WS_IN without a subprocess.
ws_read_input() {
  WS_IN=""
  local line
  while IFS= read -r line || [ -n "$line" ]; do WS_IN+="$line"$'\n'; done
}

# True if the hook input could touch a studio path (no subprocess). Case-
# insensitive on Windows, where MANUSCRIPT\x.md is the same file.
ws_mentions_studio() {
  local hit=1
  [ "$WS_WINDOWS" = 1 ] && shopt -s nocasematch
  case $WS_IN in
    *manuscript*|*works*|*bible*|*outline*|*compendium*|*reviews*) hit=0 ;;
  esac
  shopt -u nocasematch
  return $hit
}

# ---------------------------------------------------------------- output

# Deny a PreToolUse call: message to stderr, exit 2 (spec §5.2).
ws_deny() {
  printf 'Writing Studio: %s\n' "$1" >&2
  exit 2
}

# JSON-escape $1 into WS_JSON_STR (no subprocess).
ws_json_escape() {
  local s=$1
  s=${s//\\/\\\\}; s=${s//\"/\\\"}; s=${s//$'\n'/\\n}; s=${s//$'\r'/}; s=${s//$'\t'/\\t}
  WS_JSON_STR=$s
}

# Add context for Claude without making a permission decision: the normal
# permission flow stays intact (never emits permissionDecision).
ws_context() {
  ws_json_escape "$2"
  printf '{"hookSpecificOutput":{"hookEventName":"%s","additionalContext":"%s"}}\n' "$1" "$WS_JSON_STR"
}

# One-line warning shown to the author (observers degrading, spec §10.1).
ws_warn() {
  ws_json_escape "Writing Studio: $1"
  printf '{"systemMessage":"%s"}\n' "$WS_JSON_STR"
}

# ---------------------------------------------------------------- paths

# Normalise path $1 to project-relative form with forward slashes in WS_REL.
# WS_REL is empty if the path is outside the project.
ws_relpath() {
  local p=${1//\\//} root=$WS_ROOT
  # /c/Users/... → c:/Users/... (Git Bash) so both spellings compare equal
  if [ "$WS_WINDOWS" = 1 ]; then
    if [[ $p =~ ^/([a-zA-Z])/(.*)$ ]]; then p="${BASH_REMATCH[1]}:/${BASH_REMATCH[2]}"; fi
    if [[ $root =~ ^/([a-zA-Z])/(.*)$ ]]; then root="${BASH_REMATCH[1]}:/${BASH_REMATCH[2]}"; fi
  fi
  case $p in
    /*|[a-zA-Z]:/*) ;;
    *) p="$root/$p" ;;
  esac
  # collapse empty, ./ and ../ segments
  local out="" seg n=0
  local -a parts stack
  IFS=/ read -r -a parts <<< "$p"
  for seg in "${parts[@]}"; do
    case $seg in
      ''|.) ;;
      ..) [ "$n" -gt 0 ] && n=$((n - 1)) ;;
      *) stack[n]=$seg; n=$((n + 1)) ;;
    esac
  done
  local i=0
  while [ "$i" -lt "$n" ]; do out+="/${stack[i]}"; i=$((i + 1)); done
  out=${out#/}
  root=${root#/}; root=${root%/}
  local cmp_out=$out cmp_root=$root
  if [ "$WS_WINDOWS" = 1 ]; then
    # Windows paths are case-insensitive; Git Bash is Bash 4+, so ${x,,} is safe here
    cmp_out=${cmp_out,,}; cmp_root=${cmp_root,,}
  fi
  if [ "${cmp_out#"$cmp_root"/}" != "$cmp_out" ]; then
    WS_REL=${out:${#root}+1}
  else
    WS_REL=""
  fi
}

# Classify project-relative path $1. Sets:
#   WS_AREA   prose | bible | outline | compendium | works | reviews | other
#   WS_KEY    override key (prose only): path under the prose root, no extension,
#             with `sections/` dropped
#   WS_WORK   work slug (anything under works/<work>/), else empty
ws_classify() {
  local r=$1
  WS_AREA=other WS_KEY="" WS_WORK=""
  # Windows paths are case-insensitive: classify, key and compare in lower case
  [ "$WS_WINDOWS" = 1 ] && r=${r,,}
  case $r in
    manuscript/*.md)
      WS_AREA=prose; WS_KEY=${r#manuscript/}; WS_KEY=${WS_KEY%.md} ;;
    works/*/sections/*.md)
      WS_AREA=prose; WS_WORK=${r#works/}; WS_WORK=${WS_WORK%%/*}
      WS_KEY="$WS_WORK/${r#works/"$WS_WORK"/sections/}"; WS_KEY=${WS_KEY%.md} ;;
    works/*/checkpoint.md)
      WS_WORK=${r#works/}; WS_WORK=${WS_WORK%%/*} ;;      # housekeeping: not logged
    works/*/reviews/*)
      WS_AREA=reviews; WS_WORK=${r#works/}; WS_WORK=${WS_WORK%%/*} ;;
    works/*/*)
      WS_AREA=works; WS_WORK=${r#works/}; WS_WORK=${WS_WORK%%/*} ;;
    bible/*)      WS_AREA=bible ;;
    outline/*)    WS_AREA=outline ;;
    compendium/*) WS_AREA=compendium ;;
    reviews/*)    WS_AREA=reviews ;;
  esac
}

# ---------------------------------------------------------------- YAML subset

# Load studio.yaml's hook-read keys. Sets WS_HAVE_STUDIO (0/1), WS_BASE_LEVEL,
# WS_PROJECT_CAP, WS_OVERRIDES (newline-separated `key<TAB>level`), WS_FORM,
# WS_LANG.
ws_load_studio() {
  WS_HAVE_STUDIO=0 WS_BASE_LEVEL="" WS_PROJECT_CAP="" WS_OVERRIDES="" WS_FORM="" WS_LANG=""
  [ -f "$WS_ROOT/studio.yaml" ] || return 0
  WS_HAVE_STUDIO=1
  local t a b
  while IFS=$'\t' read -r t a b; do
    case $t in
      l) WS_BASE_LEVEL=$a ;;
      c) WS_PROJECT_CAP=$a ;;
      f) WS_FORM=$a ;;
      g) WS_LANG=$a ;;
      o) WS_OVERRIDES+="$a"$'\t'"$b"$'\n' ;;
    esac
  done < <(awk '
    function trim(s) { sub(/^[ \t]+/, "", s); sub(/[ \t]+$/, "", s); return s }
    function val(s) {
      sub(/[ \t]+#.*$/, "", s); s = trim(s)
      if (s ~ /^".*"$/ || s ~ /^\047.*\047$/) s = substr(s, 2, length(s) - 2)
      return s
    }
    { sub(/\r$/, "") }
    /^[ \t]*(#|$)/ { next }
    {
      ind = match($0, /[^ ]/) - 1; c = substr($0, ind + 1)
      k = c; sub(/:.*/, "", k); k = val(k)
      v = c; if (!sub(/^[^:]*:/, "", v)) v = ""; v = val(v)
    }
    ind == 0 { top = k; inov = 0; next }
    top == "prose" && inov && ind > ovind { print "o\t" k "\t" v; next }
    top == "prose" { inov = 0 }
    top == "prose" && k == "level" { print "l\t" v; next }
    top == "prose" && k == "overrides" && v == "" { inov = 1; ovind = ind; next }
    top == "integrity" && k == "assessed_cap" { print "c\t" v; next }
    top == "project" && k == "form" && ind <= 2 { print "f\t" v; next }
    top == "language" && k == "default" && ind <= 2 { print "g\t" v; next }
  ' "$WS_ROOT/studio.yaml")
}

# Read works/<work>/work.yaml's `assessed`, `assessed_cap` and `word_limit`
# into WS_W_ASSESSED, WS_W_CAP, WS_W_LIMIT.
ws_load_work() {
  WS_W_ASSESSED="" WS_W_CAP="" WS_W_LIMIT=""
  local f="$WS_ROOT/works/$1/work.yaml" t a
  [ -f "$f" ] || return 0
  while IFS=$'\t' read -r t a; do
    case $t in a) WS_W_ASSESSED=$a ;; c) WS_W_CAP=$a ;; w) WS_W_LIMIT=$a ;; esac
  done < <(awk '
    function val(s) {
      sub(/[ \t]+#.*$/, "", s); sub(/^[ \t]+/, "", s); sub(/[ \t]+$/, "", s)
      if (s ~ /^".*"$/ || s ~ /^\047.*\047$/) s = substr(s, 2, length(s) - 2)
      return s
    }
    { sub(/\r$/, "") }
    /^assessed:/     { v = $0; sub(/^assessed:/, "", v); print "a\t" val(v) }
    /^assessed_cap:/ { v = $0; sub(/^assessed_cap:/, "", v); print "c\t" val(v) }
    /^word_limit:/   { v = $0; sub(/^word_limit:/, "", v); print "w\t" val(v) }
  ' "$f")
}

# ---------------------------------------------------------------- levels

# Rank of level $1 (1..5) in WS_RANK; 0 if not a valid level.
ws_rank() {
  case $1 in
    critic) WS_RANK=1 ;; coach) WS_RANK=2 ;; editor) WS_RANK=3 ;;
    co-author) WS_RANK=4 ;; ghostwriter) WS_RANK=5 ;; *) WS_RANK=0 ;;
  esac
}

# Look up override key $1. Sets WS_OV (level) or empty.
ws_override() {
  WS_OV=""
  local k v want=$1
  [ "$WS_WINDOWS" = 1 ] && want=${want,,}
  while IFS=$'\t' read -r k v; do
    [ "$WS_WINDOWS" = 1 ] && k=${k,,}
    [ "$k" = "$want" ] && { WS_OV=$v; return 0; }
  done <<< "$WS_OVERRIDES"
  return 1
}

# Apply the integrity cap for work $1 to WS_LEVEL. Sets WS_CAP_NOTE.
ws_apply_cap() {
  WS_CAP_NOTE=""
  [ -n "$1" ] || return 0
  ws_load_work "$1"
  [ "$WS_W_ASSESSED" = true ] || return 0
  local cap=$WS_W_CAP src="works/$1/work.yaml assessed_cap"
  if [ -z "$cap" ] || [ "$cap" = null ] || [ "$cap" = "~" ]; then
    cap=$WS_PROJECT_CAP; src="studio.yaml integrity.assessed_cap"
    if [ -z "$cap" ] || [ "$cap" = null ]; then cap=coach; src="default integrity cap"; fi
  fi
  ws_rank "$cap"; local rc=$WS_RANK
  if [ "$rc" = 0 ]; then WS_LEVEL="invalid-cap:$cap"; WS_SRC=$src; return 0; fi
  ws_rank "$WS_LEVEL"
  if [ "$WS_RANK" -gt "$rc" ]; then
    WS_CAP_NOTE="capped from \`$WS_LEVEL\` to \`$cap\` by the academic-integrity cap ($src), because works/$1 is assessed"
    WS_LEVEL=$cap
  fi
}

# Resolve the prose level for override key $1 (spec §5.1) and work $2 (may be
# empty). Sets WS_LEVEL, WS_SRC, WS_CAP_NOTE. Requires ws_load_studio.
ws_resolve() {
  local key=$1 work=$2
  WS_LEVEL="" WS_SRC="" WS_CAP_NOTE=""
  while [ -n "$key" ]; do
    if ws_override "$key"; then
      WS_LEVEL=$WS_OV; WS_SRC="studio.yaml prose.overrides \`$key\`"; break
    fi
    case $key in */*) key=${key%/*} ;; *) key="" ;; esac
  done
  if [ -z "$WS_LEVEL" ]; then
    WS_LEVEL=${WS_BASE_LEVEL:-}; WS_SRC="studio.yaml prose.level"
    [ -n "$WS_LEVEL" ] || { WS_LEVEL=critic; WS_SRC="default (studio.yaml has no prose.level)"; }
  fi
  ws_apply_cap "$work"
}

# Strictest level that applies anywhere under directory key prefix $1 (empty =
# the whole prose root) of root $2 (manuscript | works). Used for shell
# commands that name a directory. Sets WS_LEVEL, WS_SRC, WS_CAP_NOTE.
ws_resolve_strictest() {
  local prefix=$1 root=$2 best=9 bl="" bs="" bc="" k v w
  _ws_consider() {
    ws_rank "$WS_LEVEL"
    if [ "$WS_RANK" -lt "$best" ]; then best=$WS_RANK; bl=$WS_LEVEL; bs=$WS_SRC; bc=$WS_CAP_NOTE; fi
  }
  if [ "$root" = works ] && [ -z "$prefix" ]; then
    for w in "$WS_ROOT"/works/*/; do
      [ -d "$w" ] || continue
      w=${w%/}; w=${w##*/}
      ws_resolve_strictest "$w" works
      _ws_consider
    done
    [ -n "$bl" ] || { ws_resolve "" ""; _ws_consider; }
  else
    w=""; [ "$root" = works ] && w=${prefix%%/*}
    ws_resolve "$prefix" "$w"; _ws_consider
    while IFS=$'\t' read -r k v; do
      [ -n "$k" ] || continue
      if [ -z "$prefix" ] || [ "${k#"$prefix"/}" != "$k" ]; then
        if [ "$root" = works ]; then w=${k%%/*}; else w=""; fi
        ws_resolve "$k" "$w"; _ws_consider
      fi
    done <<< "$WS_OVERRIDES"
  fi
  WS_LEVEL=$bl WS_SRC=$bs WS_CAP_NOTE=$bc
  return 0
}

# Human-readable "level from source[, capped…]".
ws_level_desc() {
  WS_DESC="prose level \`$WS_LEVEL\` (from $WS_SRC)"
  [ -n "$WS_CAP_NOTE" ] && WS_DESC+=", $WS_CAP_NOTE"
  return 0
}
