#!/usr/bin/env bash
# publish.sh — Markdown → LaTeX (→ PDF) for /publish (spec §8.4).
# Reports what it did; never changes prose.
#
#   publish.sh <work | manuscript> <tex | pdf>
#
# Fiction takes `manuscript`; non-fiction a work slug. Writes only under out/:
#   out/<target>.tex, and for pdf out/<target>.pdf (+ the engine's log) and
#   out/<target>.pages (the page count and build time, read by status.sh).
#
# Order: fiction — chapters from the chapter list in outline/structure.md,
# scenes from each card's `### scNN-slug` blocks; non-fiction — the
# `### NN-slug` blocks of works/<work>/outline.md. Without an outline, file
# names in sorted order. Files the outline does not list are appended
# (`unlisted:`); outline blocks without a file are listed (`missing:`).
# Fiction gets one generated `# <title>` per chapter (title from the card).
#
# `-t latex-smart` keeps quotation marks as Unicode: TeX ligatures would turn
# ?`` (German closing quote after a question mark) into ¿.
#
# Settings read (flat `key: value` lines): studio.yaml project.title,
# project.form, language.default, style.citation_style, publish.template,
# publish.engine, publish.author; work.yaml title, citation_style, template,
# language. CSL files are checked against the SHA-256 in .claude/tools.yaml
# (csl.bundled or csl.fetched).
#
# Output: `key: value` facts in `## section` blocks. Exit status:
#   0 done   1 failed (see `error:`)   2 usage
#   3 something is needed first (`need:` lines: a tool, a CSL style)

set -u

root=${CLAUDE_PROJECT_DIR:-}
if [ -z "$root" ]; then
  root=$(cd "$(dirname "$0")/../.." && pwd) || { echo "error: cannot find the project root"; exit 2; }
fi
export CLAUDE_PROJECT_DIR=$root
cd "$root" || exit 2
[ -f studio.yaml ] || { echo "error: studio.yaml does not exist: the project is not set up (run /start)"; exit 1; }

TARGET=${1:-}; FMT=${2:-}
case $FMT in tex|pdf) ;; *) echo "usage: publish.sh <work | manuscript> <tex | pdf>" >&2; exit 2 ;; esac

# shellcheck source=lib-units.sh
. "$root/.claude/scripts/lib-units.sh"
yget() { wu_yget "$@"; }
nonnull() { wu_nonnull "$@"; }

FORM=$(yget studio.yaml project form)
TMPD=$(mktemp -d "${TMPDIR:-/tmp}/ws-pub.XXXXXX") || { echo "error: cannot create a temporary directory"; exit 1; }
trap 'rm -r "$TMPD" 2>/dev/null' EXIT

INPUTS=()
echo "## inputs"
case $FORM in
  nonfiction)
    case $TARGET in ''|manuscript|*/*|.*) echo "error: non-fiction needs a work slug (works/<work>/)"; exit 2 ;; esac
    W="works/$TARGET"
    [ -d "$W" ] || { echo "error: $W does not exist"; exit 2; }
    WY="$W/work.yaml"; [ -f "$WY" ] || { echo "error: $WY does not exist"; exit 1; }
    while IFS=$'\t' read -r kind key path st listed; do
      case $kind in
        note) echo "note: $key" ;;
        unit)
          if [ "$path" = - ]; then echo "missing: $key (in the outline, no file yet)"; continue; fi
          INPUTS+=("$path")
          [ "$listed" = yes ] && echo "unit: $path" || echo "unlisted: $path (not in the outline; appended)" ;;
      esac
    done < <(wu_units_nonfiction "$TARGET")
    TITLE=$(yget "$WY" - title)
    STYLE=$(yget "$WY" - citation_style); nonnull "$STYLE" || STYLE=$(yget studio.yaml style citation_style)
    LANGTAG=$(yget "$WY" - language); nonnull "$LANGTAG" || LANGTAG=$(yget studio.yaml language default)
    TPL=$(yget "$WY" - template)
    if ! nonnull "$TPL"; then
      if [ -f "$W/template.tex" ]; then TPL="$W/template.tex"; else TPL=$(yget studio.yaml publish template); fi
    fi
    OUT=$TARGET
    ;;
  novel|short|screenplay)
    [ "$TARGET" = manuscript ] || { echo "error: fiction publishes the whole manuscript: publish.sh manuscript <tex|pdf>"; exit 2; }
    wu_units_fiction > "$TMPD/units"
    awk -F '\t' '$1 == "note" { print "note: " $2 } $1 == "chapter" && $6 == "no" { print "unlisted: manuscript/" $2 "/ (not in the chapter list; appended)" }' "$TMPD/units"
    n=0; skip=0
    while IFS=$'\t' read -r kind key a b c d; do
      case $kind in
        chapter)   # a title, b card, c folder, d listed
          if [ "$c" = no ]; then echo "missing: $key (in the chapter list, no folder yet)"; skip=1; continue; fi
          skip=0; n=$((n + 1)); h="$TMPD/$(printf '%03d' "$n")-$key.md"
          printf '# %s\n\n' "$a" > "$h"; INPUTS+=("$h"); echo "chapter: $key — $a" ;;
        unit)      # a path, b status, c listed
          [ "$skip" = 1 ] && continue
          if [ "$a" = - ]; then echo "missing: $key (on the card, no file yet)"; continue; fi
          INPUTS+=("$a")
          [ "$c" = yes ] && echo "unit: $a" || echo "unlisted: $a (not on the card; appended)" ;;
      esac
    done < "$TMPD/units"
    TITLE=$(yget studio.yaml project title)
    STYLE=""
    LANGTAG=$(yget studio.yaml language default)
    TPL=$(yget studio.yaml publish template)
    OUT=manuscript
    ;;
  *) echo "error: studio.yaml project.form is \"$FORM\": not novel, short, screenplay or nonfiction"; exit 1 ;;
esac

# Only generated chapter headings, no prose: nothing to publish.
real=0; for f in ${INPUTS[@]+"${INPUTS[@]}"}; do case $f in "$TMPD"/*) ;; *) real=$((real + 1)) ;; esac; done
[ "$real" -gt 0 ] || { echo "error: no prose files to publish"; exit 1; }

# ------------------------------------------------------------- settings
echo "## settings"
NEED=0
AUTHOR=$(yget studio.yaml publish author)
ENGINE=$(yget studio.yaml publish engine); nonnull "$ENGINE" || ENGINE=tectonic
echo "title: ${TITLE:-}"
nonnull "$AUTHOR" && echo "author: $AUTHOR" || { echo "author: (none: studio.yaml publish.author is not set)"; AUTHOR=""; }
nonnull "$LANGTAG" && echo "lang: $LANGTAG" || { echo "lang: (none)"; LANGTAG=""; }

if nonnull "$TPL"; then
  [ -f "$TPL" ] || { echo "error: template $TPL does not exist"; exit 1; }
  echo "template: $TPL"
else
  TPL=""; echo "template: pandoc built-in"
fi

# CSL (non-fiction only): .claude/csl/<id>.csl, hash-checked against tools.yaml.
CSL=""
if [ "$FORM" = nonfiction ]; then
  nonnull "$STYLE" || STYLE=ieee
  case $STYLE in *[!a-z0-9-]*|'') echo "error: citation style \"$STYLE\" is not a CSL style id"; exit 1 ;; esac
  [ -f compendium/library.bib ] || { echo "error: compendium/library.bib does not exist"; exit 1; }
  if command -v sha256sum >/dev/null 2>&1; then hash_of() { sha256sum "$1" | awk '{ print $1 }'; }
  else hash_of() { shasum -a 256 "$1" | awk '{ print $1 }'; }; fi
  # recorded <id>: sha256 under csl.bundled or csl.fetched; also `parent`.
  csl_rec() {
    awk -v id="$1" -v want="$2" '
      { sub(/\r$/, "") }
      /^[^ \t#]/ { incsl = ($0 ~ /^csl:/) }
      incsl && /^    [^ \t#]/ { cur = $0; sub(/^ +/, "", cur); sub(/:.*/, "", cur) }
      incsl && cur == id && $0 ~ "^      " want ":" { v = $0; sub("^ +" want ":[ \t]*", "", v); sub(/[ \t]+#.*$/, "", v); print v; exit }
    ' .claude/tools.yaml
  }
  check_csl() {   # $1 id → CSL_OK file or need
    local f=".claude/csl/$1.csl" rec got
    if [ ! -f "$f" ]; then echo "need: csl $1 (not in .claude/csl/; fetch it with csl-fetch.sh)"; NEED=1; return 1; fi
    rec=$(csl_rec "$1" sha256)
    if [ -z "$rec" ]; then echo "error: $f has no SHA-256 recorded in .claude/tools.yaml (csl.fetched)"; exit 1; fi
    got=$(hash_of "$f")
    [ "$got" = "$rec" ] || { echo "error: $f does not match its SHA-256 in .claude/tools.yaml (recorded $rec, now $got)"; exit 1; }
    return 0
  }
  if check_csl "$STYLE"; then
    CSL=".claude/csl/$STYLE.csl"
    PARENT=$(sed -n '/rel="independent-parent"/s/.*href="[^"]*\/styles\/\([a-z0-9-]*\)".*/\1/p' "$CSL" | head -1)
    if [ -n "$PARENT" ]; then
      echo "csl: $STYLE (dependent on $PARENT)"
      if check_csl "$PARENT"; then CSL=".claude/csl/$PARENT.csl"; fi
    else
      echo "csl: $STYLE"
    fi
  fi
fi

# ----------------------------------------------------------------- tools
tool_path() {   # $1 tool → path, or empty (and a need: line)
  local out p
  out=$(bash .claude/scripts/install-tool.sh check "$1" 2>/dev/null)
  case $out in *"status: usable"*) ;; *) echo "need: tool $1 (run install-tool.sh install $1 with approval)" >&2; return 1 ;; esac
  p=$(printf '%s\n' "$out" | sed -n 's/^path: //p' | head -1)
  printf '%s\n' "$p"
}
PANDOC=$(tool_path pandoc 2>&1) || { echo "$PANDOC"; NEED=1; PANDOC=""; }
ENG=""
if [ "$FMT" = pdf ]; then
  case $ENGINE in
    tectonic) ENG=$(tool_path tectonic 2>&1) || { echo "$ENG"; NEED=1; ENG=""; } ;;
    xelatex|lualatex|pdflatex) ENG=$(command -v "$ENGINE" 2>/dev/null) || { echo "need: $ENGINE on PATH (publish.engine), or set publish.engine: tectonic"; NEED=1; ENG=""; } ;;
    *) echo "error: publish.engine \"$ENGINE\" is not tectonic, xelatex, lualatex or pdflatex"; exit 1 ;;
  esac
  echo "engine: $ENGINE"
fi
[ "$NEED" = 0 ] || exit 3

# ---------------------------------------------------------------- pandoc
echo "## pandoc"
mkdir -p out
ARGS=(-f markdown -t latex-smart --standalone -o "out/$OUT.tex")
[ -n "$TITLE" ] && ARGS+=(-M "title=$TITLE")
[ -n "$AUTHOR" ] && ARGS+=(-M "author=$AUTHOR")
ARGS+=(-M "date=$(date +%Y-%m-%d)")
[ -n "$LANGTAG" ] && ARGS+=(-M "lang=$LANGTAG")
[ -n "$TPL" ] && ARGS+=(--template="$TPL")
if [ "$FORM" = nonfiction ]; then
  ARGS+=(--citeproc --bibliography=compendium/library.bib --csl="$CSL")
else
  ARGS+=(--top-level-division=chapter)
  [ -z "$TPL" ] && ARGS+=(-V documentclass=book)
fi
if ! "$PANDOC" "${ARGS[@]}" "${INPUTS[@]}" > "$TMPD/pandoc.log" 2>&1; then
  echo "error: pandoc failed"; tr -d '\r' < "$TMPD/pandoc.log" | sed 's/^/log: /' | head -20; exit 1
fi
tr -d '\r' < "$TMPD/pandoc.log" | sed 's/^/warning: /' | head -20
echo "output: out/$OUT.tex"
[ "$FMT" = pdf ] || exit 0

# --------------------------------------------------------------- compile
echo "## compile"
TPLDIR=""; [ -n "$TPL" ] && TPLDIR=$(cd "$(dirname "$TPL")" && pwd)
LOG="out/$OUT.log"
case $ENGINE in
  tectonic)
    TARGS=(-X compile "out/$OUT.tex" --outdir out --keep-logs)
    [ -n "$TPLDIR" ] && TARGS+=(-Z "search-path=$TPLDIR")
    "$ENG" "${TARGS[@]}" > "$TMPD/compile.out" 2>&1; rc=$?
    ;;
  *)
    rc=0
    for pass in 1 2; do
      ( cd out && TEXINPUTS="${TPLDIR:+$TPLDIR:}${TEXINPUTS:-}" "$ENG" -interaction=nonstopmode -halt-on-error "$OUT.tex" ) > "$TMPD/compile.out" 2>&1 || { rc=$?; break; }
    done
    ;;
esac
if [ "$rc" -ne 0 ] || [ ! -f "out/$OUT.pdf" ]; then
  echo "error: $ENGINE failed (exit $rc)"
  SRC="$TMPD/compile.out"; [ -f "$LOG" ] && SRC="$LOG"
  # The first TeX error and a few lines after it, then the engine's own summary.
  tr -d '\r' < "$SRC" | awk '/^! |^error:|[Ee]rror:/ && !n { n = 1 } n && c < 8 { print "log: " $0; c++ }'
  tr -d '\r' < "$TMPD/compile.out" | tail -5 | sed 's/^/tail: /'
  exit 1
fi
grep -i 'warning' "$TMPD/compile.out" | tr -d '\r' | head -5 | sed 's/^/warning: /'
echo "output: out/$OUT.pdf"
[ -f "$LOG" ] && echo "log: $LOG"

# Page count: TeX's own "Output written on … (N pages, …)" line from the log
# (or the engine's console output), else the PDF's /Type /Page objects
# (missed when they sit in compressed object streams). Recorded in
# out/<target>.pages for /status, which compares it with the sources' times.
PAGES=""
for src in "$LOG" "$TMPD/compile.out"; do
  [ -f "$src" ] || continue
  PAGES=$(tr -d '\r' < "$src" | awk 'match($0, /Output written on .*\([0-9]+ pages?/) {
            s = substr($0, RSTART, RLENGTH); sub(/.*\(/, "", s); sub(/ .*/, "", s); n = s }
          END { print n }')
  [ -n "$PAGES" ] && break
done
if [ -z "$PAGES" ]; then
  PAGES=$(LC_ALL=C grep -a -o '/Type[[:space:]]*/Page[^s]' "out/$OUT.pdf" 2>/dev/null | wc -l | tr -d ' ')
  [ "${PAGES:-0}" -gt 0 ] 2>/dev/null || PAGES=""
fi
if [ -n "$PAGES" ]; then
  echo "pages: $PAGES"
  printf 'pages: %s\nbuilt: %s\n' "$PAGES" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" > "out/$OUT.pages"
else
  echo "note: could not read the page count from the log or the PDF"
  rm -f "out/$OUT.pages"
fi
exit 0
