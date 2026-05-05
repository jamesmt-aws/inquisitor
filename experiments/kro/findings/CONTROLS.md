# Controlled view: verdicts vs LOC delta and label

## Full table (11 PRs, ordered by LOC delta)

| PR | label | LOC Δ | S1 | S2 | S3 |
|---|---|---:|---|---|---|
| #245 | simp: drifted abstraction | −1474 | improved | improved | improved |
| #247 | simp: premature optimization, dead code | −999 | improved | improved | improved |
| #249 | simp: extract interfaces, unify, dead code | −847 | improved | improved | improved |
| #253 | simp: dead code, duplication, abstractions | −758 | improved | improved | improved |
| #248 | feature: CRD schema | −17 | unchanged | improved | unchanged |
| #185 | simp: dead code, shadowing, type, sync guard | −7 | improved | improved | improved |
| #172 | simp: terminology drift | 0 | unchanged | unchanged | unchanged |
| #228 | bug fix: forEach prune flake | +4 | improved | improved | improved |
| #224 | bug fix: 4 propagation bugs | +49 | unchanged | improved | unchanged |
| #261 | simp: file boundaries (walks back #220) | +107 | improved | improved | improved |
| #203 | feature: ordered teardown via composition | +384 | unchanged | improved | unchanged |

## Cross-tabs

### Verdicts at near-zero LOC delta (|Δ| ≤ 10)

| PR | LOC Δ | label | S1 | S2 | S3 |
|---|---:|---|---|---|---|
| #185 | −7 | simp | improved | improved | improved |
| #172 | 0 | simp (terminology) | unchanged | unchanged | unchanged |
| #228 | +4 | bug fix | improved | improved | improved |

Three near-zero-delta PRs with three distinct verdict triples. Verdict is not a function of LOC delta alone.

### Verdicts at positive LOC delta (Δ > 0)

| PR | LOC Δ | label | S1 | S2 | S3 |
|---|---:|---|---|---|---|
| #228 | +4 | bug fix | improved | improved | improved |
| #224 | +49 | bug fix | unchanged | improved | unchanged |
| #261 | +107 | simp | improved | improved | improved |
| #203 | +384 | feature | unchanged | improved | unchanged |

Code-grew PRs span both `improved` and `unchanged` on S1 and S3, and all `improved` on S2.

### Verdicts at large negative LOC delta (Δ < −100)

| PR | LOC Δ | label | S1 | S2 | S3 |
|---|---:|---|---|---|---|
| #245 | −1474 | simp | improved | improved | improved |
| #247 | −999 | simp | improved | improved | improved |
| #249 | −847 | simp | improved | improved | improved |
| #253 | −758 | simp | improved | improved | improved |

Confounded: every big-shrink PR in this corpus is also labeled simplification. The corpus does not contain a big-shrink non-simplification, so we cannot tell whether S1/S3 track the labeled mechanism or just track size when size delta is large.

## Per-metric reads

**S1 (deletion-minimality).** 7 improved, 4 unchanged across 11 PRs. Tracks structural content rather than size: improved on the four big shrinks AND on small-delta PRs where existing units are absorbed/relocated/redundant (#185, #261, #228); unchanged on PRs that only add (#224, #248, #203) and on the rename (#172).

**S2 (partition match).** 10 improved, 1 unchanged. Verdict is `improved` on almost every change in the corpus. This looks like rubber-stamping but is also consistent with S2 having a broader reach than the team's label: any change that adds a preference-required input cell or collapses an over-fine cell scores as improvement, regardless of whether the team called it a simplification. Two ways to read it:
- Honest reach: bug fixes that add missing input-partition cells *are* partition-match moves, and the doc's framing supports this.
- Rubber stamp: a metric that approves of nearly every change is not a useful filter.

The corpus cannot distinguish these two readings without a change S2 should *not* approve. To test S2's discrimination, run it against a change that adds branches for input cases the preferences do not reward (a feature flag for a hypothetical use case; an abstraction layer with no second consumer; documentation that contradicts the code).

**S3 (MDL compression).** 7 improved, 4 unchanged. Distinguishes similarly to S1. Improved on big shrinks and on changes that absorb prose into named structure (#185 sentinel, #228 typed map, #261 phase-aware imports, #261 architecture coherence). Unchanged when bytes grow on both sides without compensating compression.

## Findings

1. **Verdict is not a function of LOC delta.** Three near-zero-delta PRs produce three different verdict triples; PRs at the same positive LOC delta range produce different verdicts.

2. **Big-shrink corpus is confounded with simp label.** Cannot tell from this corpus whether the four big-shrink simplification PRs got `improved` because of the structural moves or because of the size delta. To disentangle: find a big-shrink PR that was NOT labeled as simplification, or a labeled simplification that grew code substantially.

3. **S2 says `improved` on 10 of 11 PRs.** Either S2 has a broader reach than the team's label and is honestly applying its definition, or it is approximately a rubber stamp. The corpus cannot distinguish these readings. Need a change S2 should NOT approve.

4. **The metric never reports `regressed`.** Across 11 PRs no verdict is negative. Two interpretations: every PR in this curated corpus is a structurally positive change; or the metric has no negative pole. Cannot disentangle without a known-bad change.

5. **#228 is the conflation case.** A bug fix that took the form of a structural simplification (slice → typed map encoding last-writer-wins) scores `improved` on all three metrics. The team labeled it as a fix. Both readings are honest under the doc's framing. The metric is detecting the structural move, not the team's intent.

6. **#172 is the only triple-`unchanged` and the only orthogonal label** (terminology drift). All other PRs hit at least one `improved` verdict. The doc's three definitions do not score consistent vocabulary; this is a real gap in the framework.

## What this corpus cannot answer

- Whether S1/S3 discriminate at large negative LOC delta from size effects alone. Need a big-shrink non-simplification.
- Whether S2 discriminates from a rubber stamp. Need a change S2 should reject.
- Whether any metric reports `regressed`. Need a known-bad change (added dead abstraction, unnecessary indirection, premature flag).
- Whether the metrics are self-consistent across runs (I authored the prompts AND ran them; same agent producing the same verdicts on the same artifacts is not an independence check). Need a blind run or a different runner.

## Concrete next experiments

1. **Synthetic regression.** Take #185 post-state and add 100 lines of dead abstraction (a single-impl interface with no callers, or an unused configuration flag). Run the prompts. Expected: at least one metric reports `regressed`. If none do, the negative pole is broken.

2. **#220 (the move walked back by #261).** Run the prompts on #220's pre→post. The team's later judgment is that #220 was wrong. Do the metrics report `improved` (matching #220's intent at the time) or do they catch what #261 later corrected? Either answer is informative.

3. **Big-shrink non-simplification.** Find a deletion PR that was a feature removal or a deprecation rather than a simplification. If none exists in the kro repo, a synthetic test: take a labeled simplification, undo only its structural moves while keeping the deletions. Verdict on this hybrid distinguishes "structural" from "size."

4. **Blind run.** Have a fresh agent (or someone other than me) re-run the prompts on the same corpus, designs lifted independently. Compare verdicts. Disagreement = the prompts are under-specified; agreement = at least the prompts are reproducible across runners on the same inputs.
