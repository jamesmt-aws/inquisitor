#!/usr/bin/env bash
set -euo pipefail

PRS=(${PRS:-247 245 253 249 185 172 261})
WORK=${WORK:-/tmp/kro-simplicity-eval}
REPO=${REPO:-$PWD}
cd "$REPO"

for pr in "${PRS[@]}"; do
  prdir="$WORK/pr-$pr"
  mkdir -p "$prdir/before" "$prdir/after"
  sha=$(git log --all --pretty='%H %s' | awk -v p="\\(#$pr\\)" '$0 ~ p"$" { print $1; exit }')
  if [ -z "$sha" ]; then
    echo "no SHA for #$pr"
    continue
  fi
  echo "$sha" > "$prdir/sha"
  git log -1 --format=%B "$sha" > "$prdir/message"
  git diff --name-only "$sha^..$sha" > "$prdir/files"
  while read -r path; do
    [ -z "$path" ] && continue
    mkdir -p "$prdir/before/$(dirname "$path")" "$prdir/after/$(dirname "$path")"
    git show "$sha^:$path" > "$prdir/before/$path" 2>/dev/null || rm -f "$prdir/before/$path"
    git show "$sha:$path"  > "$prdir/after/$path"  2>/dev/null || rm -f "$prdir/after/$path"
  done < "$prdir/files"
  echo "pr-$pr: $(wc -l < "$prdir/files") files, sha $sha"
done
