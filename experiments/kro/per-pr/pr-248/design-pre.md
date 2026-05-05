# Design (lifted from before-state of PR #248)

Source: 3 files at sha `6db313f^`. Touched files: `chart-crds/templates/graphs.yaml`, `chart-crds/templates/graphrevisions.yaml`, `test/e2e/correctness_test.go`.

## Purpose

The kro experimental Graph and GraphRevision CRDs accept user-submitted YAML. Pre-state CRDs use `x-kubernetes-preserve-unknown-fields` at the root of `spec`, so the apiserver admits any well-formed YAML that names the right kind. Validation of node id format, required fields, and array shapes happens at controller reconcile time and surfaces as a `DeclarationError` condition on the Graph status.

## Architecture

- **CRD schema.** `spec` carries `x-kubernetes-preserve-unknown-fields`. No structural shape on `spec.nodes`, `node.id`, `node.template`, `node.readyWhen`, or `node.lifecycle.apply`.
- **Controller validation.** Parser runs structural checks during `compileRevision`. Errors set `Compiled: False` with reason `DeclarationError`.
- **Status subresource.** Untyped condition list.

## Procedures

- **Apiserver admission.** Accepts any YAML that parses against the loose CRD.
- **Controller-time validation.** Parser checks node id format (regex), required fields, array shapes, condition expression types.
- **Error surfacing.** `Compiled: False` with `DeclarationError` reason on the Graph status.

## Properties

### P1: Graph and GraphRevision CRDs accept any YAML matching the kind
Apiserver does not enforce shape; controller is sole validator.

### P2: Invalid id (e.g., hyphenated) reaches the controller and fails compile
A user submitting `id: my-node` gets the Graph created on the API server, then sees `Compiled: False` after the controller reconciles.

### P3: DeclarationError surfaces on Graph status
A user inspecting `kubectl get graph` sees the validation failure on the Compiled condition.

### P4: Test waits for status condition to learn that validation failed
E2E tests poll `Compiled` condition with timeout up to 30s.
