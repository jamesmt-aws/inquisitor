# Design (lifted from after-state of PR #249)

Source: 38 files at sha `439a520`, same scope.

## Purpose

Same as design-pre. The implementation now separates orchestration from execution explicitly, threads per-reconcile context as a typed value, and unifies teardown with prune as design 005 specified.

## Architecture

- **Two receivers.** `GraphReconciler` carries 10 methods (orchestration: reconcile loop, revision lifecycle, compilation, status). `clusterAccess` carries 15 methods (execution: API server ops, node handlers, prune, finalization). A method declares which receiver it lives on based on what infrastructure it needs.
- **Per-reconcile context.** `reconcileScope` struct bundles `(graph, watcher, name, namespace)`. Methods take a `*reconcileScope` instead of four separate parameters; name and namespace derived once at scope construction.
- **Unified prune/teardown.** One `pruneResources` code path; teardown is a special case (all nodes are candidates). `delete.go` shrinks 465 → 296 lines.
- **Optimization residue removed.** `graphcache.go`, `hash.go`, `metrics.go` deleted per design holding pen `007-optimizations.md`.
- **Compiler.** CEL env registration consolidated to one helper. Ready and updated CEL functions share a parameterized factory. `CompilationKey`/`CompilationKeyWithHints` removed. `fieldpath.go` merged into `expr.go`.
- **Graph package.** `IsGraphCRLiteral` moved to graph (domain predicate).
- **Organization.** `scope.go` merged into `resourcekey.go`. `deletion.go` merged into `prune.go`. `gvkToGVR` moved to `resourcekey.go`. `forEachState` and `forEachCarryForward` unified. `nodeType` parameter removed (callers use `node.Type()`). `evalConditions` unifies readyWhen/propagateWhen/includeWhen evaluation. `defaultNamespace` replaces 3 scattered copies. `ssaWrite` unifies SSA patch + status subresource pattern.
- **Final layout.**
  - `graph/` 1,735 lines, 6 files: data model, parsing, expressions, labels (leaf).
  - `dag/` 741 lines, 2 files: topology + walk state.
  - `compiler/` 2,647 lines, 7 files: pure compilation.
  - `watches/` 843 lines, 3 files: informer lifecycle + event routing.
  - `controller/` 5,281 lines, 16 files: reconcile loop + execution.

## Procedures

- **Reconcile loop.** `GraphReconciler.Reconcile` orchestrates; cluster access goes through the `clusterAccess` field.
- **Cluster access.** Methods on `*clusterAccess`.
- **Per-reconcile context.** `*reconcileScope` passed through procedures.
- **Prune (covers teardown).** `pruneResources` consumed by both lifecycle entry points.
- **Compilation.** Pure; no caching layer.
- **CEL registration.** One helper.
- **Ready/updated builders.** Parameterized factory.
- **`evalConditions`.** Unifies three condition evaluations.
- **`defaultNamespace`.** Single helper.
- **`ssaWrite`.** Unifies SSA patch + status subresource update.

## Properties

### P1: GraphReconciler carries 10 orchestration methods
`clusterAccess` separately carries 15 execution methods. The split is legible from the receiver type.

### P2: reconcileScope is the per-reconcile context type
17 functions take `*reconcileScope` instead of `(graph, watcher, name, namespace)`. Name and namespace derived once.

### P3: Teardown is prune with all nodes as candidates
One `pruneResources` code path; design 005's claim is now structural.

### P4: graphcache.go, hash.go, metrics.go are gone
The optimization-layer holding pen `007` is honored.

### P5: CEL env registration is one helper
Single source of registration.

### P6: Ready and updated CEL functions share a parameterized factory
One builder, two parameter sets.

### P7: scope and deletion are not standalone files
Merged into resourcekey and prune respectively.

### P8: gvkToGVR is in resourcekey
Utility lives with resource identity.

### P9: forEach state is one type
`forEachState` and `forEachCarryForward` unified.

### P10: nodeType parameter removed; callers use node.Type()
Redundant parameter gone from the call chain.

### P11: 11 condition-related symbols unexported
Public surface contains only what consumers outside the package need.

### P12: defaultNamespace is one helper
Three scattered copies absorbed.

### P13: ssaWrite is one helper
SSA patch + status subresource pattern consolidated.

### P14: clusterAccess receiver makes infrastructure dependencies explicit
Each method declares whether it needs API server access. GraphReconciler methods do not.

### P15: reconcileScope encodes the lifetime of per-reconcile state
Scope construction at the top of Reconcile establishes the values that downstream methods consume.
