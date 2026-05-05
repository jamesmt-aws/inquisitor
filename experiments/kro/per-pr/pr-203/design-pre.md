# Design (lifted from before-state of PR #203)

Source: 8 files at sha `1c67d4b^`. Touched: controller, delete, stdlib, design docs, tests.

## Architecture

- **Graph teardown.** Triggered by user-initiated delete. Controller's finalizer drives teardown of managed resources, then releases its finalizer.
- **Owner-ref cascade.** A Graph instance can have an `ownerReference` to a parent resource. Standard K8s GC kicks in when the owner is deleted. Pre-state: the controller does not detect owner Terminating; it relies on the apiserver to issue a delete on the Graph.
- **Field release ordering.** During teardown, patch-node field releases run before template deletions.
- **Lifecycle blocking.** No mechanism for the Graph to block owner deletion while it cleans up managed resources.

## Procedures

- **Reconcile loop.** Detects own deletion via deletionTimestamp; runs teardown.
- **Teardown.** Prunes managed resources, then releases finalizer.
- **Patch-release ordering.** Releases patch-node fields before template deletes.

## Properties

### P1: Graph teardown is triggered by deletionTimestamp on the Graph
A user deleting the Graph drives the controller's teardown.

### P2: Owner cascade relies on K8s GC
Owner deletion eventually causes the Graph instance to be deleted via standard ownerReference cascade.

### P3: No blocking mechanism for owner-side waits
The owner cannot wait for the Graph's teardown to complete before its own deletion proceeds. Race: owner can be GC'd before the Graph's managed resources are cleaned.

### P4: Patch field release runs before template deletion
Lifecycle finalizers can be released while managed resources still exist.
