# S1, S2, S3 at #190 with active tenets

The previous run at #190 used a fixed minimal preference set (correctness, observable behavior, public API stability). All three S metrics flagged. The verdict was predetermined by the floor.

This run uses the **active tenets at the time of #190** (April 19, 2026) as the preference set, derived from design 005-reconciliation.md at sha `58dd9a5^` plus the durable tenets visible in earlier commits.

## Active tenets at #190

Durable (already established before #190):

- **T1 — Correctness.** Graph reconciliation converges to declared state.
- **T2 — Determinism.** Deterministic errors do not retry; same inputs produce same failure.
- **T3 — Design as authority.** Implementation matches the design documents.
- **T4 — Composition over new primitives.** No new spec fields without justification.
- **T5 — Tests as contract.** Tests assert externally observable behavior.

Active at #190 (stated explicitly in design 005 of the era; later demoted in #244):

- **T6 — Performance is structural.** "Work is proportional to change, not to DAG size."
- **T7 — Three hash layers.** Input-hash skips template evaluation, apply-hash skips the write, output-hash determines propagation.
- **T8 — Per-node resync timers.** Each node has a jittered timer that bounds divergence.
- **T9 — Dependency-driven scheduling.** Independent nodes evaluated concurrently; trigger-scoped walks visit only affected subgraphs.
- **T10 — Compilation cache.** Content-addressed structural sharing of compiled artifacts.

T6–T10 are gone from design 005 by #245. They were active at #190.

## S1 (deletion-minimality)

For each unit of the design at #190, does removing it lower a tenet?

| unit | impacted tenets if removed | category |
|---|---|---|
| type cache | T6, T10 | (b) lowers a non-thresholded tenet |
| compiled graph sharing | T10 | (b) |
| forEach incremental diff | T6 | (b) |
| three hash layers (input/apply/output) | T6, T7 | (b) |
| per-node resync timers | T8 | (b) |
| trigger-scoped walks | T6, T9 | (b) |
| worker goroutine dispatch | T9 | (b) |
| drift timer reset | T8 | (b) |
| recursive validation | T1 | (b) |
| dynamic-GVK detection | T1 | (b) |

**S1 verdict: no units in category (c). Nothing deletable.** Under active tenets, the optimization machinery is justified. This contrasts with the minimal-floor verdict where every optimization unit was a category-(c) candidate.

## S2 (partition match)

Input partition forced by active tenets:

- Reconcile reason (T9): change-driven vs resync-driven vs schema-change.
- Cache state (T10): cached vs not.
- Hash layer (T7): inputs unchanged vs changed; apply unchanged vs changed; output unchanged vs changed.
- forEach item (T6): changed vs unchanged.
- Resync (T8): per-node jittered.

Branching partition at #190:

- Path 1 / Path 2 / Path 3 routing — distinguishes reconcile reason. Matches T9 cell.
- Cache hit/miss in graphCaches — matches T10 cell.
- Three-hash skip cells — matches T7 cells.
- forEach incremental skip — matches T6 cell.
- Per-node timer firing — matches T8 cell.

**S2 verdict: partitions match.** Every branching cell corresponds to an active-tenet-required input distinction. No over-fine cells. No missing cells.

This is the most interesting flip. Under minimal preferences, the same branching partition was over-fine on three axes (cache, hash layers, Path routing). Under active tenets, those same cells are exactly what the input partition requires.

## S3 (MDL compression)

| | bytes | predictability of code given design |
|---|---:|---|
| design 005 at #190 | ~13,000 (459 lines) | a regenerator producing the three-hash optimization layer would arrive at code resembling #190's controller |
| code at #190 | ~190,000 (18,982 lines) | high (4/5) — design names the structural commitments explicitly |

`|design| + cost(code | design)` < `|code|` because design 005 of the era enumerates the optimization architecture in prose — the regenerator has tight constraints from the design rather than producing the optimization independently.

**S3 verdict: design earns its keep.** The lower-resolution description compresses the higher-resolution one because the design explicitly mandates the structural commitments the code carries.

## Summary

| metric | minimal preferences | active tenets |
|---|---|---|
| S1 | flag | keep |
| S2 | flag | keep |
| S3 | flag | keep |

All three flip. With active tenets, the framework converges with Ellis's audit verdict at #190 (mostly JUSTIFIED).

## What this tells us

The metrics were never measuring "is this design simple in the abstract." They were measuring "is this design simpler than the preference set requires." Under minimal preferences, the optimization layer exceeds. Under active tenets that include performance, it does not. Same code, same metrics, different preferences, opposite verdicts.

This is not a flaw in the metrics. It is the framework working correctly. The metrics depend on preferences by definition (they ask "what is removable / what is over-fine / what compresses, *under these preferences*"). The earlier predetermined-flag pattern came from picking a preference set that did not match the project's tenets at the time.

## What changed between #190 and #245

The code changed (the strip removed ~6300 lines). The design changed (007 split out, performance demoted from 005). The active tenet set changed (T6–T10 retired).

Run S1/S2/S3 at #245 with #245's active tenets: all three keep (the stripped state matches the contracted tenet set). Run them at #190 with #245's active tenets (the actual regret prediction): all three flag. The flag is the regret signal — but it requires having the *future* tenet set, which is the thing we cannot have at the moment of the addition.

The earlier "minimal floor" framing was an attempt to use a preference set that approximates "the tenets that will eventually survive." On the kro corpus that approximation worked well for regret prediction (75% recall, 0% FPR) because the tenets that survived were a subset of the minimal floor plus a few additions. But the framing is fragile: a project where the durable tenets include performance (e.g., a JIT compiler) would invert the prediction. The minimal floor would say "flag the optimization" and be wrong every time.

## Next steps to talk through

Three directions, ordered by leverage.

1. **Verify across the regret-paired corpus.** Run active-tenets S1/S2/S3 on each of the 12 regret-paired commits at the design of its commit. Expected pattern: each scores "keep" under its commit-time tenets and "flag" under the post-strip tenet set. If the pattern holds, regret prediction reduces to **tenet-shift prediction**: which currently-active tenet is most likely to be demoted next? This is a more honest and tractable problem than predicting from fixed floors.

2. **Build a tenet-shift detector.** The performance tenet was unstable because it conflicted with correctness/determinism (T1, T2) and the conflict produced flakes. The phase-3 deflake commits (#82, #84, #228) were the early warning. Encode this: a prompt that, given the current tenet set, identifies pairs with structural conflict, then weighs which of the two has higher priority and which has more pending bug-fix commits attributed to its conflict. The unstable tenet is the lower-priority one with the most accruing bugs.

3. **Replace the minimal-floor framing in the doc.** The simplicity-doc reads as if S1/S2/S3 produce verdicts independent of context. They do not. The doc should make the preference dependency explicit and position the framework as a measurement instrument that needs preferences as input. The minimal-floor variant should be one option among several (alongside design-mandated tenets, externally-stated tenets, etc.). The choice of preference set is the engineering decision; the metrics report consistently against whichever set the user picks.

The first two are experiments. The third is a doc revision. (1) is the cheapest validation; (2) is the highest-leverage forward-looking move; (3) makes the doc honest about what it is.
