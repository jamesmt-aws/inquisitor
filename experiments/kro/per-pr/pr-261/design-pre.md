# Design (lifted from before-state of PR #261)

Source: 10 files at sha `d94ded6^`, scope spans `experimental/controller/` and `experimental/controller/dag/`.

## Purpose

The kro experimental controller has a compile-time component that produces a DAG and a reconcile-time component that walks the DAG against live cluster state. Compile-time output is a pure data structure; reconcile-time produces per-node walk state, summary state, and observed states.

## Architecture

- **Package layout.** `dag/` holds compile-time DAG construction (`BuildDAG`, `AssembleDAG`, `DetectCyclesEarly`, `DAG`, `Topology`) plus reconcile-time output types (`NodeState`, `PlanState`, `PlanSummary`) co-located in `dag/walkstate.go`.
- **Cross-package imports.** `controller/errors.go`, `controller/status.go`, and `controller/foreach.go` import `dag/` solely to reference `NodeState`, `PlanState`, and `PlanSummary`.
- **Reconcile-time output type.** `walkstate.go` defines the value the walk produces (per-node states, summary). The file lives in `dag/` because `NodeState` was originally treated as a property of DAG nodes.

## Procedures

- **DAG construction.** `BuildDAG` parses `GraphSpec.Nodes` into a `*DAG` plus a `Topology`. Pure compile-time.
- **Cycle detection.** `DetectCyclesEarly` runs at compile time over the DAG.
- **Walk state recording.** Reconcile-time code in `controller/walk.go` produces `dag.NodeState` values per node and `dag.PlanState` aggregates.
- **Status derivation.** `controller/status.go` reads `dag.PlanSummary` to write status conditions. Imports `dag/` for the type names.
- **Error reporting.** `controller/errors.go` constructs error values that include `dag.NodeState`. Imports `dag/`.
- **forEach state.** `controller/foreach.go` references `dag.NodeState` for per-item states. Imports `dag/`.

## Properties

### P1: DAG construction is pure compile-time
`BuildDAG` reads only the `GraphSpec` and produces a pure data structure.

### P2: NodeState is co-located with DAG types in `dag/`
`dag/walkstate.go` defines `NodeState`, `PlanState`, `PlanSummary`. The file is in the same package as `dag.go`, which defines `DAG` and `Topology`.

### P3: Reconcile-time files import `dag/` for state types
`controller/errors.go`, `controller/status.go`, `controller/foreach.go` import the `dag/` package to reference `NodeState`, `PlanState`, `PlanSummary`. They do not import `dag/` for `DAG` or `Topology`.

### P4: The `dag/` package mixes compile-time and reconcile-time concepts
A reader inspecting `dag/` sees both pure DAG types (`DAG`, `Topology`, `BuildDAG`) and reconcile-time output types (`NodeState`, `PlanState`, `PlanSummary`). The package boundary does not separate the two phases.

### P5: Import graph does not encode the compile-time / reconcile-time split
A new contributor cannot infer from imports alone that `BuildDAG` is compile-time and `NodeState` is reconcile-time; both come from the same package.
