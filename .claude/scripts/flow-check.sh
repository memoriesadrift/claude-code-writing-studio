#!/usr/bin/env bash
# flow-check.sh — facts for /next, /status and /start (development-flow §8.2).
# Evaluates .claude/workflow.yaml against the working tree. Reports; never
# judges and never writes.
#
#   flow-check.sh [work]    the flow (non-fiction: one work; none = every work)
#   flow-check.sh disk      what exists on disk; works without studio.yaml
#
# Output, in `## section` blocks, tab-separated:
#   ## project   form, rigour, stage-in-force
#   ## steps     step: <phase> <id> <STATUS> <rec|opt> <skill> <name> [<detail>]
#                STATUS: PRESENT · ABSENT · SHORT · PATTERN_MISS · INCOMPLETE ·
#                SKIPPED (the author chose to go on without it) · NO_CHECK
#                rec = recommended at this rigour and form; opt = available
#   ## phases    phase: <id> <complete|incomplete>; current-phase; next-step
#   ## write     drafted: <n> of <m>; next-unit / card-missing / uncarded lines
#                with the prose level in force for the next unit
# Non-fiction prints the blocks once per work, each headed `## work: <slug>`.
#
# Exit: 0 done, 1 not set up (except `disk`), 2 usage. Bash 3.2-compatible.

set -u

root=${CLAUDE_PROJECT_DIR:-}
if [ -z "$root" ]; then
  root=$(cd "$(dirname "$0")/../.." && pwd) || { echo "error: cannot find the project root"; exit 2; }
fi
export CLAUDE_PROJECT_DIR=$root
cd "$root" || exit 2
# shellcheck source=lib-units.sh
. "$root/.claude/scripts/lib-units.sh"

# ------------------------------------------------------------------- disk
if [ "${1:-}" = disk ]; then
  count() { find "$1" -type f 2>/dev/null | grep -vc '/\.' ; }
  echo "## disk"
  [ -f studio.yaml ] && echo "studio: yes" || echo "studio: no"
  for d in manuscript bible outline compendium ideas reviews; do
    if [ -d "$d" ]; then echo "$d: $(count "$d") file(s)"; else echo "$d: none"; fi
  done
  if [ -d works ]; then
    n=0; names=""
    for w in works/*/; do [ -d "$w" ] || continue; w=${w%/}; n=$((n + 1)); names="$names ${w##*/}"; done
    echo "works: $n${names:+ —$names}"
  else echo "works: none"; fi
  # Loose writing at the root or one folder down, outside the studio's own folders.
  find . -maxdepth 2 -type f \( -iname '*.md' -o -iname '*.txt' -o -iname '*.docx' -o -iname '*.odt' -o -iname '*.rtf' -o -iname '*.fdx' -o -iname '*.tex' \) 2>/dev/null \
    | sed 's|^\./||' | LC_ALL=C sort \
    | grep -Ev '^(\.|manuscript/|bible/|outline/|compendium/|ideas/|reviews/|works/|session/|out/|docs/|inspiration/|publish/)' \
    | grep -Ev '^(README|LICENSE|CLAUDE|CHANGELOG|CONTRIBUTING)[^/]*$' \
    | sed 's/^/loose: /'
  exit 0
fi

[ -f studio.yaml ] || { echo "error: studio.yaml does not exist: the project is not set up (run /start)"; exit 1; }
CAT=.claude/workflow.yaml
[ -f "$CAT" ] || { echo "error: $CAT does not exist"; exit 1; }

FORM=$(wu_yget studio.yaml project form)
RIGOUR=$(wu_yget studio.yaml modes rigour); wu_nonnull "$RIGOUR" || RIGOUR=standard
case $FORM in nonfiction) SEC=nonfiction ;; novel|short|screenplay) SEC=fiction ;;
  *) echo "error: studio.yaml project.form is \"$FORM\""; exit 1 ;; esac

# Prose levels for the write loop (hook library, read-only use).
# shellcheck source=../hooks/lib.sh
. "$root/.claude/hooks/lib.sh"
ws_init
ws_load_studio

TMPD=$(mktemp -d "${TMPDIR:-/tmp}/ws-flow.XXXXXX") || { echo "error: cannot create a temporary directory"; exit 1; }
trap 'rm -r "$TMPD" 2>/dev/null' EXIT

# ------------------------------------------------------------- catalogue
# One record per step: phase, phase name, id, name, skill, recommended,
# optional_for, note, then artefact alternatives separated by \034, each a
# \035-separated list of key=value.
awk -v sec="$SEC" '
  function val(s) { sub(/[ \t]+#.*$/, "", s); sub(/^[ \t]+/, "", s); sub(/[ \t]+$/, "", s)
                    if (s ~ /^".*"$/ || s ~ /^\047.*\047$/) s = substr(s, 2, length(s) - 2); return s }
  function list(s) { s = val(s); gsub(/[][ ]/, "", s); return s }
  function d(s) { return s == "" ? "-" : s }
  function flush() {
    if (sid == "") return
    if (alt != "") alts = alts (alts == "" ? "" : "\034") alt
    # "-" for empty fields: read with IFS=tab would collapse empty ones.
    printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n", ph, d(phn), sid, d(sn), d(sk), d(rec), d(opt), d(nt), d(alts)
    sid = ""; sn = ""; sk = ""; rec = ""; opt = ""; nt = ""; alts = ""; alt = ""; inart = 0
  }
  { sub(/\r$/, "") }
  /^[ \t]*(#|$)/ { next }
  /^[^ ]/ { flush(); cur = $0; sub(/:.*/, "", cur); next }
  cur != sec { next }
  /^    - id:/ { flush(); v = $0; sub(/^    - id:/, "", v); ph = val(v); phn = ph; next }
  /^      name:/ { v = $0; sub(/^      name:/, "", v); phn = val(v); next }
  /^        - id:/ { flush(); v = $0; sub(/^        - id:/, "", v); sid = val(v); next }
  sid == "" { next }
  /^          [a-z_]+:/ {
    k = $0; sub(/^ +/, "", k); v = k; sub(/:.*/, "", k); sub(/^[a-z_]+:/, "", v)
    inart = 0
    if (k == "name") sn = val(v); else if (k == "skill") sk = val(v)
    else if (k == "recommended") rec = list(v); else if (k == "optional_for") opt = list(v)
    else if (k == "note") nt = val(v); else if (k == "artifact") inart = 1
    next
  }
  inart && /^ +- / {           # a new any_of alternative
    if (alt != "") alts = alts (alts == "" ? "" : "\034") alt
    alt = ""; line = $0; sub(/^ +- /, "", line)
  }
  inart && !/^ +- / { line = $0; sub(/^ +/, "", line) }
  inart {
    if (line ~ /^any_of:/) next
    k = line; sub(/:.*/, "", k); v = line; sub(/^[a-z_]+:/, "", v)
    alt = alt (alt == "" ? "" : "\035") k "=" val(v)
  }
  END { flush() }
' "$CAT" > "$TMPD/steps"
[ -s "$TMPD/steps" ] || { echo "error: $CAT has no steps for $SEC (schema 2 expected)"; exit 1; }

# ------------------------------------------------------------- evaluation
PROG=""
done_state() {   # $1 step id → prints done | skipped | (nothing)
  [ -n "$PROG" ] && [ -f "$PROG" ] || return 0
  awk -v id="$1" '{ sub(/\r$/, "") } index($0, id ":") == 1 { v = substr($0, length(id) + 2); sub(/^[ \t]+/, "", v); split(v, a, /[ \t]/); print a[1]; exit }' "$PROG"
}

cards_all() {   # every listed chapter has a card; at least one chapter
  local n=0 bad="" kind key title card folder listed
  while IFS=$'\t' read -r kind key title card folder listed; do
    [ "$kind" = chapter ] || continue
    [ "$listed" = yes ] || continue
    n=$((n + 1)); [ "$card" = yes ] || bad="$bad $key"
  done < "$TMPD/units"
  if [ "$n" = 0 ]; then ALT_ST=ABSENT; ALT_WHY="no chapter list in outline/structure.md"
  elif [ -n "$bad" ]; then ALT_ST=INCOMPLETE; ALT_WHY="no card for:$bad"
  else ALT_ST=PRESENT; ALT_WHY="$n chapter(s) with cards"; fi
}

all_drafted() {   # every listed unit drafted or revised (fiction: and cards-all)
  local n=0 undone="" kind key a b c d
  if [ "$SEC" = fiction ]; then
    cards_all
    [ "$ALT_ST" = PRESENT ] || return 0
  fi
  while IFS=$'\t' read -r kind key a b c d; do
    [ "$kind" = unit ] && [ "$c" = yes ] || continue
    n=$((n + 1))
    case $b in drafted|revised) ;; *) undone="$undone $key" ;; esac
  done < "$TMPD/units"
  if [ "$n" = 0 ]; then ALT_ST=ABSENT; ALT_WHY="no outlined units"
  elif [ -n "$undone" ]; then ALT_ST=INCOMPLETE; ALT_WHY="not yet:$undone"
  else ALT_ST=PRESENT; ALT_WHY="$n unit(s) drafted"; fi
}

eval_alt() {   # $1 alternative (key=value list) → ALT_ST, ALT_WHY
  local spec=$1 glob="" pat="" req=any min=1 dn="" chk="" kv k v f files=0 hits=0 bad="" out
  ALT_ST=NO_CHECK ALT_WHY=""
  local IFS=$'\035'
  for kv in $spec; do
    k=${kv%%=*}; v=${kv#*=}
    case $k in glob) glob=$v ;; pattern) pat=$v ;; require) req=$v ;; min_count) min=$v ;; done) dn=$v ;; check) chk=$v ;; esac
  done
  unset IFS
  if [ -n "$dn" ]; then
    case $(done_state "$dn") in
      done) ALT_ST=PRESENT; ALT_WHY="marked done" ;;
      skipped) ALT_ST=SKIPPED; ALT_WHY="skipped by the author" ;;
      *) ALT_ST=ABSENT; ALT_WHY="not marked done" ;;
    esac
    return
  fi
  case $chk in
    cards-all) cards_all; return ;;
    all-drafted) all_drafted; return ;;
  esac
  [ -n "$glob" ] || return
  glob=${glob//<work>/$WORK}
  set -- $glob
  for f in "$@"; do
    [ -f "$f" ] || continue
    files=$((files + 1))
    case $req in
      all_blocks)
        out=$(awk -v pat="$pat" '{ sub(/\r$/, "") }
          /^### / { if (b != "" && !hit) print b; b = $2; hit = 0; nb++; next }
          b != "" && $0 ~ pat { hit = 1 }
          END { if (b != "" && !hit) print b; if (!nb) print "(no ### blocks)" }' "$f")
        if [ -z "$out" ]; then hits=$((hits + 1)); else bad="$bad $(printf '%s' "$out" | paste -sd, -)"; fi ;;
      all) if [ -z "$pat" ] || grep -Eq -- "$pat" "$f"; then hits=$((hits + 1)); else bad="$bad $f"; fi ;;
      *) if [ -z "$pat" ] || grep -Eq -- "$pat" "$f"; then hits=$((hits + 1)); fi ;;
    esac
  done
  if [ "$files" = 0 ]; then ALT_ST=ABSENT; ALT_WHY="no file matches $glob"; return; fi
  case $req in
    all|all_blocks)
      if [ -z "$bad" ]; then ALT_ST=PRESENT; ALT_WHY="$files file(s)"
      else ALT_ST=INCOMPLETE; ALT_WHY="not yet:$bad"; fi ;;
    *)
      if [ "$hits" -ge "$min" ]; then ALT_ST=PRESENT; ALT_WHY="$hits file(s)"
      elif [ "$hits" -gt 0 ]; then ALT_ST=SHORT; ALT_WHY="$hits of $min"
      else ALT_ST=PATTERN_MISS; ALT_WHY="$files file(s), none matching /$pat/"; fi ;;
  esac
}

report() {   # flow for the fiction project, or for work $WORK
  local ph phn id nm sk rec opt nt alts alt st why first_st first_why recflag
  local cur_phase="" next_step="" lastph="" phase_ok=1 IFS_SAVE
  echo "## steps"
  : > "$TMPD/phases"
  while IFS=$'\t' read -r ph phn id nm sk rec opt nt alts; do
    if [ "$ph" != "$lastph" ]; then
      [ -n "$lastph" ] && printf '%s\t%s\n' "$lastph" "$phase_ok" >> "$TMPD/phases"
      lastph=$ph; phase_ok=1
    fi
    st=""; why=""; first_st=""; first_why=""
    [ "$nt" = - ] && nt=""; [ "$rec" = - ] && rec=""; [ "$opt" = - ] && opt=""; [ "$alts" = - ] && alts=""
    if [ -z "$alts" ]; then st=NO_CHECK; why=${nt:-no artefact defined}
    else
      IFS_SAVE=$IFS; IFS=$'\034'
      for alt in $alts; do
        IFS=$IFS_SAVE
        eval_alt "$alt"
        [ -n "$first_st" ] || { first_st=$ALT_ST; first_why=$ALT_WHY; }
        if [ "$ALT_ST" = PRESENT ] || [ "$ALT_ST" = SKIPPED ]; then st=$ALT_ST; why=$ALT_WHY; break; fi
        IFS=$'\034'
      done
      IFS=$IFS_SAVE
      [ -n "$st" ] || { st=$first_st; why=$first_why; }
    fi
    recflag=opt
    case ",$rec," in *",$RIGOUR,"*) recflag=rec ;; esac
    case ",$opt," in *",$FORM,"*) recflag=opt ;; esac
    printf 'step: %s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$ph" "$id" "$st" "$recflag" "$sk" "$nm" "$why"
    if [ "$recflag" = rec ] && [ "$st" != PRESENT ] && [ "$st" != SKIPPED ]; then
      phase_ok=0
      [ -n "$next_step" ] || next_step="$ph/$id	$sk	$nm"
    fi
  done < "$TMPD/steps"
  [ -n "$lastph" ] && printf '%s\t%s\n' "$lastph" "$phase_ok" >> "$TMPD/phases"
  echo "## phases"
  while IFS=$'\t' read -r ph phase_ok; do
    if [ "$phase_ok" = 1 ]; then echo "phase: $ph	complete"
    else echo "phase: $ph	incomplete"; [ -n "$cur_phase" ] || cur_phase=$ph; fi
  done < "$TMPD/phases"
  echo "current-phase: ${cur_phase:-none (every recommended step is done)}"
  echo "next-step: ${next_step:-none}"
}

write_loop() {   # $1 fiction | nonfiction
  local kind key a b c d total=0 drafted=0 nextu="" nextp="" nexts="" cardmiss="" chap=""
  local cur_card="" cur_folder="" found=0
  echo "## write"
  while IFS=$'\t' read -r kind key a b c d; do
    case $kind in
      note) echo "note: $key" ;;
      chapter)   # a title, b card, c folder, d listed
        chap=$key; cur_card=$b; cur_folder=$c
        if [ "$b" = no ]; then
          if [ "$c" = yes ]; then echo "uncarded: $key	(chapter folder with no card; its units are not tracked)"
          elif [ "$found" = 0 ] && [ -z "$cardmiss" ]; then cardmiss=$key; found=1; fi
        fi ;;
      unit)      # a path, b status, c listed
        [ "$c" = yes ] || continue
        [ "$1" = fiction ] && [ "$cur_card" = no ] && continue
        total=$((total + 1))
        case $b in drafted|revised) drafted=$((drafted + 1)) ;;
          *) if [ "$found" = 0 ]; then nextu=$key; nextp=$a; nexts=$b; found=1; fi ;;
        esac ;;
    esac
  done < "$TMPD/units"
  echo "drafted: $drafted of $total"
  if [ -n "$cardmiss" ]; then
    echo "card-missing: $cardmiss	(the next chapter has no card)"
  elif [ -n "$nextu" ]; then
    local okey=$nextu w=""
    [ "$1" = nonfiction ] && { okey="$WORK/$nextu"; w=$WORK; }
    ws_resolve "$okey" "$w"
    printf 'next-unit: %s\t%s\t%s\tlevel: %s\tsource: %s%s\n' "$okey" "$nextp" "$nexts" "$WS_LEVEL" "$WS_SRC" "${WS_CAP_NOTE:+	cap: $WS_CAP_NOTE}"
  elif [ "$total" = 0 ]; then
    echo "next-unit: none	(no outline blocks: the author picks the next unit)"
  else
    echo "next-unit: none	(every outlined unit is drafted)"
  fi
}

echo "## project"
echo "form: $FORM"
echo "rigour: $RIGOUR"
if [ "$SEC" = fiction ]; then
  WORK=""
  PROG=session/progress.yaml
  st=$(wu_yget studio.yaml project stage)
  echo "stage-in-force: ${st:-unset} (studio.yaml project.stage)"
  wu_units_fiction > "$TMPD/units"
  report
  write_loop fiction
else
  WANT=${1:-}
  case $WANT in */*|.*) echo "error: $WANT: not a work slug" >&2; exit 2 ;; esac
  [ -z "$WANT" ] || [ -d "works/$WANT" ] || { echo "error: works/$WANT does not exist" >&2; exit 2; }
  [ -f session/current-work ] && echo "current-work: $(tr -d '\r\n' < session/current-work)"
  n=0
  for d in works/*/; do
    [ -d "$d" ] || continue
    WORK=${d%/}; WORK=${WORK##*/}
    [ -z "$WANT" ] || [ "$WANT" = "$WORK" ] || continue
    n=$((n + 1))
    echo "## work: $WORK"
    PROG="works/$WORK/progress.yaml"
    st=$(wu_yget "works/$WORK/work.yaml" - status 2>/dev/null)
    echo "stage-in-force: ${st:-unset} (works/$WORK/work.yaml status)"
    wu_units_nonfiction "$WORK" > "$TMPD/units"
    report
    write_loop nonfiction
  done
  [ "$n" -gt 0 ] || echo "note: no works yet (/brainstorm to explore, /new-work to start one)"
fi
exit 0
