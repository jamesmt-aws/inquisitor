# Per-PR verdicts

| PR | Categories (from commit) | S1 | S2 | S3 |
|---|---|---|---|---|
| #185 | dead code, shadowing, type-level constraint, sync guard | improved | improved | improved |
| #247 | premature optimization, dead code, structural debt | improved | improved | improved |
| #245 | drifted abstraction (impl vs design) | improved | improved | improved |
| #253 | dead code, duplication, collapsed abstractions | improved | improved | improved |
| #249 | extract interfaces, unify code paths, dead code | improved | improved | improved |
| #172 | terminology drift | unchanged (orthogonal) | unchanged (orthogonal) | unchanged (orthogonal) |
| #261 | wrong file boundaries (walks back #220) | improved | improved | improved |

## Notes per PR

- **#185.** Textbook simplification along four axes; metrics agree with all four labels.
- **#247.** Optimization-strip in the holding-pen pattern (paired with design #244). S3's leverage is highest; all (a) deletions defer to the holding pen.
- **#245.** Largest-leverage MDL move in the corpus (-23% code). The pair (#244 holding pen, #245 implementation strip) is the canonical instance of the simplicity-doc's MDL framing.
- **#253.** Most diverse mix of S1 categories (every (a)/(b)/(c)/(d) class hit at least once). Dead code, duplication, single-impl interfaces, undocumented YAML surface, exported-without-consumer.
- **#249.** Cleanest partition-match alongside #245 but for a different reason: collapses twelve over-fine cells via type-level encoding (`clusterAccess`, `reconcileScope`, `pruneResources`).
- **#172.** Real simplification (vocabulary consistency) along a dimension none of S1/S2/S3 directly score. All three metrics correctly classify as orthogonal rather than misclaim improvement or regression.
- **#261.** Walk-back of #220. Metrics agree with the post-state (which the team now considers correct). Applied to the pre-#220 state, S1/S2 would have flagged the same input cases that #261 corrects.
