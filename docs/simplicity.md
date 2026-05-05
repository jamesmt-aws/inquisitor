# Three Computable Definitions of Simplicity

Software customers today choose between expensive artisanal code and cheap slop. The artisanal end of the market produces small volumes of careful, correct, maintainable software at high cost. The slop end produces vast volumes of code that mostly works, sometimes does not, costs little, and accumulates technical debt at every step. Most software is somewhere on this line, and the line is not satisfying. Customers who need correctness pay a premium that scales with their codebase. Customers who accept low quality get cheap code that costs them later in defects, performance, and time spent untangling what was generated.

The opportunity is in the gap between the two ends. There is much more slop than there are artisans, and the slop is being produced faster than the artisans can review it. A filter that reliably separates code worth keeping from code worth rewriting would let factory-scale generation produce artisan-quality output. The leverage is in the asymmetry: one good filter applied to a large volume of generated code is worth far more than one good engineer applied to a small volume. The filter has to be cheap enough to run on every candidate and discriminating enough to actually separate the two populations. Defining the filter is the engineering problem. Simplicity is a large part of the answer.

Three pieces of evidence anchor why simplicity is worth filtering for. **Comprehension cost is real and measurable.** Peitek et al. 2021 used fMRI to measure brain activation while programmers read code and found that established complexity metrics predict comprehension load at the neural level. Complex code makes humans work harder to understand, in a way that shows up directly in brain imaging. **Performance cost is real and measurable.** Driesen and Hölzle 1996 measured the runtime cost of virtual dispatch in C++ and found a median overhead of 5.2% and a worst case near 50%, before counting the indirect cost of optimizations the dispatch blocks. Indirection has a price the machine pays on every call. **Iteration cost is real and measurable.** Basili, Briand, and Melo 1996 validated object-oriented design metrics against fault-proneness on eight industrial C++ systems and found that five of six metrics significantly predicted defects. Complex modules break more often, which means the cost of changing them is paid in regressions and debugging time. The mechanisms differ but the direction is consistent: simpler code is easier to read, faster to run, and cheaper to change.

What is missing is a definition of simplicity that a machine can compute on a single artifact, cheaply, without requiring a human in the loop. Code generation is getting cheap. What stays expensive is the judgment that separates a working program from a clean one, and at factory throughput that judgment has to be encoded in something the system can score and optimize against. This note offers three definitions of simplicity that meet the bar. Each captures a different aspect of what makes one design cleaner than another. None is obviously the right answer, and they can disagree on the same artifact. We hope they correlate with whatever simplicity actually is. We measure them because they are what we can compute.

## A filter is a sort with a threshold

A scoring function orders the design space. "Disruption cost minus savings" orders designs by economic merit. "P99 I/O latency" orders them by tail latency. "Number of branches in the consolidation policy" orders them by structural simplicity. Each ordering captures one axis of what we care about.

A threshold turns an ordering into an admissibility test. "Disruption cost minus savings, must be ≤ 0" filters out designs that disrupt at a loss. "P99 latency, must be under 5ms" filters out designs that miss a target. The threshold is what makes a scoring function feel like a binary requirement. Without it, the same scoring function is a preference: lower is better, but no level is automatically rejected.

The choice between "filter" and "preference" is the choice of whether to commit to a threshold. It is not a property of the scoring function itself. The same metric can act as either, depending on how strictly the team is willing to commit. Some metrics earn thresholds because the cost of crossing them is catastrophic (correctness invariants, safety properties). Others stay as preferences because the team has not yet decided what trade is worth making (latency, cost, code size). Naming the threshold or refusing to name it is itself a design choice, and a meaningful one.

Simplicity is a scoring function, not a threshold. The metrics below order designs from less simple to more simple along three different axes. Whether to threshold any of them, and where, is a separate decision that depends on context. The metrics also have to be useful enough for engineers to actually apply, which is an empirical question that depends on how well the metric correlates with human judgment in the team's specific setting. We expect to improve the metrics through human feedback, feature engineering, and prompt tuning (which may be the same thing). The job here is to pick scoring functions that order designs sensibly. The job of calibrating, thresholding, and improving them belongs to whoever is running the loop.

## Code is a specific design

Design and code are not different kinds of artifact. They are points on a continuum of specificity. "Use a hash map keyed on tenant id" is a design. `std::unordered_map<TenantId, Account>` is a more specific design. The actual call site with a chosen hash function and a chosen allocator is more specific still. Each is a description of behavior at a different resolution. Code is just a design specific enough to run.

The metrics below apply at every resolution. Deletion-minimality scores a module list as well as a function body. Partition match scores an architecture diagram as well as a switch statement. MDL scores any artifact that has a description length. Treating code as a special case of design means the same vocabulary covers what a senior engineer does at the whiteboard and what an automated loop does at the AST. The framing in the rest of the note is "design," and "code" is the case where the resolution is high enough to compile.

## S₁: deletion-minimality

The first definition is local. A design is deletion-minimal if removing any unit of it produces a design that fails to type-check, falls below threshold on a thresholded preference, or scores strictly lower on a non-thresholded one (in the sense of Sands 1998). The unit can be a function, a module, a type parameter, a call edge, a configuration option, or, at lower resolution, a component, a service boundary, or a layer. The compiler tells you which deletions produce a working artifact at all; the surviving deletions are scored against the user's chosen preferences.

This is the empirical handle. Mutation testing approximates it for code (Jia and Harman 2011 for the survey). The limit is that it gives local minimality only. A different design of half the size might score equivalently, and deletion cannot reach it from the design you started with. Restructuring crosses between local minima, and deletion-minimality cannot evaluate restructurings. A fixed point of deletion has eliminated everything removable without restructuring. That is useful even though restructurings might find something smaller still.

## S₂: partition match

The second definition is structural and starts from two partitions over the same input space.

The input partition is what the user's preferences force the design to distinguish. If a preference gives different scores to "spot interruption" inputs and "voluntary consolidation" inputs, then those two situations belong in different cells. The cells are exactly the distinctions the preferences care about.

The branching partition is what the design actually distinguishes. Two inputs share a cell when the design runs the same path on both. Every if-statement, every switch, every dispatch site adds branches and refines this partition.

Three cases for how these partitions relate. If the branching partition is finer than the input partition, the design is making distinctions the preferences do not pick up on. The Go/AWS-vs-GCP-vs-Azure split when the only behavior being scored is "remote object store" is the canonical example. If the branching partition is coarser than the input partition, the design is missing distinctions the preferences reward, and it is scoring lower than it could on at least one input. One catch-all error path when the preferences reward retrying transient errors and aborting on permanent ones is the canonical example. If the two partitions match, the design distinguishes exactly what the preferences reward and nothing more.

The simplicity metric is the partition match. Among designs that score acceptably on the user's chosen preferences, the simplest one has a branching partition that matches the input partition. No extra cells. Acceptable scoring is the constraint that prevents the trivial answer of "no branches at all"; matching the input partition is the operational target.

The metric catches designs that branch on distinctions the preferences do not reward. Karpenter's consolidation controller faces four input cases (do-not-disrupt nodes, PDB-governed pods, spot interruption, voluntary consolidation against on-demand). A naive controller branches four ways at the policy layer, splitting the input partition into four code paths. A controller that encodes each case as a cost value runs one rule and consumes the cost. The input partition is unchanged. The branching partition collapses from four cells to one. The four-way design was finer than the input partition required at the layer where the branches lived; the cost-value design relocates the distinctions to a place (the cost function) where they no longer multiply policy paths.

The relationship to cyclomatic complexity (McCabe 1976) is direct. McCabe counts every branch in the control-flow graph. The partition-match metric counts only branches that distinguish behaviorally significant cases, conditioned on the design scoring acceptably. The restriction makes the count comparable across designs in a way that the raw number is not.

## S₃: MDL compression

The third definition is global. A lower-resolution design earns its place over a higher-resolution one when including it as a separate description reduces total description length: −log P(low) + −log P(high | low) < −log P(high). The lower-resolution description has to compress the higher-resolution one more than it costs to describe. In the special case where "high" is code and "low" is the architecture document, this is the standard MDL question of whether the document earns its keep.

MDL is the one of the three designed for comparison across radically different structural commitments. The other two compare candidates that share a structural commitment. MDL admits structurally different alternatives into the comparison and gives a single number. The cost is that it requires a coding scheme. Li and Vitányi 2008 and Grünwald 2007 give the formal theory.

The operational form we use combines two measurements. **Path cost** is the number of tokens a capable model uses to generate the code given the design (estimating K(code | design)) and the reverse (estimating K(design | code)). Both directions are measured with the same test suite held fixed across the comparison, so correctness is constant and any difference reflects how much each design constrains its code. **Artifact complexity** measures each artifact in isolation: length, gzip size, McCabe, or another simple measure, reported for both endpoints of every (design, code) pair. The reason path cost alone is not enough is that it collapses four diagnostically different cases:

| | simple artifact | complex artifact |
|---|---|---|
| **low path cost** | design tightly determines a simple result | design tightly determines a large result (a grammar producing a parser) |
| **high path cost** | design did not constrain; the answer happened to be simple | design did not help; output is messy |

Path cost on its own treats the top row identically and the bottom row identically. Adding artifact complexity recovers the four cases. C₃ becomes: along these two combined dimensions, which design pair lowers path cost while keeping artifacts simple?

Two caveats. Path-cost estimates are model-relative: K(code | design) measured through one model differs from the same quantity measured through another. The Pareto loop tolerates this because the same model is used across comparisons; absolute scale is meaningless but ordering is preserved. The full validation move is either to integrate over an ensemble (MCMC-style sampling) or commit to a fixed reference model and report the dependence. Memorization is a related concern, especially for public codebases the model has seen; private code or held-out forks suppress it. Wang 2025 (arXiv:2501.06802) frames LLM inference as approximating conditional Kolmogorov complexity, Burnell et al. 2024 (EPJ Data Science 2025) operationalizes the LLM-as-reference move for risk assessment, and Lotfi et al. 2024 (NeurIPS) uses compressed model size as a Kolmogorov bound for generalization. The components are in the literature; the specific harness is ours to validate.

## Where distinctions go

A distinction is real and has to be encoded somewhere. The question is which layer encodes it. When a design fails one of the tests above, the response is to relocate the distinction from a layer where it shows up as a branch to a layer where it shows up as data, structure, or type. Six places it can go:

- **Into a richer cost function.** Do-not-disrupt, PDBs, and spot interruption collapse to one decision rule when each is encoded as a cost value. The rule consumes a richer input and the branches go away.
- **Into the type system.** Dependent types absorb invariants that would otherwise be runtime checks. Refinement types absorb constraints that would otherwise be assertions. The compiler discharges the case analysis at type-check time.
- **Into the action representation.** Widen the action so variants become parameter values. Separate code paths for "drain node" and "replace node" collapse into one parameterized action.
- **Into the state.** A richer state schema lets one policy handle cases that would otherwise need a discriminator and a switch. The state carries the distinction that the policy was previously branching on.
- **Into module structure.** Parnas's 1972 instruction: hide the design decision so callers cannot branch on it. The decision still has to be made, but only inside the module that owns it.
- **Into dispatch.** Replace switch statements over a discriminator type with virtual methods or trait implementations. The language runtime carries the case analysis.

Branches at the consuming layer are the failure mode the three metrics catch. The fix in every case is the same shape: relocate.

## Existing handles and what they measure

Cyclomatic complexity (McCabe 1976) counts branches without conditioning on behavior. It cannot distinguish a branch that earns its keep from one that should not be there, but it is cheap and widely available. Shepperd 1988 argues it is largely a proxy for size; treat it as a starting point rather than a settled metric. Lines of code is too coarse and too sensitive to formatting. Halstead metrics count tokens and have no semantics. Mutation testing is the empirical face of deletion-minimality and is expensive but well-understood. Parametricity (Reynolds 1983, Wadler 1989) measures how much information lives in the types: stronger types push the lower-resolution description closer to determining the higher-resolution one, and tighten what the design can guarantee with less code. MDL approximations through gzip or learned models are usable for global comparison but noisy.

None of these subsume each other. Cyclomatic complexity and mutation testing speak to deletion. Parametricity speaks to type-system absorption. MDL speaks to global comparison. The three definitions above carve out different pieces of what is actually a multi-valued property.

## What this gives the factory

An automated loop optimizing for simplicity needs preferences and an order on designs. The metrics here, S₁, S₂, and S₃, are candidates for a filter on design quality. Each captures one axis of what makes a design cleaner. In future work, we will measure how good they need to be in order to provide measurable value for our software engineers in highlighting and resolving issues related to simplicity of software designs. The vocabulary is here. The appendix gives prompts for trying it out.

## Appendix: prompts for trying this out

Each prompt is meant to be run against a single artifact (a function, a module, a service, a design document) with a clearly stated set of preferences and any thresholds the user has committed to.

**S₁ (deletion-minimality).** "Here is a design and a set of preferences, some with committed thresholds. For each unit of the design (function, module, type parameter, configuration option), tell me whether removing it would (a) drop a thresholded preference below its threshold, (b) leave all thresholds satisfied but drop a non-thresholded preference, or (c) leave all preferences unchanged. Report only units in category (c) as candidates for deletion."

**S₂ (partition match).** "Here is a design and a set of preferences. List the input cases the preferences force the design to distinguish (the input partition). Separately, list the cases the design's branches and dispatch sites actually distinguish (the branching partition). Report each branching distinction that does not appear in the input partition; these are candidates for relocation into data, types, or a richer cost function. Report each input distinction that does not appear in the branching partition; these are candidates for the design scoring lower than it could on at least one input."

**S₃ (MDL compression).** "Here is a design, the code that implements it, and a test suite the code passes. (1) Generate the code from the design under the test suite, and report the token cost (estimating K(code | design)). (2) Generate the design from the code, and report that token cost (estimating K(design | code)). (3) Report the gzip size or line count of each artifact in isolation. Place the (design, code) pair in one of four cells crossed by (low/high path cost) and (simple/complex artifact). The two high-path-cost cells are flags; the (high, complex) cell is the strongest. Record the model used; the measurement is model-relative."

**Threshold hygiene.** "Here is a list of stated commitments about the system. For each, identify (a) the underlying preference, (b) whether the user has committed to a threshold, and if so what level. Flag any commitment whose preference is unclear or unmeasurable. Flag any threshold that is implicit (the user is acting as if a threshold exists but has not named it). Flag any commitment that mixes multiple preferences in a way that hides what is being traded against what."
