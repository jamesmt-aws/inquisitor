# Design (lifted from after-state of PR #203)

Source: 8 files at sha `1c67d4b`. Same scope.

## Architecture

- **Graph teardown.** Same trigger as pre, plus a new path: `ownerDeleting()` detects the owner's deletionTimestamp and self-deletes. ~20 lines of new production code in `controller.go`.
- **Lifecycle blocking via patch node.** RGD stdlib adds an `instanceLifecycle` patch node that places `experimental.kro.run/instance-lifecycle` finalizer on the Instance. Owner waits on the finalizer; Graph's teardown prunes the patch, releasing the finalizer via SSA field release.
- **Field release ordering.** Patch field release runs AFTER template deletion. Lifecycle finalizers cannot be released while managed resources still exist.
- **Composition.** The lifecycle coupling is expressed via existing primitives (`ownerReference`, `patch:` node, finalizer). Zero new API surface (no new spec fields, no new node types).

## Procedures

- **Reconcile loop.** Plus `ownerDeleting()` detection branch.
- **Teardown.** Prune order: templates first, then patch field releases, then own finalizer.
- **stdlib RGD.** Includes the `instanceLifecycle` patch node by default.

## Properties

### P1: Graph teardown triggered by own deletionTimestamp OR owner Terminating
`ownerDeleting()` extends the trigger surface.

### P2: Owner blocks on Graph teardown via finalizer
The patch node places a finalizer on the owner; pruning the patch releases it.

### P3: Owner-Graph race resolved by composition of K8s primitives
ownerReference (cascade) + patch finalizer (blocking) produces ordered teardown without new API.

### P4: Patch field release runs after template deletion
Lifecycle finalizers held until managed resources are gone.

### P5: No new spec fields, no new node types
The capability is added by composing existing primitives in the stdlib.
