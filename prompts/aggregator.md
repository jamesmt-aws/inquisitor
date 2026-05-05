# Aggregator (run once over all per-PR reports)

Inputs: per-PR S1/S2/S3 verdicts plus the commit message for each PR. The commit message labels a specific simplification kind (dead code, duplication, premature optimization, drifted abstraction, terminology drift, file boundaries, structural debt, type-level constraint, sync guard, shadowing; one PR may carry multiple labels).

For each labeled category, do the metrics consistently report `improved`?

Where a metric reports `unchanged` or `regressed` against an `improved` team intent, classify the disagreement:

- **false negative**: metric missed a real simplification visible in the design pair.
- **false positive**: metric reported improvement on a change the team did not label as such (rare in this corpus; mostly relevant for #261, which is a walk-back of a prior decision).
- **orthogonal**: metric speaks to a dimension the change did not touch (do not count as disagreement).

Stop when every labeled category has been seen at least once with a verdict, or all PRs are processed.

Report:

1. Per-category agreement table. Rows are categories; columns are S1/S2/S3; cells are `improved` / `unchanged` / `regressed` plus disagreement classification.
2. Per-metric agreement summary across categories. For S1, S2, S3 separately: how often it agrees with team intent, and which categories it most often misses.
3. List of disagreements ordered by category frequency. Each entry: PR, metric, expected vs reported, classification.
4. One-line answer: of S1, S2, S3, which most consistently agrees with the team's labeled intent on this corpus, and which category each metric is best at.
