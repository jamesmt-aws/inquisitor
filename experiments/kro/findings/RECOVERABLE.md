# Recoverable: what survives the empirical disappointments

Earlier files argued that S1/S2/S3 "collapse to" or "replicate" Ellis's audit when run with active tenets, framing this as a defeat. That framing was wrong. Simpler doing approximately the same job 80% of the time is the value proposition, not a failure mode. This file is the corrected synthesis.

## Where the earlier framing was wrong

The claim was: with active tenets, S/C produces verdicts indistinguishable from Ellis's audit, so it adds no value beyond the audit.

Two errors:

1. **Verdicts are not actually indistinguishable.** On #190, Ellis's audit caught two shape-excess findings (`Reconcile()` cog:363, `WatchCoordinator` LCOM4:2) that S/C missed. S/C with active tenets caught nothing at the shape level because S/C reasons over design units (the optimization layer's components, named in 005), not over function/type metrics. The audit catches shape-level excess; S/C catches mandate-level excess. **They're a complementary pair, not equivalents.**

2. **Cost-of-running was treated as zero on both sides.** It isn't. Ellis's audit needs a working language-specific static analyzer (~6700 lines of Go source for the Inquisitor binary), nine calibrated metrics, a ~160-line audit prompt, and all design docs read in advance to build a concept map. S/C needs a lifted design, a preference set, and three short prompts (~3KB total). The two methods do not occupy the same point on the cost curve.

## Updated value proposition for S/C

S/C is the **cheaper-coarser** option in a complementary pair. The cases where it is the right tool:

- **Non-Go codebases.** Ellis's tool runs on Go AST. Languages without a running analyzer (any language without an inquisitor port — i.e., almost all of them) can use S/C.

- **PR-time review.** When the diff is in hand but the running analyzer isn't (no checked-out repo, no toolchain available, reviewer on a phone). Lift the design from the diff, apply the prompts.

- **Design-document review.** No compiled code to feed the tool. S/C operates on the design directly.

- **Quick pre-check.** Run S/C in seconds before deciding whether to pay for the full audit. Treat it as the cheap filter; reserve the audit for what S/C flags or for periodic deep cleaning.

- **Mandate-level excess specifically.** When the design over-claims relative to preferences, S/C catches it directly (the #190 optimization layer under minimal preferences). The audit JUSTIFIES it because the design at the time mandates it. Different question, different signal.

## Updated recoverable list

Ordered by what is strongest as forward-looking value:

1. **Shift detector** (`TENET_SHIFT_DETECTOR.md`). Forward-looking, novel signal, ~15-day lead time on kro's performance demotion. The mechanism (structural-conflict + accruing-bugs + pace-exceeds-reduction) is testable on other corpora. Neither the audit nor S/C can do this on their own; both operate on current state.

2. **Tenet derivation from commit history** (`TENETS.md`). Reading what a team has demonstrated they will pay complexity for, rather than what a stated principles doc says. A real work product distinct from design-doc analysis.

3. **S/C as the lightweight alternative** to Ellis's audit. Cheaper-coarser; useful where the audit doesn't run or isn't worth paying for. Complementary, not equivalent.

4. **S2 partition-match on lifted designs.** Catches implicit-tenet violations the audit can't, because the audit requires explicit design citation. The #220 walkstate split is the example: architecture-matches-import-graph was an active tenet but not stated in design 005's text. S2 reads the partition mismatch directly from the design and code.

5. **Design-lift methodology** ("code is a specific design"). Enables items 3 and 4 without running a language-specific tool. The methodological framing earns its keep regardless of empirical results because it makes the analyses portable across resolutions and languages.

## What did not earn keep

- **S1/S2/S3 with a fixed minimal floor.** Predetermined verdicts. Don't use this configuration.

- **C1/C2/C3 in the one configuration tested** (#190 vs #245 with a stacked-deck preference set). All three returned −1 because the preference set was chosen knowing #245 was simpler. Run C on a non-stacked deck and the verdict could be informative; that experiment hasn't been done.

- **REGRET_PREDICTOR.md's 75% TPR / 0% FPR claim** as a property of S1/S2/S3. The result was real but came from the floor, not the metrics. REGRET_PREDICTOR_V2.md corrected this with active tenets.

## How to read the earlier files

- `REGRET_PREDICTOR.md`: the headline numbers were a property of the minimal floor. Treat as descriptive of "what minimal-floor S1/S2/S3 says on this corpus" rather than evidence that the metrics work.

- `COMPARISON.md`, `SEQUENCING.md`: the framings of "S/C vs audit" implicitly treated S/C as a less-mechanical replication of the audit. Read with this file's correction: S/C and the audit catch different things; both are useful in different conditions.

- `REGRET_PREDICTOR_V2.md`: the 11-of-12 keep-at-active-tenets result is the substantive claim. Stands.

- `TENETS.md`, `TENET_SHIFT_DETECTOR.md`, `S_ACTIVE_TENETS_AT_190.md`: stand as written.

## What this changes about next steps

The next experiment most worth running is no longer "validate S1/S2/S3" (the tenet question is settled — verdicts depend on preferences, the floor was wrong). The shift detector and tenet derivation are the load-bearing forward-looking pieces.

For S/C specifically, the test that would actually earn it keep is **applying it to a non-Go codebase or a non-Ellis project**, where the audit is unavailable. If S/C catches mandate-level excess that the codebase's team would agree with, it is doing useful work as a lightweight standalone tool. The kro corpus cannot answer this because Ellis's audit covers Go specifically.

The Recursive Language Model direction (Zhang/Kraska/Khattab 2026) is the natural fit for the shift detector and tenet derivation — both are operations over a long history (232 commits + design docs + temporal context), exactly the regime RLMs are designed for. The genuine connection is at the **history-traversal** level, not at the metric level.
