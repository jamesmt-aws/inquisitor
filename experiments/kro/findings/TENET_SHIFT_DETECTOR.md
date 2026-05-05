# Tenet-shift detector

If regret-prediction reduces to tenet-shift prediction (REGRET_PREDICTOR_V2.md), the next question is whether the shifts are predictable from observable signals. This file encodes a recognition rule, tests it retrospectively on the performance tenet, and applies it forward to the current kro state.

## Recognition rule

A tenet is **unstable** when:

1. It has a **structural conflict** with at least one higher-priority tenet. Conflicts are not philosophical disagreements; they are mechanisms by which serving tenet A produces failures of tenet B. Caching produces stale reads (cache vs correctness). Concurrent dispatch produces races (concurrency vs determinism). Indirection produces ambiguity (abstraction vs traceability).

2. **Bug fixes attributable to the conflict** are accumulating in commit history. Each fix is a debit against the lower-priority tenet's stability. Common shapes: deflakes, race fixes, "X masked by Y" framings, retries added to handle observed contention, "remove override" / "remove gate" framings.

3. **The accruing-bug pace exceeds the reduction-of-conflict pace.** Each fix should reduce the conflict surface; if new fixes for the same conflict keep arriving, the tenet pair has a topology where the conflict cannot be fully resolved at this layer.

When all three hold, the tenet is at risk of demotion. The fix is one of: lower the priority of the unstable tenet (kro's choice with #244), absorb the conflict into a higher-resolution structure (move the cache to a different layer where it doesn't fight correctness), or accept the bug rate (rare in production systems).

## Retrospective test: the performance tenet at kro

**Conflict identified.** Performance (T6 — work proportional to change) vs Correctness (T1) and Determinism (T2). Mechanism: the optimization layer (caches, incremental diffs, trigger-scoped walks, concurrent dispatch) requires invariants about input/output equivalence under skip, item identity under reorder, and ordering under parallelism. Each invariant has corner cases that surface as flakes or wrong outputs.

**Bug fixes attributable to the conflict (chronological)**:

| date | commit | what |
|---|---|---|
| 2026-04-09 | #36 | hash skip bug, eliminate time.Sleep |
| 2026-04-10 | #39 | double-dispatch race in DAG coordinator |
| 2026-04-11 | #56 | silent divergence gaps in hash detection |
| 2026-04-12 | #67 | finalization races (premature GC, stale CEL cache) |
| 2026-04-12 | #82 | deflake TestResourcePruning with conflict retry |
| 2026-04-12 | #84 | deflake all Graph update sites with conflict retry |
| 2026-04-13 | #93 | cache leak fix |
| 2026-04-14 | #121 | deflake forEach reordering |
| 2026-04-15 | #127 | topological sort race, revision transition race |
| 2026-04-15 | #129 | stdlib convergence re-apply race |
| 2026-04-18 | #193 | deflake crash recovery + histogram metrics |
| 2026-04-22 | #213 | propagation bugs masked by 2s resync |
| 2026-04-22 | #214 | remove resync override (was masking bugs) |
| 2026-04-23 | #224 | ReadinessDependents propagation, stale dispatch |
| 2026-04-24 | #228 | forEach prune flake — per-node applied key tracking |

15 fixes attributable to the conflict, accumulated over **15 days**. The pace was approximately one optimization-layer-conflict fix per day, sustained.

**Pace exceeds reduction.** Each fix added a workaround (conflict retry, stable iteration order, explicit dispatch trigger, per-node tracking) without removing the conflicting mechanism. The cache, the trigger-scoped walk, the worker dispatch, the resync timer — all stayed. The fixes were patches, not structural reductions.

**Detector verdict (retrospective)**: by 2026-04-15 (10 days into the streak, after 10 conflict-attributable fixes with no structural reduction), the performance tenet was unstable. The detector would have flagged at this point.

**Actual demotion**: 2026-04-30 (#244 splits 007 out). Detector signal led the actual demotion by **~15 days**. The team kept patching for two more weeks before contracting the tenet.

## Forward application: current kro state

Active tenets after #244 (per TENETS.md):

- T1 — Correctness
- T2 — Determinism
- T3 — Design as authority
- T4 — Composition over new primitives
- T5 — Tests as contract
- T6' — Implement core before optimization (replaces old T6)
- T7' — Architecture legible from import graph
- T8' — One name per concept

**Conflict scan.**

- T3 (design as authority) vs T4 (composition over new primitives): designs sometimes describe behavior that has no clean composition with existing primitives. Conflict mechanism: design adds a primitive; T4 wants it expressed via existing ones. Looking for fixes: I don't see this pattern in recent commits.

- T1 (correctness) vs T6' (defer optimization): when correctness requires structural performance (e.g., a graph with 10k nodes that times out under full re-evaluation), T6' might be challenged. Mechanism: timeouts or scaling limits surface as bugs against T1. No commits I see attribute timeouts to T6'.

- T2 (determinism) vs concurrency: the controller-runtime layer still uses goroutines. The `-race` propagation in #257 suggests race risk persists, but at the framework layer not the application layer. Not enough to flag.

- T7' (architecture matches imports) vs incremental refactor: any partial refactor risks #220-style boundary errors. The walk-back at #261 is the resolution; no recurrence visible.

**No unstable tenet flagged for the current kro state.** Maintenance commits in phase 5 are not concentrated against any specific tenet pair. The recognition rule produces no signal — which is consistent with the empirical observation that no major strip cascade has happened in the post-#244 period.

## Calibration: what the detector doesn't catch

1. **Replacement regret** (#58, #17, #224 from REGRET_PREDICTOR_V2). When an addition serves a durable tenet at commit time and a simpler mechanism is found later, no tenet shifts. The detector has nothing to flag. Predicting future invention is out of scope.

2. **Tenet-priority shifts within a stable tenet set.** If correctness and determinism trade priorities (e.g., a project decides eventual consistency is acceptable), no new conflict appears, but additions previously tolerated may become unstable. The detector watches for new conflicts, not for re-weighting.

3. **External constraint changes.** A new compliance requirement, a downstream API change, or a new performance target introduced by an SLA — these can demote a tenet without any internal conflict. The detector sees only internal signals.

4. **Tenets that are conflict-free but obsolete.** A tenet can become irrelevant because the system grew past it (e.g., "single-binary deployment" stops being a tenet when you adopt microservices). No bug fixes accumulate; the tenet simply stops being load-bearing. The detector won't flag this either.

## What this gives you

The detector's strongest claim is **the optimization-layer demotion at kro was visible in commit history ~15 days before #244 landed**. If the team had been running this rule, they would have had ~2 weeks of advance warning that the performance tenet was approaching demotion. They could have contracted earlier, stopped adding optimization machinery sooner (#190 landed 2026-04-19, after the bug-pace had already started accumulating), and saved some of the strip work.

The forward signal is currently null — no tenet is at risk in the current state. That itself is informative: the project is in a stable phase. If the maintenance commits of phase 5 start clustering around a particular tenet conflict, the rule will fire.

## Honesty

The conflict identification (performance vs correctness/determinism) is mine, made in retrospect. A detector running prospectively in March 2026 would have had to identify this conflict at #190's commit time, before the bug-pace was visible. It is plausible that the conflict was identifiable from design 005 itself ("the optimization layer relies on input/output equivalence under skip" is a hash-correctness invariant, observable from prose); I did not run the detector that way.

The "15-day lead time" is between when I would have flagged based on the bug pace and when #244 actually landed. A more conservative detector with a higher threshold would have flagged later but with more confidence; a more aggressive one would have flagged earlier with more false positives. The threshold is a knob.

The forward-looking null result on the current kro state is also a calibration risk. I am not the right reader to identify subtle conflicts in the current tenet set. Ellis would catch things I miss. The detector's value is in surfacing patterns visible from the corpus; final judgment requires someone with deeper context.

## Next

The natural composition: run the detector quarterly (or at every major design-doc revision) against the active tenet set. Flag any unstable tenet ≥30 days before the bug-pace exceeds the reduction-pace, giving the team a window to choose: contract the tenet, restructure to remove the conflict, or accept the bug rate as a stated cost.

This is the genuinely forward-looking thing the framework can do that the audit cannot. The audit operates on current state and current design; it cannot read trajectories.
