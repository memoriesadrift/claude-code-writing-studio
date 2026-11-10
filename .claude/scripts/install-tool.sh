#!/usr/bin/env bash
# install-tool.sh — check for, or install, a tool pinned in .claude/tools.yaml
# (spec §8.4, §10.1). Used by /start (jq) and /publish (pandoc, tectonic).
#
#   install-tool.sh check   <tool>   report whether a usable copy exists
#   install-tool.sh install <tool>   download, verify and install the pinned build
#
# A copy is usable if it is .claude/bin/<binary>, or <binary> on PATH, at the
# pinned version or newer. `install` downloads <release_url>/<file> for this
# platform into a temporary folder under .claude/bin/, checks its SHA-256
# against the hash COMMITTED in tools.yaml (never fetched alongside it),
# deletes it on a mismatch, and otherwise places <binary> in .claude/bin/.
#
# Output: one `key: value` fact per line. Exit status:
#   0 usable / installed   1 not usable / failed   2 usage error
#   3 no official build for this platform (install it yourself)
#
# Run with approval only: `install` downloads from the network.

set -u

die() { printf 'error: %s\n' "$1"; exit "${2:-1}"; }

mode=${1:-}; tool=${2:-}
case $mode in check|install) ;; *) die "usage: install-tool.sh check|install <tool>" 2 ;; esac
[ -n "$tool" ] || die "usage: install-tool.sh check|install <tool>" 2
case $tool in *[!a-z0-9_-]*) die "invalid tool name: $tool" 2 ;; esac

root=${CLAUDE_PROJECT_DIR:-}
if [ -z "$root" ]; then
  root=$(cd "$(dirname "$0")/../.." && pwd) || die "cannot find the project root" 2
fi
root=${root//\\//}
spec="$root/.claude/tools.yaml"
bin="$root/.claude/bin"
[ -f "$spec" ] || die "missing $spec" 2

# ---------------------------------------------------------------- platform

case $(uname -s) in
  MINGW*|MSYS*|CYGWIN*|Windows_NT) os=windows ;;
  Darwin) os=macos ;;
  Linux) os=linux ;;
  *) die "unsupported operating system: $(uname -s)" 3 ;;
esac
case $(uname -m) in
  x86_64|amd64|AMD64) arch=amd64 ;;
  arm64|aarch64|ARM64) arch=arm64 ;;
  *) die "unsupported architecture: $(uname -m)" 3 ;;
esac
platform="$os-$arch"

# ---------------------------------------------------------------- tools.yaml
# Reads tools.<tool>.{version,release_url,archive} and
# tools.<tool>.platforms.<platform>.{file,sha256,binary} (or `null`).

eval "$(awk -v want="$tool" -v plat="$platform" '
  function val(s) {
    sub(/[ \t]+#.*$/, "", s); sub(/^[ \t]+/, "", s); sub(/[ \t]+$/, "", s)
    if (s ~ /^".*"$/ || s ~ /^\047.*\047$/) s = substr(s, 2, length(s) - 2)
    return s
  }
  function emit(k, v) {
    gsub(/\047/, "", v)                     # values are single-quoted below
    printf "%s=\047%s\047\n", k, v
  }
  { sub(/\r$/, "") }
  /^[ \t]*(#|$)/ { next }
  {
    ind = match($0, /[^ ]/) - 1; c = substr($0, ind + 1)
    k = c; sub(/:.*/, "", k)
    v = c; if (!sub(/^[^:]*:/, "", v)) v = ""; v = val(v)
  }
  ind == 0 { top = k; t = ""; inpl = 0; p = ""; next }
  top != "tools" { next }
  ind == 2 { t = k; inpl = 0; p = ""; if (t == want) print "found=1"; next }
  t != want { next }
  ind == 4 && k == "platforms" { inpl = 1; next }
  ind == 4 { inpl = 0
    if (k == "version") emit("version", v)
    if (k == "release_url") emit("release_url", v)
    if (k == "archive") emit("archive", v)
    next }
  inpl && ind == 6 { p = k; if (p == plat) { emit("plat_value", v); print "plat_found=1" } next }
  inpl && ind == 8 && p == plat {
    if (k == "file") emit("file", v)
    if (k == "sha256") emit("sha256", v)
    if (k == "binary") emit("binary", v)
  }
' "$spec")"

[ "${found:-0}" = 1 ] || die "tool not in tools.yaml: $tool" 2
[ -n "${version:-}" ] || die "tools.yaml: $tool has no version" 2
[ "${plat_found:-0}" = 1 ] || die "tools.yaml: $tool lists no entry for $platform" 3
if [ "${plat_value:-}" = null ]; then
  printf 'tool: %s %s\nplatform: %s\nstatus: no-official-build\n' "$tool" "$version" "$platform"
  printf 'note: there is no official %s build for %s; install it yourself and put it on PATH\n' "$tool" "$platform"
  exit 3
fi
[ -n "${file:-}" ] && [ -n "${binary:-}" ] || die "tools.yaml: $tool/$platform needs file and binary" 2
case ${sha256:-} in
  *[!0-9a-f]*|'') die "tools.yaml: $tool/$platform has no valid sha256; refusing to install" 2 ;;
esac
[ ${#sha256} -eq 64 ] || die "tools.yaml: $tool/$platform sha256 is not 64 hex digits" 2
case $file$binary in */*|*..*) die "tools.yaml: file and binary must be plain names" 2 ;; esac

# ---------------------------------------------------------------- helpers

# Print the first dotted version number in `<cmd> --version`.
version_of() {
  "$1" --version 2>/dev/null | awk 'match($0, /[0-9]+(\.[0-9]+)+/) { print substr($0, RSTART, RLENGTH); exit }'
}

# True if version $1 >= version $2.
version_ge() {
  awk -v a="$1" -v b="$2" 'BEGIN {
    na = split(a, x, "."); nb = split(b, y, "."); n = na > nb ? na : nb
    for (i = 1; i <= n; i++) { if (x[i] + 0 > y[i] + 0) exit 0; if (x[i] + 0 < y[i] + 0) exit 1 }
    exit 0 }'
}

hash_of() {
  if command -v sha256sum >/dev/null 2>&1; then sha256sum "$1" | awk '{ print $1 }'
  elif command -v shasum >/dev/null 2>&1; then shasum -a 256 "$1" | awk '{ print $1 }'
  else return 1
  fi
}

# Sets usable_path and usable_version if a usable copy exists.
find_usable() {
  usable_path="" usable_version=""
  local cand v
  for cand in "$bin/$binary" "$(command -v "${binary%.exe}" 2>/dev/null)"; do
    [ -n "$cand" ] && [ -x "$cand" ] || continue
    v=$(version_of "$cand")
    if [ -n "$v" ] && version_ge "$v" "$version"; then
      usable_path=$cand usable_version=$v; return 0
    fi
    [ -n "$v" ] && printf 'found-older: %s (%s)\n' "$cand" "$v"
  done
  return 1
}

printf 'tool: %s %s\nplatform: %s\n' "$tool" "$version" "$platform"

# ---------------------------------------------------------------- check

if find_usable; then
  printf 'status: usable\npath: %s\nversion: %s\n' "$usable_path" "$usable_version"
  exit 0
fi
if [ "$mode" = check ]; then
  printf 'status: missing\n'
  exit 1
fi

# ---------------------------------------------------------------- install

command -v curl >/dev/null 2>&1 || die "curl is not available; install $tool yourself"
hash_of /dev/null >/dev/null 2>&1 || die "neither sha256sum nor shasum is available; cannot verify the download"

mkdir -p "$bin" || die "cannot create $bin"
work="$bin/.download-$tool-$$"
mkdir "$work" || die "cannot create $work"
cleanup() { [ -d "$work" ] && rm -r -- "$work"; }
trap cleanup EXIT

url="$release_url/$file"
printf 'download: %s\n' "$url"
curl -fsSL --proto '=https' --tlsv1.2 --retry 2 -o "$work/$file" "$url" \
  || die "download failed: $url"

got=$(hash_of "$work/$file") || die "could not hash the download"
if [ "$got" != "$sha256" ]; then
  rm -f -- "$work/$file"
  printf 'expected-sha256: %s\nactual-sha256: %s\n' "$sha256" "$got"
  die "checksum mismatch: the download was deleted and nothing was installed"
fi
printf 'sha256: ok\n'

case ${archive:-none} in
  none)
    src="$work/$file" ;;
  extract)
    mkdir "$work/x" || die "cannot create $work/x"
    case $file in
      *.tar.gz|*.tgz) tar -xzf "$work/$file" -C "$work/x" || die "could not unpack $file" ;;
      *.zip)
        if command -v unzip >/dev/null 2>&1; then
          unzip -q "$work/$file" -d "$work/x" || die "could not unpack $file"
        elif [ "$os" = windows ]; then
          # Git Bash's GNU tar cannot read .zip; Windows' own tools can.
          win_zip=$(cygpath -w "$work/$file") win_dir=$(cygpath -w "$work/x")
          powershell.exe -NoProfile -NonInteractive -Command \
            "Expand-Archive -LiteralPath '$win_zip' -DestinationPath '$win_dir'" \
            || die "could not unpack $file"
        else
          tar -xf "$work/$file" -C "$work/x" || die "could not unpack $file (no unzip)"
        fi ;;
      *) die "unknown archive type: $file" ;;
    esac
    src=$(find "$work/x" -type f -name "$binary" | head -n 1)
    [ -n "$src" ] || die "$binary not found inside $file" ;;
  *) die "tools.yaml: unknown archive mode: $archive" 2 ;;
esac

cp -- "$src" "$bin/$binary.new" || die "cannot write $bin/$binary"
chmod +x "$bin/$binary.new" 2>/dev/null
mv -f -- "$bin/$binary.new" "$bin/$binary" || die "cannot write $bin/$binary"
v=$(version_of "$bin/$binary")
printf 'status: installed\npath: %s\nversion: %s\n' "$bin/$binary" "${v:-unknown}"
exit 0
