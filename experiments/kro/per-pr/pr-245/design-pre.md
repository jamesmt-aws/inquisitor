# Design (lifted from before-state of PR #245)

Source: 18 files at sha `9014431^`, scope `experimental/controller/` plus tests.

## Purpose

The kro experimental controller compiles user-declared graphs and reconciles them. Pre-state implements both the core algorithm (DAG walk, evaluate, apply) and a separate optimization layer that aims to do less work per reconcile (skip unchanged nodes, partial walks, parallel evaluation). The two layers are intermingled in the implementation files (`controller.go`, `walk.go`, `eval.go`, `instance.go`, `hash.go`, `foreach.go`, `node.go`).

## Architecture

- **Core algorithm.** DAG walk over topological order. For each node: dependencies → includeWhen → propagateWhen → evaluate → publish to scope.
- **Optimization layer.** Layered into the same files as the core. Components:
  - **3-layer hash system.** `hashNodeInputs`, `hashSelfPaths`, plus field-path hashing. Detects when evaluation can be skipped because inputs have not changed.
  - **Trigger-scoped walks.** Partial DAG walks scoped to the subgraph affected by a watch event.
  - **Per-node resync timers.** Each node carries a resync timer with exponential backoff and jitter; expiry triggers re-evaluation.
  - **Worker goroutine dispatch.** Coordinator dispatches nodes to workers via channels; Path 1, Path 2, and Path 3 distinguish stale-read self-refresh, watch-driven scheduling, and resync-triggered work.
  - **forEach incremental diffing.** Per-item content hash caching, changed-item sets, skip on unchanged.
  - **Watch incremental cache.** `mergeCollectionChanges`, collection dirty tracking.
  - **Evaluation caching.** `previousEvalHashes`, `previousSelfHashes`, `snapshotFor` carry per-node state across reconciles for skip detection.
- **Apply path.** SSA Patch with content-addressed hash to skip unnecessary API writes (this is the hash that survives into post; it is not part of the optimization layer being stripped).

## Procedures

- **DAG walk.** Coordinator/worker pattern with channel-based dispatch.
- **Path 1 / 2 / 3 routing.** Coordinator decides which Path each node enters based on watch event provenance and timer state.
- **Hash-based skip.** Three-layer hash check at evaluation time; skip evaluation when input hashes match the previous reconcile.
- **Trigger-scoped subgraph walk.** Watch event identifies a subgraph; coordinator walks only that subgraph.
- **Resync timer firing.** Timer expiry enqueues a node for re-evaluation; tracked via `ResyncTimerFiresTotal`.
- **forEach incremental diff.** Per-item hash check; skip items whose content has not changed.
- **Watch collection dirty tracking.** Incremental update to cached collection state; `mergeCollectionChanges` integrates new events.
- **Evaluation cache snapshot.** `snapshotFor` produces a per-worker view of previous-reconcile state.

## Properties

### P1: Repeated reconcile with no change skips evaluation
Hash check returns true on every node; no node's expressions are re-evaluated.

### P2: Watch-driven reconcile walks only the affected subgraph
A watch event for one resource triggers re-evaluation only of nodes whose inputs depend on that resource.

### P3: Per-node resync timers fire on independent schedules
Each node's timer has its own jittered interval; expiries are decorrelated across nodes.

### P4: Coordinator dispatches across worker goroutines
Nodes ready to evaluate are sent to a worker pool; results return via channels.

### P5: Path 1, 2, 3 distinguish reconcile reasons
The coordinator routes each work item via Path 1 (stale-read self-refresh), Path 2 (watch-driven), or Path 3 (resync-driven).

### P6: forEach skips unchanged items
Items with matching content hash from the previous reconcile are not re-evaluated.

### P7: Watch incremental updates avoid full re-list
`mergeCollectionChanges` integrates events into the cached collection state.

### P8: walk.go is ~1000 lines; controller.go is ~830
The implementation surface is dominated by optimization machinery.

### P9: Test `TestPropagationStopsOnIrrelevantChange` asserts evaluation skip
The optimization invariant (no re-evaluation when inputs unchanged) is part of the test surface.
