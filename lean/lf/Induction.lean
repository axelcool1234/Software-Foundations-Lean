import lf.Basics

set_option autoImplicit false

open NatPlayground2 (minus plus)
open bin

/- ################################################################# -/
/- * Induction: Proof by Induction -/

/-
This chapter is a Lean-oriented translation of `rocq/lf/Induction.v`. Like the
Rocq original, it introduces induction by contrasting it with proof by
simplification and proof by cases, then uses that new proof principle in a
sequence of small examples.

As in the other Lean chapters in this repository, the goal is to preserve the
textbook feel of Software Foundations rather than merely porting theorem
statements. Worked examples are translated into ordinary Lean proofs, while
student exercises are intentionally left as `sorry` unless the source chapter
already solved them.
-/

/- ################################################################# -/
/- * Separate Compilation -/

/-
The Rocq version of this chapter begins with `Require Export Basics`, together
with a long explanation of how compiled `.vo` files let one chapter depend on
another. The same broad idea applies here: this Lean file simply imports the
previous chapter with `import lf.Basics` and then builds on the definitions and
proofs established there.

To support this workflow, the repository's Lean helper script compiles local
imports into a repo-local cache under `.build/lean/` before checking the target
chapter. That means later chapters can depend on earlier ones naturally, much
closer to the structure of the Rocq development.
-/

/- ################################################################# -/
/- * Proof by Induction -/

/-
We can prove that `0` is a neutral element for addition on the left using just
`rfl`. The corresponding statement on the right is different. When the goal is
`n + 0 = n` for an arbitrary `n`, Lean cannot reduce the left-hand side all the
way, because addition is defined by recursion on its first argument.

The same obstruction appears if we try case analysis alone. Splitting on `n`
solves the `0` case, but the successor case reduces only to a smaller version
of the same problem. Since `n` can be arbitrarily large, repeatedly doing case
analysis will never finish the proof.

The Rocq chapter records these failed starts as aborted proofs named
`add_0_r_firsttry` and `add_0_r_secondtry`. We keep the lesson rather than the
failing Lean code itself: `rfl` is too weak, and plain case analysis only peels
off one successor at a time.
-/

/-
What we need is the familiar induction principle for natural numbers. To prove
that a proposition `P n` holds for every `n`, we show two things:

1. `P 0` holds.
2. Whenever `P n'` holds, `P (S n')` also holds.

In Lean, the `induction` tactic packages these two obligations into separate
goals. The second goal comes with an induction hypothesis recording that the
statement is already known for the predecessor.
-/

theorem add_0_r : ∀ n : nat, n + 0 = n := by
  intro n
  induction n with
  | zero =>
      rfl
  | succ n ih =>
      change S (n + 0) = S n
      rw [ih]

/-
Lean's `induction n with` plays the same role as Rocq's
`induction n as [| n' IHn']`. In the base case there is nothing left to prove
after simplification. In the successor case the induction hypothesis, here
named `ih`, says exactly that `n + 0 = n`, and rewriting with it finishes the
goal.
-/

theorem minus_n_n : ∀ n : nat, minus n n = 0 := by
  intro n
  induction n with
  | zero =>
      rfl
  | succ n ih =>
      simpa [minus] using ih

/-
As in Rocq, we often begin induction proofs with `intro` to move quantified
variables into the local context. Lean can sometimes combine these steps for
us, but writing them explicitly is still good proof-reading practice in an
early chapter.
-/

/- **** Exercise: 2 stars, standard, especially useful (basic_induction) -/

/-
Prove the following using induction. You may need facts established earlier in
the chapter.
-/

theorem mul_0_r : ∀ n : nat, n * 0 = 0 := by
  intro n
  induction n with
  | zero => rfl
  | succ n ih => rw [<- mult_n_O]  

theorem plus_n_Sm : ∀ n m : nat, S (n + m) = n + S m := by
  intro n m
  induction n with
  | zero => repeat rw [plus_O_n]
  | succ n ih => 
    /- simp only [<- plus_1_l] -/
    /- simp only [Nat.succ_eq_add_one] -/


theorem add_comm : ∀ n m : nat, n + m = m + n := by
  sorry

theorem add_assoc : ∀ n m p : nat, n + (m + p) = (n + m) + p := by
  sorry

/- **** Exercise: 2 stars, standard (double_plus) -/

/-
Consider the following function, which doubles its argument.
-/

def double : nat → nat
  | 0 => 0
  | Nat.succ n' => Nat.succ (Nat.succ (double n'))

/-
Use induction to prove this simple fact about `double`.
-/

theorem double_plus : ∀ n : nat, double n = n + n := by
  sorry

/- **** Exercise: 2 stars, standard (eqb_refl) -/

/-
The following theorem relates the computational equality test `eqb` on `nat`
with the boolean value `true`.
-/

theorem eqb_refl : ∀ n : nat, eqb n n = true := by
  sorry

/- **** Exercise: 2 stars, standard, optional (even_S) -/

/-
Our definition of `even` recurses on `n - 2`, so direct induction on `n` can be
slightly awkward. The next lemma gives a more convenient reformulation.
-/

theorem even_S : ∀ n : nat, even (S n) = negb (even n) := by
  sorry

/- ################################################################# -/
/- * Proofs Within Proofs -/

/-
Large proofs are often organized as a sequence of named lemmas. But sometimes a
proof needs a small side fact that is too local to deserve a top-level name.
Rocq's `replace` tactic is one way to handle this. In Lean, the same idea is
often expressed by introducing a local equality with `have` and then rewriting
with it.
-/

theorem mult_0_plus' : ∀ n m : nat, (n + 0 + 0) * m = n * m := by
  intro n m
  have h : n + 0 + 0 = n := by
    rw [add_0_r, add_0_r]
  rw [h]

/-
The important point is the same as in the Rocq proof: we temporarily replace a
complicated expression by a simpler equal one, and we discharge the required
equality as a separate local argument.

The next example also mirrors the Rocq chapter. A naive rewrite with
commutativity changes the wrong occurrence of `+`, just as in Rocq's aborted
`plus_rearrange_firsttry`. So we isolate the inner sum we actually want to
rewrite.
-/

theorem plus_rearrange : ∀ n m p q : nat,
    (n + m) + (p + q) = (m + n) + (p + q) := by
  intro n m p q
  have h : n + m = m + n := by
    exact add_comm n m
  rw [h]

/- ################################################################# -/
/- * Formal vs. Informal Proof -/

/-
The Rocq chapter pauses here to contrast formal proofs, which are checked by a
proof assistant, with informal proofs, which are written for human readers. The
central observation carries over unchanged: a formal proof is precise enough
for Lean to verify, but that does not automatically make it pleasant for a
person to read.

Informal mathematical proofs aim at conviction and communication. A proof is
successful when it makes the reader see why the result is true. Too little
detail leaves the argument mysterious; too much detail can bury the main idea.
Good mathematical writing balances those pressures.

Lean proofs therefore serve two roles in a chapter like this one. They are code
that the system can check, but they are also models for how a learner should
organize an argument. The next pair of proofs illustrates the difference.
-/

theorem add_assoc' : ∀ n m p : nat, n + (m + p) = (n + m) + p := by
  intro n m p
  induction n with
  | zero =>
      rfl
  | succ n ih =>
      change S (n + (m + p)) = S ((n + m) + p)
      rw [ih]

/-
Lean is perfectly happy with that compact proof. For a human reader, though, it
takes a bit more work to reconstruct the shape of the argument. A more expanded
version makes the base case, inductive step, and use of the induction
hypothesis easier to see.
-/

theorem add_assoc'' : ∀ n m p : nat, n + (m + p) = (n + m) + p := by
  intro n m p
  induction n with
  | zero =>
      rfl
  | succ n ih =>
      change S (n + (m + p)) = S ((n + m) + p)
      exact congrArg Nat.succ ih

/-
An informal proof would usually say the same things in prose: prove the claim
by induction on `n`; check the case `n = 0`; then assume the induction
hypothesis for `n'` and derive the claim for `S n'`. The formal and informal
proofs have the same backbone even though they look different on the page.
-/

/- **** Exercise: 2 stars, advanced, optional (add_comm_informal) -/

/-
Translate your solution for `add_comm` into an informal proof.

Theorem: Addition is commutative.

Proof: fill in here.
-/

def manual_grade_for_add_comm_informal : Option (nat × String) := none

/- **** Exercise: 2 stars, standard, optional (eqb_refl_informal) -/

/-
Write an informal proof of the following theorem, using the informal proof of
associativity as a model. Do not merely paraphrase the Lean tactics into
English.

Theorem: `eqb n n = true` for any `n`.

Proof: fill in here.
-/

def manual_grade_for_eqb_refl_informal : Option (nat × String) := none

/- ################################################################# -/
/- * More Exercises -/

/- **** Exercise: 3 stars, standard, especially useful (mul_comm) -/

/-
Use a local replacement argument to help prove `add_shuffle3`. You should not
need induction for the first theorem.
-/

theorem add_shuffle3 : ∀ n m p : nat, n + (m + p) = m + (n + p) := by
  sorry

/-
Now prove commutativity of multiplication. The proof will likely need several
facts about addition.
-/

theorem mul_comm : ∀ m n : nat, m * n = n * m := by
  sorry

/- **** Exercise: 3 stars, standard, optional (more_exercises) -/

/-
For each of the following theorems, first predict whether simplification and
rewriting suffice, whether case analysis is needed, or whether induction is
required. Then fill in the proof.
-/

theorem leb_refl : ∀ n : nat, leb n n = true := by
  sorry

theorem zero_neqb_S : ∀ n : nat, eqb 0 (S n) = false := by
  sorry

theorem andb_false_r : ∀ b : bool, andb b false = false := by
  sorry

theorem S_neqb_0 : ∀ n : nat, eqb (S n) 0 = false := by
  sorry

theorem mult_1_l : ∀ n : nat, 1 * n = n := by
  sorry

theorem all3_spec : ∀ b c : bool,
    orb (andb b c) (orb (negb b) (negb c)) = true := by
  sorry

theorem mult_plus_distr_r : ∀ n m p : nat, (n + m) * p = n * p + m * p := by
  sorry

theorem mult_assoc : ∀ n m p : nat, n * (m * p) = (n * m) * p := by
  sorry

/- ################################################################# -/
/- * Nat to Bin and Back to Nat -/

/-
Recall the binary numerals from `Basics`. In the Rocq chapter this section
restates the datatype and asks the reader to paste in earlier definitions of
`incr` and `bin_to_nat`. In this Lean translation, those definitions come
directly from the imported `lf.Basics` chapter, so they are available here in
exactly the way the Rocq chapter intends.
-/

/- **** Exercise: 3 stars, standard, especially useful (binary_commute) -/

/-
Prove that incrementing a binary number and then converting to unary yields the
same result as converting first and then adding one.
-/

theorem bin_to_nat_pres_incr : ∀ b : bin, bin_to_nat (incr b) = 1 + bin_to_nat b := by
  sorry

/- **** Exercise: 3 stars, standard (nat_bin_nat) -/

/-
Write a function converting unary naturals to binary numerals.
-/

def nat_to_bin (n : nat) : bin := by
  sorry

/-
Prove that converting a natural number to binary and back again recovers the
original natural number.
-/

theorem nat_bin_nat : ∀ n : nat, bin_to_nat (nat_to_bin n) = n := by
  sorry

/- ################################################################# -/
/- * Bin to Nat and Back to Bin (Advanced) -/

/-
The reverse direction is subtler. Starting with a binary numeral, converting it
to `nat`, and converting back again does not always return the exact same
syntax tree. Different binary values can represent the same natural number, so
we should expect to recover a canonical representative rather than the original
term verbatim.
-/

/- **** Exercise: 2 stars, advanced (double_bin) -/

/-
First prove the corresponding unary lemma about `double`.
-/

theorem double_incr : ∀ n : nat, double (S n) = S (S (double n)) := by
  sorry

/-
Now define a binary doubling function.
-/

def double_bin (b : bin) : bin := by
  sorry

/-
Check that your function doubles zero correctly.
-/

theorem double_bin_zero : double_bin Z = Z := by
  sorry

/-
Prove the binary analogue of `double_incr`.
-/

theorem double_incr_bin : ∀ b : bin,
    double_bin (incr b) = incr (incr (double_bin b)) := by
  sorry

/-
The failed theorem from the Rocq chapter fails for the same reason in Lean:
binary numerals with extra leading zero bits are extensionally equal as numbers
but not definitionally the same piece of syntax. The right fix is to normalize
them.
-/

/- **** Exercise: 4 stars, advanced (bin_nat_bin) -/

/-
Define a normalization function selecting a canonical representative for each
binary numeral. Keep the recursion simple; the later proofs will depend on that
choice.
-/

def normalize (b : bin) : bin := by
  sorry

/-
It is a good idea to add a few small examples here while developing the proof,
even though they are not graded in the original text.
-/

theorem bin_nat_bin : ∀ b : bin, nat_to_bin (bin_to_nat b) = normalize b := by
  sorry
