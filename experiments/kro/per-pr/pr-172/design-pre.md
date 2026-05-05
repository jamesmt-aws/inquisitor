# Design (lifted from before-state of PR #172)

Source: 23 files at sha `fbd29c8^`, scope `experimental/controller/` plus tests and watches.

## Purpose

The kro experimental graph controller compiles a user-declared `Graph` spec into a DAG of typed nodes and reconciles the resulting Kubernetes objects. Each node carries a `NodeType` value that determines whether the node creates a resource (`NodeTypeTemplate`), patches an existing one (`NodeTypePatch`), references one for read access, or watches a collection.

## Architecture

- **Node typing.** `NodeType` is an exported enum with values `NodeTypeTemplate`, `NodeTypePatch`, `NodeTypeRef`, `NodeTypeWatch`, `NodeTypeDef`. Public-facing keywords match: `template:`, `patch:`, `ref:`, `watch:`, `def:`.
- **Internal vocabulary.** Comments, log field names (`"ownNode"`, `"contributeNode"`), and test helper functions (`ownNode()`, `contributeNode()`) use a different vocabulary: "Own" for what the type system calls Template, "Contribute" for Patch. The mapping is one-to-one but undocumented.
- **Reconciliation loop, watch routing, prune/delete, finalization.** Same as the post-state; behavior unchanged by this PR.

## Procedures

- **Node-type dispatch.** Reconciler branches on `node.Type()` to pick the right apply path: template creates the resource fresh on each reconcile (force-applied); patch merges into an existing object owned by another controller. Implementation uses the canonical vocabulary at the type level.
- **Logging.** Log fields and event reasons emit string keys derived from internal vocabulary (`ownNode`, `contributeNode`).
- **Test helpers.** `ownNode()` and `contributeNode()` wrap node construction in test code with the older vocabulary.

## Properties

### P1: NodeType has five exported values
`NodeTypeTemplate`, `NodeTypePatch`, `NodeTypeRef`, `NodeTypeWatch`, `NodeTypeDef`.

### P2: User-facing keywords match the type names
The YAML keywords are `template:` and `patch:`; the corresponding `NodeType` values are `NodeTypeTemplate` and `NodeTypePatch`.

### P3: Internal vocabulary diverges from canonical names
Comments, log field keys, and test helper names use "Own" and "Contribute" interchangeably with template/patch. There is no run-time check that the two vocabularies align; a developer reading code is required to learn the mapping.

### P4: Reconciler dispatches on `node.Type()`
The dispatch is at the type level using `NodeType` enum constants, not on string-matched comments.

### P5: Test helpers exist for each public node shape
`ownNode()` and `contributeNode()` exist in test packages; new test files import the existing helpers and follow their naming.

### P6: Log field naming is unstable across grep contexts
A reader searching for `template` finds production code; a reader searching for `Own` finds comments and log fields covering the same concept. The two sets do not overlap.
