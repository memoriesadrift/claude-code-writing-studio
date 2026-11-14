#!/usr/bin/env bash
# status.sh — facts for /status (spec §8.1, §10.1, §11). Reports; never judges.
#
#   status.sh [work]              config lint, overrides, packs, word counts,
#                                 workflow phases, latest review verdicts
#   status.sh provenance [work]   provenance.jsonl summarised per unit (needs jq)
#
# Output is plain text in `## section` blocks; one fact per line. Lines that
# start `error:` are problems a hook could misread or a key that matches
# nothing; `note:` lines are informational. Claude interprets the rest.
#
# Bash 3.2-compatible. Read-only: writes nothing.

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
ws_load_studio
FORM=${WS_FORM:-}

LEVELS_RE='^(critic|coach|editor|co-author|ghostwriter)$'

# Shared awk helpers, prepended to the awk programs below.
AWK_LIB='
function trim(s) { sub(/^[ \t]+/, "", s); sub(/[ \t]+$/, "", s); return s }
function nocomment(s) { sub(/[ \t]+#.*$/, "", s); return trim(s) }
function unq(s) { if (s ~ /^".*"$/ || s ~ /^\047.*\047$/) return substr(s, 2, length(s) - 2); return s }
# Why value s (comment stripped) is outside the hook-read subset, or "".
function badflat(s) {
  if (s ~ /^[{[]/) return "flow collection ({...} or [...])"
  if (s ~ /^[&*!]/) return "anchor, alias or tag"
  if (s ~ /^[|>][-+0-9]*$/) return "multi-line string"
  if (s ~ /^"/ && s !~ /^".*"$/) return "unbalanced quotes"
  if (s ~ /^\047/ && s !~ /^\047.*\047$/) return "unbalanced quotes"
  return ""
}
function err(f, n, m) { if (n) printf "error: %s:%d: %s\n", f, n, m; else printf "error: %s: %s\n", f, m }
function note(f, n, m) { if (n) printf "note: %s:%d: %s\n", f, n, m; else printf "note: %s: %s\n", f, m }
'

# ======================================================================= main

if [ "${1:-}" = provenance ]; then
  shift
  WANT=${1:-}
  echo "## provenance"
  P=session/provenance.jsonl
  [ -f "$P" ] || { echo "note: $P does not exist yet (nothing has been written by Claude, or the hook is not wired)"; exit 0; }
  ws_find_jq
  [ -n "$WS_JQ" ] || { echo "error: jq is not installed; run /start to install it"; exit 1; }
  # Group key: fiction prose → chapter; non-fiction prose → work/section;
  # anything else → area (work-scoped where it has a work).
  # Lines that are not JSON objects are counted and skipped, never fatal.
  "$WS_JQ" -rRs --arg want "$WANT" '
    split("\n") | map(sub("\r$"; "")) | map(select(length > 0))
    | (map(fromjson? // null) | map(select(type == "object"))) as $recs
    | (length - ($recs | length)) as $bad
    | (if $bad > 0 then "error: \($bad) line(s) of session/provenance.jsonl are not JSON records and were skipped" else empty end),
      ($recs
    | map(select($want == "" or .work == $want))
    | map(. + { unit: (
        .work as $w
        | if .area == "prose" and $w != null then (.file | sub("^works/[^/]+/sections/"; $w + "/") | sub("\\.md$"; ""))
        elif .area == "prose" then (.file | sub("^manuscript/"; "") | split("/")[0])
        elif .work != null then (.work + " (" + .area + ")")
        else .area end) })
    | group_by(.unit)[]
    | { unit: .[0].unit, area: .[0].area, writes: length,
        added: (map(.added) | add), removed: (map(.removed) | add),
        levels: (map(.level) | unique | join(",")),
        capped: (map(select(.capped)) | length),
        files: (map(.file) | unique | length),
        first: (map(.ts) | min), last: (map(.ts) | max) }
    | "unit: \(.unit)\tarea: \(.area)\twrites: \(.writes)\tfiles: \(.files)\tadded: \(.added)\tremoved: \(.removed)\tlevels: \(.levels)\tcapped: \(.capped)\tfirst: \(.first)\tlast: \(.last)")
  ' "$P" | tr -d '\r'
  exit 0
fi

WANT=${1:-}
if [ -n "$WANT" ] && [ ! -d "works/$WANT" ]; then
  echo "error: works/$WANT does not exist"; exit 1
fi

# ------------------------------------------------------------------ project
echo "## project"
echo "form: ${FORM:-unset}"
echo "prose.level: ${WS_BASE_LEVEL:-unset}"
NOV=0; [ -n "$WS_OVERRIDES" ] && NOV=$(printf '%s' "$WS_OVERRIDES" | grep -c .)
echo "overrides: $NOV"
echo "language.default: ${WS_LANG:-unset}"
[ "$FORM" = nonfiction ] && echo "integrity.assessed_cap: ${WS_PROJECT_CAP:-unset (default coach)}"
ws_find_jq
if [ -n "$WS_JQ" ]; then echo "jq: $WS_JQ"; else echo "error: jq is not installed: guards deny writes and observers are off (run /start)"; fi
if [ "$FORM" = nonfiction ]; then
  CUR=""
  if [ -f session/current-work ]; then
    IFS= read -r CUR < session/current-work || true
    CUR=$(printf '%s' "$CUR" | tr -d '\r' | awk '{ $1 = $1; print }')
  fi
  if [ -z "$CUR" ]; then echo "current-work: none"
  elif [ -d "works/$CUR" ]; then echo "current-work: $CUR"
  else echo "error: session/current-work names \`$CUR\`, which is not a work"; fi
fi

# ------------------------------------------------------------------ lint
echo "## lint"
case $FORM in
  novel|short|nonfiction|screenplay) ;;
  *) echo "error: studio.yaml: project.form \`$FORM\` is not novel, short, nonfiction or screenplay" ;;
esac

awk "$AWK_LIB"'
  { sub(/\r$/, "") }
  FNR == 1 { sub(/^\357\273\277/, "") }
  /^[ \t]*(#|$)/ { next }
  /^ *\t/ { err(FILENAME, FNR, "tab in indentation (YAML forbids it; hooks misread it)"); next }
  {
    ind = match($0, /[^ ]/) - 1; c = substr($0, ind + 1)
    k = c; sub(/:.*/, "", k); k = unq(trim(k))
    v = c; if (!sub(/^[^:]*:/, "", v)) v = ""; v = nocomment(v)
  }
  ind == 0 { top = k; inov = 0; seen[k]++
             if (seen[k] == 2 && (k == "prose" || k == "integrity" || k == "project" || k == "language"))
               err(FILENAME, FNR, "`" k ":` appears twice; hooks read only part of it")
             next }
  top == "prose" && inov && ind > ovind {
    if (ovchild == 0) ovchild = ind
    if (ind != ovchild) { err(FILENAME, FNR, "override `" k "` is nested; one `key: level` per line under overrides"); next }
    b = badflat(v); if (b != "") { err(FILENAME, FNR, "override `" k "`: " b); next }
    v = unq(v)
    if (v == "") { err(FILENAME, FNR, "override `" k "` has no level"); next }
    if (v !~ /^(critic|coach|editor|co-author|ghostwriter)$/) err(FILENAME, FNR, "override `" k "`: `" v "` is not a prose level")
    if (k !~ /^[A-Za-z0-9._-]+(\/[A-Za-z0-9._-]+)?$/) err(FILENAME, FNR, "override key `" k "` must be <chapter>[/<unit>] or <work>[/<section>]")
    if (ovk[k]++) err(FILENAME, FNR, "override key `" k "` appears twice")
    next
  }
  top == "prose" { inov = 0 }
  top == "prose" && k == "level" { lvl = FNR
    b = badflat(v); if (b != "") { err(FILENAME, FNR, "prose.level: " b); next }
    if (unq(v) !~ /^(critic|coach|editor|co-author|ghostwriter)$/) err(FILENAME, FNR, "prose.level `" unq(v) "` is not a prose level")
    next }
  top == "prose" && k == "overrides" {
    if (v == "" ) { inov = 1; ovind = ind; ovchild = 0 }
    else if (v != "{}") err(FILENAME, FNR, "prose.overrides must be one `key: level` per line, not " badflat(v))
    next }
  top == "integrity" && k == "assessed_cap" { cap = FNR
    b = badflat(v); if (b != "") { err(FILENAME, FNR, "integrity.assessed_cap: " b); next }
    v = unq(v); if (v != "" && v != "null" && v != "~" && v !~ /^(critic|coach|editor|co-author|ghostwriter)$/)
      err(FILENAME, FNR, "integrity.assessed_cap `" v "` is not a prose level")
    next }
  top == "project" && k == "form" { b = badflat(v); if (b != "") err(FILENAME, FNR, "project.form: " b); next }
  top == "language" && k == "default" { lang = FNR
    b = badflat(v); if (b != "") { err(FILENAME, FNR, "language.default: " b); next }
    if (unq(v) !~ /^[A-Za-z][A-Za-z][A-Za-z]?(-[A-Za-z0-9][A-Za-z0-9]+)*$/) err(FILENAME, FNR, "language.default `" unq(v) "` is not a BCP 47 tag")
    next }
  END {
    if (!lvl) err(FILENAME, 0, "no prose.level: hooks fall back to critic")
    if (!lang) err(FILENAME, 0, "no language.default")
  }
' studio.yaml

if [ "$FORM" = nonfiction ]; then
  for f in works/*/work.yaml; do
    [ -f "$f" ] || continue
    awk "$AWK_LIB"'
      { sub(/\r$/, "") }
      /^[ \t]+(assessed|assessed_cap|word_limit):/ { err(FILENAME, FNR, "hook-read key is indented; it must start the line"); next }
      /^(assessed|assessed_cap|word_limit):/ {
        k = $0; sub(/:.*/, "", k); v = $0; sub(/^[^:]*:/, "", v); v = nocomment(v)
        b = badflat(v); if (b != "") { err(FILENAME, FNR, k ": " b); next }
        v = unq(v); seen[k] = 1
        if (k == "assessed" && v != "true" && v != "false") err(FILENAME, FNR, "assessed must be true or false (hooks read anything else as false), not `" v "`")
        if (k == "assessed_cap" && v != "" && v != "null" && v != "~" && v !~ /^(critic|coach|editor|co-author|ghostwriter)$/) err(FILENAME, FNR, "assessed_cap `" v "` is not a prose level or null")
        if (k == "word_limit" && v != "" && v != "null" && v !~ /^[0-9]+$/) err(FILENAME, FNR, "word_limit must be a whole number or null, not `" v "`")
      }
      END { if (!seen["assessed"]) note(FILENAME, 0, "no `assessed:` line: treated as not assessed") }
    ' "$f"
  done
fi

# Prose frontmatter (`locked`) and author fences.
set -- manuscript/*/*.md works/*/sections/*.md
PROSE=()
for f in "$@"; do [ -f "$f" ] && PROSE+=("$f"); done
if [ "${#PROSE[@]}" -gt 0 ]; then
  awk "$AWK_LIB"'
    function done_file() {
      if (FNR_last && fm == 1) err(last, 1, "frontmatter is not closed with ---")
      if (FNR_last && open > 0) err(last, openline, "<!-- author --> fence is not closed; the guard cannot protect it")
    }
    FNR == 1 { done_file(); last = FILENAME; fm = 0; open = 0; FNR_last = 1
               sub(/^\357\273\277/, ""); sub(/\r$/, "")
               if ($0 == "---") { fm = 1; next } }
    { sub(/\r$/, "") }
    fm == 1 && $0 == "---" { fm = 2; next }
    fm == 1 && /^[ \t]*locked:/ {
      if ($0 !~ /^locked:/) { err(FILENAME, FNR, "`locked:` is indented; it must start the line"); next }
      v = $0; sub(/^locked:/, "", v); v = nocomment(v)
      if (v != "true" && v != "false") err(FILENAME, FNR, "locked must be the bare word true or false; the guard reads `" v "` as unlocked")
      next }
    fm == 1 { next }
    /<!--[ \t]*author[ \t]*-->/ { if (open) err(FILENAME, FNR, "nested <!-- author --> fence"); open = 1; openline = FNR }
    /<!--[ \t]*\/author[ \t]*-->/ { if (!open) err(FILENAME, FNR, "<!-- /author --> without an opening fence"); open = 0 }
    END { done_file() }
  ' "${PROSE[@]}"
fi

# Source-note frontmatter (`status`, `archive.kind`, `archive.held`).
if [ -d compendium/sources ]; then
  set -- compendium/sources/*.md
  if [ -f "$1" ]; then
    awk "$AWK_LIB"'
      function done_file() {
        if (!last) return
        if (fm == 1) err(last, 1, "frontmatter is not closed with ---")
        else if (!st) err(last, 1, "no `status:` line in the frontmatter")
        if (fm == 2 && !kind) note(last, 1, "no `archive.kind`: the source cannot be verified until it has one")
      }
      FNR == 1 { done_file(); last = FILENAME; fm = 0; st = 0; kind = 0; inarch = 0
                 sub(/^\357\273\277/, ""); sub(/\r$/, "")
                 if ($0 == "---") { fm = 1; next } else { err(FILENAME, 1, "no frontmatter"); fm = 3 } }
      { sub(/\r$/, "") }
      fm != 1 { next }
      $0 == "---" { fm = 2; next }
      /^[^ \t#]/ { inarch = ($0 ~ /^archive:[ \t]*(#.*)?$/) }
      /^status:/ { st = 1; v = $0; sub(/^status:/, "", v); v = nocomment(v)
        b = badflat(v); if (b != "") { err(FILENAME, FNR, "status: " b); next }
        if (unq(v) != "unverified" && unq(v) != "verified") err(FILENAME, FNR, "status must be unverified or verified, not `" unq(v) "`")
        next }
      /^[ \t]+(kind|held):/ {
        k = $0; sub(/:.*/, "", k); k = trim(k); v = $0; sub(/^[^:]*:/, "", v); v = nocomment(v)
        if (!inarch) { err(FILENAME, FNR, "`" k ":` is not under `archive:`"); next }
        b = badflat(v); if (b != "") { err(FILENAME, FNR, "archive." k ": " b " (must be one flat line)"); next }
        if (k == "kind") { kind = 1
          if (unq(v) !~ /^(pdf|web|scan|physical)$/) err(FILENAME, FNR, "archive.kind must be pdf, web, scan or physical, not `" unq(v) "`") }
        next }
      END { done_file() }
    ' "$@"
  fi
fi

# ------------------------------------------------------------------ overrides
echo "## overrides"
if [ -n "$WS_OVERRIDES" ]; then
  while IFS=$'\t' read -r k v; do
    [ -n "$k" ] || continue
    a=${k%%/*} b=""; [ "$a" != "$k" ] && b=${k#*/}
    if [ "$FORM" = nonfiction ]; then
      if [ -n "$b" ]; then t="works/$a/sections/$b.md"; else t="works/$a"; fi
    else
      if [ -n "$b" ]; then t="manuscript/$a/$b.md"; else t="manuscript/$a"; fi
    fi
    if [ -e "$t" ]; then echo "ok: $k → $t ($v)"
    else echo "error: override \`$k\` matches no file or directory ($t does not exist)"; fi
  done <<< "$WS_OVERRIDES"
else
  echo "note: no overrides"
fi

# ------------------------------------------------------------------ packs
echo "## language"
pack_fact() {   # $1 tag, $2 where it is set
  local tag=$1 sub=${1%%-*} sup=""
  sub=$(printf '%s' "$sub" | tr 'A-Z' 'a-z')
  if [ -f ".claude/languages/$sub/pack.yaml" ]; then
    sup=$(awk '/^support:/ { v = $0; sub(/^support:[ \t]*/, "", v); sub(/[ \t]+#.*$/, "", v); print v; exit }' ".claude/languages/$sub/pack.yaml" | tr -d '\r')
    if [ -f ".claude/languages/$sub/variants/$tag.md" ]; then ov="variants/$tag.md"; else ov="none (base pack only)"; fi
    # A variant entry may carry its own `support:` (an overlay /language add wrote).
    vs=$(awk -v tag="$tag" '
      { sub(/\r$/, "") }
      /^[^ #]/ { inv = ($0 ~ /^variants:/); cur = ""; next }
      inv && /^  [^ #][^:]*:/ { cur = $0; sub(/^  /, "", cur); sub(/:.*/, "", cur); next }
      inv && cur == tag && /^    support:/ { v = $0; sub(/^    support:[ \t]*/, "", v); sub(/[ \t]+#.*$/, "", v); print v; exit }
    ' ".claude/languages/$sub/pack.yaml")
    [ -n "$vs" ] && sup="$sup (overlay: $vs)"
    echo "pack: $tag ($2) → .claude/languages/$sub/ · support ${sup:-unknown} · overlay $ov"
  else
    echo "error: $tag ($2) has no language pack: no grammar review (run /language add $tag)"
  fi
}
[ -n "${WS_LANG:-}" ] && pack_fact "$WS_LANG" "studio.yaml"
if [ "$FORM" = nonfiction ]; then
  for f in works/*/work.yaml; do
    [ -f "$f" ] || continue
    t=$(awk '/^language:/ { v = $0; sub(/^language:[ \t]*/, "", v); sub(/[ \t]+#.*$/, "", v); gsub(/["\047]/, "", v); print v; exit }' "$f" | tr -d '\r')
    case $t in ''|null|'~') ;; *) pack_fact "$t" "$f" ;; esac
  done
fi

# ------------------------------------------------------------------ words
# Counts tokens containing a letter or digit. Always skipped: frontmatter, HTML
# comments. Non-fiction also skips what work.yaml → word_count_excludes names:
# bibliography (everything from a references heading on), footnotes
# (definitions and inline ^[…]), citations ([@…] groups), headings.
echo "## words"
count_words() {   # $1 excludes (comma list), files…
  local ex=$1; shift
  awk -v ex=",$ex," '
    FNR == 1 { fm = 0; incom = 0; skip = 0; sub(/^\357\273\277/, ""); sub(/\r$/, "")
               if ($0 == "---") { fm = 1; next } }
    { sub(/\r$/, "") }
    fm { if ($0 == "---") fm = 0; next }
    skip { next }
    index(ex, ",bibliography,") && /^#+[ \t]+(Bibliography|References|Works cited|Literaturverzeichnis|Literatur|Quellen|Quellenverzeichnis)[ \t]*$/ { skip = 1; next }
    incom { if (sub(/.*-->/, "")) incom = 0; else next }
    { while (match($0, /<!--/)) {
        pre = substr($0, 1, RSTART - 1); rest = substr($0, RSTART + 4)
        if (match(rest, /-->/)) $0 = pre substr(rest, RSTART + 3)
        else { $0 = pre; incom = 1; break }
      } }
    index(ex, ",footnotes,") && /^\[\^[^]]*\]:/ { next }
    index(ex, ",headings,") && /^#/ { next }
    { if (index(ex, ",footnotes,")) { gsub(/\^\[[^]]*\]/, ""); gsub(/\[\^[^]]*\]/, "") }
      if (index(ex, ",citations,")) gsub(/\[[^]]*@[^]]*\]/, "")
      n = 0
      for (i = 1; i <= NF; i++) if ($i ~ /[[:alnum:]]/) n++
      w[FILENAME] += n }
    END { for (f in w) print f "\t" w[f] }
  ' "$@"
}
if [ "$FORM" = nonfiction ]; then
  for d in works/*/; do
    [ -d "$d" ] || continue
    w=${d%/}; w=${w##*/}
    [ -z "$WANT" ] || [ "$WANT" = "$w" ] || continue
    lim=$(awk '/^word_limit:/ { v = $0; sub(/^word_limit:[ \t]*/, "", v); sub(/[ \t]+#.*$/, "", v); print v; exit }' "$d/work.yaml" 2>/dev/null | tr -d '\r')
    ex=$(awk '/^word_count_excludes:/ { v = $0; sub(/^word_count_excludes:[ \t]*/, "", v); sub(/[ \t]+#.*$/, "", v); gsub(/[][ "\047]/, "", v); print v; exit }' "$d/work.yaml" 2>/dev/null | tr -d '\r')
    set -- "$d"sections/*.md
    if [ -f "$1" ]; then
      total=0
      while IFS=$'\t' read -r f n; do
        [ -n "$f" ] || continue
        echo "section: $w/$(basename "$f" .md)	$n"
        total=$((total + n))
      done < <(count_words "$ex" "$@" | sort)
    else
      total=0
    fi
    case $lim in
      ''|null|'~') echo "work: $w	$total	limit: none	excludes: ${ex:-none}" ;;
      *[!0-9]*) echo "work: $w	$total	limit: unreadable ($lim)	excludes: ${ex:-none}" ;;
      *) echo "work: $w	$total	limit: $lim	excludes: ${ex:-none}"
         [ "$total" -gt "$lim" ] && echo "note: $w is over its word limit by $((total - lim))" ;;
    esac
  done
else
  set -- manuscript/*/*.md
  if [ -f "$1" ]; then
    count_words "" "$@" | sort | awk -F '\t' '
      { ch = $1; sub(/^manuscript\//, "", ch); sub(/\/.*/, "", ch); c[ch] += $2; u[ch]++; t += $2
        if (!(ch in seen)) { seen[ch] = 1; order[++n] = ch } }
      END { for (i = 1; i <= n; i++) printf "chapter: %s\t%d\tunits: %d\n", order[i], c[order[i]], u[order[i]]
            printf "total: %d\n", t }'
  else
    echo "total: 0"
  fi
fi

# ------------------------------------------------------------------ phases
# From flow-check.sh, the one reader of workflow.yaml (development-flow §8.2):
# stage in force, each phase, the recommended steps not yet done, the current
# phase and the next step. Non-fiction lines carry a `<work>: ` prefix.
echo "## phases"
bash "$root/.claude/scripts/flow-check.sh" ${WANT:+"$WANT"} 2>&1 | tr -d '\r' | awk -F '\t' '
  /^## work: / { w = substr($0, 10) ": "; next }
  /^## / { sec = substr($0, 4); next }
  /^error:/ { print; next }
  /^note: no works yet/ { print; next }
  /^stage-in-force: / { sub(/^stage-in-force: /, ""); print "stage-in-force: " w $0; next }
  sec == "steps" && /^step: / && $4 == "rec" && $3 != "PRESENT" && $3 != "SKIPPED" {
    p = $1; sub(/^step: /, "", p); print "missing: " w p "/" $2 "\t" $3 "\t" $6 "\t" $7 "\tnext: " $5; next }
  sec == "steps" && /^step: / && $3 == "SKIPPED" { p = $1; sub(/^step: /, "", p); print "skipped: " w p "/" $2 "\t" $6; next }
  sec == "phases" && /^phase: / { sub(/^phase: /, ""); print "phase: " w $0; next }
  sec == "phases" && /^(current-phase|next-step): / { k = $0; sub(/: .*/, "", k); v = $0; sub(/^[a-z-]+: /, "", v); print k ": " w v; next }
  sec == "write" && /^(drafted|next-unit|card-missing): / { k = $0; sub(/: .*/, "", k); v = $0; sub(/^[a-z-]+: /, "", v); print k ": " w v; next }
'

# ------------------------------------------------------------------ reviews
# Latest report per (pass, target); file name <pass>-<target>-<YYYY-MM-DD>[-n].md.
echo "## reviews"
if [ -n "$WANT" ]; then set -- "works/$WANT"/reviews/*.md; else set -- reviews/*.md works/*/reviews/*.md; fi
R=()
for f in "$@"; do [ -f "$f" ] && R+=("$f"); done
if [ "${#R[@]}" -gt 0 ]; then
  awk '
    FNR == 1 {
      b = FILENAME; sub(/.*\//, "", b); sub(/\.md$/, "", b)
      dir = FILENAME; sub(/\/[^\/]*$/, "", dir)
      pass = ""; tgt = ""; date = ""; seq = 1
      if (match(b, /^(continuity|citation|developmental|line|grammar|beta|milestone)-/)) {
        pass = substr(b, 1, RLENGTH - 1); r = substr(b, RLENGTH + 1)
        if (match(r, /-[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9](-[0-9]+)?$/)) {
          tgt = substr(r, 1, RSTART - 1); d = substr(r, RSTART + 1)
          date = substr(d, 1, 10); if (length(d) > 10) seq = substr(d, 12) + 0
        }
      }
      if (date == "") { print "note: " FILENAME ": name is not <pass>-<target>-<YYYY-MM-DD>.md"; skipf = 1 } else skipf = 0
      verdict = ""
    }
    { sub(/\r$/, "") }
    !skipf && verdict == "" && /^\*\*Verdict:\*\* / { verdict = substr($0, 14) }
    !skipf && verdict != "" && !done[FILENAME]++ {
      key = dir "|" pass "|" tgt; ord = date sprintf("%04d", seq)
      if (!(key in best) || ord > best[key]) { best[key] = ord; bf[key] = FILENAME; bv[key] = verdict; bd[key] = date }
    }
    END {
      for (k in best) { split(k, a, "|"); printf "review: %s\t%s\t%s\t%s\t%s\n", a[2], a[3], bd[k], bv[k], bf[k] }
    }
  ' "${R[@]}" | sort
  # Correctly named reports with no verdict line at all
  for f in "${R[@]}"; do
    case ${f##*/} in
      *-[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9].md|*-[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-[0-9]*.md)
        grep -q '^\*\*Verdict:\*\* ' "$f" || echo "note: $f has no **Verdict:** line" ;;
    esac
  done
else
  echo "note: no review reports yet"
fi

exit 0
