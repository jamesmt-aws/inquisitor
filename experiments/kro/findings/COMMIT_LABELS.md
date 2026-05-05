# Commit-level simple/complex labels (v2 with author and LOC)

232 commits on krocodile branch touching `experimental/`. Newest first.

Note: **author is uniform across all 232 commits — Ellis Tarn**. The author column is included as requested but does not differentiate.

| date | sha | author | files | + | − | net | label | subject | why |
|---|---|---|---:|---:|---:|---:|---|---|---|
| 2026-05-04 | d94ded6 | Ellis Tarn | 10 | 200 | 199 | +1 | more_simple | Move walk state from dag/ to controller/ (#261) | Reconcile-time types out of compile-time package; boundary now reflects phase split. |
| 2026-05-04 | 6d6dbbf | Ellis Tarn | 16 | 1000 | 984 | +16 | more_simple | Reconcile code organization against architecture (#258) | File boundaries aligned to architectural claims. |
| 2026-05-03 | 0338032 | Ellis Tarn | 28 | 784 | 1555 | −771 | more_complex | add observedGeneration, propagate -race, harden CI (#257) | New status field with semantics; CI cleanup is incidental. |
| 2026-05-03 | 1242002 | Ellis Tarn | 16 | 519 | 579 | −60 | more_simple | simplify: CBO-grounded skill + controller refactoring (#256) | Labeled simplify; balanced controller refactor. |
| 2026-05-03 | 7a80460 | Ellis Tarn | 5 | 494 | 264 | +230 | more_complex | forEach ready-first ordering (#255) | New ordering rule plus supporting state. |
| 2026-05-03 | 44d03e2 | Ellis Tarn | 17 | 492 | 250 | +242 | more_simple | simplify: skill + instanceState + prune refactoring | Refactor consolidating instanceState handling. |
| 2026-05-02 | c6fe182 | Ellis Tarn | 12 | 136 | 25 | +111 | more_complex | fix e2e flakiness and compat test gaps (#254) | Adds test cases and harness logic for prior gaps. |
| 2026-05-02 | 2121f02 | Ellis Tarn | 39 | 749 | 1781 | −1032 | more_simple | radical simplification (#253) | Removes ~1000 net lines; dead fields, duplication, single-impl interfaces. |
| 2026-05-02 | 564d7ff | Ellis Tarn | 21 | 435 | 2350 | −1915 | more_simple | fix bugs and drop unimplemented feature tests (#252) | Drops tests for features that were never implemented. |
| 2026-05-01 | 0e22fdd | Ellis Tarn | 1 | 199 | 164 | +35 | more_simple | split CompileGraphSpec into focused helpers (#251) | Decomposes one big function into named helpers. |
| 2026-05-01 | 47b6d8b | Ellis Tarn | 1 | 2 | 3 | −1 | more_simple | exclude compat tests from presubmit (#250) | Removes a noisy CI step. |
| 2026-05-01 | 439a520 | Ellis Tarn | 38 | 909 | 2241 | −1332 | more_simple | simplify controller architecture (#249) | Extract clusterAccess and reconcileScope; net −1332. |
| 2026-05-01 | 6db313f | Ellis Tarn | 3 | 333 | 48 | +285 | more_complex | add structural OpenAPI schema to CRDs (#248) | New validation surface; second error-surfacing channel. |
| 2026-05-01 | 9e4b2f7 | Ellis Tarn | 30 | 521 | 2043 | −1522 | more_simple | strip optimization infrastructure (#247) | Removes resourceCache, dead interfaces, dead metrics. |
| 2026-04-30 | 9014431 | Ellis Tarn | 18 | 740 | 3183 | −2443 | more_simple | simplify reconciliation to core algorithm (#245) | Removes 3-layer hash, worker dispatch, resync timers; −2443 net. |
| 2026-04-30 | 64fe475 | Ellis Tarn | 8 | 364 | 460 | −96 | more_simple | separate optimizations into additive layer (007) (#244) | Splits design so core can be read without optimization claims. |
| 2026-04-30 | e8c8d82 | Ellis Tarn | 10 | 18 | 17 | +1 | more_simple | separate CRD chart from controller chart (#243) | One-job charts. |
| 2026-04-30 | c71ed68 | Ellis Tarn | 49 | 440 | 117 | +323 | more_simple | split into standalone Go module (#241) | Module boundary makes the dependency invariant explicit. |
| 2026-04-29 | e026928 | Ellis Tarn | 3 | 63 | 10 | +53 | more_complex | fix validation regression and add `each` keyword (#235) | New keyword in DSL surface. |
| 2026-04-29 | 0ea1e5d | Ellis Tarn | 2 | 12 | 0 | +12 | more_complex | chart: command, args, env overrides (#238) | New chart parameters. |
| 2026-04-29 | ce513fc | Ellis Tarn | 11 | 17 | 16 | +1 | more_simple | charts symlink to source of truth (#237) | One source of truth replaces two. |
| 2026-04-29 | 80be844 | Ellis Tarn | 22 | 110 | 205 | −95 | more_simple | add lightweight Helm chart, remove --bootstrap (#236) | Removes --bootstrap path. |
| 2026-04-28 | b6ace7e | Ellis Tarn | 12 | 143 | 26 | +117 | more_complex | compat: instance_conditions and include_when tests pass (#233) | Adds handling for previously-failing input cases. |
| 2026-04-28 | 31bd70c | Ellis Tarn | 24 | 1210 | 522 | +688 | more_complex | .ready() as a field path — lazy evaluation model (#232) | Big new evaluation model. |
| 2026-04-27 | 2952747 | Ellis Tarn | 5 | 287 | 311 | −24 | more_simple | move coordinator loop and post-walk into walk.run() (#230) | Consolidates walk lifecycle. |
| 2026-04-27 | 0fd27d1 | Ellis Tarn | 16 | 2828 | 2767 | +61 | more_simple | organize code — file boundaries to architecture (#229) | Massive reorganization; near-balanced LOC. |
| 2026-04-26 | fe7ff8c | Ellis Tarn | 2 | 18 | 8 | +10 | more_simple | fix forEach prune flake — per-node applied key tracking (#228) | Slice → typed map; encodes invariant in type. |
| 2026-04-26 | e5727ba | Ellis Tarn | 1 | 14 | 1 | +13 | more_complex | add diagnostic instrumentation for forEach prune (#227) | Pure logging additions. |
| 2026-04-26 | 73cc383 | Ellis Tarn | 3 | 165 | 34 | +131 | more_complex | include child ref content in compilation key (#226) | Cache key gains a new component. |
| 2026-04-25 | c1cd645 | Ellis Tarn | 11 | 816 | 819 | −3 | more_simple | harden API surface, split walk, deduplicate propagation (#225) | Net dedup plus boundary hardening. |
| 2026-04-25 | 9313102 | Ellis Tarn | 3 | 112 | 22 | +90 | more_complex | fix ReadinessDependents propagation, cluster-scoped routing (#224) | Three bug fixes adding new branches. |
| 2026-04-25 | d724e60 | Ellis Tarn | 5 | 96 | 34 | +62 | more_complex | fix body .ready() hard deps, ReadinessDependents dispatch (#223) | Multiple fixes adding dispatch logic. |
| 2026-04-24 | 51f29d3 | Ellis Tarn | 4 | 60 | 8 | +52 | more_complex | instrument decision points and handoffs (#221) | Pure logging additions. |
| 2026-04-24 | 3d5f85a | Ellis Tarn | 10 | 347 | 323 | +24 | more_simple | harden package and struct boundaries (#222) | Tightens boundaries; balanced LOC. |
| 2026-04-24 | 8be8137 | Ellis Tarn | 5 | 298 | 14 | +284 | more_complex | fix .ready() dependency extraction, .dependencies() scope (#216) | Adds validation logic. |
| 2026-04-24 | cd46848 | Ellis Tarn | 4 | 284 | 258 | +26 | more_simple | split mixed-concept files (#220) | File boundaries align with concepts. |
| 2026-04-24 | 5a14440 | Ellis Tarn | 14 | 440 | 433 | +7 | more_simple | extract setup.go and resourcekey.go (#219) | File-level organization. |
| 2026-04-23 | 4bc2df5 | Ellis Tarn | 50 | 7192 | 7037 | +155 | more_simple | extract graph/, dag/, watches/, compiler/ subpackages (#217) | Package-level architecture extraction. |
| 2026-04-23 | 17426bd | Ellis Tarn | 8 | 197 | 101 | +96 | more_simple | direct API reads, eliminate stale-read polling (#215) | Removes the polling layer. |
| 2026-04-23 | 3572985 | Ellis Tarn | 4 | 177 | 70 | +107 | more_simple | fix watch propagation bugs, remove resync override (#214) | Net structural cleanup. |
| 2026-04-23 | 29a0078 | Ellis Tarn | 28 | 1111 | 576 | +535 | more_complex | fix propagation bugs masked by 2s resync (#213) | Multiple bug fixes; +535 net. |
| 2026-04-22 | aeba841 | Ellis Tarn | 2 | 67 | 7 | +60 | more_complex | return nil for deterministic errors (#212) | Adds error-handling branches. |
| 2026-04-22 | 4397650 | Ellis Tarn | 1 | 2 | 1 | +1 | more_simple | add unknown_fields_test.go to allowlist (#208) | One-line allowlist update. |
| 2026-04-21 | 4de7d9a | Ellis Tarn | 1 | 19 | 177 | −158 | more_simple | update 006-stdlib for RGD raw Graph conversion (#209) | Doc shrinkage following architectural simplification. |
| 2026-04-21 | 0641909 | Ellis Tarn | 13 | 669 | 510 | +159 | more_simple | convert RGD from Kind to raw Graph (#205) | Collapses Kind abstraction. |
| 2026-04-21 | 1c67d4b | Ellis Tarn | 8 | 572 | 29 | +543 | more_complex | hold instance during teardown via patch node (#203) | Adds composition + 435 lines of new tests. |
| 2026-04-21 | 1db7f6a | Ellis Tarn | 6 | 398 | 5 | +393 | more_complex | detect RGD resource cycles at compile time (#204) | New compile-time detection. |
| 2026-04-20 | a605835 | Ellis Tarn | 7 | 91 | 17 | +74 | more_complex | fix Path 2 self-refresh re-stamp __ready (#200) | Bug fix adding stamping logic. |
| 2026-04-20 | f79469f | Ellis Tarn | 2 | 101 | 10 | +91 | more_complex | support externalRef in RGD stdlib (#202) | New stdlib feature. |
| 2026-04-20 | 5c575bf | Ellis Tarn | 2 | 63 | 3 | +60 | more_complex | fix forEach hash carry-forward double-prefix (#201) | Fix adds handling code. |
| 2026-04-20 | f17225c | Ellis Tarn | 13 | 330 | 148 | +182 | more_simple | remove kro.run/apply annotation (#194) | One source of truth replaces dual-source toggle. |
| 2026-04-20 | 85a77bc | Ellis Tarn | 8 | 511 | 65 | +446 | more_complex | dynamic GVK type resolution and CRD update detection (#199) | New feature with significant new code. |
| 2026-04-20 | ffb687c | Ellis Tarn | 4 | 522 | 320 | +202 | more_simple | extract finalization into explicit state machine (#198) | Implicit state becomes explicit. |
| 2026-04-19 | c62b9ba | Ellis Tarn | 9 | 307 | 258 | +49 | more_simple | reconcile implementation against design (compilation) (#197) | Code-design alignment. |
| 2026-04-19 | 58dd9a5 | Ellis Tarn | 21 | 2637 | 69 | +2568 | more_complex | type cache, structural caching, recursive validation (#190) | Big new optimization machinery (later stripped). |
| 2026-04-19 | 6d3686c | Ellis Tarn | 39 | 1673 | 296 | +1377 | more_simple | add 004-compilation, separate from reconciliation (#195) | Architectural split. |
| 2026-04-19 | d6cbc54 | Ellis Tarn | 5 | 75 | 31 | +44 | more_complex | cache canonical Kind in WatchManager (#196) | Fix adding cache state. |
| 2026-04-18 | e480f78 | Ellis Tarn | 4 | 13 | 2305 | −2292 | more_simple | delete redundant unit tests covered by e2e (#191) | −2292 lines of redundant tests. |
| 2026-04-18 | ff33a4a | Ellis Tarn | 5 | 149 | 39 | +110 | more_complex | forEach context-aware hashing (#188) | Adds context-aware hashing. |
| 2026-04-18 | 2badac0 | Ellis Tarn | 3 | 31 | 11 | +20 | more_complex | deflake crash recovery and histogram metrics tests (#193) | Adds test logic. |
| 2026-04-18 | 22681e7 | Ellis Tarn | 9 | 585 | 26 | +559 | more_complex | forEach O(changed) incremental diff (#192) | New optimization layer (later stripped). |
| 2026-04-17 | 3376810 | Ellis Tarn | 5 | 225 | 114 | +111 | more_simple | encapsulate Watch merge, unify hash paths (#186) | Labeled simplicity. |
| 2026-04-17 | 7a4c588 | Ellis Tarn | 6 | 514 | 203 | +311 | more_simple | delete tautology unit tests, add e2e coverage (#187) | Replaces low-value tests with substantive coverage. |
| 2026-04-17 | 8a6e2e9 | Ellis Tarn | 17 | 423 | 410 | +13 | more_simple | simplicity (#185) | Four targeted simplicity fixes. |
| 2026-04-17 | be88c4f | Ellis Tarn | 1 | 3 | 3 | 0 | more_complex | add validation compat (#184) | Tiny but adds compat handling. |
| 2026-04-16 | 3bcbe92 | Ellis Tarn | 3 | 119 | 1 | +118 | more_complex | propagation trigger on self-state refresh (#182) | New trigger semantics. |
| 2026-04-16 | 47a48d9 | Ellis Tarn | 2 | 424 | 0 | +424 | more_complex | .updated() integration tests (#183) | Pure test additions. |
| 2026-04-16 | 94695c8 | Ellis Tarn | 5 | 419 | 0 | +419 | more_complex | implement .updated() CEL function (#181) | New CEL function. |
| 2026-04-16 | 05f3bd6 | Ellis Tarn | 69 | 10 | 10 | 0 | more_simple | consolidate integration tests under experimental/test/ (#180) | File moves to one location. |
| 2026-04-16 | 8695db1 | Ellis Tarn | 2 | 263 | 383 | −120 | more_simple | remove redundant unit tests, add table-driven e2e (#179) | Net deletion. |
| 2026-04-15 | 6bcd57c | Ellis Tarn | 2 | 334 | 8 | +326 | more_complex | per-item propagateWhen edge case coverage (#178) | Test additions. |
| 2026-04-15 | 4a0aae8 | Ellis Tarn | 2 | 372 | 1 | +371 | more_complex | implement propagateWhen and readyWhen on Kind spec (#174) | New behavioral surface. |
| 2026-04-15 | 311e0a5 | Ellis Tarn | 5 | 322 | 12 | +310 | more_complex | per-item propagateWhen in forEach (#176) | New per-item behavior. |
| 2026-04-15 | 59c675f | Ellis Tarn | 9 | 1026 | 502 | +524 | more_simple | promote unit tests to e2e, status condition assertions (#177) | Replaces internal-API tests with contract assertions. |
| 2026-04-15 | 606eb2f | Ellis Tarn | 1 | 52 | 17 | +35 | more_complex | RGD Inactive state validation (#175) | Adds validation. |
| 2026-04-14 | f8dff1c | Ellis Tarn | 2 | 15 | 8 | +7 | more_simple | parallelize presubmit (#173) | Faster CI. |
| 2026-04-14 | fbd29c8 | Ellis Tarn | 23 | 194 | 195 | −1 | more_simple | Own/Contribute → template/patch (#172) | Naming consistency. |
| 2026-04-14 | fa35bf6 | Ellis Tarn | 10 | 154 | 219 | −65 | more_simple | unify duplicated patterns, fix naming collisions (#170) | Labeled simplicity. |
| 2026-04-14 | 9c3140e | Ellis Tarn | 2 | 601 | 3 | +598 | more_complex | WatchCoordinator e2e tests (#167) | Test additions. |
| 2026-04-14 | 42e8459 | Ellis Tarn | 7 | 922 | 20 | +902 | more_complex | SystemError fault injection, prune safety, Ready rollup tests (#171) | Test additions. |
| 2026-04-13 | 0632b05 | Ellis Tarn | 1 | 36 | 28 | +8 | more_complex | re-check selector membership on incremental watch (#169) | Bug fix adds re-check. |
| 2026-04-13 | 72700d4 | Ellis Tarn | 16 | 328 | 300 | +28 | more_complex | propagateWhen input gate and .dependencies() CEL primitive (#168) | New CEL primitive plus gate semantics. |
| 2026-04-13 | c232173 | Ellis Tarn | 1 | 11 | 2 | +9 | more_simple | propagateWhen is an input gate, not output gate (#164) | Reframes the role; tightens semantics. |
| 2026-04-13 | 96048c6 | Ellis Tarn | 3 | 264 | 9 | +255 | more_complex | 2x faster hashDesiredState (#166) | New custom hashing replaces stdlib marshal. |
| 2026-04-12 | 769299c | Ellis Tarn | 3 | 178 | 40 | +138 | more_complex | design: propagation control for forEach and Kind (#165) | Adds new control surface. |
| 2026-04-12 | 5cfb5a1 | Ellis Tarn | 9 | 208 | 278 | −70 | more_simple | deduplicate repeated patterns (#162) | Labeled simplicity. |
| 2026-04-12 | 10a365f | Ellis Tarn | 15 | 776 | 37 | +739 | more_complex | reconcile implementation against designs (#163) | +739 net to match design. |
| 2026-04-12 | cdc4bb9 | Ellis Tarn | 6 | 278 | 33 | +245 | more_complex | schema-aware CEL: typed resource schemas (#161) | New typing layer. |
| 2026-04-12 | 1899079 | Ellis Tarn | 5 | 238 | 56 | +182 | more_complex | fix forEach multi-variable silent data loss (#160) | Adds defensive checks. |
| 2026-04-12 | a1709a7 | Ellis Tarn | 19 | 1010 | 1034 | −24 | more_simple | simplicity: file truthfulness, dead code, naming (#159) | Labeled simplicity. |
| 2026-04-11 | 99a4232 | Ellis Tarn | 20 | 235 | 229 | +6 | more_simple | align code naming to design — template/patch (#158) | Naming alignment. |
| 2026-04-11 | 6cacd2e | Ellis Tarn | 4 | 539 | 6 | +533 | more_complex | skip dynamic-GVR nodes via HasDynamicGVR() (#157) | New mode in startup hydration. |
| 2026-04-11 | 851a8a8 | Ellis Tarn | 2 | 33 | 3 | +30 | more_complex | observable startup + health-gated readiness (#156) | New health-gating surface. |
| 2026-04-11 | 05db829 | Ellis Tarn | 5 | 43 | 46 | −3 | more_simple | rename Kind items, drop ApiVersion column (#155) | Drops unneeded column. |
| 2026-04-10 | ef1a3b6 | Ellis Tarn | 4 | 183 | 179 | +4 | more_simple | reconcile 001/003/004/005 with declared-keyword schema (#153) | Doc reconciliation. |
| 2026-04-10 | 70a337b | Ellis Tarn | 10 | 245 | 21 | +224 | more_complex | cluster-scoped Kind, printer columns, instance count (#152) | Adds capabilities. |
| 2026-04-10 | 6e59992 | Ellis Tarn | 46 | 1590 | 1126 | +464 | more_complex | explicit-keyword schema for Graph node classification (#150) | New schema model. |
| 2026-04-10 | 5413e3b | Ellis Tarn | 2 | 44 | 2 | +42 | more_complex | rgd stdlib: instance GVK labels + force-apply (#149) | New stdlib state. |
| 2026-04-09 | 81c5a03 | Ellis Tarn | 3 | 100 | 3 | +97 | more_complex | compat suite: incremental workflow + allowlist (#146) | New CI mechanism. |
| 2026-04-09 | 27eadc5 | Ellis Tarn | 2 | 89 | 23 | +66 | more_complex | test helpers: classification accessor + waiter (#147) | New test helpers. |
| 2026-04-09 | 57b7a3c | Ellis Tarn | 5 | 250 | 25 | +225 | more_complex | cover four P1/P2 items (#148) | Test additions. |
| 2026-04-09 | 9f9be63 | Ellis Tarn | 12 | 386 | 138 | +248 | more_complex | close ten P1/P2 follow-up items (#144) | Multiple bug fixes. |
| 2026-04-09 | d08f341 | Ellis Tarn | 9 | 212 | 76 | +136 | more_simple | split Reference into parse-time and ResolvedReference (#145) | Encodes phase distinction in types. |
| 2026-04-08 | 428ecbd | Ellis Tarn | 8 | 117 | 38 | +79 | more_complex | add Node.Identity/Payload accessors (#142) | New accessor API. |
| 2026-04-08 | 9ba6e1d | Ellis Tarn | 13 | 889 | 68 | +821 | more_complex | close six P0 correctness gaps (#136) | Big bug fixes. |
| 2026-04-08 | 6024823 | Ellis Tarn | 5 | 34 | 17 | +17 | more_simple | route Node reference lookups through a single method (#141) | Consolidation. |
| 2026-04-08 | fe5fea8 | Ellis Tarn | 47 | 249 | 31 | +218 | more_complex | upstream integration tests pass (#137) | Adds compat handling. |
| 2026-04-08 | 9fb1149 | Ellis Tarn | 7 | 57 | 57 | 0 | more_simple | rename skeletonApply to releaseApply (#140) | Naming clarity. |
| 2026-04-07 | 22ab864 | Ellis Tarn | 3 | 12 | 11 | +1 | more_simple | change SSA field manager format (#139) | Format clarity. |
| 2026-04-07 | 9d3a180 | Ellis Tarn | 1 | 106 | 215 | −109 | more_simple | polish 003-ownership doc (#122) | −109 net doc lines. |
| 2026-04-07 | 59264fa | Ellis Tarn | 1 | 8 | 0 | +8 | more_simple | parallelize stdlib tests (#138) | Test speedup. |
| 2026-04-07 | 4f81073 | Ellis Tarn | 7 | 591 | 14 | +577 | more_complex | upstream compat test harness (#130) | New harness. |
| 2026-04-07 | 6a9d901 | Ellis Tarn | 2 | 31 | 31 | 0 | more_simple | rename Singleton node IDs (#135) | Rename. |
| 2026-04-07 | fb4d43e | Ellis Tarn | 14 | 371 | 313 | +58 | more_complex | feat: Singleton E2E (#133) | New feature. |
| 2026-04-06 | 83ee885 | Ellis Tarn | 4 | 52 | 25 | +27 | more_complex | declaration-order-stable topological sort (#134) | More sophisticated algorithm. |
| 2026-04-06 | b785120 | Ellis Tarn | 5 | 285 | 517 | −232 | more_simple | move stdlib integration tests into controller/test (#132) | Net dedup. |
| 2026-04-06 | 8071f77 | Ellis Tarn | 4 | 60 | 95 | −35 | more_simple | flatten graphCaches three-map state machine (#131) | Net flattening. |
| 2026-04-06 | 4b5f7a2 | Ellis Tarn | 3 | 25 | 6 | +19 | more_complex | declaration-order-preserving topological sort (#127) | Adds ordering constraint. |
| 2026-04-06 | 7b4b284 | Ellis Tarn | 7 | 134 | 33 | +101 | more_complex | stdlib: typed nodes/resources, fix race (#129) | Adds typing. |
| 2026-04-05 | 745998f | Ellis Tarn | 18 | 2367 | 15 | +2352 | more_complex | Decorator as bootstrap primitive (#126) | New primitive abstraction. |
| 2026-04-05 | 9ad427a | Ellis Tarn | 3 | 275 | 28 | +247 | more_complex | align L3 graph RGD schema with upstream API (#124) | Schema alignment adds code. |
| 2026-04-05 | d07562a | Ellis Tarn | 8 | 637 | 59 | +578 | more_complex | close three design gaps (#125) | Big fix. |
| 2026-04-05 | 670e9d6 | Ellis Tarn | 32 | 123 | 110 | +13 | more_simple | converge implementation comments and design docs (#123) | Doc-code alignment. |
| 2026-04-04 | 417e24a | Ellis Tarn | 10 | 1230 | 57 | +1173 | more_complex | feat: compile-time type inference (#119) | New feature. |
| 2026-04-04 | 0879580 | Ellis Tarn | 7 | 620 | 36 | +584 | more_complex | forEach duplicate key detection, FinalizerSkipped status (#120) | Detection plus status surface. |
| 2026-04-04 | 6ed459f | Ellis Tarn | 1 | 59 | 77 | −18 | more_simple | deflake test (#121) | Net deletion. |
| 2026-04-04 | 9b52650 | Ellis Tarn | 6 | 461 | 33 | +428 | more_complex | close three design gaps (#118) | Bug fixes. |
| 2026-04-04 | 8d83689 | Ellis Tarn | 4 | 441 | 36 | +405 | more_complex | Contribute teardown releases field ownership (#116) | Adds release logic. |
| 2026-04-03 | f342d3c | Ellis Tarn | 1 | 2 | 2 | 0 | more_simple | docs: clarify resync respects propagateWhen (#117) | Doc clarification. |
| 2026-04-03 | 3b4c1b1 | Ellis Tarn | 1 | 88 | 72 | +16 | more_simple | docs: compilation section, unified trigger model (#113) | Unifies trigger model. |
| 2026-04-03 | facbc84 | Ellis Tarn | 10 | 1306 | 0 | +1306 | more_complex | test: 8 design doc coverage gap tests (#114) | +1306 test lines. |
| 2026-04-03 | 9a6be37 | Ellis Tarn | 3 | 422 | 719 | −297 | more_simple | rewrite 004-graph-execution as 004-graph-reconciliation (#105) | −297 net via focus. |
| 2026-04-02 | c5dc775 | Ellis Tarn | 12 | 482 | 45 | +437 | more_complex | reconciliation findings — multiple fixes (#111) | Multiple fixes. |
| 2026-04-02 | 948ad6c | Ellis Tarn | 4 | 153 | 6 | +147 | more_complex | validate node IDs DNS-1123 (#109) | Adds validation. |
| 2026-04-02 | e082fe9 | Ellis Tarn | 8 | 823 | 0 | +823 | more_complex | resolveReference errors silently lost, +10 regression tests (#106) | Adds error handling and tests. |
| 2026-04-02 | 0bc6537 | Ellis Tarn | 6 | 320 | 8 | +312 | more_complex | readyWhen expression errors gate dependents (#104) | Adds gating. |
| 2026-04-01 | bd10b50 | Ellis Tarn | 9 | 63 | 90 | −27 | more_simple | simplicity: dead parameters, unify reference resolution (#103) | Labeled simplicity. |
| 2026-04-01 | 40a7d6c | Ellis Tarn | 1 | 15 | 12 | +3 | more_simple | document apply-hash annotation persistence (#102) | Doc clarification. |
| 2026-04-01 | fa9a7cc | Ellis Tarn | 2 | 147 | 15 | +132 | more_complex | drift timer reset only for dispatched nodes (#100) | Adds branching logic. |
| 2026-04-01 | e554eab | Ellis Tarn | 2 | 22 | 45 | −23 | more_simple | simplicity: unify reconcileOwn and reconcileContribute (#101) | Unification. |
| 2026-03-31 | 3539ec4 | Ellis Tarn | 5 | 22 | 38 | −16 | more_simple | simplicity: dead code, duplicated patterns, stale references (#98) | Labeled simplicity. |
| 2026-03-31 | f3c8a0a | Ellis Tarn | 3 | 256 | 107 | +149 | more_complex | remove propagateState first-wins flood fill (#97) | Replaces logic with new logic. |
| 2026-03-30 | f5c3dc5 | Ellis Tarn | 9 | 871 | 15 | +856 | more_complex | perf: cache leak, Kahn's O(V²), benchmarks (#93) | New perf code. |
| 2026-03-30 | 0b609d0 | Ellis Tarn | 2 | 157 | 0 | +157 | more_complex | include propagateWhen state in propagation hash (#95) | New hash component. |
| 2026-03-30 | 49e9f5d | Ellis Tarn | 5 | 276 | 23 | +253 | more_complex | reconcile correctness gaps against design docs (#92) | Bug fixes. |
| 2026-03-29 | 6bd7b1a | Ellis Tarn | 11 | 156 | 375 | −219 | more_simple | doc review comments, rename CircularDependency → DependencyError (#91) | Doc cleanup. |
| 2026-03-29 | 5aa6123 | Ellis Tarn | 19 | 96 | 149 | −53 | more_simple | simplicity: unify naming, extract readyWhen, dead code (#89) | Labeled simplicity. |
| 2026-03-28 | f3cdd21 | Ellis Tarn | 7 | 48 | 48 | 0 | more_simple | rename Compiled condition reasons to error taxonomy (#88) | Rename for taxonomy. |
| 2026-03-28 | 00b2102 | Ellis Tarn | 10 | 88 | 88 | 0 | more_simple | rename Graph condition Accepted → Compiled (#87) | Rename. |
| 2026-03-28 | 7be5702 | Ellis Tarn | 13 | 758 | 301 | +457 | more_complex | feat: field-path extraction from CEL ASTs (#86) | New feature. |
| 2026-03-28 | 0101967 | Ellis Tarn | 12 | 129 | 179 | −50 | more_simple | refactor: gate-oriented hash naming, three-hash model (#85) | Naming + dead-code removal. |
| 2026-03-27 | c235c63 | Ellis Tarn | 14 | 568 | 618 | −50 | more_simple | deflake all Graph update sites with conflict retry (#84) | Net delete via retry-replaces-ad-hoc. |
| 2026-03-27 | 5c65e32 | Ellis Tarn | 2 | 28 | 15 | +13 | more_complex | deflake TestResourcePruning (#82) | Adds retry logic. |
| 2026-03-27 | 944f1c7 | Ellis Tarn | 7 | 569 | 854 | −285 | more_simple | simplify: collapse duplicated code (#81) | Labeled simplify. |
| 2026-03-26 | 3bc1db5 | Ellis Tarn | 13 | 251 | 123 | +128 | more_complex | drift timer bypass for SSA ownership enforcement (#79) | New mode in drift timer. |
| 2026-03-26 | f85befa | Ellis Tarn | 4 | 235 | 21 | +214 | more_complex | collection watch .ready() bug, error classification (#78) | Multiple fixes. |
| 2026-03-26 | c9f6462 | Ellis Tarn | 24 | 281 | 281 | 0 | more_simple | rename references to base verb form (#77) | Rename. |
| 2026-03-26 | 4f142a5 | Ellis Tarn | 8 | 3192 | 39 | +3153 | more_complex | forEach Contribute/finalizes bugs, +30 correctness tests (#76) | Big fix plus tests. |
| 2026-03-25 | 3287e5d | Ellis Tarn | 8 | 569 | 21 | +548 | more_complex | feat: definition nodes (#73) | New feature. |
| 2026-03-25 | a93f961 | Ellis Tarn | 2 | 29 | 20 | +9 | more_simple | move quality from design doc to project-local skill (#74) | Reorganization. |
| 2026-03-25 | 7109985 | Ellis Tarn | 16 | 159 | 115 | +44 | more_complex | Pending propagates as Pending, not Blocked (#71) | New state-precedence rule. |
| 2026-03-24 | 8e3d532 | Ellis Tarn | 3 | 40 | 16 | +24 | more_simple | build: go test self-resolves envtest (#72) | Removes Makefile dependency. |
| 2026-03-24 | 52de51b | Ellis Tarn | 2 | 4 | 2 | +2 | more_simple | build: GOPATH/bin as LOCALBIN (#70) | Worktree-friendly. |
| 2026-03-24 | 47f8395 | Ellis Tarn | 2 | 14 | 14 | 0 | more_simple | docs: fix four design inconsistencies (#69) | Doc fixes. |
| 2026-03-24 | fe0937c | Ellis Tarn | 20 | 271 | 224 | +47 | more_simple | rename TemplateShape → Reference (#66) | Rename. |
| 2026-03-23 | 8667ef7 | Ellis Tarn | 3 | 87 | 42 | +45 | more_complex | finalization races (#67) | Bug fix adds locking. |
| 2026-03-23 | 8066a86 | Ellis Tarn | 4 | 319 | 12 | +307 | more_complex | propagateWhen cross-node scope (#65) | Adds cross-node scoping. |
| 2026-03-23 | 8b5b650 | Ellis Tarn | 6 | 136 | 19 | +117 | more_complex | performance reconcile O(V²)→O(V+E) (#64) | Big perf rewrite. |
| 2026-03-23 | 714c115 | Ellis Tarn | 4 | 85 | 16 | +69 | more_complex | add experimental/Makefile and presubmit (#63) | New CI infra. |
| 2026-03-22 | 91c3bfc | Ellis Tarn | 12 | 1639 | 20 | +1619 | more_complex | reconcile tests toward design commitments (#62) | +1619 net test lines. |
| 2026-03-22 | c624baf | Ellis Tarn | 9 | 85 | 40 | +45 | more_complex | prune skipped on revision transition (#61) | Bug fix. |
| 2026-03-22 | 89aec19 | Ellis Tarn | 8 | 448 | 49 | +399 | more_complex | reconcile implementation toward design (#59) | +399 net to match design. |
| 2026-03-21 | 8ac5620 | Ellis Tarn | 3 | 360 | 0 | +360 | more_complex | add drift timer and system error metrics (#58) | Pure addition. |
| 2026-03-21 | dc5c12c | Ellis Tarn | 2 | 295 | 0 | +295 | more_complex | regression tests for surgical correctness fixes (#57) | Test additions. |
| 2026-03-21 | 922d402 | Ellis Tarn | 2 | 29 | 0 | +29 | more_complex | close silent divergence gaps in hash detection (#56) | Adds checks. |
| 2026-03-21 | f2231a6 | Ellis Tarn | 5 | 192 | 34 | +158 | more_complex | implement drift timers and trigger-scoped walks (#55) | New machinery (later stripped). |
| 2026-03-20 | 7e22393 | Ellis Tarn | 3 | 152 | 79 | +73 | more_complex | redesign forEach: parent-child model (#54) | New model. |
| 2026-03-20 | 56b0d7b | Ellis Tarn | 12 | 693 | 277 | +416 | more_complex | implement execution design (#53) | Big new implementation. |
| 2026-03-20 | 9c18aa3 | Ellis Tarn | 1 | 37 | 17 | +20 | more_simple | fix execution design: trigger terminology (#52) | Doc fix. |
| 2026-03-19 | d6d202b | Ellis Tarn | 3 | 103 | 105 | −2 | more_simple | simplify storage model (#51) | Labeled simplify. |
| 2026-03-19 | e205934 | Ellis Tarn | 4 | 246 | 199 | +47 | more_complex | redesign graph reconciliation (#48) | New design with new mechanisms. |
| 2026-03-19 | 7bc52dd | Ellis Tarn | 11 | 650 | 30 | +620 | more_complex | reconcile designs: prune safety, ordered prune (#49) | New design surface. |
| 2026-03-18 | 501ea75 | Ellis Tarn | 9 | 163 | 332 | −169 | more_simple | fix test infrastructure: shutdown, logging (#47) | Net delete via cleanup. |
| 2026-03-18 | 49e9980 | Ellis Tarn | 3 | 274 | 42 | +232 | more_complex | run tests against real kro binary (#46) | More elaborate harness. |
| 2026-03-18 | bbb3846 | Ellis Tarn | 3 | 30 | 63 | −33 | more_simple | use embedded CRD YAMLs in tests (#45) | Removes external file deps. |
| 2026-03-18 | 4822426 | Ellis Tarn | 31 | 120 | 120 | 0 | more_simple | move CRDs to experimental.kro.run (#44) | Rename/move. |
| 2026-03-17 | c06852a | Ellis Tarn | 1 | 58 | 6 | +52 | more_complex | fix envtest process leak (#43) | Fix adds cleanup logic. |
| 2026-03-17 | 74d3099 | Ellis Tarn | 4 | 109 | 175 | −66 | more_simple | batch watch registration (#42) | Net delete via batching. |
| 2026-03-17 | 3039cce | Ellis Tarn | 9 | 17 | 16 | +1 | more_simple | consolidate experimental/crds and deploy (#41) | One destination. |
| 2026-03-17 | 5b0760c | Ellis Tarn | 9 | 195 | 115 | +80 | more_complex | fix WatchManager informer killing (#40) | Fix adds locking. |
| 2026-03-16 | 1b0ce35 | Ellis Tarn | 18 | 1239 | 89 | +1150 | more_complex | fix double-dispatch race in DAG coordinator (#39) | +1150 net via fix and tests. |
| 2026-03-16 | 760af17 | Ellis Tarn | 3 | 476 | 41 | +435 | more_complex | finalizes: walk exclusion, teardown cleanup (#38) | New feature surface. |
| 2026-03-16 | 94a24fa | Ellis Tarn | 11 | 389 | 37 | +352 | more_complex | move experimental APIs, fix bugs (#37) | Net add. |
| 2026-03-16 | aa7bf22 | Ellis Tarn | 8 | 90 | 39 | +51 | more_simple | fix .ready() hash skip, eliminate time.Sleep (#36) | Removes Sleep. |
| 2026-03-15 | 7445902 | Ellis Tarn | 3 | 81 | 13 | +68 | more_complex | finalizes: deferral, applied set persistence (#35) | Multiple fixes. |
| 2026-03-15 | fe38b81 | Ellis Tarn | 5 | 224 | 2 | +222 | more_complex | finalizes: implement finalization sequence (#34) | New feature. |
| 2026-03-15 | 4f94b12 | Ellis Tarn | 2 | 74 | 0 | +74 | more_complex | block deletion when third-party SSA managers present (#33) | Pure addition. |
| 2026-03-15 | a1c351e | Ellis Tarn | 8 | 147 | 107 | +40 | more_complex | shape: existence-based Owns vs Contribute detection (#32) | New detection logic. |
| 2026-03-14 | c9af1f1 | Ellis Tarn | 47 | 17 | 17 | 0 | more_simple | flatten experimental/graph/ into experimental/ (#31) | One directory level removed. |
| 2026-03-14 | 19b4a41 | Ellis Tarn | 9 | 196 | 218 | −22 | more_simple | status: align Ready condition with design (#29) | Code-design alignment. |
| 2026-03-14 | fb79060 | Ellis Tarn | 2 | 30 | 18 | +12 | more_simple | design: fix shape detection and applied set semantics (#28) | Doc fix. |
| 2026-03-14 | a6e68c2 | Ellis Tarn | 1 | 14 | 10 | +4 | more_simple | design: derive Ready reasons from node plan states (#27) | Doc clarification. |
| 2026-03-13 | 00f4b32 | Ellis Tarn | 5 | 116 | 39 | +77 | more_complex | execution: continue walk on node failure (#23) | New error-handling rule. |
| 2026-03-13 | 17fcc02 | Ellis Tarn | 6 | 746 | 719 | +27 | more_simple | simplicity: reorganize controller package (#22) | Labeled simplicity. |
| 2026-03-13 | 14e4cfb | Ellis Tarn | 1 | 1 | 0 | +1 | more_complex | quality: add naming consistency check (#26) | Adds checklist item. |
| 2026-03-13 | e02896f | Ellis Tarn | 5 | 679 | 131 | +548 | more_complex | content-addressed compiled graph sharing (#25) | New perf layer (later stripped). |
| 2026-03-12 | d6d6e4e | Ellis Tarn | 9 | 645 | 29 | +616 | more_complex | section-scoped input hashing and scoped walks (#24) | New perf machinery (later stripped). |
| 2026-03-12 | 4f844ef | Ellis Tarn | 7 | 1121 | 33 | +1088 | more_complex | implement .ready(), revision immutability, GC (#17) | Big new feature. |
| 2026-03-12 | bbaf56a | Ellis Tarn | 1 | 11 | 9 | +2 | more_simple | quality: design-first frame, no-flake constraint (#21) | Doc tightening. |
| 2026-03-11 | 72f9631 | Ellis Tarn | 3 | 680 | 605 | +75 | more_simple | simplicity: gvkToGVR pluralization, split controller.go (#20) | Labeled simplicity. |
| 2026-03-11 | 9ebcb06 | Ellis Tarn | 9 | 148 | 171 | −23 | more_simple | simplicity: reconcile experimental/graph/ against 006 (#19) | Labeled simplicity. |
| 2026-03-11 | 850f414 | Ellis Tarn | 1 | 8 | 0 | +8 | more_complex | quality: add open-ended item to each section (#18) | Adds checklist. |
| 2026-03-10 | cf3d5cc | Ellis Tarn | 3 | 1364 | 7 | +1357 | more_complex | quality: test untested commitments, benchmarks (#16) | +1357 test/bench lines. |
| 2026-03-10 | 2df3263 | Ellis Tarn | 19 | 178 | 186 | −8 | more_simple | quality: reconcile against design and code standards (#15) | Code-design alignment. |
| 2026-03-10 | 4eb0c30 | Ellis Tarn | 5 | 161 | 3 | +158 | more_complex | add deploy and bootstrap infrastructure (#14) | New infra surface. |
| 2026-03-09 | 770fae4 | Ellis Tarn | 1 | 64 | 0 | +64 | more_complex | design: add quality checklist (#13) | Doc addition. |
| 2026-03-09 | 822525a | Ellis Tarn | 2 | 714 | 120 | +594 | more_complex | fix correctness bugs found during design reconciliation (#12) | +594 net via fixes. |
| 2026-03-09 | f86ba8f | Ellis Tarn | 3 | 112 | 33 | +79 | more_simple | restore design docs reverted by #10 (#11) | Restoration. |
| 2026-03-09 | 88bb42b | Ellis Tarn | 25 | 1252 | 539 | +713 | more_complex | implement experimental designs 1-4 (#10) | Big initial implementation. |
| 2026-03-08 | 2240826 | Ellis Tarn | 3 | 26 | 31 | −5 | more_simple | design: use 'node' for graph entries (#9) | Naming clarity. |
| 2026-03-08 | 9029857 | Ellis Tarn | 3 | 86 | 2 | +84 | more_complex | design: add finalizes field for deletion-phase (none) | New design surface. |
| 2026-03-07 | cf4599b | Ellis Tarn | 26 | 334 | 340 | −6 | more_simple | rename resources → nodes (none) | Naming alignment. |
| 2026-03-07 | 6c19f44 | Ellis Tarn | 4 | 51 | 41 | +10 | more_simple | align naming across design docs (none) | Naming alignment. |
| 2026-03-07 | 3bdb227 | Ellis Tarn | 1 | 406 | 263 | +143 | more_simple | rewrite 004-graph-execution from first principles (none) | Doc rewrite. |
| 2026-03-07 | 0e18cf8 | Ellis Tarn | 1 | 0 | 167 | −167 | more_simple | remove 005-performance: properties baked into 004 (none) | Doc deletion via consolidation. |
| 2026-03-06 | 730675c | Ellis Tarn | 1 | 271 | 245 | +26 | more_simple | rewrite 004-execution: DAG mechanics (none) | Doc rewrite. |
| 2026-03-06 | 647f76d | Ellis Tarn | 3 | 28 | 15 | +13 | more_simple | fix correctness and clarity in 001-003 (none) | Doc fixes. |
| 2026-03-06 | 01b1a8c | Ellis Tarn | 6 | 652 | 762 | −110 | more_simple | restructure design doc suite (none) | Reorder + align terminology. |
| 2026-03-06 | 80aa28c | Ellis Tarn | 5 | 840 | 293 | +547 | more_complex | add graph execution and ownership design docs (none) | New design surface. |
| 2026-03-05 | 688456a | Ellis Tarn | 6 | 1433 | 144 | +1289 | more_complex | implement GraphRevision (none) | Big new feature. |
| 2026-03-05 | b11a749 | Ellis Tarn | 11 | 247 | 332 | −85 | more_simple | reconcile implementation against design docs (none) | Code-design alignment. |
| 2026-03-04 | 3948ca1 | Ellis Tarn | 6 | 107 | 28 | +79 | more_complex | reconcile graph controller against 001-graph design (none) | +79 net to match design. |

## Counts and aggregates

- **Authors**: 1 (Ellis Tarn).
- **Date range**: 2026-03-04 to 2026-05-04 (about 2 months on the experimental subtree).
- **Counts**: 109 `more_simple`, 123 `more_complex`.
- **LOC totals**: +63,196 added, −59,287 deleted across 232 commits. Net +3,909.
- **Median commit size**: ~6 files, ~140 + / ~30 −.

## Patterns at first read

1. The `simplicity:`/`simplify:` prefix is a reliable label: every such commit is `more_simple`. Used as a first-class commit type by the team, like `feat:` or `fix:`.
2. `feat:` and explicit `add` commits are uniformly `more_complex`. New behavior reliably equals new code.
3. `fix:` is ambiguous: split between `more_simple` (when the fix is a deletion or constraint relocation, e.g. #228 typed map, #198 explicit state machine) and `more_complex` (when the fix adds branches for previously-missed cases, e.g. #224, #213).
4. The recent simplification PRs (#245, #247, #253, #249) clean up complexity that earlier `more_complex` commits had explicitly added: #190 type cache (+2568), #25 perf scoping (+548), #24 hash machinery (+616), #192 forEach incremental diff (+559), #93 perf code (+856), #166 hash rewrite (+255). The simplification work is a debt cleanup against earlier optimization-layer additions, not a steady-state simplicity discipline.
5. Renames and naming-alignment commits are uniformly `more_simple` with near-zero net LOC (#172 −1, #87 0, #88 0, #66 +47, #135 0, #140 0, #155 −3, #158 +6, #77 0, #44 0).
6. Doc-only commits split: design rewrites for clarity are `more_simple` (#105, #122, #91, #51, #49, #117); design additions of new mechanisms are `more_complex` (#48, #126, #150, #80aa28c).
7. The branch is roughly even on simple-vs-complex by count (109 vs 123), but the LOC totals are also near-balanced (+63K vs −59K). The large `more_simple` deletions (#191 −2292, #245 −2443, #247 −1522, #253 −1032, #252 −1915, #249 −1332) compensate for the large `more_complex` additions (#76 +3153, #126 +2352, #190 +2568, #4f844ef +1088, #213 +535, #1306 from #114).
8. The author is uniform; cross-author analysis is not possible on this subtree. To see a different signal you would need to extend scope to the parts of `kro/` that include other contributors, or look at upstream merges separately.

## What this view enables that the metric attempt did not

- A binary label per commit beats a curated 7-PR validation set.
- LOC and date columns surface temporal patterns: the simplification work clusters in the recent 30 days and targets specific older optimization-layer additions.
- The author column eliminates one degree of freedom (identity confound) by being constant — the variation in the data is entirely about what kind of work the same person did at different times.
