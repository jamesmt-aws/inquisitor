# Design (lifted from before-state of PR #247)

Source: 30 files at sha `9e4b2f7^`, scope spans controller, watches, e2e tests.

## Purpose

The kro experimental controller compiles user-declared graphs and reconciles them. The controller carries an optimization layer alongside the core reconciliation algorithm: per-resource caching of SSA writes, content-addressed sharing of compiled graphs across instances, selective state carry-forward across revision transitions, and revision lifecycle conditions exposed via CRD status.

## Architecture

- **Reconciliation core.** Sequential walk over the DAG (post-#245 simplification).
- **Optimization layer.** Sits on top of the core:
  - `resourceCache` keyed by SSA target object; an apply-hash check elides redundant Patch calls.
  - Content-addressed compiled-graph sharing: instances with structurally identical compiled graphs share a single artifact (`graphCaches` keyed by content hash).
  - `precompileExpressionChildGraphs`: forEach children pre-compiled at graph compile time.
  - `diffRevisionNodes` plus selective state carry-forward across revision transitions.
- **Revision lifecycle.** Revisions carry Ready, Active, and GC conditions exposed in CRD status; controllers watch all three.
- **Watch interfaces.** `DrainTriggers`, `DepositTrigger`, `DrainCollectionChanges`, `CollectionChange`, `GetResourceVersion`, `RetainWatches` define an extensible watch contract.
- **Metrics.** Prometheus counters include `ResyncTimerFiresTotal` and `SelfRefreshTotal`.
- **Apply path.** `applySSA` is one ~200-line function; `compileRevision` branches in 6 places; `RouteEvent` covers six event-routing cases. Prune and delete share preflight logic but it is duplicated across the two paths.

## Procedures

- **resourceCache lookup and elision.** Apply path consults the cache; on hit with matching apply-hash, the SSA Patch is skipped.
- **Content-addressed graph sharing.** Compilation key derived from spec content; identical compiled artifacts share storage.
- **forEach child precompile.** Children of forEach nodes are precompiled at graph-build time.
- **Revision diff and carry-forward.** Across revision transitions, unchanged nodes carry forward state selectively.
- **Revision condition publishing.** Ready, Active, and GC conditions written to revision status.
- **Watch trigger drain.** `DrainTriggers` and related interfaces gate event delivery.
- **Apply.** `applySSA` covers prepare, ownership, patch, third-party manager eviction, error classification in one block.
- **Compile revision.** `compileRevision` dispatches across six branches.
- **Event routing.** `RouteEvent` matches six event shapes.
- **Prune / delete.** Each path has its own preflight; logic is duplicated.
- **forEach carry-forward.** State carried as separate fields across function boundaries.

## Properties

### P1: SSA elision via resourceCache reduces API writes
A repeated reconcile with no spec change produces zero SSA Patch calls for unchanged nodes.

### P2: Compiled graphs are shared across instances by content hash
Two instances of the same graph schema with identical structural content share one compiled artifact in `graphCaches`.

### P3: Revision transitions selectively carry forward unchanged-node state
A revision transition where 90% of nodes are unchanged carries forward those nodes' applied state without re-evaluation.

### P4: Revision Ready and Active conditions are observable in CRD status
A user inspecting a Revision sees Ready, Active, and GC conditions plus their reasons.

### P5: Watch interfaces support drain and retain semantics
Implementations of `DrainTriggers` etc. are part of the public watch contract.

### P6: Metrics include resync-timer and self-refresh counters
`ResyncTimerFiresTotal` and `SelfRefreshTotal` are exported Prometheus counters.

### P7: applySSA is one entry point covering five concerns
Prepare, ownership, patch, third-party eviction, error classification all live in one function body.

### P8: compileRevision has six branches
Dispatch covers six cases at the top level.

### P9: RouteEvent covers six event shapes
The router matches six distinct cases at the top level.

### P10: Prune and delete have duplicated preflight logic
Both paths perform similar pre-deletion checks; the code is duplicated rather than shared.

### P11: forEach carry-forward state lives in separate fields across function boundaries
The carry-forward shape is implicit; readers infer it from individual field references.
