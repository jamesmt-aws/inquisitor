# Design lift (run twice per PR: once on before/, once on after/)

You are reconstructing the design document that underlies a running implementation. You receive a set of Go source files from the kro controller, a Kubernetes operator that compiles a graph of resources and reconciles them. The files are the touched files at one git revision; treat them as the artifact under analysis. There is no tenets file. The design is what the code itself implies.

Produce `design.md` that:

- States the module's **Purpose** in one paragraph.
- Describes the **Architecture**: graph compilation, node evaluation, walk algorithm, watch dispatch, propagation, forEach expansion, prune and delete, finalization. Cover only the parts the input files exercise. Do not invent structure you cannot see.
- Lists named **Procedures** at the level of "graph compilation," "node evaluation," "watch dispatch," "forEach expansion," "propagation walk," "prune candidate selection," "hash-gated apply." Not at the level of individual Go functions.
- Produces numbered **Properties** `### P1: ...` through `### PN: ...`, each with a concrete scenario, input, expected behavior, or invariant that an implementer could turn into a unit or e2e test. Aim for 10-15 properties.

Constraints:

- Be **grounded in the code**. Only include procedures and properties that correspond to code paths you can point to. Cite function or type names where helpful.
- Do not include properties for behavior the code does not implement, even if a stronger principle might suggest them. The design's job is to describe what is, not what should be.
- If a referenced concept is defined outside the input files, treat it as opaque and describe its role at the boundary, not its internals.

Output `design.md` only.
