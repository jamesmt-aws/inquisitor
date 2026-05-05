# Aggregator output

## 1. Per-category agreement

Each row is a labeled simplification kind from a commit message; cells report the verdict from each metric for the PR(s) that carried that label. Multi-PR labels show all PRs.

| Category | PRs | S1 | S2 | S3 |
|---|---|---|---|---|
| dead code | #185, #247, #249, #253 | improved (×4) | improved (×4) | improved (×4) |
| duplication | #253 | improved | improved | improved |
| premature optimization | #247 | improved | improved | improved |
| drifted abstraction (impl vs design) | #245 | improved | improved | improved |
| structural debt | #247 | improved | improved | improved |
| collapsed abstractions | #253 | improved | improved | improved |
| extract interfaces | #249 | improved | improved | improved |
| unify code paths | #249 | improved | improved | improved |
| terminology drift | #172 | unchanged (orthogonal) | unchanged (orthogonal) | unchanged (orthogonal) |
| wrong file boundaries | #261 | improved | improved | improved |
| shadowing | #185 | improved | improved | improved |
| type-level constraint | #185 | improved | improved | improved |
| sync guard | #185 | improved | improved | improved |

## 2. Per-metric agreement summary

- **S1 (deletion-minimality).** Agrees with team intent on 6/7 PRs (every label except terminology drift). Strongest on dead-code, duplication, single-impl interfaces, redundancy. Each removal in the agreeing PRs maps cleanly to (a)/(b)/(c)/(d) per the prompt's classification.
- **S2 (partition match).** Agrees on 6/7 PRs. Strongest on over-fine branching collapse: optimization-layer removal (#245, #247), receiver/parameter splits (#249), type-level constraint encoding (#185, #253). Reads file-boundary moves (#261) as input-partition encoding moves at the package level.
- **S3 (MDL compression).** Agrees on 6/7 PRs. Strongest where a holding-pen design exists (#244 ↔ #245 ↔ #247) because the lower-resolution description splits cleanly. Also strong where named-types absorb prose (#249's `clusterAccess`, `reconcileScope`, `pruneResources`). Weak where bytes are flat and the change is purely about consistency (#172).

All three metrics are blind to terminology drift. #172 is correctly read as orthogonal by every metric rather than misclaimed.

## 3. Disagreements

- #172 (terminology drift) × S1, S2, S3: expected `improved`, reported `unchanged (orthogonal)`. Classification: **orthogonal**, not a disagreement to count. The metric correctly identifies that the change operates on a dimension it does not measure.

No false negatives in the corpus (no PR where the team labeled a simplification and a metric reported `unchanged` against a structural change). No false positives (no PR where a metric reported `improved` on a change the team did not label).

## 4. One-line answer

All three metrics agree with the team's labeled intent on six of seven PRs. The one exception (#172, terminology drift) is correctly classified as orthogonal by all three, indicating the metrics fail honestly rather than misclassifying. **S1 is best at dead-code and redundancy; S2 is best at over-fine branching collapse; S3 is best when a holding-pen design exists so the lower-resolution description has somewhere to absorb the deferred work.** Together they cover every labeled category in the corpus except terminology consistency, which is its own simplicity dimension the doc does not currently address.
