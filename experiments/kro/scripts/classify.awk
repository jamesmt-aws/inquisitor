# Apply Ellis-derived labels to commit subjects.
# Input: TSV with sha\tauthor\tdate\tfiles\tadds\tdels\tsubject
# Output: TSV with sha\tlabel\trule\tsubject
#
# Rule precedence: SIMPLE patterns > COMPLEX patterns > AMBIGUOUS.
# Multiple-action subjects ("X and Y") fall through to AMBIGUOUS unless
# both halves agree.
BEGIN { FS = "\t"; OFS = "\t" }
{
  sha = $1; subj = $7
  s = tolower(subj)
  label = ""; rule = ""

  # SIMPLE patterns
  if (s ~ /simplicity:/)           { label="simple"; rule="prefix:simplicity"; next_print() }
  else if (s ~ /simplify:/)        { label="simple"; rule="prefix:simplify"; next_print() }
  else if (s ~ /simplification/)   { label="simple"; rule="word:simplification"; next_print() }
  else if (s ~ / strip /)          { label="simple"; rule="verb:strip"; next_print() }
  else if (s ~ /^strip /)          { label="simple"; rule="verb:strip"; next_print() }
  else if (s ~ /unify/)            { label="simple"; rule="verb:unify"; next_print() }
  else if (s ~ /consolidat/)       { label="simple"; rule="verb:consolidate"; next_print() }
  else if (s ~ /deduplicat|dedup/) { label="simple"; rule="verb:dedup"; next_print() }
  else if (s ~ /collapse/)         { label="simple"; rule="verb:collapse"; next_print() }
  else if (s ~ /flatten/)          { label="simple"; rule="verb:flatten"; next_print() }
  else if (s ~ /^rename|: rename/) { label="simple"; rule="verb:rename"; next_print() }
  else if (s ~ /polish/)           { label="simple"; rule="verb:polish"; next_print() }
  else if (s ~ /reconcile.*against/) { label="simple"; rule="phrase:reconcile-against"; next_print() }
  else if (s ~ /move .* into|merge .* into/) { label="simple"; rule="verb:relocate-merge"; next_print() }
  else if (s ~ /^remove |: remove /) { label="simple"; rule="verb:remove"; next_print() }
  else if (s ~ /delete redundant|delete tautology/) { label="simple"; rule="phrase:delete-redundant"; next_print() }
  else if (s ~ /align.*naming|align code naming/) { label="simple"; rule="phrase:align-naming"; next_print() }
  # COMPLEX patterns
  else if (s ~ /^feat:|: feat/)    { label="complex"; rule="prefix:feat"; next_print() }
  else if (s ~ /^add |: add /)     { label="complex"; rule="verb:add"; next_print() }
  else if (s ~ /^implement |: implement /) { label="complex"; rule="verb:implement"; next_print() }
  else if (s ~ /introduce/)        { label="complex"; rule="verb:introduce"; next_print() }
  else if (s ~ /redesign/)         { label="complex"; rule="verb:redesign"; next_print() }
  else if (s ~ /^performance:|: performance|^perf:|: perf /) { label="complex"; rule="prefix:perf"; next_print() }
  # AMBIGUOUS
  else { label="ambiguous"; rule="no-clear-direction"; next_print() }
}
function next_print() {
  print sha, label, rule, subj
}
