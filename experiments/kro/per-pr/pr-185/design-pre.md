# Design (lifted from before-state of PR #185)

Source: 17 files at sha `8a6e2e9^`, scope `experimental/controller/`.

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
  shapes lower to `Node.ForEach` of type `map[string]string`. A
  validation pass enforces at most one entry in the map; multi-variable
  cross-product expansion is rejected at parse time with an explicit
  error.
- **Evaluation.** A walk over the DAG produces an evaluator per node;
  the evaluator carries a CEL scope, the previous reconcile's per-item
  state for any forEach nodes upstream, and identity caches.
- **Apply.** Each evaluated node lowers to one or more SSA Patch
  operations. A `reconcileState` value tracks counts, errors, and
  derived status across the walk. The state struct contains a
  `nodeCount` field set during walk traversal but not consumed by any
  status derivation function.
- **Per-item forEach.** `reconcileForEach` iterates the `Node.ForEach`
  map (always one entry by validation), evaluates the collection,
  builds an identity → item map, sorts identities for stable order,
  and processes each item. A `hasPerItemGate` flag computed at the
  start of the function determines whether the `propagateWhen` gate is
  evaluated per item; the same flag is re-declared inside the
  outer `for varName, collectionExpr := range node.ForEach` loop, with
  the same expression and same value, shadowing the outer
  declaration.
- **Status / metrics.** `NodeState` is an exported iota in `dag.go`
  with eight values (Ready, NotReady, Pending, Excluded, Blocked,
  Error, Conflict, SystemError). `metrics.go` carries a
  `nodeStateLabels` slice used as Prometheus label values. The two
  must be kept in sync by hand; a code comment notes the requirement
  but no run-time or build-time assertion exists.

## Procedures

- **Graph parsing.** `parseNodeList` reads YAML, dispatches on the
  shape of `forEach` (map vs array), calls `parseForEachMap` for the
  flat-map case, builds a `map[string]string`, then validates
  cardinality (must be exactly one) after the map is built.
- **forEach normalization.** `parseForEachMap` extracts string values
  from a `map[string]any`, returning an error if any value is
  non-string. Called from the flat-map branch of `parseNodeList`.
- **Identifier collection.** `GraphSpec.AllIdentifiers` and
  `AllExpressions` iterate `node.ForEach` as a map to collect variable
  names and collection expressions for downstream validation and
  static analysis.
- **forEach evaluation.** `reconcileForEach` iterates
  `node.ForEach` as a map (one entry post-validation), evaluates the
  collection, diffs against previous items, applies a per-item
  `propagateWhen` gate when configured.
- **forEach state snapshot.** `evaluator.snapshotFor` iterates
  `node.ForEach` to copy per-variable cache state for the worker
  evaluator.
- **Node state metrics emission.** `updateNodeStateMetrics` reads
  `nodeStateLabels` to emit one gauge sample per state per node.
- **Reconcile state.** `reconcileState` tracks `nodeCount` (set during
  walk, never read) plus other counters used for status conditions.

## Properties

### P1: forEach map cardinality validated at parse time
Input: `Graph` with `forEach: {a: "${expr1}", b: "${expr2}"}`.
Expected: parse error `forEach must have exactly one variable (got 2);
multi-variable cross-product expansion is not supported`.

### P2: forEach accepts both YAML shapes
Input: `forEach: {region: "${regions}"}` or
`forEach: [{region: "${regions}"}]`. Expected: both lower to a single-
entry `map[string]string` with key `region`.

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
Expected: identity sort yields the same iteration order; per-item
gate halts at the same position.

### P8: identity-based item diff retains state
Input: collection with one item changed and one item unchanged
(by identity hash). Expected: changed item re-evaluated; unchanged
item retains previous applied state and `__ready` stamp.

### P9: NodeState has eight exported values
The exported iota in `dag.go` has values Ready, NotReady, Pending,
Excluded, Blocked, Error, Conflict, SystemError.

### P10: nodeStateLabels matches NodeState exported values
The `nodeStateLabels` slice in `metrics.go` has the same eight string
labels as the exported `NodeState` constants. Maintenance is by
inspection of a code comment; no run-time check.

### P11: reconcileState carries a nodeCount field
The struct field exists and is set during walk traversal. No
status-derivation function reads it.

### P12: hasPerItemGate is a boolean derived from PropagateWhen length
`hasPerItemGate := len(node.PropagateWhen) > 0`. The expression is
evaluated at the top of `reconcileForEach` and again inside the
forEach iteration loop with the same operand and the same result.

### P13: forEach iteration is over a map
The dispatch `for varName, collectionExpr := range node.ForEach`
appears in `reconcileForEach`, `snapshotFor`, `AllIdentifiers`, and
`AllExpressions`. The map always has exactly one entry by parse-time
validation; iteration order is therefore singleton but the loop shape
admits multiple entries by type.
