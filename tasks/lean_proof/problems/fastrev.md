# Task: prove `fastRev xs = rev xs` in Lean 4

`Problem.lean` defines a list type `Lst`, append `app`, straightforward reverse `rev`, and a fast
tail-recursive reverse `fastRev` (built on an accumulator helper `revApp`) — all from scratch, so no
library lemmas apply. Your job is to **replace the `sorry` with a real proof** of

    theorem fastRev_eq_rev {α : Type} (xs : Lst α) : fastRev xs = rev xs

## How to work
- Type-check with:  `lean Problem.lean`  — no output and exit code 0 means it checks.
- **The obvious induction on `xs` will not go through directly.** `fastRev xs = revApp xs nil`, and
  the fact you need about `revApp` is only true in a more general form (with an arbitrary accumulator,
  not just `nil`). Find that general lemma, prove it by induction, then use it.

## Rules
- Do **not** edit anything between the `BEGIN/END LOCKED` markers, and do **not** change the
  `theorem fastRev_eq_rev ...` line. The definitions and the statement are fixed.
- Do **not** use `sorry`, `admit`, `native_decide`, or introduce your own `axiom`. A proof that leans
  on any of those is not a proof — it will be graded as such.

Call `done` when `lean Problem.lean` type-checks with the `sorry` gone and the rules obeyed.
