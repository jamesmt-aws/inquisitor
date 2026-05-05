# Design (lifted from after-state of PR #261)

Source: 10 files at sha `d94ded6`, same scope.

## Purpose

Same as design-pre. No behavioral changes; this is a code move.

## Architecture

- **Package layout.** `dag/` holds only compile-time DAG construction: one file (`dag.go`), three exported types (`DAG`, `Topology`, plus internal node), three exported functions (`BuildDAG`, `AssembleDAG`, `DetectCyclesEarly`). `walkstate.go` moves to `controller/`.
- **Cross-package imports.** `controller/errors.go`, `controller/status.go`, `controller/foreach.go` no longer import `dag/`. Remaining imports of `dag/` are for the actual `DAG` struct in compile-time call sites.
- **Reconcile-time output type.** `controller/walkstate.go` defines `NodeState`, `PlanState`, `PlanSummary`. The file lives next to `walk.go` in the package that produces these values.

## Procedures

- **DAG construction.** Same as design-pre. Still compile-time.
- **Cycle detection.** Same as design-pre.
- **Walk state recording.** `controller/walk.go` produces `controller.NodeState` values. No package boundary crossed.
- **Status derivation.** `controller/status.go` reads `controller.PlanSummary` directly. No `dag/` import.
- **Error reporting.** `controller/errors.go` constructs error values including `controller.NodeState`. No `dag/` import.
- **forEach state.** `controller/foreach.go` references `controller.NodeState`. No `dag/` import.

## Properties

### P1: DAG construction is pure compile-time
Same as design-pre.

### P2: NodeState is co-located with the walk that produces it
`controller/walkstate.go` sits next to `controller/walk.go`. The file location matches the lifecycle of the type.

### P3: Reconcile-time files do not import `dag/` for state types
Imports of `dag/` from `errors.go`, `status.go`, `foreach.go` are removed. The remaining imports of `dag/` are confined to call sites that consume the `DAG` struct.

### P4: The `dag/` package contains only compile-time concepts
A reader inspecting `dag/` sees pure DAG types and pure DAG operations. Zero reconcile-time concepts.

### P5: Import graph encodes the compile-time / reconcile-time split
A new contributor inspecting imports alone can infer the split: `dag/` types appear at compile-time call sites; reconcile-time types appear in `controller/`. The architecture is legible from the dependency direction.
