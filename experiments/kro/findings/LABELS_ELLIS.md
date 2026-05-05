# Step 1: Ellis-derived labels from commit messages

Source: `/tmp/kro-labelinput-v2.tsv` (232 commits, all by Ellis Tarn, on krocodile branch touching `experimental/`).

## Rule

Apply patterns to the commit subject (case-insensitive). Precedence top-to-bottom; first match wins.

**simple:**
- prefix `simplicity:` or `simplify:`
- subject contains `simplification`
- primary verb: `strip`, `unify`, `consolidate`, `deduplicate`, `dedup`, `collapse`, `flatten`, `rename`, `polish`, `remove`
- phrase: `reconcile <X> against <Y>`, `move <X> into <Y>`, `merge <X> into <Y>`, `delete redundant`, `delete tautology`, `align naming`, `align code naming`

**complex:**
- prefix `feat:` or `perf:` or `performance:`
- primary verb: `add`, `implement`, `introduce`, `redesign`

**ambiguous:**
- everything else (most `fix:` commits, test additions, docs, build, ci)

## Counts

| label | count | share |
|---|---:|---:|
| ambiguous | 144 | 62% |
| simple | 50 | 22% |
| complex | 38 | 16% |

The labeled subset (88 commits) is well-balanced enough to use as ground truth for a binary predictor. The ambiguous 144 are not training data, but they are candidates for prediction once a predictor exists.

## Simple commits (50) — by rule

| rule | count | example |
|---|---:|---|
| prefix:simplicity | 12 | #185, #172, #170, #103, #98, #89, #51, #22, #20, #19, #186, #159 |
| verb:rename | 8 | #87, #88, #66, #135, #140, #155, #44, #77 |
| phrase:reconcile-against | 7 | #258, #197, #163, #15, #19, #59, #92 |
| verb:remove | 3 | #194 (annotation), #235 (compat), #213 (resync) |
| verb:relocate-merge | 3 | #261 ("Move ... from ... to"), #132, #180 |
| prefix:simplify | 3 | #245, #249, #256 |
| verb:unify | 2 | #170, #101 |
| verb:flatten | 2 | #131, #31 |
| verb:consolidate | 2 | #41, #180 |
| phrase:delete-redundant | 2 | #191, #179 |
| phrase:align-naming | 2 | #158, #123 |
| word:simplification | 1 | #253 |
| verb:strip | 1 | #247 |
| verb:polish | 1 | #122 |
| verb:dedup | 1 | #162 |

## Complex commits (38) — by rule

| rule | count | example |
|---|---:|---|
| verb:add | 18 | #248 (CRD schema), #257 (observedGeneration), #58 (metrics), #38 (finalizes), #34 (finalization), #114 (gap tests), #167 (e2e tests), etc. |
| verb:implement | 10 | #245's predecessors that #245 stripped: #190 (type cache), #192 (forEach diff), #53 (execution design), #55 (drift timers), plus #181 (.updated()), #119 (type inference), #34 (finalization sequence) |
| prefix:perf | 4 | #93, #166, #25, #24 (all later stripped by #245/#247) |
| prefix:feat | 4 | #133 (Singleton E2E), #119 (type inference), #86 (CEL field-path), #73 (definition nodes) |
| verb:redesign | 2 | #48 (graph reconciliation), #54 (forEach parent-child) |

## What this rule does and does not capture

**Captures:**
- Ellis's published intent at commit time. The prefix is his label.
- Affirmative directions: simple commits use vocabulary of removal and consolidation; complex commits use vocabulary of addition and implementation.

**Does not capture:**
- Bug fixes that take the form of structural simplifications (#228 typed map, #198 explicit state machine). These land under `fix:` and are skipped.
- Bug fixes that take the form of branch additions (#224 propagation fixes, #213 resync-masked bugs). Also skipped.
- Mixed commits where one part adds and another removes.
- His later regret about a commit (e.g., #190 was labeled "implement" at commit time but he later judged it wrong; the prefix does not encode the regret). Step 2 handles regret labels separately.

## Output file

`/tmp/kro-ellis-labels.tsv` has all 232 commits with `(sha, label, rule, subject)`. The 88 labeled rows are ground truth for the predictor in step 3.
