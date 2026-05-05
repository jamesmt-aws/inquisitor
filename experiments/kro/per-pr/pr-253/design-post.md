# Design (lifted from after-state of PR #253)

Source: 39 files at sha `2121f02`, same scope.

## Purpose

Same as design-pre. After this PR, the implementation tracks the architecture; dead code, duplication, and over-abstraction are removed.

## Architecture

- **Compiled graph state.** `CompiledGraph` carries only fields production code reads.
- **Hash infrastructure.** `graph/hash.go` removed.
- **Topology fields.** `nodeSelfPaths`, `nodeDepPaths`, `Node.SelfPaths`, `Node.DepPaths`, `ForEachBinding.CollectionSource` removed; allocation per reconcile drops.
- **State.** Write-only fields gone. `resyncCorrection` parameter removed from 5 signatures. Vestigial parameters removed.
- **Dead constants and exports.** Removed. `gateDispatch`, dead production fields gone.
- **Shared procedures.** `main_test.go` migrated to `testenv.Environment` (-320 lines). `conditionField` generic replaces `graphReady*` extractors. `buildKeyPositionMap` unifies `pruneOrder` and `pruneOrderApplied`. `walkAST` plus `astVisitor` deduplicates the two AST walkers in `fieldpath.go`. `runFinalization` and `runForEachFinalization` share `ensureFinalizerResource`. `WalkExpressions` shared between `AllExpressions` and `ExtractReferencedPathsFromNode`.
- **Single-impl abstractions removed.** `GVKScopeResolver` interface replaced by concrete `*scopeResolver`. `WatchCoordinator.Watches` is now unexported with delegation. `SetOnEvent`/`SetOnNewType` lifted to constructor parameters.
- **Identifiers.** `resource.gvr` renamed `resource.obj` to match content. `LabelValue()` delegates to `String()`. `conditionsSchemaProperties` collapsed to `conditionsSchema`. `celReadyFunction`/`celUpdatedFunction` inlined.
- **Undocumented surface removed.** `forceApply: "true"` string form removed. `pruneReleased` outcome removed; type-check at the patch site replaces outcome-level distinction.
- **Exports.** 11 symbols unexported (condition types, finalization phase, watch events, `CompiledGraph` internals).

## Procedures

- **Graph compilation.** Produces a `CompiledGraph` with only live fields.
- **Topology assembly.** Allocates only what is consumed.
- **forEach state assembly.** Single-source carry-forward; no phantom fields.
- **Finalization.** Shared `ensureFinalizerResource` between flat and forEach paths.
- **AST walking.** Single `walkAST` plus `astVisitor`; both consumers use the shared walker.
- **Test setup.** All test files use `testenv.Environment`.
- **Condition extraction.** Generic `conditionField` parameterized by condition type.
- **GVK scope resolution.** Direct call on concrete `*scopeResolver`.
- **Force-apply parsing.** One YAML shape (`forceApply: Force`).

## Properties

### P1: CompiledGraph carries only live fields
Five dead fields removed.

### P2: graph/hash.go removed
File no longer present.

### P3: Topology allocates only what is consumed
Per-reconcile allocation drops.

### P4: All state fields are read by some consumer
Write-only fields removed.

### P5: Function signatures do not carry resyncCorrection
Five signatures cleaned up.

### P6: No public symbols without production callers
Exported constants with no consumers removed.

### P7: testenv.Environment is the single test harness
main_test.go's duplicate harness gone.

### P8: conditionField is the single condition extractor
Per-condition extractors absorbed.

### P9: fieldpath.go has one AST walker
Parallel walkers absorbed; shared by both consumers.

### P10: scopeResolver is concrete
Interface removed; one consumer calls the struct directly.

### P11: forceApply has one documented shape
String form removed.

### P12: prune outcome is uniform
`pruneReleased` removed; patches identified by type check.

### P13: Exported surface contains only what consumers outside the package read
11 symbols unexported.
