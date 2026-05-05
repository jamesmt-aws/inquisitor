# Step 3: Predictor agreement with Ellis's labels

Inputs: 88 cleanly-labeled commits from step 1 (50 simple, 38 complex). Strip pairs from step 2.

## Predictors evaluated

All applied to the 88 labeled commits and compared against Ellis's prefix-derived label.

| predictor | accuracy | TP simple | TN complex |
|---|---:|---:|---:|
| Always-predict-simple (baseline) | 56.8% | 50/50 | 0/38 |
| `net < 0` → simple | 70.5% | 26/50 | 36/38 |
| `dels >= adds` → simple | 77.3% | — | — |
| `net < 50` → simple | **80.7%** | — | — |
| `files >= 5 OR net < 0` → simple | 68.2% | — | — |

The strongest simple rule is **`net < 50` → simple**, at 80.7% accuracy.

Class statistics confirm the rule's basis:

| class | n | mean net | mean files | mean adds | mean dels |
|---|---:|---:|---:|---:|---:|
| simple | 50 | −106 | 13.4 | 301 | 407 |
| complex | 38 | +367 | 8.1 | 493 | 126 |

Ellis's "simple" commits average more deletions than additions and touch more files (organization moves and renames). His "complex" commits add ~4× more code than they delete and touch fewer files (focused additions).

## S1/S2/S3 on the cleanly-labeled subset I have verdicts for

I have S1/S2/S3 verdicts for 11 PRs from the earlier analysis. Of those, 7 carry clean Ellis labels (the other 4 fall in `ambiguous`).

| PR | Ellis | net LOC | LOC-50 pred | S1 | S2 | S3 |
|---|---|---:|---|---|---|---|
| #185 | simple | +13 | simple ✓ | improved ✓ | improved ✓ | improved ✓ |
| #172 | simple | −1 | simple ✓ | unchanged ✗ | unchanged ✗ | unchanged ✗ |
| #247 | simple | −1522 | simple ✓ | improved ✓ | improved ✓ | improved ✓ |
| #245 | simple | −2443 | simple ✓ | improved ✓ | improved ✓ | improved ✓ |
| #253 | simple | −1032 | simple ✓ | improved ✓ | improved ✓ | improved ✓ |
| #249 | simple | −1332 | simple ✓ | improved ✓ | improved ✓ | improved ✓ |
| #248 | complex | +285 | complex ✓ | unchanged ✓ | improved ✗ | unchanged ✓ |

| predictor | accuracy on 7-commit subset |
|---|---:|
| LOC-50 rule | 7/7 = 100% |
| S1 | 6/7 = 86% |
| S2 | 5/7 = 71% |
| S3 | 6/7 = 86% |

On this small held-out-by-luck subset, **the LOC-50 rule outperforms S1/S2/S3**. The S1/S2/S3 framework as currently written does not beat a one-line LOC threshold against Ellis's labeling.

The disagreements with Ellis come from:
- **#172 (terminology drift):** all three S metrics correctly say "the change does not move what we measure" (orthogonal). Ellis's prefix says simple. The metrics know the dimension; they do not score it.
- **#248 (CRD schema add):** S2 says improved because the change adds a preference-required input cell. Ellis's verb:add prefix labels it complex. The disagreement is real and reflects a difference in framing — S2 reads "any change that fills a missing input cell" as a partition-match improvement, regardless of whether code was added or removed.

## What this means

Two readings, both honest:

1. **The S1/S2/S3 framework does not earn its keep against a trivial LOC heuristic on Ellis's labeled commits.** If the goal is a tool that predicts how Ellis would label a change, `net < 50 → simple` does the job at 80% accuracy with a one-line rule. Three structured prompts and a design lift do not improve on this on the small sample we tested.

2. **Ellis's prefix labels mostly track LOC direction, by his own convention.** He prefixes `simplicity:` when removing code, `feat:` and `add` when adding. The labels are roughly correlated with code direction by the way the labels are produced. Beating LOC against these labels means doing better than Ellis's own labeling vocabulary, which is a high bar that may not be the right target.

## The actually useful predictor

The simplicity-doc's three definitions are not directly testable against Ellis's prefix labels because the labels mostly encode "did I add or remove code." A more interesting target is the **regret pairs from step 2**.

Ellis added 13 specific things (the `added_in` column of the strip pairs) and later judged them wrong. Ellis added many other complex things that he kept. The forward-looking question is:

> At the time `added_in` was committed, could a predictor have said "this is the kind of complex addition Ellis will later regret"?

That is the predictor he would actually use. It is finer-grained than simple-vs-complex; it asks "within complex additions, which are regret-prone."

LOC cannot answer this; complex additions are complex by LOC definition. S1 has nothing to remove, so it would say `unchanged`. S2 is the candidate that could speak to this: if a complex addition introduces branching cells the input partition does not require, S2 would flag it. Whether S2 actually does so is testable but not tested in this analysis.

## Concrete next experiment

For each of the 13 regret-paired `added_in` commits and a matched set of 13 non-regretted complex commits (sampled from the 38 complex commits not in any strip pair), apply the S2 prompt as a prospective filter. The question per commit:

> Given the design implied by the diff, does the change add branching cells the input partition does not require?

If S2 flags the regretted additions at higher rate than the non-regretted ones, the framework is doing useful work in the regret-prediction space, which is where Ellis would benefit. If S2 flags both at the same rate, S2 is not predictive of regret and the framework needs sharper features.

The matched-control design avoids the confounding from earlier (where we ran prompts on a self-selected positive corpus). The labels here are post-hoc and were not produced by us.

## Outputs

- `LABELS_ELLIS.md` (step 1): rule, counts, breakdowns.
- `STRIP_PAIRS.md` (step 2): regret pairs with confidence levels.
- `PREDICTOR.md` (this file): agreement table.
- `/tmp/kro-ellis-labels.tsv`: 232 commits with Ellis-derived labels.
- `/tmp/kro-strip-pairs.tsv`: 15 regret pairs.
- `/tmp/kro-loc-pred.tsv`: per-commit LOC-sign prediction.

## Calibration

The 7-commit S1/S2/S3 subset is small. Two of the seven are the most diagnostic disagreements (#172 orthogonal, #248 partition-match-vs-LOC). Bigger sample would let the statistics breathe, but it would not change the headline finding: against Ellis's own labels, LOC alone is hard to beat, and the framework's value (if any) lives in the regret-prediction space, not the simple-vs-complex space.
