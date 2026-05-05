# Design (lifted from before-state of PR #249)

Source: 38 files at sha `439a520^`, scope spans graph, dag, compiler, watches, controller.

## Purpose

The kro experimental controller compiles graphs and reconciles them. Pre-state has the orchestration concerns (reconcile loop, revision lifecycle, compilation, status) and the execution concerns (API server ops, node handlers, prune, finalization) co-resident on a single `GraphReconciler` receiver. Several optimization-layer artifacts remain (`graphcache.go`, `hash.go`, `metrics.go`) despite the design holding pen `007-optimizations.md` deferring them. Teardown and prune have separate ~400-line implementations even though design 005 says teardown is pruning where all nodes are candidates.

## Architecture

- **Receiver-bound methods.** `GraphReconciler` carries 25+ methods spanning orchestration and execution. Methods that only need a Kubernetes client receive the entire reconciler value.
- **Per-reconcile context.** Every function in the reconcile chain takes (graph, watcher, name, namespace) as separate parameters, threading through 17 functions at 5 call levels. Each callee re-derives `graph.GetName()` and `graph.GetNamespace()`.
- **Teardown and prune.** Two separate implementations. `delete.go` is 465 lines covering teardown of a graph instance. `prune.go` covers per-reconcile prune candidates. Each carries its own finalization handling.
- **Optimization residue.** `graphcache.go` implements compilation result caching by structural key. `hash.go` carries SSA apply-hash annotation logic. `metrics.go` carries Prometheus counter setup.
- **Compiler.** CEL environment registration appears in 4 places. Ready and updated CEL functions are written separately. `CompilationKey` and `CompilationKeyWithHints` exist for the cache key. `fieldpath.go` is its own file.
- **Graph package.** `IsGraphCRLiteral` lives in compiler concerns; should be domain predicate.
- **Scattered organization.** `scope.go` is its own file; `deletion.go` is its own file; `gvkToGVR` lives in controller. `scope.go` and `deletion.go` overlap with `resourcekey.go` and `prune.go` respectively.

## Procedures

- **Reconcile loop.** `GraphReconciler.Reconcile` orchestrates compilation, walk, apply, prune, status. Same receiver carries cluster-access methods.
- **Cluster access.** API server ops, node handlers, prune, finalization all hang off `GraphReconciler`.
- **Per-reconcile parameter threading.** `(graph, watcher, name, namespace)` passed by value through 17 functions; callers re-derive name/namespace.
- **Teardown.** `delete.go` runs its own walk over graph instance state.
- **Prune.** `prune.go` runs a separate walk over candidates.
- **Compilation cache.** `graphcache.go` keys compiled artifacts by structural hash.
- **Apply hash.** `hash.go` annotates desired state with SSA hash.
- **CEL registration.** Repeated four times in compiler setup paths.
- **Ready/updated functions.** Two separate function builders.

## Properties

### P1: GraphReconciler carries 25+ methods spanning two concerns
A reader looking at `GraphReconciler` cannot tell which methods are orchestration and which are execution.

### P2: (graph, watcher, name, namespace) threaded through 17 functions
Same four parameters appear in 17 signatures at 5 call levels. Callees often call `graph.GetName()`/`.GetNamespace()` to re-derive what was already derivable.

### P3: Teardown and prune are separate ~400-line implementations
Despite 005-design saying teardown IS pruning, the two paths diverge in finalization handling.

### P4: Optimization residue persists in three files
`graphcache.go`, `hash.go`, `metrics.go` carry cache, apply-hash, metrics machinery the design holding pen says is deferred.

### P5: CEL env registration appears 4 times
Compiler setup repeats the registration pattern.

### P6: Ready and updated CEL functions are separate builders
Functionally parametrized; written separately.

### P7: scope.go, deletion.go are standalone files with overlapping concerns
`scope.go` overlaps with `resourcekey.go` (both about resource identity). `deletion.go` overlaps with `prune.go` (preflight checks belong with prune infrastructure).

### P8: gvkToGVR lives in controller
Utility for resource-key derivation; placement does not match its job.

### P9: forEach state is split across multiple types
`forEachState`, `forEachCarryForward` exist as separate types with overlapping fields.

### P10: nodeType parameter is threaded redundantly with node.Type()
Callers pass `nodeType` alongside the node from which it could be derived.

### P11: 11 condition-related symbols are exported
Condition types, finalization phase, watch events, CompiledGraph internals visible from outside the package.

### P12: namespace defaulting appears in 3 places
Three scattered copies of "if namespace empty, use default."

### P13: SSA patch and status subresource update are written separately at each call site
The same pattern repeats; helper does not exist.
