# shellcheck shell=bash
# lib-units.sh — the order of prose units, shared by publish.sh and
# flow-check.sh (spec v1 §8.4, development-flow §8.2). Sourced, never run.
# Run from the project root. Bash 3.2-compatible.
#
# Order: fiction — chapters from the chapter list in outline/structure.md,
# then chapter folders the list lacks; within a chapter, the card's
# `### scNN-slug` blocks, then files the card lacks. Non-fiction — the
# `### NN-slug` blocks of works/<work>/outline.md, then files it lacks.
# Without an outline, file names in sorted order.
#
# wu_units_fiction / wu_units_nonfiction <work> print tab-separated records:
#   note      <text>
#   chapter   <key> <title> <card: yes|no> <folder: yes|no> <listed: yes|no>
#   unit      <key> <path or -> <status or -> <listed: yes|no>
#                (key: <chapter>/<unit> or <section>; path - = no file yet;
#                 status from the block's `status:` line, - if none;
#                 listed no = a file the outline does not list)

# wu_yget <file> <section or -> <key>: a flat value, quotes and comments removed.
wu_yget() {
  awk -v sec="$2" -v key="$3" '
    function val(s) { sub(/[ \t]+#.*$/, "", s); sub(/^[ \t]+/, "", s); sub(/[ \t]+$/, "", s)
                      if (s ~ /^".*"$/ || s ~ /^\047.*\047$/) s = substr(s, 2, length(s) - 2); return s }
    { sub(/\r$/, "") }
    /^[ \t]*(#|$)/ { next }
    /^[^ \t]/ { top = $0; sub(/:.*/, "", top) }
    sec == "-" && /^[^ \t]/ && index($0, key ":") == 1 { v = substr($0, length(key) + 2); print val(v); exit }
    sec != "-" && top == sec && $0 ~ "^[ \t]+" key ":" { v = $0; sub("^[ \t]+" key ":", "", v); print val(v); exit }
  ' "$1"
}
wu_nonnull() { case ${1:-} in ''|null|'~') return 1 ;; *) return 0 ;; esac; }

# _wu_blocks <file>: "<slug>\t<status or ->" per `### ` block, in order.
_wu_blocks() {
  awk '
    { sub(/\r$/, "") }
    /^### [^ ]/ { if (b != "") print b "\t" (s == "" ? "-" : s); b = $2; s = ""; first = 1; next }
    b != "" && first && /^[ \t]*$/ { next }
    b != "" && first { first = 0; if ($0 ~ /^status:/) { s = $0; sub(/^status:[ \t]*/, "", s); sub(/[ \t]+#.*$/, "", s) } }
    END { if (b != "") print b "\t" (s == "" ? "-" : s) }
  ' "$1"
}

# _wu_files <dir> <keyprefix> <seen>: unlisted .md files of <dir>.
_wu_files() {
  local f s
  for f in "$1"/*.md; do
    [ -f "$f" ] || continue
    s=${f##*/}; s=${s%.md}
    case $3 in *" $s "*) continue ;; esac
    printf 'unit\t%s%s\t%s\t-\t%s\n' "$2" "$s" "$f" "$4"
  done
}

wu_units_nonfiction() {
  local W="works/$1" s st seen=" " listed=no
  if [ -f "$W/outline.md" ] && [ -n "$(_wu_blocks "$W/outline.md")" ]; then
    listed=yes
    while IFS=$'\t' read -r s st; do
      if [ -f "$W/sections/$s.md" ]; then printf 'unit\t%s\t%s\t%s\tyes\n' "$s" "$W/sections/$s.md" "$st"
      else printf 'unit\t%s\t-\t%s\tyes\n' "$s" "$st"; fi
      seen="$seen$s "
    done < <(_wu_blocks "$W/outline.md")
  else
    printf 'note\tno outline blocks; sections in file-name order\n'
  fi
  # Files the outline lacks are "listed: no" only when there is an outline.
  _wu_files "$W/sections" "" "$seen" "$([ "$listed" = yes ] && echo no || echo yes)"
}

wu_units_fiction() {
  local CH="" c d title card folder inlist s st seen listed=" " haslist=no
  if [ -f outline/structure.md ]; then
    CH=$(awk -F '|' '{ sub(/\r$/, "") }
      /^## Chapter list/ { on = 1; next } /^## / { on = 0 }
      on && NF > 3 { k = $3; gsub(/^[ \t]+|[ \t]+$/, "", k); if (k ~ /^ch[0-9]/) print k }' outline/structure.md)
  fi
  if [ -n "$CH" ]; then haslist=yes
  else
    printf 'note\tno chapter list in outline/structure.md; chapters in folder-name order\n'
    CH=$(for d in manuscript/*/; do [ -d "$d" ] && { d=${d%/}; echo "${d##*/}"; }; done)
  fi
  for c in $CH; do listed="$listed$c "; done
  for d in manuscript/*/; do
    [ -d "$d" ] || continue; d=${d%/}; d=${d##*/}
    case $listed in *" $d "*) ;; *) CH="$CH $d" ;; esac
  done
  for c in $CH; do
    card="outline/chapters/$c.md"; title=""
    [ -f "$card" ] && title=$(wu_yget "$card" - title)
    if ! wu_nonnull "$title" && [ -f outline/structure.md ]; then
      title=$(awk -F '|' -v c="$c" '{ sub(/\r$/, "") }
        /^## Chapter list/ { on = 1; next } /^## / { on = 0 }
        on && NF > 4 { k = $3; t = $4; gsub(/^[ \t]+|[ \t]+$/, "", k); gsub(/^[ \t]+|[ \t]+$/, "", t)
                       if (k == c) { print t; exit } }' outline/structure.md)
    fi
    wu_nonnull "$title" || title=$c
    [ -f "$card" ] && card=yes || card=no
    [ -d "manuscript/$c" ] && folder=yes || folder=no
    case $listed in *" $c "*) inlist=$haslist ;; *) inlist=no ;; esac
    [ "$haslist" = no ] && inlist=yes
    printf 'chapter\t%s\t%s\t%s\t%s\t%s\n' "$c" "$title" "$card" "$folder" "$inlist"
    seen=" "
    if [ "$card" = yes ]; then
      while IFS=$'\t' read -r s st; do
        if [ -f "manuscript/$c/$s.md" ]; then printf 'unit\t%s/%s\t%s\t%s\tyes\n' "$c" "$s" "manuscript/$c/$s.md" "$st"
        else printf 'unit\t%s/%s\t-\t%s\tyes\n' "$c" "$s" "$st"; fi
        seen="$seen$s "
      done < <(_wu_blocks "outline/chapters/$c.md")
    fi
    _wu_files "manuscript/$c" "$c/" "$seen" "$([ "$card" = yes ] && [ "$seen" != " " ] && echo no || echo yes)"
  done
}
