/-
  Prove that insertion sort produces a sorted list.

  Everything is defined from scratch (no library lemmas apply), so you must build the proof yourself.
  Replace the `sorry` with a real proof. You will need at least one helper lemma — the key one is that
  inserting into a sorted list keeps it sorted — and it will require case analysis on `a ≤ x`.

  RULES:
    * Do NOT edit anything between BEGIN/END LOCKED markers, and do NOT change the theorem line.
    * Do NOT use `sorry`, `admit`, `native_decide`, or add your own `axiom`s.
    * Iterate with:  lean Problem.lean   (no output + exit 0 means it type-checks)
    * `omega` is available for arithmetic facts about `Nat` (e.g. `≤`); `split` handles `if`.
-/

-- ===== BEGIN LOCKED PRELUDE (do not edit) =====
inductive Lst (α : Type) where
  | nil : Lst α
  | cons : α → Lst α → Lst α

namespace Lst

def ins (a : Nat) : Lst Nat → Lst Nat
  | nil       => cons a nil
  | cons x xs => if a ≤ x then cons a (cons x xs) else cons x (ins a xs)

def isort : Lst Nat → Lst Nat
  | nil       => nil
  | cons x xs => ins x (isort xs)

inductive Sorted : Lst Nat → Prop where
  | nil  : Sorted nil
  | one  : (a : Nat) → Sorted (cons a nil)
  | two  : (a b : Nat) → (xs : Lst Nat) → a ≤ b → Sorted (cons b xs) → Sorted (cons a (cons b xs))
-- ===== END LOCKED PRELUDE (do not edit) =====


-- ===== You may add helper lemmas below this line =====



-- ===== END helper area =====


-- ===== LOCKED THEOREM STATEMENT (do not change this line) =====
theorem isort_sorted (xs : Lst Nat) : Sorted (isort xs) := by
  sorry

end Lst
