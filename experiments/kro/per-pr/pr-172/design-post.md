# Design (lifted from after-state of PR #172)

Source: 23 files at sha `fbd29c8`, same scope.

## Purpose

Identical to design-pre. No behavioral changes.

## Architecture

- **Node typing.** Identical to design-pre.
- **Internal vocabulary.** Comments, log field names, and test helper functions all use the canonical vocabulary that matches the type-system names: `template` and `patch`. No "Own" or "Contribute" remains in the package's prose surface.
- **Other architecture.** Same as design-pre.

## Procedures

- **Node-type dispatch.** Identical to design-pre.
- **Logging.** Log fields emit `templateNode`, `patchNode`, etc., matching the type-system names. A grep for `template` reaches the type, the keyword, and the log field; a grep for `patch` does the same.
- **Test helpers.** `templateNode()` and `patchNode()` wrap node construction. Older `ownNode()`/`contributeNode()` names removed.

## Properties

### P1: NodeType has five exported values
Same as design-pre.

### P2: User-facing keywords match the type names
Same as design-pre.

### P3: Internal vocabulary matches canonical names
Comments, log field keys, and test helper names all use template/patch. A reader searching for either term reaches every relevant surface.

### P4: Reconciler dispatches on `node.Type()`
Same as design-pre.

### P5: Test helpers exist for each public node shape
`templateNode()` and `patchNode()` exist in test packages.

### P6: Log field naming is consistent across grep contexts
A reader searching for `template` reaches the type, the keyword, the log field, the test helper, and the comments. Same for `patch`.
