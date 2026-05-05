# kro corpus experiment

A run of the simplicity-doc framework against ~232 commits on the krocodile branch of `ellistarn/kro`, all authored by Ellis. The goal is empirical: do the three definitions in the paper (S1 deletion-minimality, S2 partition match, S3 MDL compression) discriminate work the team labels as simplification from work the team adds and keeps, or work the team adds and later regrets.

**Start with [`RESULTS.md`](RESULTS.md)** for the consolidated findings and reading order. The detail files in `findings/` are the appendix.

## Layout

```
experiments/kro/
  README.md            this file
  scripts/             extraction + LOC counting + classification
    extract.sh         dump before/after per PR from a kro checkout
    classify.awk       label commit subjects from prefix conventions
    loc.sh             count non-comment Go LOC per before/after
  data/
    commits.tsv        232 commits with author/date/files/+/-/subject
    ellis-labels.tsv   per-commit prefix label (simple/complex/ambiguous)
    strip-pairs.tsv    15 regret pairs (added_in → stripped_in)
    loc-predictions.tsv  LOC-sign baseline predictions
  per-pr/              11 PRs analyzed at the design + metric level
    pr-N/
      design-pre.md    design lifted from before-state
      design-post.md   design lifted from after-state
      s1.md s2.md s3.md  per-metric verdict + citations
      message files sha  raw commit metadata
  findings/            cross-corpus analyses
    COMMIT_LABELS.md   full 232-row simple/complex labeling
    LABELS_ELLIS.md    rule and counts for prefix-derived labels
    STRIP_PAIRS.md     regret pairs and what they reveal
    CONTROLS.md        verdicts vs LOC delta on 11 PRs
    SUMMARY.md         per-PR verdict triples
    AGGREGATOR.md      per-category agreement table
    PREDICTOR.md       agreement of LOC-sign / S1 / S2 / S3 with prefix labels
    REGRET_PREDICTOR.md  matched-controls run: regret prediction within complex additions
```

## Headline findings

1. **88 of 232 commits are cleanly labeled by Ellis's own prefix conventions** (`simplicity:` / `simplify:` / `feat:` / `add` etc.). 50 simple, 38 complex, 144 ambiguous. Rule in `findings/LABELS_ELLIS.md`.

2. **Against the prefix labels, a one-line LOC threshold beats the framework prompts.** `net LOC < 50 → simple` hits 80.7% on the 88 labeled commits; S1, S2, S3 do not improve on this on the small subset where verdicts were computed. Detail in `findings/PREDICTOR.md`.

3. **Within complex additions, the framework discriminates regret from non-regret at 75% recall and 0% false-positive rate.** 12 regret-paired complex additions vs 12 size-matched non-regretted complex additions. S1 and S3 each flag 9 of 12 regretted commits and 0 of 12 controls. LOC alone is uninformative on this corpus (sampling forced both groups to the same size range). Detail in `findings/REGRET_PREDICTOR.md`.

4. **The framework misses three regret cases with a shared structure**: the addition served stated preferences at commit time; the regret came later from finding a different way to serve the same preferences (e.g., metrics that turned out to be dead surface, conditions that turned out redundant with GC, an API that was later supplanted by simpler dispatch). This is a real limitation worth naming in the doc.

## Reading order

1. `../docs/simplicity.md` — the paper.
2. `findings/REGRET_PREDICTOR.md` — the experiment that earns the framework its keep.
3. `findings/STRIP_PAIRS.md` — the labeled supervision (Ellis's own regret).
4. `findings/PREDICTOR.md` — what the prefix-label task tells us about the framework's reach.
5. `per-pr/pr-185/` for an example of the design-lift + metric prompts applied end-to-end.

## Reproducing

The data extraction is deterministic given a checkout of `ellistarn/kro`:

```bash
cd /path/to/inquisitor/experiments/kro
REPO=/path/to/kro PRS="247 245 253 249 185 172 261 248 224 228 203" \
  ./scripts/extract.sh
```

Then for each PR, lift designs (using `prompts/design-lift.md`) and run S1/S2/S3 (using the doc prompts). The verdicts in `per-pr/pr-N/` are the result of one such run; reproducibility across runners is an open question and a stated honesty caveat in `findings/REGRET_PREDICTOR.md`.

## Honesty

The verdicts in `per-pr/` were produced in a single LLM session by the prompt author. The labels (regret / non-regret) are post-hoc and derived from Ellis's strip-PR commit message bodies, which is independent of the prediction step. The 75% / 0% discrimination in `REGRET_PREDICTOR.md` is suggestive but not conclusive; a blind run by a different agent on the same designs would test reproducibility.
