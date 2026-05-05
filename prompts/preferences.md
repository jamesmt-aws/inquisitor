# Preferences (preamble; prepend to every per-PR prompt)

Treat these as the scoring axes. None are thresholded; lower is worse on each.

1. **Correctness.** Graph reconciliation converges to declared state for inputs the design distinguishes.
2. **Observable behavior.** Status conditions, events, finalizer ordering, and CRD-visible state are consistent across the change.
3. **Public API stability.** Graph DSL surface (CEL expressions, field paths, forEach semantics) and CRD field semantics are not silently changed.

Do not invent additional preferences. If a procedure or property in the design serves none of these, say so.
