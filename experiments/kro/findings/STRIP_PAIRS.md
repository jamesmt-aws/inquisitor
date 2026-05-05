# Step 2: Regret pairs (added then stripped)

A regret pair is `(added_in, stripped_in)` where Ellis explicitly removed in `stripped_in` machinery he had earlier added in `added_in`. Regret pairs are stronger than prefix labels because they capture his post-hoc judgment that the addition was not worth the cost.

Identified from the bodies of the four major strip PRs (#245, #247, #249, #253) plus the explicit walk-back (#261).

## Pairs

| stripped in | added in | what was stripped | confidence |
|---|---|---|---|
| #261 (d94ded6) | #220 (cd46848) | `walkstate.go` location: split into `dag/`, then moved back to `controller/` | explicit walk-back, named in body |
| #245 (9014431) | #190 (58dd9a5) | Type cache, structural caching, evaluation-cache snapshots | strong (#190 added these, #245 strips "evaluation caching") |
| #245 | #192 (22681e7) | forEach O(changed) incremental diff: per-item content hash caching | strong (#192 named forEach incremental; #245 strips it explicitly) |
| #245 | #24 (d6d6e4e) | Section-scoped input hashing, scoped walks (3-layer hash system) | strong |
| #245 | #166 (96048c6) | Custom 2x faster hashDesiredState | medium (#245 strips "hash machinery"; #166 added the custom hasher) |
| #245 | #55 (f2231a6) | Drift timers, trigger-scoped walks | strong |
| #245 | #53 (56b0d7b) | Worker goroutine dispatch, Path 1/2/3 routing | strong |
| #245 | #93 (f5c3dc5) | Perf code, cache leak fix, Kahn's O(V²) rewrite | medium |
| #247 (9e4b2f7) | #25 (e02896f) | Content-addressed compiled graph sharing across instances | strong (named in #247 body) |
| #247 | #58 (8ac5620) | `ResyncTimerFiresTotal`, `SelfRefreshTotal` metrics (parts) | strong (named in #247 body) |
| #247 | #17 (4f844ef) | Revision Ready/Active conditions; #247 keeps only GC | strong (named in #247 body) |
| #247 | #224 (9313102) | Watch interfaces `DrainTriggers`, `DepositTrigger`, `RetainWatches`, etc. | strong (#224 added DepositTrigger; #247 strips it) |
| #249 (439a520) | #190 (58dd9a5) | `graphcache.go` (compilation cache surface that survived #245) | medium (#249 names "graphcache.go ... compilation cache") |
| #249 | #58 (8ac5620) | `metrics.go` (Prometheus metrics surface) | medium |
| #249 | #166 (96048c6) | `hash.go` (apply-hash annotation logic that survived #245) | medium |

## What the pairs reveal

1. **#190 (58dd9a5) is the highest-cost regret in the corpus.** It added the type cache, structural caching, recursive validation, and dynamic-GVK detection in one PR (+2568 net LOC). Three later PRs strip parts of it (#245, #249, #253). Ellis's later judgment is that #190's optimization layer was wrong to add; the design holding pen `007-optimizations.md` exists to absorb the deferred claim that was previously implicit in #190's code.

2. **The optimization-layer cluster** (#24, #25, #53, #55, #58, #79, #93, #166, #190, #192) accounts for the bulk of stripped work. Ellis added optimization machinery aggressively in March-April 2026, then stripped it in late April–May 2026.

3. **One walk-back at the file-boundary level**: (#220, #261). Ellis split walkstate into the dag/ package, lived with it, then judged the split was wrong because reconcile-time types do not belong in the compile-time package. This is the only pure file-boundary regret in the corpus; the rest are about machinery.

4. **No regret pairs at the rename/naming level.** Ellis renames things and the renames stick. This is consistent with the framework's read on #172 (terminology drift) — naming work pays off and stays. He does not appear to walk back naming decisions.

## Use as supervised signal

Each regret pair (`added`, `stripped`) gives two labeled examples:

- `added` is **complex-with-regret**: at commit time, this was new code Ellis judged worthwhile; later he judged it wrong. Stronger than a plain "complex" label because it includes the post-hoc regret.
- `stripped` is **simple-as-cleanup**: removing the regretted addition. Stronger than a plain "simple" label because it targets specific named earlier work.

A predictor that learns from these pairs has access to "Ellis added X and later regretted X" — which is closer to the simplicity question Ellis is actually asking ("how do I avoid adding things I'll regret") than the prefix labels alone.

## Output

`/tmp/kro-strip-pairs.tsv`:

```
stripped_sha	added_sha	what	confidence
d94ded6	cd46848	walkstate location	high
9014431	58dd9a5	type cache, evaluation caching	strong
9014431	22681e7	forEach incremental diff	strong
9014431	d6d6e4e	section-scoped hashing	strong
9014431	96048c6	custom hashDesiredState	medium
9014431	f2231a6	drift timers, trigger-scoped walks	strong
9014431	56b0d7b	worker goroutine dispatch	strong
9014431	f5c3dc5	perf rewrite	medium
9e4b2f7	e02896f	content-addressed graph sharing	strong
9e4b2f7	8ac5620	resync/self-refresh metrics	strong
9e4b2f7	4f844ef	revision Ready/Active conditions	strong
9e4b2f7	9313102	watch interfaces	strong
439a520	58dd9a5	graphcache.go	medium
439a520	8ac5620	metrics.go	medium
439a520	96048c6	hash.go	medium
```
