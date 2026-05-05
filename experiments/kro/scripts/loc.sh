#!/usr/bin/env bash
# Count non-comment, non-blank Go LOC for before/after of each PR.
# Cheap heuristic: strip lines that are entirely whitespace or that
# start (after whitespace) with // or /* or */ or *. Block-comment
# spillover is approximate but consistent across before/after.
set -euo pipefail

WORK=${WORK:-/tmp/kro-simplicity-eval}
PRS=("$@")
[ ${#PRS[@]} -eq 0 ] && PRS=(247 245 253 249 185 172 261 248 224 228 203 257)

count_loc() {
  local dir=$1
  find "$dir" -name '*.go' -print0 2>/dev/null | xargs -0 -r awk '
    /^[[:space:]]*$/        { next }
    /^[[:space:]]*\/\//     { next }
    /^[[:space:]]*\/\*/     { next }
    /^[[:space:]]*\*\//     { next }
    /^[[:space:]]*\*/       { next }
    { c++ } END { print c+0 }
  '
}

printf "%-6s %-12s %-12s %-10s\n" "PR" "before_loc" "after_loc" "delta"
for pr in "${PRS[@]}"; do
  prdir="$WORK/pr-$pr"
  [ -d "$prdir" ] || continue
  before=$(count_loc "$prdir/before")
  after=$(count_loc "$prdir/after")
  delta=$((after - before))
  printf "%-6s %-12s %-12s %-10s\n" "$pr" "$before" "$after" "$delta"
done
