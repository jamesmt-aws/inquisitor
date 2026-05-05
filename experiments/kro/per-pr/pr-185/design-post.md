# Design (lifted from after-state of PR #185)

Source: 17 files at sha `8a6e2e9`, scope `experimental/controller/`.

## Purpose

The kro experimental graph controller compiles a user-declared `Graph`
spec into a directed acyclic graph of typed nodes (resource creation,
references, watches, definitions), evaluates each node against a CEL
scope built from upstream nodes, applies the resulting Kubernetes
objects via Server-Side Apply, and tracks per-node state across
reconciles. Nodes may carry a `forEach` block that expands the node
into one child per item in a CEL-evaluated collection, with per-item
state, identity-based diffing, and an optional `propagateWhen` gate
that halts expansion when a condition first goes false.

## Architecture

- **Compilation.** `GraphSpec` is parsed from unstructured YAML into a
  list of `Node` values plus a DAG. Parsing handles two YAML shapes
  for `forEach`: a flat map (`forEach: {region: "${...}"}`) and an
  array of single-key maps (`forEach: [{region: "${...}"}]`). Both
  shapes are validated to contain exactly one variable binding and
  lower to `Node.ForEach` of type `*ForEachBinding`, a struct with
  `VarName` and `Expr` fields. Multi-variable cross-product expansion
  is rejected at parse time before the binding is constructed.
- **Evaluation.** A walk over the DAG produces an evaluator per node;
  the evaluator carries a CEL scope, the previous reconcile's per-item
  state for any forEach nodes upstream, and identity caches.
- **Apply.** Each evaluated node lowers to one or more SSA Patch
  operations. A `reconcileState` value tracks errors and derived
  status across the walk.
- **Per-item forEach.** `reconcileForEach` reads `Node.ForEach.VarName`
  and `Node.ForEach.Expr` directly without iteration. A
  `hasPerItemGate` flag computed once at the top of the function
  controls the `propagateWhen` gate evaluated per item.
- **Status / metrics.** `NodeState` is an exported iota in `dag.go`
  with eight values (Ready, NotReady, Pending, Excluded, Blocked,
  Error, Conflict, SystemError) followed by an unexported sentinel
  `_nodeStateCount` that holds the count for use in compile- and
  init-time assertions. `metrics.go` carries a `nodeStateLabels`
  slice and an `init()` that panics at startup if
  `len(nodeStateLabels) != int(_nodeStateCount) - 1`.

## Procedures

- **Graph parsing.** `parseNodeList` reads YAML, dispatches on the
  shape of `forEach` (map vs array), validates exactly-one cardinality
  inline in each branch (returning an error before any binding is
  built), then constructs a single `*ForEachBinding`.
- **Identifier collection.** `GraphSpec.AllIdentifiers` and
  `AllExpressions` read `node.ForEach.VarName` and `node.ForEach.Expr`
  directly when the binding is non-nil; no map iteration.
- **forEach evaluation.** `reconcileForEach` reads `node.ForEach.VarName`
  and `node.ForEach.Expr` directly; no outer iteration loop.
  `hasPerItemGate` is computed once.
- **forEach state snapshot.** `evaluator.snapshotFor` reads
  `node.ForEach.VarName` directly to derive the cache key.
- **Node state count assertion.** An `init()` function in `metrics.go`
  panics with a diagnostic message if the length of `nodeStateLabels`
  does not equal `int(_nodeStateCount) - 1`. The assertion fires at
  process startup, before any reconcile begins.
- **Node state metrics emission.** `updateNodeStateMetrics` reads
  `nodeStateLabels` to emit one gauge sample per state per node.
- **Reconcile state.** `reconcileState` tracks errors and counters
  used for status conditions.

## Properties

### P1: forEach cardinality validated at parse time
Input: `Graph` with `forEach: {a: "${expr1}", b: "${expr2}"}`.
Expected: parse error `forEach must have exactly one variable (got 2);
multi-variable cross-product expansion is not supported`.

### P2: forEach accepts both YAML shapes
Input: `forEach: {region: "${regions}"}` or
`forEach: [{region: "${regions}"}]`. Expected: both lower to a
`*ForEachBinding` with `VarName: "region"` and the corresponding
`Expr`.

### P3: empty forEach is rejected
Input: `forEach: {}` or `forEach: []`. Expected: parse error
`forEach must have at least one dimension`.

### P4: forEach value must be string
Input: `forEach: {region: 5}`. Expected: parse error `forEach
variable "region" value must be a string, got int`.

### P5: forEach variable cannot collide with a node ID
Input: a Graph with node ID `region` and another node with
`forEach: {region: "${...}"}`. Expected: parse error citing the
collision.

### P6: per-item propagateWhen halts expansion
Input: a forEach node with `propagateWhen: ["${index < 3}"]` over a
five-item collection. Expected: the first three items are processed
and stamped; the last two carry forward previous state without re-
evaluation; the gate is evaluated per item against the partially-built
collection.

### P7: stable item order across reconciles
Input: same collection re-emitted in a different order by an informer.
Expected: identity sort yields the same iteration order.

### P8: identity-based item diff retains state
Input: collection with one item changed and one item unchanged.
Expected: changed item re-evaluated; unchanged item retains previous
applied state and `__ready` stamp.

### P9: NodeState has eight exported values plus one unexported sentinel
The exported iota in `dag.go` has values Ready, NotReady, Pending,
Excluded, Blocked, Error, Conflict, SystemError, followed by
`_nodeStateCount`. The sentinel is unexported and serves as a
compile-time count of the iota block.

### P10: nodeStateLabels is enforced at startup to match NodeState
Input: a developer adds a new exported `NodeState` value before
`_nodeStateCount` without adding a label to `nodeStateLabels`.
Expected: process startup panics with a diagnostic message naming
both counts and the file to update. The check runs in an `init()`
function in `metrics.go`.

### P11: ForEach is a single-dimension binding by type
The field `Node.ForEach` has type `*ForEachBinding`, not a map. A
caller cannot construct a multi-variable forEach; the type forecloses
the case the parser used to reject at runtime.

### P12: hasPerItemGate is computed once per forEach reconcile
`hasPerItemGate := len(node.PropagateWhen) > 0` appears once in
`reconcileForEach`, at the top of the function. There is no inner
declaration of the same name.
