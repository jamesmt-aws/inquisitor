# Design (lifted from before-state of PR #253)

Source: 39 files at sha `2121f02^`, scope spans controller, graph, dag, watches, compiler, stdlib, tests.

## Purpose

The kro experimental controller compiles graphs and reconciles them. After the optimization-layer strip in #245/#247, the remaining surface still carries dead code, duplicated logic, and over-abstracted single-implementation interfaces. The architecture is mostly correct; the implementation lags it.

## Architecture

- **Compiled graph state.** `CompiledGraph` carries five fields beyond what production code reads: `ExprPaths`, `ExprAccessModes`, `DynamicGVKNodes`, `ChildTopologies`, `TypeCacheGen`. Pre-staged for an optimization that was deferred.
- **Hash infrastructure.** `graph/hash.go` defines content-hash machinery for an unimplemented optimization.
- **Topology fields.** `Topology.nodeSelfPaths`, `Topology.nodeDepPaths`, `Node.SelfPaths`, `Node.DepPaths`, `ForEachBinding.CollectionSource` — pre-staged with allocation cost on every reconcile.
- **Dead state.** `walkResult.scope`, `walkResult.nodeReady`, `walkResult.forEach` written but never read. `forEachCarryForward.items` write-only. `reconcileState.topologicalOrder` dead with dead guard. `instanceState.spec` set, never read. `PlanState.SetState` carries a vestigial `dag` parameter.
- **Dead constants and exports.** `FinalizeSkippedStates`, `NodeStateCount` exported, no production callers. `gateDispatch` constant defined, never tested in production. `pruneOrder` field with no production usage (replaced by `pruneOrderApplied`).
- **Duplicated procedures.** `main_test.go` carries a 320-line setup harness duplicated against `testenv.Environment`. `graphReady*` extractors are written separately for each condition. `runFinalization` and `runForEachFinalization` share preamble. `AllExpressions` and `ExtractReferencedPathsFromNode` walk the AST separately. `fieldpath.go` has two parallel AST walkers.
- **Single-implementation interfaces.** `GVKScopeResolver` is an interface with one production implementation. `WatchCoordinator.Watches` is a public field with no external consumer. `SetOnEvent`/`SetOnNewType` are setters that callers always call after construction.
- **Stale identifiers.** `resource.gvr` is a field name that no longer matches its content (it holds `*unstructured.Unstructured`, not a GVR). `LabelValue()` and `String()` exist as separate methods returning the same string. `conditionsSchemaProperties` is a wrapper map adding nothing. `celReadyFunction`/`celUpdatedFunction` are wrappers around inline-shaped expressions.
- **Undocumented surface.** `forceApply: "true"` string form accepted by parser but not documented in any design. `pruneReleased` outcome distinguished from other prune outcomes despite identical handling.

## Procedures

- **Graph compilation.** Produces a `CompiledGraph` with the five dead fields populated alongside the live ones.
- **Topology assembly.** Allocates `nodeSelfPaths`, `nodeDepPaths` per node every reconcile.
- **forEach state assembly.** Maintains `items` field whose contents nothing reads.
- **Finalization.** Two procedures (`runFinalization`, `runForEachFinalization`) with shared preamble duplicated.
- **AST walking.** Two parallel walkers in `fieldpath.go`; `AllExpressions` and `ExtractReferencedPathsFromNode` each walk separately.
- **Test setup.** `main_test.go` duplicates 320 lines of harness logic.
- **Condition extraction.** Per-condition extractor functions (`graphReadyType`, `graphReadyMessage`, etc.) repeating the same lookup shape.
- **GVK scope resolution.** Goes through `GVKScopeResolver` interface that has one impl.
- **Force-apply parsing.** Accepts `forceApply: "true"` (string) and `forceApply: Force` (typed) shapes.

## Properties

### P1: CompiledGraph carries five fields with no production reader
ExprPaths, ExprAccessModes, DynamicGVKNodes, ChildTopologies, TypeCacheGen are all written; nothing reads.

### P2: graph/hash.go is dead infrastructure
File compiles, exports unused functions.

### P3: Topology pre-allocates self/dep paths on every reconcile
Allocation cost paid; data not consumed.

### P4: Several state fields are write-only
`walkResult.{scope, nodeReady, forEach}`, `forEachCarryForward.items`, `instanceState.spec`, `reconcileState.topologicalOrder` all set, never read.

### P5: resyncCorrection is a dead parameter threaded through 5 signatures
Function signatures carry it; no caller cares about its value.

### P6: Exported constants with no production callers
`FinalizeSkippedStates`, `NodeStateCount` exist on the public surface with no consumer.

### P7: main_test.go duplicates testenv.Environment
320 lines of harness that match an existing helper.

### P8: graphReady* extractors duplicate condition lookup
Each condition has its own extractor; shape is the same; differences fit one parameter.

### P9: fieldpath.go has parallel AST walkers
Two near-identical walkers; AllExpressions walks separately too.

### P10: GVKScopeResolver is a single-impl interface
Defined as interface; one struct implements it; no second consumer.

### P11: forceApply has two YAML shapes
Parser accepts `forceApply: "true"` and `forceApply: Force`; only the second is documented.

### P12: pruneReleased is a distinct outcome with identical handling
Type-level distinction without observable difference.

### P13: 11 symbols are exported with no external consumer
Condition types, finalization phase, watch events, CompiledGraph internals all visible publicly.
