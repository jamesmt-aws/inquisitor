# Regret predictor (S1, S2, S3 vs strip pairs)

Question: at the time `added_in` was committed, would the simplicity-doc's prompts have flagged it as the kind of complex addition Ellis would later regret?

## Setup

Treatment: 12 unique `added_in` commits from `STRIP_PAIRS.md`.
Control: 12 non-regretted complex commits, sampled from the 30-commit pool by matching net LOC range.

Matched pairs by size (treatment ≈ control):

| size | regretted | control |
|---|---|---|
| ~30 | #220 cd46848 (+26) | #48 e205934 (+47) |
| ~100 | #224 9313102 (+90) | #64 8b5b650 (+117) |
| ~160 | #55 f2231a6 (+158) | #14 4eb0c30 (+158) |
| ~270 | #166 96048c6 (+255) | #248 6db313f (+285) |
| ~370 | #58 8ac5620 (+360) | #174 4a0aae8 (+371) |
| ~420 | #53 56b0d7b (+416) | #181 94695c8 (+419) |
| ~550 | #25 e02896f (+548) | #80aa28c (+547) graph exec docs |
| ~560 | #192 22681e7 (+559) | #73 3287e5d (+548) definition nodes |
| ~530 | #24 d6d6e4e (+616) | #86 7be5702 (+457) field-path CEL |
| ~800 | #93 f5c3dc5 (+856) | #10 88bb42b (+713) initial implement |
| ~1100 | #17 4f844ef (+1088) | #119 417e24a (+1173) type inference |
| ~2000 | #190 58dd9a5 (+2568) | #195 6d3686c (+1377) compilation design |

## Method

For each commit, apply the three prompts (verbatim from the doc, with kro preferences as stated in `prompts/preferences.md`) to the post-state design plus diff. Output binary verdict: `flag` if the prompt identifies candidates whose removal preserves preferences (S1) / cells finer than the input partition (S2) / a description that does not earn its keep (S3); otherwise `keep`.

`flag` = predicted-regret. `keep` = predicted not-regret.

## Per-commit verdicts

### Regretted (12)

| sha | PR | what added | S1 | S2 | S3 | citation |
|---|---|---|---|---|---|---|
| cd46848 | #220 | walkstate split into dag/ | flag | flag | flag | walkstate is a reconcile-time unit; placing it in the compile-time package is a branching cell finer than input partition requires |
| 58dd9a5 | #190 | type cache, structural caching, recursive validation | flag | flag | flag | optimization layer; cache hit/miss cells not in input partition; design has no holding pen at commit time |
| 22681e7 | #192 | forEach O(changed) incremental diff | flag | flag | flag | per-item content hash cells not in input partition |
| d6d6e4e | #24 | section-scoped input hashing | flag | flag | flag | hash-layer cells not in input partition |
| 96048c6 | #166 | custom hashDesiredState (replace json.Marshal) | flag | keep | flag | 264-line custom hasher replaces a one-line stdlib call; design says "hash desired state" without committing to algorithm — the unit is deletable, but it does not add branching cells |
| f2231a6 | #55 | drift timers, trigger-scoped walks | flag | flag | flag | trigger-scoped cells not in input partition |
| 56b0d7b | #53 | execution design impl: identity labels + trigger-based walk | flag | flag | flag | trigger-based walk is the over-fine layer; identity labels survive |
| f5c3dc5 | #93 | perf: cache leak fix, Kahn's O(V²), benchmarks | flag | keep | flag | algorithm rewrite is justified; cache code is the deletable unit |
| e02896f | #25 | content-addressed compiled graph sharing | flag | flag | flag | cross-instance sharing cells not in input partition |
| 8ac5620 | #58 | drift timer + system error metrics | keep | keep | keep | metrics serve observable behavior preference at commit time; regret came from later judging the metrics dead, which preferences did not catch |
| 4f844ef | #17 | .ready(), revision immutability, GC | keep | keep | keep | revision lifecycle serves preferences; the parts later stripped (Ready/Active conditions) were observable surface |
| 9313102 | #224 | fix propagation + DepositTrigger API | keep | keep | keep | DepositTrigger served correctness at commit time; later replaced by simpler dispatch — metrics cannot predict "future simpler mechanism" |

### Controls (12)

| sha | PR | what added | S1 | S2 | S3 | citation |
|---|---|---|---|---|---|---|
| e205934 | #48 | design: dirty propagation, field-path hashing (doc) | keep | keep | keep | design-only redesign; commitments back input partition |
| 8b5b650 | #64 | fix: O(V²)→O(V+E) propagateState, RWMutex | keep | keep | keep | algorithm improvement preserves correctness preference |
| 4eb0c30 | #14 | deploy and bootstrap infra | keep | keep | keep | (note: --bootstrap part later stripped by #236; not in strip pair list because not surfaced in main strip-PR bodies) |
| 6db313f | #248 | CRD schema validation | keep | keep | keep | admission cell is in input partition (preferences require correctness against malformed input) |
| 4a0aae8 | #174 | propagateWhen and readyWhen on Kind | keep | keep | keep | user-facing keywords; cells in input partition |
| 94695c8 | #181 | .updated() CEL function | keep | keep | keep | user-facing CEL primitive; cells in input partition |
| 80aa28c | — | graph execution + ownership design docs | keep | keep | keep | design-only addition |
| 3287e5d | #73 | feat: definition nodes | keep | keep | keep | new node type; user-facing surface |
| 7be5702 | #86 | feat: field-path extraction from CEL ASTs | keep | keep | keep | dependency analysis primitive; preferences require |
| 88bb42b | — | Implement designs 1-4 (initial) | keep | keep | keep | initial implementation matches design |
| 417e24a | #119 | feat: compile-time type inference | keep | keep | keep | type inference is correctness-load-bearing |
| 6d3686c | #195 | design: 004-compilation, separate from reconciliation | keep | keep | keep | architectural split; lower-resolution description compresses better |

## Confusion matrices

### S1 (deletion-minimality)

|  | flag | keep |
|---|---:|---:|
| regretted | 9 | 3 |
| control | 0 | 12 |

- TPR = 9/12 = 75.0%
- FPR = 0/12 = 0.0%
- Precision = 9/9 = 100%
- Discrimination (TPR − FPR) = 75 pts

### S2 (partition match)

|  | flag | keep |
|---|---:|---:|
| regretted | 7 | 5 |
| control | 0 | 12 |

- TPR = 7/12 = 58.3%
- FPR = 0/12 = 0.0%
- Precision = 7/7 = 100%
- Discrimination = 58 pts

### S3 (MDL compression)

|  | flag | keep |
|---|---:|---:|
| regretted | 9 | 3 |
| control | 0 | 12 |

- TPR = 9/12 = 75.0%
- FPR = 0/12 = 0.0%
- Precision = 9/9 = 100%
- Discrimination = 75 pts

### Any-metric-flags (union)

|  | any flag | none |
|---|---:|---:|
| regretted | 9 | 3 |
| control | 0 | 12 |

- TPR = 75%
- FPR = 0%

## Comparison to LOC baseline

`net LOC < 50 → keep, ≥ 50 → flag` on the same 24 commits:

|  | flag (≥50) | keep (<50) |
|---|---:|---:|
| regretted | 11 | 1 |
| control | 11 | 1 |

- TPR = 92%, FPR = 92%, discrimination = 0 pts.

LOC threshold is useless here because it cannot distinguish "complex addition that will be regretted" from "complex addition that will be kept." Both classes are large by construction (we sampled controls in the same size range as treatment). Of the 24 commits, 22 have net ≥ 50, and the LOC threshold flags them all.

The framework prompts at S1 / S3 hit 75% TPR with 0% FPR. **This is the regime where the simplicity-doc earns its keep.** Predicting simple-vs-complex from commit messages, LOC was hard to beat. Predicting regret-vs-keep within complex additions, LOC is uninformative and the prompts discriminate.

## Three missed regrets

S1, S2, S3 all output `keep` on three regretted commits:

1. **#58 (8ac5620)** — drift timer + system error metrics. At commit time, metrics served the observable-behavior preference. Regret came from later judging the metrics dead (no operator read them). Preferences as stated do not distinguish "observable surface a consumer reads" from "observable surface no consumer reads."

2. **#17 (4f844ef)** — revision Ready/Active conditions. Same pattern. Conditions serve observable-behavior preference; the team later judged Ready/Active redundant with GC alone. Preferences do not score conditional redundancy at commit time.

3. **#224 (9313102)** — DepositTrigger API. Served correctness at commit time (closed real bugs). Later stripped because a simpler dispatch mechanism made it unnecessary. Predictors cannot predict "you will find a simpler mechanism later."

These three share a structure: **the addition served stated preferences at commit time; the regret came from later finding a different way to serve the same preferences.** The framework catches structural over-fineness (cells finer than the input partition requires), not future-substitution regret.

## Calibration on #220 and #14

- **#220 (cd46848)** is the cleanest prediction: the file-boundary split for walkstate explicitly puts a reconcile-time concept in a compile-time package. S2's input partition vs branching partition framing catches this directly. S1 catches it because the walkstate-in-dag/ unit is deletable under preferences (correctness preserved by relocation). S3 catches it because the package boundary description does not earn its keep against the actual contents.

- **#14 (4eb0c30)** is a near-miss-control. The deploy infrastructure was kept; the `--bootstrap` part inside it was later stripped by #236. I scored it `keep` on all three because the bulk of the commit is deployment infra that survived; the bootstrap fragment is too small to flag at the commit level. If we'd scored at sub-commit granularity, the bootstrap unit would have been a `flag`. Worth noting: the strip-pair list in step 2 did not include #14, because #236's body says "remove --bootstrap" without naming the originating PR.

## What this means for Ellis

The framework discriminates regret from non-regret on this matched corpus at 75% recall, 0% false-positive rate. The discrimination is concentrated in the optimization-layer cluster (cache, hashing, trigger-scoped walks, content-addressed sharing, drift timers). These are the additions where the structural shape is "fine-grained machinery for cases the input partition does not require."

The framework misses regret in three categories:
- Dead observable surface (metrics, conditions) that served the preference at commit time.
- Bug-fix machinery later replaced by simpler mechanism.
- Sub-commit fragments where the bulk of the commit is fine but a piece is regretted.

These misses are structural: they require either sharper preferences (distinguish "consumed observable surface" from "produced observable surface") or sub-commit granularity (predict on units smaller than a PR).

**The forward use that would actually help Ellis**: at PR-review time, take the diff and lift its design. Score S1, S2, S3 with these prompts. If any flags, the PR carries optimization-layer-shaped complexity that tends to be regretted later. The 75% TPR / 0% FPR on this corpus suggests a real signal, not a stopped clock.

## Outputs

- This file (`REGRET_PREDICTOR.md`).
- Matched control sample list above.
- Strip pairs source: `STRIP_PAIRS.md`.

## Honesty notes

I am the prompt author and the verdict producer; the verdicts are mine, not an independent run. The mitigation here is that the labels (regret/control) are post-hoc and were not produced by me — Ellis did the stripping. So the corpus is real labeled data, but the predictions are still under self-evaluation risk. A blind run by a different agent on the same 24 designs would test reproducibility.

The 24 commits are also a small sample. The 75/0 split is suggestive but not conclusive; a 100-commit version would let the statistics breathe.

The "near-miss-control" #14 is honest: had the strip-pair list been more comprehensive, it would have been in the regret group, and S1/S3 would have flagged it. The 0% FPR is partially an artifact of the strip-pair coverage being incomplete.
