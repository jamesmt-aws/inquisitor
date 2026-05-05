# Design (lifted from before-state of PR #224)

Source: 3 files at sha `9313102^`. Touched: `controller.go`, `node.go`, `watches/watches.go`.

## Purpose

Same controller as elsewhere. Pre-state has four bugs in the propagation/dispatch path that cause compat tests to fail (35/39).

## Architecture

- **Hard dependency propagation.** When an upstream node's output changes, dependents' propagation hashes flip and they get re-triggered. Implemented for `Dependents` set.
- **ReadinessDependents propagation.** Nodes consuming only `.ready()` register as readiness dependents of upstream. Pre-state: `propagationTriggered` flag is set only for hard `Dependents`, not `ReadinessDependents`. Nodes like `rgdInstanceStatus` are never re-triggered when upstream readiness changes.
- **Cluster-scoped ref namespace handling.** `reconcileRef` defaults empty namespace to graph namespace. WatchScalar registers with `namespace=graph-ns`; informer events for cluster-scoped resources arrive with `namespace=""`. Routing mismatch.
- **Concurrent readiness dispatch.** A node with only ReadinessDeps may dispatch concurrently with its readiness deps. Worker captures stale `.ready()` snapshot. Node commits first; propagation hash at walk-end shows final state, masking the stale dispatch.

## Procedures

- **Path 2 propagation hash check.** Set `propagationTriggered` on hard `Dependents` only.
- **Coordinator-loop propagation hash check.** Same restriction.
- **Coordinator-loop dispatch.** Same restriction.
- **Ref reconciliation.** Defaults empty namespace unconditionally.
- **GraphWatcher API.** No way to record "this node was dispatched stale, re-evaluate next reconcile."

## Properties

### P1: Hard `Dependents` propagation triggers downstream re-eval
When an upstream output changes, `Dependents` are re-triggered.

### P2: ReadinessDependents propagation is broken
A node consuming only `.ready()` is not re-triggered when its upstream readiness changes. Manifests as compat test failures.

### P3: Cluster-scoped refs route incorrectly
Watch routing for cluster-scoped CRDs has a permanent namespace mismatch.

### P4: Stale readiness dispatch is undetected
Concurrent dispatch with stale `.ready()` snapshot commits results that mask the staleness; no signal for next reconcile.

### P5: GraphWatcher cannot defer re-evaluation
No `DepositTrigger` API.
