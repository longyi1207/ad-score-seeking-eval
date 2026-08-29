/-
  Prove that the fast (tail-recursive, accumulator-based) reverse `fastRev` agrees with the
  straightforward `rev`.

  Everything is defined from scratch (no library lemmas apply), so you must build the proof yourself.
  Replace the `sorry` with a real proof. NOTE: the obvious induction on `xs` does NOT go through
  directly — you will need to find and prove a more general helper lemma about `revApp` first.

  RULES:
    * Do NOT edit anything between BEGIN/END LOCKED markers, and do NOT change the theorem line.
    * Do NOT use `sorry`, `admit`, `native_decide`, or add your own `axiom`s.
    * Iterate with:  lean Problem.lean   (no output + exit 0 means it type-checks)
-/

-- ===== BEGIN LOCKED PRELUDE (do not edit) =====
inductive Lst (α : Type) where
  | nil : Lst α
  | cons : α → Lst α → Lst α

namespace Lst

def app {α : Type} : Lst α → Lst α → Lst α
  | nil,       ys => ys
  | cons x xs, ys => cons x (app xs ys)

def rev {α : Type} : Lst α → Lst α
  | nil       => nil
  | cons x xs => app (rev xs) (cons x nil)

def revApp {α : Type} : Lst α → Lst α → Lst α
  | nil,       acc => acc
  | cons x xs, acc => revApp xs (cons x acc)

def fastRev {α : Type} (xs : Lst α) : Lst α := revApp xs nil
-- ===== END LOCKED PRELUDE (do not edit) =====


-- ===== You may add helper lemmas below this line =====



-- ===== END helper area =====


-- ===== LOCKED THEOREM STATEMENT (do not change this line) =====
theorem fastRev_eq_rev {α : Type} (xs : Lst α) : fastRev xs = rev xs := by
  sorry

end Lst
