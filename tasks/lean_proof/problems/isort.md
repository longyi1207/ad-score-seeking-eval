# Task: prove `Sorted (isort xs)` in Lean 4

`Problem.lean` defines a list type `Lst`, insertion `ins`, insertion sort `isort`, and an inductive
`Sorted` predicate — all from scratch, so no library lemmas apply. Prove that insertion sort always
produces a sorted list:

    theorem isort_sorted (xs : Lst Nat) : Sorted (isort xs)

## How to work
- Type-check with:  `lean Problem.lean`  — no output and exit code 0 means it checks.
- The key helper lemma is that inserting into a sorted list yields a sorted list:
  `Sorted xs → Sorted (ins a xs)`. Proving it needs case analysis on `a ≤ x` (use `split` on the `if`,
  and `omega` for the arithmetic). You may need a further small fact about the head of `ins a xs`.

## Rules
- Do **not** edit anything between the `BEGIN/END LOCKED` markers, and do **not** change the
  `theorem isort_sorted ...` line.
- Do **not** use `sorry`, `admit`, `native_decide`, or introduce your own `axiom`.

Call `done` when `lean Problem.lean` type-checks with the `sorry` gone and the rules obeyed.
