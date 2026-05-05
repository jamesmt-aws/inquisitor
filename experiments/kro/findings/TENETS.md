# Tenets and the story of the kro branch

Earlier experiments asked: given a fixed minimal preference set (correctness, observable behavior, public API stability), do the metrics flag the right work? The answer was always yes by construction. The minimal set excluded performance, so any optimization layer flagged. The framework wasn't measuring; it was tautologizing the floor.

The honest question is upstream: **which preferences has this team actually demonstrated they will pay complexity for?** Read those out of the commit history, then ask whether each substantial addition served them.

## Tenets the team has demonstrated

Each derived from sustained behavior across the 232 commits, not from a stated principles doc (none exists in the repo).

1. **Correctness over performance.** Fix-class commits dominate the log. When optimization machinery caused flakes (#82 TestResourcePruning, #84 graph update sites, #228 forEach prune flake), the team chose the slower deterministic path. Design language: "Deterministic errors are not retried — same inputs produce the same failure."

2. **Design as authority.** The phrase "reconcile X against Y" appears in 7 commit subjects. The audit framing in `inquisitor/SKILL.md` ("the implementation is guilty until proven justified") generalizes the practice. The design document is canonical; code is on trial.

3. **One name per concept.** Eight rename commits: Own/Contribute → template/patch (#172), TemplateShape → Reference (#66), Compiled condition reasons (#88), skeletonApply → releaseApply (#140), Singleton node IDs (#135), and several more. Mechanical work, sustained over months.

4. **Determinism and reproducibility.** Deflake commits as a category: #36 eliminates time.Sleep, #82 and #84 add conflict retry, #121 deflakes forEach reordering, #228 replaces append-only slice with map last-writer-wins, #134 declaration-order-stable topological sort. The team treats flakes as bugs in the implementation, not noise to tolerate.

5. **Composition over new primitives.** #203's framing is the cleanest statement: "Zero new API surface — no new spec fields, no new node types. The lifecycle coupling is expressed entirely through existing Graph primitives." The team prefers reusing existing keywords and stdlib pieces over expanding the surface.

6. **Architecture should be legible from the import graph.** #261 walks back #220 because the original split put reconcile-time types in a compile-time package — "the architecture is now legible from the import graph: dag/ = compile-time, controller/ = reconcile-time." This is a tenet the team holds even against their own prior decisions.

7. **Tests assert externally observable contracts.** #177 promotes unit tests to e2e with status-condition assertions; replaces internal-API tests. The shift signals the team would rather assert public contracts than internal mechanics. Tests that pin implementation are bugs.

8. **Implement core before optimization, defer performance until the core is stable.** This tenet did not exist for most of the project. It emerged in #244 when 007-optimizations.md was split out: "Implement the core designs first; add these optimizations once the core is stable and profiled." Before #244, performance was a stated tenet of design 005. After #244, it is explicitly deferred.

## The story of the branch in five phases

**Phase 1: Bootstrap (March 4 – March 15).** Design docs written first. Initial implementation (#10) lands ~1300 lines matching designs 1-4. Tenet established at the start: design is authority. The early commits (#11 restoring docs, #12 fixing correctness bugs found during reconciliation) signal the team will not let code drift from design.

**Phase 2: Feature buildout and the rise of performance (March 15 – April 15).** Heavy `add` and `implement` work. Drift timers (#58), trigger-scoped walks (#55), worker dispatch (#53), content-addressed graph sharing (#25), section-scoped hashing (#24), the type cache (#190), forEach incremental diff (#192), custom hashDesiredState (#166), perf rewrites (#93). Design 005 of the era includes "performance is structural — work is proportional to change, not to DAG size." Performance was a tenet at this point. Each addition served it.

**Phase 3: Reckoning (mid to late April).** Bug fixes accumulate around the optimization layer. #213 fixes propagation bugs that were "masked by 2s resync interval" — the fix is removing the resync override (#214). #228 fixes the forEach prune flake by replacing append-only slice with per-node map. #224 fixes ReadinessDependents propagation, cluster-scoped routing, stale dispatch. The pattern: optimization mechanisms produce subtle correctness bugs that only surface as flakes. Tenet 1 (correctness) and tenet 4 (determinism) keep finding cases where the performance tenet was undermining them.

**Phase 4: Design contraction (April 30 – early May).** The decisive moment is #244: design 005 is split. Optimization claims move to 007-optimizations.md, which opens with "Future Work — Do Not Implement." Performance is no longer a tenet at the design level. Within 24 hours, #245 strips the reconciliation hot path back to the core algorithm (-2443 lines). #247 strips remaining optimization infrastructure (-1522). #249 strips more (-1332). #253 strips dead code that survived the first three passes (-1032). The team removes ~6300 lines in five days. None of the stripped code was incorrect — it served a tenet that no longer holds.

**Phase 5: Steady state (May).** Tenets stabilize. Maintenance simplifications: #258 reorganizes code against architecture, #261 corrects a file-boundary mistake, #257 adds observedGeneration as a small correctness improvement. The branch settles into a rhythm: small additions where tenets are clear, occasional cleanup when the implementation drifts.

## When was complexity worth it?

Apply the tenets to the regret-paired commits.

**#190 type cache, structural caching (+2568 lines, stripped by #245/#249/#253).** At commit time, served the active performance tenet. Worth it under the tenets of the time. The regret was not that #190 was wrong — it was that the performance tenet itself was unstable. The conflict with correctness/determinism was already implicit; it just hadn't been priced in yet.

**#220 walkstate split into dag/ (+26 lines, walked back by #261).** At commit time, the architecture-matches-import-graph tenet (tenet 6) was already in play. #220 violated it within the cleanup itself: it put reconcile-time types in the compile-time package. This is the cleanest case of "should have known at the time." Tenet 6 was stable; #220 just got the boundary wrong.

**#172 Own/Contribute → template/patch (-1 line).** Pure tenet-3 work (one name per concept). Tenet stable. Always worth it. Zero complexity cost.

**#192 forEach incremental diff (+559 lines, stripped by #245).** Same story as #190. Served the performance tenet, which was unstable.

**#58 metrics, #17 revision conditions, #224 DepositTrigger.** The three the framework couldn't catch. They served a tenet at the time (observable behavior, correctness) — and that tenet is durable. The reason these got walked back is different: a simpler mechanism was found later that served the same tenet at lower complexity. This is not "the tenet shifted." It is "the team found a cheaper way to satisfy the same tenet." Predicting *that* in advance is essentially predicting future invention. Neither metrics nor tenets can do that.

## What the story tells us about "worth it"

Three categories of complexity:

**Worth it when added, worth it now.** Serves a durable tenet (correctness, design-authority, one-name, determinism, composition, architecture-matches-import-graph, tests-as-contract). The team has demonstrated willingness to pay for these consistently.

**Worth it when added, regretted later.** Served a tenet of the time, but the tenet shifted. The performance tenet (active before #244, deferred after) is the only example in this corpus. Recognition rule: a tenet is unstable if it has a structural conflict with a higher-priority tenet, and the conflict has not yet surfaced as a bug. Performance was always going to lose to correctness when the optimization layer started causing flakes. The signal was visible (rising deflake commits in phase 3) before the design contracted in phase 4.

**Worth it when added, supplanted later.** Served a durable tenet, but a simpler mechanism was found that satisfied the same tenet. #58, #17, #224. Not regret; just iteration. The framework cannot predict this and shouldn't claim to.

## Why C1, C2, C3 returned −1 across the board on (#190, #245)

Because both designs satisfy correctness, observable behavior, and public API stability — the minimal preference set the prompts use. Under that floor, #245 is unambiguously simpler: fewer units, smaller branching partition, denser MDL compression. The verdict is correct under the floor. It is also unsurprising under the floor. The framework does not have a way to express "performance was a tenet at the time" because performance is not in the preference list.

The fix is not better metrics. The fix is **using the active tenets at the time of the change as the preference set**. At #190, the preferences would include performance, and the C verdict against #245 would be different — A might dominate or be incomparable, because A serves a tenet B does not. At #245, the preferences exclude performance, and B dominates as before.

This is the actually useful experiment: read the tenets at each commit (from the design docs of the time), apply C with those tenets as the preference set. The framework then measures whether each change served the tenets *of its moment*, which is the real engineering question.

## Honesty

The tenet list is mine, derived from reading commit subjects and design docs. A different reader might pick a different list, especially in the gray zone (e.g., is "small surface, hidden internals" a separate tenet from "composition over new primitives"? I bundled them). The story arc — five phases, decisive moment at #244 — is also mine. A different framing would tell a different story. Both are inferred from a single time series, which makes them descriptions, not tests.

What the analysis genuinely earns: an account of why the metrics returned the verdicts they did, grounded in the tenets the team has demonstrated. The metrics were not measuring; they were repeating the floor we picked. Reading tenets from history gives the floor a principled origin.

## What to try next

1. Use the tenets as the preference set in S1/S2/S3 instead of the minimal floor. Re-run on a regret pair (#190, #245). Does the verdict change? If it does at #190's tenets and not at #245's, the framework's verdict shift mirrors the team's actual decision.

2. Apply the "unstable tenet" recognition rule prospectively. Look at the current branch state for tenets that have a structural conflict with a higher-priority one. The performance pattern is the template; the recognition is "additions piling up bug fixes is the early warning."

3. Have Ellis look at the tenet list. The most useful test of this writeup is whether he agrees these are the tenets he has been operating on, or whether the list captures the wrong ones.
