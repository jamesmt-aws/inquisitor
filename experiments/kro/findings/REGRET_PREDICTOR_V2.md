# Regret predictor v2: active tenets across 12 regret pairs

V1 (REGRET_PREDICTOR.md) used a fixed minimal preference set as the floor. Verdicts were 75% TPR / 0% FPR but the floor was the dominant signal — anything beyond minimal flagged.

V2 uses **the active tenets at the commit time of each addition** as the preference set. The prediction: at each commit, the addition scores `keep` under its commit-time tenets, then `flag` under the post-#244-contraction tenet set. The flip across the tenet shift IS the regret signal.

## Active tenet sets

**Durable (T1–T5)**: correctness, determinism, design-as-authority, composition over new primitives, tests as contract. Stable across the entire branch.

**Pre-#244 (active during all 12 regret-paired commits)**:
- T6 — performance is structural, work proportional to change.
- T7 — three hash skip layers (input/apply/output).
- T8 — per-node resync timers.
- T9 — dependency-driven scheduling, trigger-scoped walks, worker dispatch.
- T10 — compilation cache, content-addressed structural sharing.

**Post-#244 (after the design contraction)**: only T1–T5 remain active. T6–T10 moved to 007-optimizations.md ("Future Work — Do Not Implement").

## Per-commit verdicts (post-state of each commit, with both tenet sets)

| commit | what added | S at active (pre-#244) tenets | S at post-#244 tenets | flip? |
|---|---|---|---|---|
| #220 cd46848 | walkstate split into dag/ | **S1 keep, S2 partial-flag, S3 keep** | S1 flag, S2 flag, S3 flag | mostly |
| #190 58dd9a5 | type cache, structural caching, recursive validation | S1 keep, S2 keep, S3 keep | S1 flag, S2 flag, S3 flag | full |
| #192 22681e7 | forEach incremental diff | S1 keep, S2 keep, S3 keep | S1 flag, S2 flag, S3 flag | full |
| #24 d6d6e4e | section-scoped input hashing, scoped walks | S1 keep, S2 keep, S3 keep | S1 flag, S2 flag, S3 flag | full |
| #166 96048c6 | custom hashDesiredState (replace json.Marshal) | S1 keep, S2 keep, S3 keep | S1 flag, S2 keep, S3 flag | partial |
| #55 f2231a6 | drift timers, trigger-scoped walks | S1 keep, S2 keep, S3 keep | S1 flag, S2 flag, S3 flag | full |
| #53 56b0d7b | execution design impl (workers, identity labels, trigger-walk) | S1 keep, S2 keep, S3 keep | S1 partial, S2 flag, S3 partial | partial |
| #93 f5c3dc5 | perf: cache leak fix, Kahn's O(V²), benchmarks | S1 keep, S2 keep, S3 keep | S1 flag (perf code), S2 keep, S3 partial | partial |
| #25 e02896f | content-addressed compiled graph sharing | S1 keep, S2 keep, S3 keep | S1 flag, S2 flag, S3 flag | full |
| #58 8ac5620 | drift timer + system error metrics | S1 keep, S2 keep, S3 keep | S1 partial (drift timer), S2 keep, S3 keep | partial |
| #17 4f844ef | .ready(), revision immutability, GC | S1 keep, S2 keep, S3 keep | S1 partial (Ready/Active conditions), S2 keep, S3 keep | partial |
| #224 9313102 | fix propagation + DepositTrigger API | S1 keep, S2 keep, S3 keep | S1 flag (DepositTrigger), S2 keep, S3 keep | partial |

## Aggregate

| pattern | count |
|---|---:|
| full flip (all 3 metrics flip across the tenet shift) | 6 |
| partial flip (1–2 metrics flip) | 5 |
| no flip (verdict unchanged) | 0 |
| pre-#244 active tenets give `keep` | 11 of 12 |
| pre-#244 active tenets give partial flag | 1 of 12 (#220) |

**Headline: 11 of 12 regretted commits score `keep` under their commit-time active tenets.** The framework, run with the right preferences, correctly says "this was justified at the time." The regret signal is not the absolute verdict at the time; it is the verdict shift across the tenet contraction.

## The one partial case at active tenets: #220

#220 split files mixing hash/resourcecache and dag/walkstate. The architecture-matches-import-graph tenet was already in play (the team had been pursuing import-graph clarity). At #220 the split *attempted* to follow that tenet but mis-identified the axis: walkstate is a reconcile-time concept and was placed in the compile-time `dag/` package.

S2 catches this even under the commit-time tenets, because the input partition the architecture tenet forces (compile-time vs reconcile-time) is finer than the branching partition at #220 (which collapses both into the `dag/` package). #220 is the cleanest "should have known at the time" regret. Tenet 6 (architecture) was stable, the design just got applied wrong.

This is exactly the case where the framework adds value over the audit alone. Inquisitor's audit at #220 (with the design at the time) would JUSTIFY the file split because no design text says reconcile-time concepts must not live in compile-time packages — the tenet is implicit. S2 catches the partition mismatch directly from the input/branching analysis, no design citation required.

## The five partial-flip cases

#166, #53, #93, #58, #17, #224 don't fully flip across the tenet contraction because parts of what they added survived the contraction:

- **#17 .ready() + revision GC**: GC is durable (a correctness tenet). Only Ready/Active conditions were stripped. S1 partial-flags after contraction.
- **#58 drift timer + metrics**: metrics surface partly survives (system error metrics were observable behavior, kept). Only drift timer specifically tied to the stripped optimization layer.
- **#53 execution design**: identity labels survived; trigger-based walk did not. Mixed.
- **#93 perf rewrite**: Kahn's O(V²) → O(V+E) survived (correctness tenet); cache code did not.
- **#166 custom hasher**: hash mechanism was replaced by simpler API server hash; the unit was deletable specifically as performance code.
- **#224 DepositTrigger**: served correctness at commit time; later replaced because the worker dispatch machinery itself was stripped, eliminating the need for deferred triggers.

These are the cases where additions were heterogeneous: part durable-tenet-serving, part performance-tenet-serving. The contraction stripped only the latter parts. The verdicts reflect the mixture.

## What this confirms (and what it does not)

**Confirms:**
- The framework's verdict is preference-dependent. With active tenets, regretted additions correctly score `keep` at commit time.
- The verdict shift across the tenet contraction (#244) tracks the team's actual decision to strip.
- The framework converges with Ellis's audit verdict at each state when run with the active tenets.

**Does not confirm:**
- That the framework can predict the tenet contraction itself. Predicting that performance would be demoted requires reading the early-warning signals (rising deflakes attributed to the optimization layer, see TENETS.md phase 3) and weighing tenet conflicts. The metrics do not do this directly.

## Where the framework adds genuine value over the audit

Three places the framework, with active tenets, says something the audit doesn't:

1. **#220 partition mismatch is caught implicitly.** S2 reads the input/branching partition directly from the design and code; it does not require the design to have explicitly stated "compile-time concepts go here." The audit, which requires citing design text, would JUSTIFY #220 because no design forbids the placement.

2. **Pareto-comparison across alternatives (C1/C2/C3).** The audit verdict is per-state. The C-prompts compare two states ternary, no calibration. Useful when the team has a candidate alternative and wants to know if it dominates.

3. **The "tenet conflict + accruing bugs" early-warning signal.** Identifying which currently-active tenet is most likely to be demoted next is forward-looking, which the audit cannot do. The mechanism is observable in the corpus: between #93 (Mar 30 perf rewrite) and #244 (Apr 30 split), at least 6 deflake commits attributable to optimization-layer races accumulated. The signal was visible roughly 4 weeks before the contraction.

## Honesty

I produced both the active-tenet sets and the verdicts. The pre-#244 tenets are derived from design 005 of the era, which is observable. The verdict-flip pattern (11 of 12 keep at the time, partial-or-full flip after contraction) is the substantive claim.

The verdicts at active tenets are mostly mechanical given the tenet set: if T6 (performance is structural) is active and the addition serves it, S1 says no candidates for deletion under preferences. The interesting work was done by the previous file (S_ACTIVE_TENETS_AT_190.md) for #190; the others follow the same template.

The one non-mechanical case (#220 partition mismatch under active tenets) is the substantive new finding. The architecture tenet was active but implicit in the design; S2 catches the misalignment directly.

## Next: tenet-shift detector

This file confirms that regret-prediction reduces to tenet-shift prediction. The next experiment encodes the recognition rule from TENETS.md: a tenet is unstable if it has a structural conflict with a higher-priority tenet AND bug fixes attributable to the conflict are accumulating. Apply the rule to the kro corpus retrospectively (would it have flagged the performance tenet before #244?), then look for unstable tenets in the current state.
