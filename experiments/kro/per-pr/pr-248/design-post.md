# Design (lifted from after-state of PR #248)

Source: 3 files at sha `6db313f`. Same scope.

## Purpose

Same as design-pre. After this PR, the apiserver enforces structural shape on Graph and GraphRevision CRDs at admission time. The controller still validates the cases the structural schema cannot express (mutual exclusivity of body keywords, unique node IDs, per-keyword shape rules).

## Architecture

- **CRD schema.** Typed structural schema. `spec.nodes` is `required`, max 128. `node.id` is `required`, pattern `^[a-zA-Z_][a-zA-Z0-9_]*$`. Body keywords (`template`, `patch`, `ref`, `watch`, `def`, `forEach`) are named properties with `x-kubernetes-preserve-unknown-fields` at the value (mixed string/map). Conditions are `array of string`, max 32. `lifecycle.apply` is enum `[Force]`. Status subresource has typed conditions list with `x-kubernetes-list-type: map` keyed by `type`.
- **Controller validation.** Parser still runs the cases CEL/structural cannot express: mutual exclusivity, unique IDs, per-keyword shape requirements (`template requires apiVersion+kind` etc.).
- **Status surfacing.** Same as pre. Schema-rejected Graphs never reach the controller, so `DeclarationError` on Compiled is reserved for parser-time errors.

## Procedures

- **Apiserver admission.** Rejects malformed YAML at admission time (`Invalid` API error). Schema enforces id pattern, required fields, array shapes, condition types, `lifecycle.apply` enum.
- **Controller-time validation.** Reduced surface; only the residual cases.
- **Error surfacing.** Two paths: API admission `Invalid` vs `Compiled: False` for parser-only errors.

## Properties

### P1: CRDs enforce structural shape at admission
Apiserver rejects YAML missing required fields or violating shape constraints.

### P2: Invalid id (e.g., hyphenated) is rejected at admission with an Invalid API error
A user submitting `id: my-node` receives an immediate `kubectl` error with the violated pattern; the Graph is never created.

### P3: DeclarationError still surfaces on Graph status for parser-only errors
Cases the schema cannot enforce (duplicate IDs, mutual exclusivity violations, per-keyword shape requirements) still fail at controller time.

### P4: Test expects API-server rejection for schema-enforceable errors
`require.True(t, apierrors.IsInvalid(err))` replaces the polling-for-condition pattern for cases the schema covers.

### P5: Two distinct error surfaces exist
A user encountering invalid id sees an immediate API error; a user with duplicate ids sees a later status condition. The two paths are not interchangeable.
