# Circularity check

Here are two designs A and B and the union of their test suites. For each test, decide whether it (a) refers to externally-observable behavior the system must produce, or (b) pins implementation details that change between A and B. Report any tests in category (b) as candidates for rewriting. Flag any test that exists only in B's commit and pins behavior A would have failed; this is a retrofitted constraint and should be reviewed before being treated as a real preference.
