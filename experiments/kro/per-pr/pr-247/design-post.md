# Design (lifted from after-state of PR #247)

Source: 30 files at sha `9e4b2f7`, same scope.

## Purpose

The kro experimental controller compiles user-declared graphs and reconciles them. After #247, the controller carries the core reconciliation algorithm and a flat instance-state map. Optimization-layer constructs (resource cache, content-addressed sharing, precompile, revision-transition carry-forward) are removed; the holding pen for them is `007-optimizations.md`, which says "do not implement."

## Architecture

- **Reconciliation core.** Same sequential walk as pre.
- **No optimization layer.**
  - `resourceCache` removed.
  - Content-addressed compiled-graph sharing removed; `graphCaches` flattened to `map[string]*instanceState` keyed by instance identity.
  - `precompileExpressionChildGraphs` removed; design says child compiles independently.
  - `diffRevisionNodes` and selective state carry-forward across revisions removed.
- **Revision lifecycle.** Only the GC condition remains. Ready and Active conditions removed.
- **Watch interfaces.** `DrainTriggers`, `DepositTrigger`, `DrainCollectionChanges`, `CollectionChange`, `GetResourceVersion`, `RetainWatches` removed; the watch surface is reduced to what the core algorithm consumes.
- **Metrics.** `ResyncTimerFiresTotal` and `SelfRefreshTotal` removed.
- **Apply path.** `applySSA` decomposed into named steps: `prepareObject`, `checkOwnership`, `ssaPatch`, `evictThirdPartyManagers`. `compileRevision` reduced from 6 branches to 2. `RouteEvent` simplified to identify-owner-and-enqueue. `deletePreflight()` extracted from duplicated prune/delete logic. forEach carry-forward bundled into a single `forEachCarryForward` struct. `reconcileNode` returns `*nodeOutput` rather than a three-way tuple.

## Procedures

- **Apply.** Decomposed into `prepareObject`, `checkOwnership`, `ssaPatch`, `evictThirdPartyManagers`, each named at the level the design discusses.
- **Compile revision.** Two branches: with-prior-revision, without-prior-revision.
- **Event routing.** Identify owner, enqueue. One concern per call.
- **Prune / delete.** Shared `deletePreflight()` consumed by both paths.
- **forEach carry-forward.** Bundled into a single struct; readers see one shape, not seven fields.
- **Reconcile node.** Returns `*nodeOutput`. Single value carries everything the caller needs.

## Properties

### P1: No SSA elision via cache; correctness via apply-hash on the Patch path
Repeated reconciles produce SSA Patch calls; the API server's apply-hash short-circuits at the field-manager level. Application-level cache is gone.

### P2: Each instance has its own compiled graph
`graphCaches` is keyed by instance identity; structurally identical graphs do not share storage.

### P3: Revision transitions reconcile every node from scratch
No selective carry-forward; the post-design says revision transitions are full re-evaluations.

### P4: Only the GC condition is observable on Revision status
Ready and Active are removed.

### P5: Watch surface contains only what the core consumes
The removed interfaces are gone; remaining watch types serve the simple sequential walk.

### P6: Metrics surface omits resync-timer and self-refresh
The removed counters are gone.

### P7: applySSA is decomposed into four named steps
`prepareObject`, `checkOwnership`, `ssaPatch`, `evictThirdPartyManagers` are each callable and individually testable.

### P8: compileRevision has two branches
With-prior and without-prior. Other distinctions absorbed into helpers.

### P9: RouteEvent is one concern: identify owner, enqueue
The router does not branch over six event shapes.

### P10: Prune and delete share preflight via deletePreflight()
One function consumed by both paths.

### P11: forEach carry-forward is one struct with named fields
A single value flows across function boundaries.
