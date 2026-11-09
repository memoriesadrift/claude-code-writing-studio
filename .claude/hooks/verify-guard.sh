#!/usr/bin/env bash
# verify-guard — PreToolUse on Write, Edit of compendium/sources/*.md (spec §6.3,
# §6.4, §10).
#
# Acts only when the write changes the note's `status:` to `verified` (from
# anything else, including a new note). Then:
#   - kind pdf|web|scan  → deny unless compendium/archive.sha256 has at least
#                          one line under archive/<citekey>/ and every such
#                          line passes `sha256sum -c` (files present, hashes match)
#   - kind physical      → deny if archive.held is empty
#   - any other kind     → deny
#   - checks pass        → force a permission prompt ("ask") even in auto-accept
#                          modes: only the author marks a source verified
# Fails closed: without jq, any Write/Edit naming compendium/sources is denied.
# Shell commands are not inspected.

. "${BASH_SOURCE%/*}/lib.sh"
ws_init
ws_read_input

[ "$WS_WINDOWS" = 1 ] && shopt -s nocasematch
case $WS_IN in *compendium*) ;; *) exit 0 ;; esac
case $WS_IN in *'"Write"'*|*'"Edit"'*) ;; *) exit 0 ;; esac
case $WS_IN in *compendium/sources*|*compendium\\\\sources*) ;; *) exit 0 ;; esac
shopt -u nocasematch

ws_find_jq
[ -n "$WS_JQ" ] || ws_deny "jq is not installed, so verify-guard cannot check this write to a source note and is denying it. Run /start to install jq, or install jq 1.8.2+ on PATH."

{
  IFS= read -r -d '' TOOL
  IFS= read -r -d '' FILE
} < <(printf '%s' "$WS_IN" | "$WS_JQ" -j '
  [ .tool_name, (.tool_input.file_path // "") ] | map(tostring + "\u0000") | add')

case $TOOL in Write|Edit) ;; *) exit 0 ;; esac
[ -n "$FILE" ] || exit 0
ws_relpath "$FILE"
[ -n "$WS_REL" ] || exit 0
REL_LC=$WS_REL; [ "$WS_WINDOWS" = 1 ] && REL_LC=${REL_LC,,}
case $REL_LC in compendium/sources/*/*) exit 0 ;; compendium/sources/*.md) ;; *) exit 0 ;; esac
CITEKEY=${WS_REL##*/}; CITEKEY=${CITEKEY%.[mM][dD]}
ABS="$WS_ROOT/$WS_REL"

# Old and new frontmatter fields, from the file on disk and the content the
# write would produce (Edit: the replacement applied to the current file).
OLDARG=(--arg old ""); [ -f "$ABS" ] && OLDARG=(--rawfile old "$ABS")
read -r OLD_STATUS NEW_STATUS KIND HELD < <(printf '%s' "$WS_IN" | "$WS_JQ" -r "${OLDARG[@]}" '
  def fm: (capture("\\A\\x{FEFF}?---\\r?\\n(?<fm>(?:.*\\r?\\n)*?)---") .fm) // "";
  def top($k): (capture("(^|\\n)" + $k + ":[ \\t]*[\"\u0027]?(?<v>[^\"\u0027#\\r\\n]*)") .v // "")
               | sub("[ \\t]+$"; "");
  def archive: (capture("(^|\\n)archive:[^\\n]*\\n(?<b>(?:[ \\t]+[^\\n]*(?:\\n|$))*)") .b) // "";
  def nested($k): (capture("(^|\\n)[ \\t]+" + $k + ":[ \\t]*[\"\u0027]?(?<v>[^\"\u0027#\\r\\n]*)") .v // "")
                  | sub("[ \\t]+$"; "");
  def dash: if . == "" then "-" else . end;
  .tool_input as $in
  | (if .tool_name == "Write" then ($in.content // "")
     else ($in.old_string // "") as $o | ($in.new_string // "") as $n
       | if $o == "" then $old
         elif $in.replace_all == true then ($old | split($o) | join($n))
         else ($old | index($o)) as $i
           | if $i == null then $old else $old[:$i] + $n + $old[($i + ($o | length)):] end
         end
     end) as $new
  | ($old | fm | top("status")) as $os
  | ($new | fm) as $nf
  | ($nf | top("status")) as $ns
  | ($nf | archive) as $ab
  | ($ab | nested("kind")) as $kind
  | ($ab | nested("held")) as $held
  | [ ($os | dash), ($ns | dash), ($kind | dash),
      (if $held == "" or $held == "null" or $held == "~" then "0" else "1" end) ]
  | join(" ")')
OLD_STATUS=${OLD_STATUS%$'\r'} NEW_STATUS=${NEW_STATUS%$'\r'} KIND=${KIND%$'\r'} HELD=${HELD%$'\r'}

[ -n "$NEW_STATUS" ] || ws_deny "could not read the status of $WS_REL (jq failed), so this write is denied."
[ "$NEW_STATUS" = verified ] || exit 0
[ "$OLD_STATUS" != verified ] || exit 0

case $KIND in
  physical)
    [ "$HELD" = 1 ] || ws_deny "$WS_REL is \`kind: physical\` but \`archive.held\` is empty. A physical source can be marked verified only once the author has recorded where they hold the print copy (spec §6.4)." ;;
  pdf|web|scan)
    SUMS="$WS_ROOT/compendium/archive.sha256"
    [ -f "$SUMS" ] || ws_deny "compendium/archive.sha256 does not exist, so $CITEKEY has no archived copy on record. Archive the source with /source before marking it verified (spec §6.4)."
    LINES=$(awk -v p="archive/$CITEKEY/" -v ci="$WS_WINDOWS" '
      { sub(/\r$/, ""); f = $0; sub(/^[0-9A-Fa-f]+ [ *]/, "", f)
        a = f; b = p; if (ci == 1) { a = tolower(a); b = tolower(b) }
        if (index(a, b) == 1 && f !~ /(^|\/)\.\.(\/|$)/) print }' "$SUMS")
    [ -n "$LINES" ] || ws_deny "compendium/archive.sha256 has no line under archive/$CITEKEY/, so $CITEKEY has no archived copy on record. Archive the source with /source before marking it verified (spec §6.4)."
    if command -v sha256sum >/dev/null 2>&1; then SHA=(sha256sum -c)
    elif command -v shasum >/dev/null 2>&1; then SHA=(shasum -a 256 -c)
    else ws_deny "neither sha256sum nor shasum is available, so the archive of $CITEKEY cannot be checked."
    fi
    if ! RES=$(cd "$WS_ROOT/compendium" && printf '%s\n' "$LINES" | "${SHA[@]}" - 2>&1); then
      BAD=$(printf '%s\n' "$RES" | grep -v ': OK$')
      ws_deny "the archived copy of $CITEKEY does not match compendium/archive.sha256, so it cannot be marked verified:
$BAD
Restore the archived files, or re-archive the source with /source (spec §6.4)."
    fi ;;
  *)
    ws_deny "$WS_REL has \`archive.kind: ${KIND#-}\`; it must be pdf, web, scan or physical before the source can be marked verified." ;;
esac

ws_json_escape "Writing Studio: this marks $CITEKEY as verified. Only the author may do that (spec §6.3): approve only if you have checked the source exists and says what the note claims."
printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"%s"}}\n' "$WS_JSON_STR"
exit 0
