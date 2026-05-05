# Experimental results: simplicity metrics on the kro corpus

Single time-series, one author (Ellis Tarn), 232 commits over two months on the krocodile branch of `ellistarn/kro`. Two methods compared: the simplicity-doc's S1/S2/S3 (and ternary forms C1/C2/C3) at design level, and Inquisitor + IAS audit at code level.

## Findings

### 1. The tenet-shift detector caught kro's performance demotion 15 days early

The optimization-layer demotion at `#244` (split of 007-optimizations.md as "Future Work — Do Not Implement") was not a surprise inside the commit history. Between 2026-04-09 and 2026-04-24, fifteen bug fixes accumulated that were attributable to the conflict between performance (T6 — work proportional to change) and correctness/determinism (T1, T2). Each fix added a workaround (conflict retry, stable iteration order, explicit dispatch trigger) without removing the conflicting mechanism.

A recognition rule of three parts — structural conflict between tenets, accruing bug fixes attributable to the conflict, accruing-pace exceeds reduction-pace — would have flagged the performance tenet at 2026-04-15, ten conflict-attributable fixes deep with no structural reduction. The actual demotion landed 2026-04-30. **Lead time: ~15 days.**

This is the strongest forward-looking signal in the work. Neither S/C nor Ellis's audit produces it on their own; both operate on a single state and cannot read trajectories.

Detail in `findings/TENET_SHIFT_DETECTOR.md`.

### 2. Regret reduces to tenet shift, not to a metric verdict

Across all 12 regret-paired commits in the corpus (the `added_in` side of `findings/STRIP_PAIRS.md`), 11 score `keep` under their commit-time active tenets when the metrics are run with active tenets as the preference set. The 12th (#220 walkstate split) gets a partial flag from S2 because its mistake — putting a reconcile-time concept in a compile-time package — was a partition-mismatch even at commit time, against the architecture-matches-import-graph tenet that was already implicit in the design.

The verdict shift between commit-time tenets and post-strip tenets is the regret signal:
- 6 commits show full flip (all three S metrics).
- 5 show partial flip (heterogeneous additions where parts served durable tenets).
- 0 show no flip.

The implication: at the moment of an addition, the framework cannot produce a "this is regret-prone" verdict using the metrics alone, because the metrics correctly say "this is justified." The regret only becomes visible once the active tenet set contracts. Predicting regret prospectively requires predicting tenet shifts (finding 1).

Detail in `findings/REGRET_PREDICTOR_V2.md` and `findings/S_ACTIVE_TENETS_AT_190.md`.

### 3. S/C and Ellis's audit are complementary, not equivalents

On #190 with active tenets, S/C says all keep. Ellis's audit says mostly JUSTIFIED but flags two shape-level findings: `Reconcile()` cog:363 (832 lines) and `WatchCoordinator` LCOM4:2. These are functions and types violating Inquisitor's research-backed thresholds (Campbell 2018, Hitz & Montazeri 1995) regardless of design mandate.

The methods catch different things:
- **S/C** reasons over design units. Catches **mandate-level excess** — design carries units the preferences do not require.
- **Audit** reasons over function/type metrics with thresholds. Catches **shape-level excess** — code shapes that are too complex regardless of mandate.

They also occupy different cost points:
- **Audit**: Go static analyzer (~6700 lines of Go), 9 calibrated metrics, ~160-line audit prompt, all design docs read in advance to build a concept map.
- **S/C**: lifted design (or existing design doc), stated preference set, three short prompts (~3KB total).

S/C is plausibly the right tool for non-Go codebases (no analyzer to run), PR-time review (only the diff in hand), design-document review (no compiled code), or as a quick pre-check before paying for the full audit.

Detail in `findings/COMPARISON.md`, `findings/SEQUENCING.md`, `findings/RECOVERABLE.md`.

### 4. The framework's verdicts are preference-dependent by definition

The S1/S2/S3 prompts ask "what is removable / what is over-fine / what compresses, *under these preferences*." Run with a fixed minimal floor (correctness, observable behavior, public API stability), the verdicts are predetermined: anything beyond minimal flags. Run with active tenets at the time of the commit, the verdicts agree with the team's actual judgment.

The earlier "minimal-floor" framing was an attempt to use a preference set that approximates "the tenets that will eventually survive." On the kro corpus this approximation worked for surface regret prediction (75% TPR / 0% FPR in the matched-controls run) because the surviving tenets happened to be close to minimal. The framing would fail on a project where durable tenets include performance (e.g., a JIT compiler).

The doc revision implied: the simplicity-doc should make the preference dependency explicit. The choice of preference set is the engineering decision; the metrics report consistently against whichever set the user picks.

Detail in `findings/PREDICTOR.md` (the original minimal-floor experiment, now read with this correction in mind), `findings/REGRET_PREDICTOR.md` (same), `findings/REGRET_PREDICTOR_V2.md` (corrected version).

### 5. Tenet derivation from commit history is the unique forward-looking work product

Ellis's project has no stated tenets document. Eight tenets were derived from sustained behavior across 232 commits:

1. Correctness over performance.
2. Determinism and reproducibility.
3. Design as authority.
4. Composition over new primitives.
5. Tests assert externally observable contracts.
6. Architecture legible from the import graph.
7. One name per concept.
8. Implement core before optimization (emerged in #244).

Five phases of the project narrate cleanly through these tenets: bootstrap (designs first), performance buildout (T6–T10 active), reckoning (bug pace rises), design contraction (#244 demotes performance), steady state.

Three categories of complexity follow:
- **Worth it then, worth it now**: serves a durable tenet.
- **Worth it then, regretted later**: served a tenet that shifted. The performance tenet is the only example in this corpus.
- **Worth it then, supplanted later**: served a durable tenet, replaced by a simpler mechanism. The framework cannot predict this.

Tenet derivation is the load-bearing input for findings 1, 2, and 4. Without it, the metrics either collapse to design-doc-anchored audit (where the audit operates on stated rather than demonstrated commitment) or to predetermined-verdict floor.

Detail in `findings/TENETS.md`.

## Method

- Extracted 232 commits' before/after states with `scripts/extract.sh` from a kro checkout.
- Labeled commits programmatically by Ellis's prefix conventions (`scripts/classify.awk`): 50 simple, 38 complex, 144 ambiguous.
- Identified 15 regret pairs (`added_in` → `stripped_in`) by reading commit message bodies of the four major strip PRs.
- Lifted designs from before/after of 11 PRs (7 simplifications + 4 negative controls) using the design-lift prompt.
- Applied S1/S2/S3 with multiple preference configurations: minimal floor, active tenets at the commit, post-strip tenets.
- Applied C1/C2/C3 on (#190, #245) — the cleanest contrast pair.
- Built and ran Inquisitor's tool on the kro post-states of #190 and #245; applied IAS audit prompt against the design at each commit.
- Encoded the tenet-shift recognition rule and tested it retrospectively against the performance demotion.

Reproducibility: `scripts/extract.sh` is deterministic given a kro checkout. The design lifts and metric verdicts are LLM judgments; cross-runner reproducibility is the largest open caveat.

## Limits

The single largest caveat: **I authored the prompts, picked the corpus, and produced the verdicts in the same session.** The labels (regret/control) are post-hoc and not from me, but the predictions are still under self-evaluation risk. A blind run by a different agent on the same designs would test whether the framework's verdicts are reproducible across runners.

Other limits worth naming:
- One project, one author, one time series. The tenet-shift detector's recognition rule is testable elsewhere; we have not done it.
- Forward signal on the current kro state is null. This may be correct (project is in a stable phase) or my missing context (Ellis would catch things I miss).
- C1/C2/C3 was tested once on a stacked-deck pair (#190 vs #245). The verdict was foreordained.
- The earlier `findings/PREDICTOR.md` and `findings/REGRET_PREDICTOR.md` reported headline numbers (75% TPR / 0% FPR) that were properties of the minimal-floor preference set rather than properties of the metrics. Read with the correction in `RECOVERABLE.md`.

## Open questions

1. **Does the tenet-shift recognition rule generalize beyond kro?** Single-corpus validation is suggestive, not conclusive. Apply to a project with a different tenet pattern (e.g., a JIT compiler where performance is durable).

2. **Does Ellis recognize the derived tenets?** The single biggest threat to the analysis is that the tenet list is wrong. Have him read `findings/TENETS.md` and tell us if the eight tenets are the ones he has been operating on, or if the list captures the wrong ones.

3. **What does S/C catch on a non-Go codebase?** Ellis's audit is Go-specific. The cases S/C is plausibly the right tool (PR-time review, design docs, non-Go languages) cannot be tested on the kro corpus alone.

4. **Recursive Language Models connection.** The shift detector and tenet derivation both operate over a long history (232 commits + design docs + temporal context) — exactly the regime RLMs (Zhang/Kraska/Khattab 2026) are designed for. The natural application is at the history-traversal level, not at the metric level.

## Reading order

For a quick read: **this file**, then `findings/TENET_SHIFT_DETECTOR.md`, then `findings/TENETS.md`. Three files, the headline result and the load-bearing inputs.

For depth on a specific finding:
- Finding 1 (shift detector): `findings/TENET_SHIFT_DETECTOR.md`.
- Finding 2 (regret = tenet shift): `findings/REGRET_PREDICTOR_V2.md`, `findings/S_ACTIVE_TENETS_AT_190.md`.
- Finding 3 (S/C vs audit): `findings/COMPARISON.md`, `findings/SEQUENCING.md`, `findings/RECOVERABLE.md`.
- Finding 4 (preference dependency): `findings/PREDICTOR.md` plus `findings/REGRET_PREDICTOR.md` (read as descriptions of minimal-floor behavior, not as evidence of metric value), corrected by `findings/REGRET_PREDICTOR_V2.md`.
- Finding 5 (tenet derivation): `findings/TENETS.md`.

For raw data: `data/commits.tsv`, `data/ellis-labels.tsv`, `data/strip-pairs.tsv`. For per-PR design lifts and metric verdicts: `per-pr/`. For Inquisitor tool outputs at #190 and #245: `findings/inquisitor-pr*.txt`.

## What this is not

This is not a controlled experiment. It is a single time-series with descriptive analysis. The strongest claim — the shift detector's lead time — rests on one project's commit history and one identified conflict. Replication is the main thing missing.

It is also not a replacement for Ellis's audit. The audit catches shape-level excess that S/C does not surface; S/C catches mandate-level excess that the audit's design-citation requirement may miss. Both belong in the toolbox.
