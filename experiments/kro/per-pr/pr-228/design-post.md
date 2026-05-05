# Design (lifted from after-state of PR #228)

Source: 2 files at sha `fe7ff8c`. Same scope.

## Architecture

- **Walk state.** `walkState.nodeKeys map[string][]string` keyed by node ID. Carry-forward and dispatch both write to `nodeKeys[nodeID]`. Last writer wins by map semantics.
- **Carry-forward.** Writes `nodeKeys[nodeID] = prevKeys`.
- **Dispatch result.** Writes `nodeKeys[nodeID] = res.keys`.
- **Prune.** Flattens the map into a single applied-key slice at walk end.

## Procedures

- **`carryForwardKeys`.** Writes per-node entry; subsequent dispatch overwrites.
- **Dispatch processing.** Overwrites the map entry for the node.
- **Prune.** Reads the flattened slice.

## Properties

### P1: Applied keys are tracked per node
`walkState.nodeKeys map[string][]string`. Map shape encodes uniqueness per node.

### P2: A node contributes one set of keys to the applied set per walk
Last-writer-wins by map semantics: carry-forward then dispatch leaves only the dispatch result. Stale carry-forward cannot accumulate.

### P3: forEach scale-down does not leave stale keys
Dispatch result with 0 keys overwrites the carry-forward; prune sees no stale entry; resource is correctly pruned.

### P4: TestRGDLifecyclePort is deterministic
20/20 passes (was ~9/10).
