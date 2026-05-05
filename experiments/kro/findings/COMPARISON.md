# Comparison: Inquisitor IAS vs simplicity-doc S1/S2/S3 on PR #190

PR #190 is the highest-cost regret in our corpus. Ellis added a type cache, structural caching, recursive validation, and dynamic-GVK detection (+2568 lines). Three later PRs (#245, #249, #253) stripped parts of it. Both methods are run against the **post-#190 state**.

## Method A: Inquisitor's tool + audit prompt

### Tool output (excerpts)

Run: `inquisitor ./experimental/controller/...` at sha `58dd9a5`.

```
github.com/kubernetes-sigs/kro/experimental/controller
  1 packages · 19 types · 439 functions · 18982 lines
  function median: cog:1, cyc:2, fan_in:1, 17 lines

=== Cohesion — LCOM4 ===
  instanceState     LCOM4:2  4 methods
    Group 1: isDriftExpired, nextDriftExpiry, resetDriftTimer
    Group 2: updateAppliedKeys
  WatchManager      LCOM4:2  10 methods
    Group 1: KindFor, deriveAppliedSet, ensureWatch, eventHandlers, ...
    Group 2: defaultCreateInformer
  WatchCoordinator  LCOM4:2  10 methods
    Group 1: addCollectionLocked, addScalarLocked, ..., routeEvent
    Group 2: forGraph
  evaluator         LCOM4:2  15 methods
    Group 1: checkPropagateWhen, evalString, snapshotFor, ...
    Group 2: collectionCacheUpdate

=== Cognitive Complexity (cog > 15) ===
  Reconcile()              cog:363  832 lines
  reconcileDelete()        cog:182  418 lines
  tryDispatch()            cog:153  364 lines
  reconcileForEach()       cog:132  388 lines
  parseNodeList()          cog:117  177 lines
  BuildDAG()               cog:101  214 lines
  pruneRemovedResources()  cog:99   241 lines
  compileGraphSpec()       cog:81   333 lines
  applySSA()               cog:75   197 lines
  ... (30+ more)
```

### Applying Ellis's audit prompt

Reading the design docs at sha `58dd9a5^`: 001-graph, 002-revisions, 003-ownership, 004-compilation, 005-reconciliation, 006-stdlib. **Critically, design 005-reconciliation at this point describes the optimization machinery as architecture, not future work.** Direct quotes:

- "Performance is structural — work is proportional to change, not to DAG size."
- "Each walk uses dependency-driven scheduling: level-0 nodes are seeded, and each completion dispatches dependents whose dependencies have all been processed. Independent nodes are dispatched concurrently."
- "Three hashes at progressively deeper layers: input-hash skips template evaluation, apply-hash skips the write, output-hash determines propagation."
- "Resync — per-node, jittered; corrects configuration drift."

Verdicts following Ellis's protocol:

| finding | verdict | citation |
|---|---|---|
| `Reconcile()` cog:363 | **JUSTIFIED** | 005-reconciliation § Reconcile mandates dependency-driven scheduling, hash layers, propagation triggers, frontier walk, prune walk. The function orchestrates these. |
| `tryDispatch()` cog:153 | **JUSTIFIED** | 005 § Propagation describes the dispatch protocol with input-hash / apply-hash / output-hash layers. |
| `reconcileForEach()` cog:132 | **JUSTIFIED** | 005 § forEach (and 001-graph) describe per-item evaluation with propagateWhen gate. |
| `instanceState` LCOM4:2 (drift timer + applied keys) | **JUSTIFIED** | 005 § Trigger names per-node resync timers; § Prune names applied-key tracking. Two responsibilities, both design-mandated. |
| `WatchCoordinator` LCOM4:2 (route events + per-graph utility) | **EXCESS** | 005 names "route events to owning Graph" as the coordinator's job. The `forGraph` utility cluster is not in the design. Split candidate. |
| `evaluator` LCOM4:2 (eval + collectionCacheUpdate) | **JUSTIFIED** | 005 § Watch describes incremental cache merge as part of evaluator's job. |
| `Reconcile()` 832-line single function | **EXCESS** | The 005 design names the steps but does not mandate they live in one function. Decompose along design's named phases. |
| (no Heresy candidates surface) | — | — |

Top-level audit verdict for #190: **mostly JUSTIFIED with two EXCESS findings on shape (function decomposition, type splitting).** The optimization machinery itself is not flagged because the design mandates it.

## Method B: Our S1/S2/S3 (from REGRET_PREDICTOR.md)

Same artifact (#190 post-state). Preferences as stated in `prompts/preferences.md`:

1. Correctness: graph reconciliation converges to declared state.
2. Observable behavior: status conditions, events, finalizer ordering.
3. Public API stability: graph DSL surface, CRD field semantics.

Verdicts:

- **S1 deletion-minimality**: flag. The cache layer, content-addressed sharing, evaluation cache snapshots are units whose removal leaves all three preferences satisfied. Correctness is preserved by full re-evaluation (slower, still correct). Deletable under the stated preferences.
- **S2 partition match**: flag. Cache hit/miss cells, dirty/clean cache cells, three-hash-layer cells are not in the input partition the preferences require. Branching finer than input.
- **S3 MDL compression**: flag. The optimization machinery is ~2568 lines of code whose claims are mandated by 005-reconciliation but the design language and the code each carry the claim independently — at #190 there is no holding-pen design that absorbs the implementation. Lower-resolution description does not earn its keep.

Top-level prediction: **all three flag.** Predicted regret.

## Where the methods diverge

Inquisitor + IAS says JUSTIFIED on the optimization machinery at #190. We say "would flag" (regret-predicted). Both readings are honest. The divergence is at the **reference frame**:

- **Inquisitor's audit anchors on the design at the time of inspection.** At #190 the design mandates optimization. The audit JUSTIFIES it. Later, when #244 splits the optimization claim out of 005 into 007-optimizations.md ("do not implement"), the same code becomes EXCESS by Inquisitor's audit — the reference contracted.

- **Our prompts anchor on a fixed minimal preference set** (correctness, observable behavior, public API stability). Performance is not in the list. The optimization machinery does not serve a stated preference, so S1 says deletable. The verdict does not depend on the design at the time.

This is the **complementarity**: Inquisitor catches code-design mismatch at the current state; our prompts catch design-overclaim relative to a minimal floor.

## What this means for regret prediction

A regret like #190 happens because the design itself contracted. Ellis added optimization with design backing; later judged the design over-claimed; split 007 out of 005; stripped the implementation. The regret is the design walking back.

- **Inquisitor's audit predicts the regret only retrospectively** — after the design contracts. At the time of #190, his audit JUSTIFIES the work because the design mandates it. The system has no signal that the design is over-claiming.

- **Our prompts can predict the regret prospectively** — at #190 commit time — *if* the preferences anchor below the design. Performance is not in our minimal preference set. So we flag the optimization layer immediately as "more than the preferences require." The flag is not about the design at the time; it is about whether the design is over-claiming relative to the floor.

The cost of our framing: **we will flag any commit that adds machinery beyond minimal preferences, including commits where the additional commitment is genuinely worth keeping.** Our 75% recall on regret-pairs and 0% false-positive rate on size-matched controls (REGRET_PREDICTOR.md) suggests the floor we picked is roughly right, but the framing is structurally aggressive: anything that exceeds the floor is suspicious.

The cost of his framing: **regret is invisible until the design contracts**, at which point the audit produces the EXCESS verdict. Useful for steady-state cleanup; less useful for catching regret at PR time.

## Where the methods agree

Two of Inquisitor's findings — `WatchCoordinator` LCOM4:2 and `Reconcile()` 832-line monolith — Ellis's audit flags as EXCESS regardless of the optimization-mandate. Our framework would flag the same shape for the same reason: a single type carrying two unrelated method clusters, a single function carrying many steps the design names separately. The cog:363 / 832-line monolith is over-fine in the partition-match sense (S2), and the LCOM4:2 split is a candidate-for-deletion of the cohesion-violating coupling (S1).

Both methods agree on **shape excess**. They disagree on **mandate excess**: machinery the design mandates that the preferences do not require.

## Composition (what would actually be useful)

A combined run at PR review:

1. Lift design from the post-state of the change (our prompt).
2. Run Inquisitor on the code (his tool).
3. For each Inquisitor finding, ask: does the lifted design carry a unit that justifies it? If yes, JUSTIFIED. If no, his audit's UNJUSTIFIED is doubly attested.
4. Separately, ask: does the design itself carry units that the stated preferences do not require? Those are S1 candidates for deletion regardless of whether his tool flags them at the code level.

The first three steps are his framework. Step four is ours. They compose without conflicting because they answer different questions:
- His: is the code more complex than the design specifies?
- Ours: is the design more elaborate than the preferences require?

A regret like #190 would be caught by step four immediately (design over-claims relative to preferences) and by steps 1-3 only after the design contracts.

## Honesty

I generated the inquisitor output mechanically (the tool ran). The audit verdicts are mine, applying Ellis's prompt under the same self-evaluation caveat as our regret prediction. The verdicts are also point-estimates on a single PR — generalizing to "his framework predicts regret retrospectively, ours prospectively" needs more PRs (e.g., run both on the post-states of all 12 regret-paired commits and tabulate divergence).

The Go tool itself required a newer toolchain (go1.26.0) than the inquisitor module declares (go1.23.0); built with `GOTOOLCHAIN=go1.26.0 go build`. No code changes to inquisitor.

## Outputs

- This file (`COMPARISON.md`).
- Raw inquisitor output: `inquisitor-pr190.txt` (in `/tmp/`; can be committed if useful).
- Worktree at sha 58dd9a5: `/tmp/kro-at-190` (transient, can be removed).
