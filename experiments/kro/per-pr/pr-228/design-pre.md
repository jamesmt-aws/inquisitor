# Design (lifted from before-state of PR #228)

Source: 2 files at sha `fe7ff8c^`. Touched: `controller.go`, `walk.go`.

## Purpose

The reconciler tracks applied resource keys per walk so the prune phase can identify candidates for removal. Pre-state uses an append-only slice.

## Architecture

- **Walk state.** `walkState.appliedKeys []string` accumulates keys across the walk. Both carry-forward (skip path) and dispatch result processing append into the same slice.
- **Carry-forward.** When a node is skipped at Step 1 of `tryDispatch`, its previous applied keys are appended to `appliedKeys`.
- **Dispatch result.** When a node completes evaluation, its result keys are appended to `appliedKeys`.
- **Prune.** Reads `appliedKeys` to decide what to keep.

## Procedures

- **`carryForwardKeys`.** Reads `state.previousKeys[nodeID]` and appends to `walk.appliedKeys`.
- **Dispatch processing.** Appends `res.keys` to `walk.appliedKeys`.
- **Prune.** Reads the slice; treats every entry as "keep this."

## Properties

### P1: Applied keys are tracked as a flat slice
`walkState.appliedKeys []string`.

### P2: Same node can contribute keys twice in one walk
A node skipped at Step 1 then dispatched on a propagation trigger appends carry-forward keys first and dispatch result keys second. Both ranges remain in `appliedKeys`.

### P3: forEach scale-down can leave stale keys in the applied set
When a forEach scales N→0, the dispatch result returns 0 keys, but a prior carry-forward already appended the stale key. Prune sees the stale key and keeps the resource.

### P4: TestRGDLifecyclePort is flaky (~10%)
Symptom of P3 in the test surface.
