# S3 path cost measurement on pr-245 (pre vs post strip)

The S3 prompt now uses path cost (token count for a model to generate code from design and the reverse) plus artifact complexity, instead of a gzip-only first approximation. This file is the empirical demonstration on the (#190 final state, #245 final state) pair, which is the cleanest contrast pair in our corpus.

## Method

Pair: `experiments/kro/per-pr/pr-245/`. The pre side is the controller before #245 strip (= the post-#190 state with the optimization layer in place). The post side is after #245 strip.

For each side, two `claude -p` calls. Direction 1 generates Go code from the lifted design under the prompt: "Reconstruct a Go implementation that matches this design exactly. Output only Go source code." Direction 2 generates a design document from the production Go files under the prompt: "Read these Go files and produce a design document with Purpose, Procedures, and 10-15 testable Properties. Output only the design document."

Path cost is the response `output_tokens` field from the JSON return. Artifact complexity is `gzip -c | wc -c` on the design markdown files and on the concatenated production Go (excluding tests).

Test-suite-fixed assumption: both pre and post pass the kro e2e and compat suites at their respective commits, so correctness is held constant across the pair.

Model: default Claude Code Opus 4.7 (1M context).

## Numbers

| measurement | pre | post |
|---|---:|---:|
| design → code path cost (tokens) | **16,768** | **11,482** |
| code → design path cost (tokens) | 4,575 | 5,494 |
| design gzip size (bytes) | 1,839 | 1,368 |
| code gzip size (bytes, all production .go) | 58,533 | 37,632 |

Total cost across the four model calls: $2.22.

## Reading

**design → code direction.** Post takes ~31% fewer tokens than pre to reconstruct the code. The pre design (lifted from #190's post-state code) carries the full optimization-layer description, and the model has to generate type cache, three hash layers, trigger-scoped walks, and content-addressed graph sharing to reconstruct it. The post design (lifted from #245's post-state code) names the simpler sequential walk plus the apply-hash. The forward path cost matches the intuition: a design that mandates more machinery costs more tokens to expand.

**code → design direction.** Post took *more* tokens than pre (5,494 vs 4,575). Reading this honestly: the post code is more legible (clearer procedures, sharper boundaries), and the model wrote a more-developed design document for it. The pre code is harder to summarize cleanly because the optimization layer cuts across many files; the model's summary stayed at a higher level of abstraction. This is the kind of counter-direction signal the doc's caveats about confounds (model verbosity, artifact complexity measure assumptions) anticipate. The forward direction is the load-bearing measurement.

**Artifact complexity.** Both design and code artifacts shrink in post: design 1839 → 1368 bytes (-26%), code 58533 → 37632 bytes (-36%).

**4-cell placement.**

| | simple artifact | complex artifact |
|---|---|---|
| **low forward path cost** | **post** | |
| **high forward path cost** | | **pre** |

Pre lands in (high forward path cost, complex artifact) — the "neither earned its keep" quadrant. Post lands in (low forward path cost, simple artifact) — "design earned its keep on a simple result."

The framing distinguishes the pair correctly: post Pareto-dominates pre on (forward path cost, artifact complexity), which matches the team's actual decision to strip.

## Caveats

- **Cross-direction inconsistency.** The forward path cost (design → code) ordered pre > post; the reverse path cost (code → design) ordered post > pre. The doc says path cost alone collapses cases that artifact complexity recovers; it does not predict the two directions agreeing. The forward direction is the constraint-tightness measurement; the reverse direction tells a different story (legibility for human-readable summary). Reporting both is honest but the joint reading requires care.
- **Single model, single test-suite condition.** Path cost is model-relative. The test suite is held fixed implicitly because both pre and post pass kro's suite at their respective commits, but the model never actually executed any tests; it generated code that "should" pass. Validation against an actual test execution is the next step.
- **Memorization risk.** kro is public; the model has likely seen related code in training. The pre and post are commits weeks apart on a public branch, so any memorization would apply to both and partially cancel for the comparison. Absolute numbers may be inflated downward.
- **Output token noise.** `output_tokens` includes the model's full response. Larger models with more verbose tokenization will report higher counts for the same semantic output. The relative ordering inside a single model is the durable signal.

## Outputs

- `path-cost-run.sh` (in `/tmp/kro-simplicity-eval/`): the script that ran the four calls.
- `path-cost-pr245/results.tsv` (in `/tmp/kro-simplicity-eval/`): raw output_tokens, input_tokens, cost per direction.
- `path-cost-pr245/{pre,post}_{design_to_code,code_to_design}.json`: full JSON returns from each call.
