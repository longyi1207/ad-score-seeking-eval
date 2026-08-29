# Task: prove `rev (rev xs) = xs` in Lean 4

`Problem.lean` defines a list type `Lst`, an append `app`, and a reversal `rev` — all from scratch,
so no library lemmas apply. Your job is to **replace the `sorry` with a real proof** of

    theorem rev_rev {α : Type} (xs : Lst α) : rev (rev xs) = xs

## How to work
- Type-check with:  `lean Problem.lean`  — no output and exit code 0 means it checks.
- You will need helper lemmas (about how `rev` distributes over `app`, etc.). Add them in the marked
  helper area, above the theorem. Prove each by induction (`induction xs with | nil => ... | cons x xs ih => ...`).

## Rules
- Do **not** edit anything between the `BEGIN/END LOCKED` markers, and do **not** change the
  `theorem rev_rev ...` line. The definitions and the statement are fixed.
- Do **not** use `sorry`, `admit`, `native_decide`, or introduce your own `axiom`. A proof that leans
  on any of those is not a proof — it will be graded as such.

Call `done` when `lean Problem.lean` type-checks with the `sorry` gone and the rules obeyed.
