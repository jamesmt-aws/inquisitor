# Design (lifted from after-state of PR #224)

Source: 3 files at sha `9313102`. Same scope.

## Architecture

- **Hard and readiness propagation are symmetric.** `propagationTriggered` is set for both `Dependents` and `ReadinessDependents` in Path 2 propagation hash, coordinator loop propagation hash, and coordinator loop dispatch.
- **Cluster-scoped refs.** Scope check matches the `applySSA` pattern; cluster-scoped resources are routed with `namespace=""` consistently.
- **Stale readiness dispatch detection.** Coordinator detects inflight readiness deps at dispatch time and deposits explicit triggers via `GraphWatcher.DepositTrigger` for the next reconcile.

## Procedures

- **Path 2 propagation hash check.** Sets trigger for hard or readiness dependents.
- **Coordinator-loop propagation hash check.** Symmetric.
- **Coordinator-loop dispatch.** Symmetric.
- **Ref reconciliation.** Scope-aware namespace defaulting.
- **GraphWatcher API.** New `DepositTrigger` method for scheduling re-evaluation on the next reconcile cycle.

## Properties

### P1: Hard `Dependents` propagation triggers downstream re-eval
Same as design-pre.

### P2: ReadinessDependents propagation triggers downstream re-eval
A node consuming only `.ready()` is re-triggered when its upstream readiness changes; compat test passes.

### P3: Cluster-scoped refs route correctly
Watch routing for cluster-scoped CRDs uses `namespace=""` consistently.

### P4: Stale readiness dispatch is detected and deferred
Coordinator detects inflight readiness deps at dispatch time; deposits trigger for next reconcile via `DepositTrigger`.

### P5: GraphWatcher provides DepositTrigger
API method for deferring re-evaluation.
