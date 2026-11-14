#!/usr/bin/env bash
# prose-guard — PreToolUse on Write, Edit, Bash, PowerShell (spec §5.2, §5.3, §10).
#
# Write/Edit on a prose file (manuscript/**, works/*/sections/**):
#   - critic, coach            → deny (exit 2), naming the level, its source and any cap
#   - editor and above         → no decision (normal permission flow) + the level's
#                                contract added to Claude's context
#   - at every level           → deny if the file is `locked: true`, if an Edit
#                                touches an <!-- author --> fence, or if a Write
#                                drops or alters a fenced passage
# Bash/PowerShell: `bash .claude/scripts/import-draft.sh …` alone on the line is
# allowed at every level (/import). Otherwise best effort: a command that
# writes and names a prose path is denied if any named path resolves to
# critic/coach. A shell command can always obscure its target; the rules
# and agent prompts carry the same contract.
#
# Before a Write (any studio file) or a replace-all Edit, records the old length
# / occurrence count for provenance-log, which cannot see the old file.
#
# Fails closed: if jq is missing, studio.yaml is missing, or a level is invalid,
# a prose write is denied.

. "${BASH_SOURCE%/*}/lib.sh"
ws_init
ws_read_input

# ---- fast exit: nothing that could touch a studio path (no subprocess so far)
ws_mentions_studio || exit 0

ws_find_jq
if [ -z "$WS_JQ" ]; then
  case $WS_IN in
    *manuscript*|*works/*|*works\\\\*)
      ws_deny "jq is not installed, so the prose guard cannot check this call and is denying it. Run /start to install jq, or install jq 1.8.2+ on PATH." ;;
  esac
  exit 0
fi

# ---- extract fields (NUL-separated: the command may hold any character)
{
  IFS= read -r -d '' TOOL
  IFS= read -r -d '' FILE
  IFS= read -r -d '' TUID
  IFS= read -r -d '' REPLACE_ALL
  IFS= read -r -d '' CMD
} < <(printf '%s' "$WS_IN" | "$WS_JQ" -j '
  [ .tool_name, (.tool_input.file_path // ""), (.tool_use_id // ""),
    (.tool_input.replace_all // false | tostring), (.tool_input.command // "") ]
  | map(tostring + "\u0000") | add')

LEVEL_CONTRACT_editor="Line-level suggestions only: present edits as a numbered list of diffs and apply only the ones the author accepts, one at a time. No new passages."
LEVEL_CONTRACT_coauthor="Whole units drafted from the author's card or outline, each shown and approved before writing. Set frontmatter prose: claude (or mixed if the file already had author text). Never touch author-owned passages."
LEVEL_CONTRACT_ghostwriter="Whole chapters or works drafted from the outline, unit by unit, each approved before writing. Set frontmatter prose: claude (or mixed). Never touch author-owned passages."
COMMON_CONTRACT="Never edit a locked: true file or inside <!-- author --> … <!-- /author -->; no unrequested rewrites; follow the style guide and the language pack in force."

# ================================================================ Write / Edit
if [ "$TOOL" = Write ] || [ "$TOOL" = Edit ]; then
  [ -n "$FILE" ] || exit 0
  ws_relpath "$FILE"
  [ -n "$WS_REL" ] || exit 0
  ws_classify "$WS_REL"
  [ "$WS_AREA" != other ] || exit 0

  ABS="$WS_ROOT/$WS_REL"

  # Inspect the existing file in one jq run: locked, fence violation, old
  # length, replace-all occurrence count.
  VERDICT=ok OLDLEN=0 COUNT=1
  if [ -f "$ABS" ]; then
    read -r VERDICT OLDLEN COUNT < <(printf '%s' "$WS_IN" | "$WS_JQ" -r --rawfile f "$ABS" --arg prose "$WS_AREA" '
      .tool_name as $tool | .tool_input as $in
      | ($f | length) as $len
      | (if $tool == "Edit" and ($in.old_string // "") != ""
           then [$f | indices($in.old_string)[]] else [] end) as $hits
      | if $prose != "prose" then "ok \($len) \($hits | length)"
        else
          (($f | capture("\\A\\x{FEFF}?---\\r?\\n(?<fm>(?:.*\\r?\\n)*?)---") .fm) // "") as $fm
          | ([$f | match("<!-- author -->(?:.|\\n)*?<!-- /author -->"; "g")
              | {o: .offset, e: (.offset + .length), s: .string}]) as $fences
          | if ($fm | test("(^|\\n)locked:[ \\t]*true[ \\t]*(#[^\\n]*)?(\\r?\\n|$)")) then "locked"
            elif $tool == "Edit" then
              ($in.old_string | length) as $ol
              | if any($hits[] as $h | $fences[] | ($h < .e and ($h + $ol) > .o); .)
                then "fence-edit" else "ok" end
            else
              if all($fences[]; .s as $s | $in.content | contains($s))
              then "ok" else "fence-write" end
            end
          | "\(.) \($len) \($hits | length)"
        end')
  fi

  # jq on Windows writes CRLF line ends
  VERDICT=${VERDICT%$'\r'} OLDLEN=${OLDLEN%$'\r'} COUNT=${COUNT%$'\r'}

  # Stash for provenance-log (Write: old length; Edit: replace-all count)
  if [ -n "$TUID" ]; then
    printf '%s %s\n' "${OLDLEN:-0}" "${COUNT:-1}" > "$WS_TMP/ws-prov-$TUID" 2>/dev/null
  fi

  [ "$WS_AREA" = prose ] || exit 0

  case $VERDICT in
    locked)
      ws_deny "$WS_REL has \`locked: true\` in its frontmatter: Claude may not edit it at any prose level. Only the author can unlock it." ;;
    fence-edit)
      ws_deny "this edit touches an author-owned passage (<!-- author --> … <!-- /author -->) in $WS_REL. Claude never edits inside an author fence; narrow the edit to text outside it." ;;
    fence-write)
      ws_deny "this write to $WS_REL would remove or alter an author-owned passage (<!-- author --> … <!-- /author -->). Keep every fenced passage byte for byte, or use Edit on the text outside the fences." ;;
    ok) ;;
    *)  # the check itself failed: fail closed
      ws_deny "could not check $WS_REL for \`locked\` and author fences (jq failed), so this write is denied." ;;
  esac

  ws_load_studio
  [ "$WS_HAVE_STUDIO" = 1 ] || ws_deny "studio.yaml is missing, so the prose level for $WS_REL is unknown. Run /start first."
  ws_resolve "$WS_KEY" "$WS_WORK"
  ws_level_desc
  case $WS_LEVEL in
    critic|coach)
      ws_deny "$WS_DESC does not let Claude write to prose files ($WS_REL). At \`$WS_LEVEL\` the author writes every word; feedback goes in reviews/ and names the problem without rewriting it." ;;
    editor)      ws_context PreToolUse "Writing Studio: $WS_DESC for $WS_REL. $LEVEL_CONTRACT_editor $COMMON_CONTRACT" ;;
    co-author)   ws_context PreToolUse "Writing Studio: $WS_DESC for $WS_REL. $LEVEL_CONTRACT_coauthor $COMMON_CONTRACT" ;;
    ghostwriter) ws_context PreToolUse "Writing Studio: $WS_DESC for $WS_REL. $LEVEL_CONTRACT_ghostwriter $COMMON_CONTRACT" ;;
    *)
      ws_deny "$WS_DESC is not a valid prose level for $WS_REL (valid: $WS_LEVELS). Fix studio.yaml or work.yaml; /status reports the line." ;;
  esac
  exit 0
fi

# ================================================================ Bash / PowerShell
if [ "$TOOL" = Bash ] || [ "$TOOL" = PowerShell ]; then
  # /import (development-flow §10, §12): the import script copies the author's
  # own text verbatim and checks it, so it is allowed at every level, but only
  # as the whole command line, with nothing that could chain, redirect or
  # substitute another command (; & | < > ` $ or a line break).
  case $CMD in
    "bash .claude/scripts/import-draft.sh "*)
      case $CMD in
        *[\;\&\|\<\>\`\$]*|*$'\n'*|*$'\r'*) ;;
        *) exit 0 ;;
      esac ;;
  esac

  C=${CMD//\\//}
  case $C in *manuscript*|*works/*) ;; *) exit 0 ;; esac

  # Drop redirections that cannot write a file before looking for writes.
  C=${C//[0-9]>&[0-9]/ }
  C=${C//>&[0-9]/ }
  C=${C//[0-9]>\/dev\/null/ }
  C=${C//>\/dev\/null/ }
  C=${C//[0-9]>\$null/ }
  C=${C//>\$null/ }
  C=${C//[0-9]>nul/ }

  WRITE_RE='(>|(^|[^[:alnum:]_-])(tee|cp|mv|rm|rmdir|touch|truncate|dd|install|ln|unlink|shred|rsync|patch)([^[:alnum:]_-]|$)|sed[^|;&]*[[:space:]]-[[:alpha:]]*i|perl[^|;&]*[[:space:]]-[[:alpha:]]*i|(python3?|node|perl|ruby|php)[^|;&]*[[:space:]]-[ce]([[:space:]]|$)|git[[:space:]]+(checkout|restore|apply|reset|stash|mv|rm|switch|merge|rebase|pull|cherry-pick|revert)|Set-Content|Add-Content|Clear-Content|Out-File|Copy-Item|Move-Item|Remove-Item|Rename-Item|New-Item|WriteAll|AppendAll|(^|[^[:alnum:]_-])(sc|ac|ni|ri|mi|cpi|del|erase|ren|copy|move|cpi)[[:space:]])'
  shopt -s nocasematch
  [[ $C =~ $WRITE_RE ]] || exit 0
  shopt -u nocasematch

  ws_load_studio
  if [ "$WS_HAVE_STUDIO" != 1 ]; then
    ws_deny "this command writes and names a prose path, but studio.yaml is missing, so the prose level is unknown. Run /start first."
  fi

  # Every prose-root path mentioned in the command (relative or absolute).
  TOKEN_RE='(^|[^[:alnum:]_.-])((manuscript|works)(/[^[:space:]"'\''|;&<>()`]*)?)'
  REST=$C
  while [[ $REST =~ $TOKEN_RE ]]; do
    TOK=${BASH_REMATCH[2]}
    REST=${REST#*"${BASH_REMATCH[0]}"}
    # A glob (works/*/sections/*.md) is judged at the directory above the
    # first wildcard, i.e. by the strictest level beneath it.
    case $TOK in *[*?]*) TOK=${TOK%%[*?]*}; TOK=${TOK%/*} ;; esac
    TOK=${TOK%/}
    case $TOK in
      manuscript/*.md|works/*/sections/*.md)
        ws_classify "$TOK"; ws_resolve "$WS_KEY" "$WS_WORK" ;;
      manuscript|manuscript/*)
        P=${TOK#manuscript}; P=${P#/}; P=${P%/}
        ws_resolve_strictest "$P" manuscript ;;
      works)
        ws_resolve_strictest "" works ;;
      works/*)
        W=${TOK#works/}; W=${W%%/*}; 
        R=${TOK#works/"$W"}; R=${R#/}
        case $R in
          ''|sections|sections/*)
            if [ -z "$W" ]; then ws_resolve_strictest "" works
            else
              S=${R#sections}; S=${S#/}; S=${S%/}
              ws_resolve_strictest "$W${S:+/$S}" works
            fi ;;
          *) continue ;;     # works/<w>/brief.md etc.: not prose
        esac ;;
      *) continue ;;
    esac
    ws_level_desc
    case $WS_LEVEL in
      critic|coach)
        ws_deny "this command appears to write under $TOK, and $WS_DESC does not let Claude write prose. (Shell checks are best effort; if this command does not write prose, rephrase it so it does not look like a write, e.g. use Read or Grep.)" ;;
      editor|co-author|ghostwriter) ;;
      *) ws_deny "$WS_DESC is not a valid prose level (valid: $WS_LEVELS). Fix studio.yaml or work.yaml." ;;
    esac
  done
  exit 0
fi

exit 0
