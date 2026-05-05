# Methods in sequence: S, C, Inquisitor on (#190, #245)

A and B share a system. A is post-#190 (the regret state, optimization machinery added). B is post-#245 (the stripped state). #245 is the explicit walk-back of the optimization layer #190 added.

The experiment runs the absolute simplicity prompts (S1, S2, S3), the comparison prompts (C1, C2, C3), and Inquisitor's mechanical findings, on each state. Then proposes a sequence and reports what each step adds.

## Inquisitor (mechanical, both states)

| state | packages | functions | LCOM4>1 | cog>15 |
|---|---:|---:|---:|---:|
| #190 (A) | 1 | 439 | 4 types | **30+ functions, top: cog:363** |
| #245 (B) | 5 | 457 | 4 types | **0 functions** |

The `cog>15` collapse is total. At #190 the `Reconcile()` function alone has cog:363 in 832 lines; thirty other functions exceed the threshold. At #245, every function in the analyzed packages is under cog:15. The strip eliminated cognitive-complexity violations entirely, by Ellis's own tool's threshold. LCOM4 violations persist (different types, mostly in `watches/` package), which is shape excess unrelated to the optimization layer.

## S1, S2, S3 absolute (state A = #190)

From REGRET_PREDICTOR.md:
- **S1 flag**: the cache layer, content-addressed sharing, evaluation cache snapshots are deletable under stated preferences (correctness, observable behavior, public API stability). Citation: full re-evaluation preserves correctness; the optimization layer serves no stated preference.
- **S2 flag**: cache hit/miss, dirty/clean, three-hash-layer cells are not in the input partition the preferences require.
- **S3 flag**: 2568 lines of optimization code at #190 with no design holding pen yet (007 doesn't exist). Lower-resolution description does not earn its keep against the higher-resolution one.

## S1, S2, S3 absolute (state B = #245)

- **S1 keep**: remaining units (sequential walk, apply-hash for SSA write elision, full DAG walk per reconcile) all serve correctness or public API stability. Citation: nothing in B is deletable under preferences without losing a preference value.
- **S2 keep**: the simple sequential loop has one cell per node per reconcile. Input partition requires one cell per node. Match.
- **S3 keep**: B's design split (core 005-reconciliation + holding-pen 007-optimizations) compresses the code efficiently. New structure (the split itself) earns its keep against the optimization claims it absorbs into the deferred-work doc.

## C1, C2, C3 comparison on (A, B), test suite = union

Both A and B pass the kro e2e + compat suite. Union test suite is approximately the intersection here; the suite is roughly stable across the two commits with minor differences in optimization-asserting tests (#245's commit message notes one test relaxed from "evaluation skipped" to "no API write," but the correctness contract is preserved on both sides).

- **C1 = −1** (B more deletion-minimal). Citation: A carries the optimization layer (cache, hash machinery, worker dispatch) as removable units under the preferences both states satisfy; B has already removed them. B's design is local-minimum-deletion-stable; A's is not.
- **C2 = −1** (B's partition closer to input partition). Citation: A's branching partition has Path 1 / Path 2 / Path 3 cells, three hash-layer cells, and cache-hit/miss cells that the input partition (preferences-required) does not distinguish; B collapses these into a single sequential cell per node.
- **C3 = −1** (B compresses more). Citation: A's design and code each independently carry the optimization claim (the implementation surface mirrors design 005's mandate); B's design splits core and optimization into 005 + 007, so the lower-resolution architectural description compresses the implementation more efficiently per byte.

All three −1. **B Pareto-dominates A.** A is removed from the frontier. The team's actual choice (strip A, keep B) matches the framework's verdict.

## Ellis's audit (design-anchored, at each state)

- **Audit at #190 with #190's design (which mandates optimization in 005)**: mostly JUSTIFIED. Two EXCESS findings on shape — the 832-line `Reconcile()` and the `WatchCoordinator` LCOM4:2 split. Mandate-level excess is invisible because the design demands the optimization.
- **Audit at #245 with #245's design (007-optimizations split, mandates simplicity)**: 4 LCOM4 candidates flagged by tool; mix of EXCESS (e.g., `WatchManager` LCOM4 split appears unrelated to design concepts) and JUSTIFIED (e.g., `Node` LCOM4 split has `HasStatusSubresource` cluster traceable to 003-ownership). Zero cog>15 candidates means his audit has nothing to do at the function level.

The audit tracks the design. When the design contracts (between #190 and #245), so does what counts as JUSTIFIED.

## Sequence proposal

Cheapest-to-most-expensive, with each step adding signal the previous did not:

1. **Inquisitor (cheap, mechanical, deterministic)**. Produces a list of candidates with research-backed thresholds. No design or preferences required. Output: cog>15 functions, LCOM4>1 types, CBO>5, dependency cycles, etc.

2. **C1, C2, C3 against an alternative (cheap, comparative, no calibration needed)**. If the user has an alternative implementation (a different commit, a sibling branch, a generated baseline), run the three comparisons. Pareto-dominated states are removed; incomparable states stay on the frontier. No need for absolute calibration — the comparison is local. Output: which alternative is on the frontier.

3. **S1, S2, S3 against minimal preferences (anchors against the floor)**. Run the absolute prompts with a minimal preference set (correctness, observable behavior, public API stability — not performance). Anything that exceeds the floor is suspicious. This catches mandate-level excess that the design at the time may justify but the floor does not. Output: design-level units, partition cells, MDL ratio.

4. **Ellis's audit against the current design (anchors against the ceiling)**. Apply his prompt with the design as authority. Resolves whether each candidate from step 1 is JUSTIFIED, EXCESS, or HERESY. Mandate-level excess only surfaces if the design has already contracted. Output: per-candidate verdicts.

The sequence works on either an absolute artifact (run only steps 1, 3, 4) or a comparative pair (run steps 1, 2, 3, 4). Step 2 requires an alternative; the others do not.

## What each step added on (A, B)

| step | new signal beyond previous step |
|---|---|
| 1. Inquisitor | A has 30+ cog>15 violations; B has zero. LCOM4 patterns differ. Mechanical, no judgment. |
| 2. C1, C2, C3 on (A, B) | All −1 → B Pareto-dominates A. The framework agrees with the team's actual decision to strip. |
| 3. S1, S2, S3 absolute | Names *which units* (cache layer, hash machinery), *which cells* (Path 1/2/3, three-hash-layer), *which compression* (007 split as the MDL move). C said "B better"; S says *why*. |
| 4. Ellis's audit | At #190's design, the optimization is JUSTIFIED. At #245's design, the same code would be EXCESS. The audit's verdict shifts only when the design contracts; the regret is invisible to the audit at #190 commit time. |

## Honesty

The C verdicts are mine, on a pair I expect to come out −1 across the board. The bias risk is the same as in earlier sections: I am the prompt author and the verdict producer. A blind run by a different agent on the same designs would test reproducibility. The C prompts in the doc are short — a reproducibility check across runners is cheap and worth doing.

The Inquisitor result (cog>15 collapse from 30+ to 0) is mechanical and not under self-evaluation risk. That's the strongest single piece of evidence in the comparison.

## What the sequence cannot do

- It cannot predict regret in advance for additions that genuinely serve preferences at commit time but get supplanted later (#58 metrics, #17 revision conditions, #224 DepositTrigger from REGRET_PREDICTOR.md). Steps 3 and 4 both require either a minimal preference set or a contracted design to surface the issue; neither is available at the moment of regret-prone addition.

- It cannot tell you which preference set is the right one. Picking "minimal" preferences (step 3) is itself a design choice. A team that includes performance in the floor would never flag the optimization layer at A; a team that excludes it would always flag it. The sequence runs the test at whatever floor the user picks; calibrating the floor is upstream of the framework.

## Outputs

- This file (`SEQUENCING.md`).
- `inquisitor-pr190.txt`, `inquisitor-pr245.txt`: raw tool outputs.
- `COMPARISON.md`: prior side-by-side on #190 alone (this file generalizes).
- `REGRET_PREDICTOR.md`: prior matched-controls run with S1/S2/S3 only.
