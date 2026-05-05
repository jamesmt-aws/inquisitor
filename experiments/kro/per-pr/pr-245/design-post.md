# Design (lifted from after-state of PR #245)

Source: 18 files at sha `9014431`, same scope.

## Purpose

The kro experimental controller compiles user-declared graphs and reconciles them. Post-state implements only the core algorithm from `005-reconciliation.md`. Optimization machinery is removed; the holding pen `007-optimizations.md` carries the deferred work as design only.

## Architecture

- **Core algorithm.** Sequential walk over topological order. For each node: dependencies → includeWhen → propagateWhen → evaluate → publish to scope. Every node evaluated every reconcile.
- **No optimization layer.** Removed: 3-layer hash system, trigger-scoped walks, per-node resync timers, worker goroutine dispatch (Path 1/2/3), forEach incremental diffing, watch incremental cache merging, evaluation caching.
- **Apply path.** Unchanged. SSA Patch with content-addressed hash still elides redundant API writes; this lives at the apply layer, not the evaluation layer.

## Procedures

- **DAG walk.** Sequential loop over topological order. No coordinator, no workers, no channels.
- **Reconcile node.** Check dependencies (already evaluated), evaluate includeWhen, propagateWhen, then expression bodies, publish to scope.
- **Watch event handling.** Event enqueues a full reconcile of the owning graph instance. No subgraph routing.
- **forEach evaluation.** Every item evaluated every reconcile (unless `propagateWhen` halts the loop).
- **Apply.** SSA Patch via `applySSA`; content-addressed hash on the desired state; the API server elides on identical Patch.

## Properties

### P1: Every reachable node is evaluated every reconcile
No skip via input-hash; correctness by construction.

### P2: A watch event triggers a full reconcile
The reconciler does not walk a subgraph; the simple loop processes the whole DAG.

### P3: Resync uses the controller-runtime resync interval, not per-node timers
Per-node resync machinery is gone.

### P4: Sequential walk; no coordinator or workers
walk.go has one loop. No goroutines beyond what controller-runtime provides.

### P5: Path 1/2/3 distinction does not exist
There is one path: the sequential loop. Distinctions absorbed.

### P6: forEach has no per-item skip
Every item is evaluated each reconcile; correctness preserved.

### P7: No watch incremental cache merging
`mergeCollectionChanges` removed; collection state comes from the informer fresh each reconcile.

### P8: Implementation files shrink substantially
controller.go: 830 → 497 (-40%). walk.go: 982 → 479 (-51%). hash.go: 361 → 136 (-62%). Net -2443 lines across 18 files.

### P9: Test `TestPropagationStopsOnIrrelevantChange` asserts the correctness invariant, not the skip invariant
The test now checks that no API write occurs when nothing changes (correctness via apply-hash), not that evaluation was skipped.
