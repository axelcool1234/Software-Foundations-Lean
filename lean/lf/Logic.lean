import lf.Tactics

set_option autoImplicit false

namespace Logic

open Tactics
open Poly
open Poly.OptionPlayground.option
open NatPlayground2

/- ################################################################# -/
/- * Logic: Logic in Lean -/

/-
We have now seen many examples of factual claims, i.e. propositions, and of
evidence establishing that such claims are true, i.e. proofs. Up to this point
we have worked mainly with equality, implication, and universal quantification.
In this chapter we extend the story to the other familiar logical connectives.

As in Rocq, mathematical statements in Lean are typed expressions. Any well-
formed proposition has type `Prop`, regardless of whether it is actually true.
Being a proposition and being provable are quite different things.
-/

#check (∀ n m : nat, n + m = m + n : Prop)
#check (2 = 2 : Prop)
#check (3 = 2 : Prop)
#check (∀ n : nat, n = 2 : Prop)

/-
Propositions are first-class citizens: they can be named, passed to functions,
and manipulated just like other expressions.
-/

theorem plus_2_2_is_4 : 2 + 2 = 4 := by
  rfl

def plus_claim : Prop := 2 + 2 = 4

#check plus_claim

theorem plus_claim_is_true : plus_claim := by
  rfl

/-
We can also write parameterized propositions, i.e. functions that take data and
return propositions.
-/

def is_three (n : nat) : Prop :=
  n = 3

#check is_three

/-
Functions returning propositions are usually called properties of their
arguments. Here is the familiar notion of an injective function.
-/

def injective {A B : Type} (f : A -> B) : Prop :=
  ∀ x y : A, f x = f y -> x = y

theorem succ_inj : injective S := by
  intro x y h
  injection h

/-
The equality notation `n = m` is itself just a polymorphic proposition-valued
function.
-/

#check @Eq

/- ################################################################# -/
/- * Logical Connectives -/

/- ================================================================= -/
/- ** Conjunction -/

/-
The conjunction `A /\ B` asserts that both `A` and `B` are true. Lean's ASCII
notation `/\` parallels Rocq's, while the pretty-printed version is usually
`∧`.
-/

theorem and_example : 3 + 4 = 7 /\ 2 * 2 = 4 := by
  constructor
  · rfl
  · rfl

/-
Lean's theorem `And.intro` plays the same role as Rocq's `conj`.
-/

#check And.intro

theorem and_example' : 3 + 4 = 7 /\ 2 * 2 = 4 := by
  apply And.intro
  · rfl
  · rfl

/- **** Exercise: 2 stars, standard (plus_is_O) -/

theorem plus_is_O :
    ∀ n m : nat, n + m = 0 -> n = 0 /\ m = 0 := by
  sorry

/-
To use a conjunctive hypothesis, we break it apart.
-/

theorem and_example2 :
    ∀ n m : nat, n = 0 /\ m = 0 -> n + m = 0 := by
  intro n m h
  rcases h with ⟨hn, hm⟩
  rw [hn, hm]

theorem and_example2' :
    ∀ n m : nat, n = 0 /\ m = 0 -> n + m = 0 := by
  intro n m ⟨hn, hm⟩
  rw [hn, hm]

theorem and_example2'' :
    ∀ n m : nat, n = 0 -> m = 0 -> n + m = 0 := by
  intro n m hn hm
  rw [hn, hm]

/-
Conjunctions are especially useful when they arise as intermediate facts in
larger proofs.
-/

theorem and_example3 :
    ∀ n m : nat, n + m = 0 -> n * m = 0 := by
  intro n m h
  have h' := plus_is_O n m h
  rcases h' with ⟨hn, hm⟩
  simp [hn]

theorem proj1 : ∀ P Q : Prop, P /\ Q -> P := by
  intro P Q hpq
  rcases hpq with ⟨hp, _⟩
  exact hp

/- **** Exercise: 1 star, standard, optional (proj2) -/

theorem proj2 : ∀ P Q : Prop, P /\ Q -> Q := by
  sorry

theorem and_commut : ∀ P Q : Prop, P /\ Q -> Q /\ P := by
  intro P Q ⟨hp, hq⟩
  constructor
  · exact hq
  · exact hp

/- **** Exercise: 1 star, standard (and_assoc) -/

theorem and_assoc : ∀ P Q R : Prop, P /\ (Q /\ R) -> (P /\ Q) /\ R := by
  intro P Q R ⟨hp, hqr⟩
  sorry

#check And

/- ================================================================= -/
/- ** Disjunction -/

/-
The disjunction `A \/ B` says that at least one of `A` or `B` holds.
-/

theorem factor_is_O : ∀ n m : nat, n = 0 \/ m = 0 -> n * m = 0 := by
  intro n m h
  rcases h with hn | hm
  · simp [hn]
  · simp [hm]

theorem or_intro_l : ∀ A B : Prop, A -> A \/ B := by
  intro A B hA
  exact Or.inl hA

theorem zero_or_succ : ∀ n : nat, n = 0 \/ n = S (pred n) := by
  intro n
  cases n with
  | zero => exact Or.inl rfl
  | succ n' => exact Or.inr rfl

/- **** Exercise: 2 stars, standard (mult_is_O) -/

theorem mult_is_O : ∀ n m : nat, n * m = 0 -> n = 0 \/ m = 0 := by
  sorry

/- **** Exercise: 1 star, standard (or_commut) -/

theorem or_commut : ∀ P Q : Prop, P \/ Q -> Q \/ P := by
  sorry

/- ================================================================= -/
/- ** Falsehood and Negation -/

/-
Besides positive statements, we often want to express that some proposition is
not true. Lean's notation `~ P` means `P -> False`.
-/

namespace NotPlayground

def not (P : Prop) := P -> False

#check not

notation:max "~ " x => not x

end NotPlayground

theorem ex_falso_quodlibet : ∀ P : Prop, False -> P := by
  intro P contra
  exact False.elim contra

/- **** Exercise: 2 stars, standard, optional (not_implies_our_not) -/

theorem not_implies_our_not : ∀ P : Prop,
    ~ P -> (∀ Q : Prop, P -> Q) := by
  sorry

notation:50 x " <> " y => ~(x = y)

theorem zero_not_one : 0 ≠ 1 := by
  intro contra
  cases contra

theorem not_False : ~ False := by
  intro h
  exact h

theorem contradiction_implies_anything : ∀ P Q : Prop, (P /\ ~ P) -> Q := by
  intro P Q h
  rcases h with ⟨hp, hnp⟩
  exact False.elim (hnp hp)

theorem double_neg : ∀ P : Prop, P -> ~~ P := by
  intro P hP hNP
  exact hNP hP

/- **** Exercise: 2 stars, advanced, optional (double_neg_informal) -/

def manual_grade_for_double_neg_informal : Option (nat × String) := none

/- **** Exercise: 1 star, standard, especially useful (contrapositive) -/

theorem contrapositive : ∀ P Q : Prop, (P -> Q) -> (~ Q -> ~ P) := by
  sorry

/- **** Exercise: 1 star, standard (not_both_true_and_false) -/

theorem not_both_true_and_false : ∀ P : Prop, ~ (P /\ ~ P) := by
  sorry

/- **** Exercise: 1 star, advanced (not_PNP_informal) -/

def manual_grade_for_not_PNP_informal : Option (nat × String) := none

/- **** Exercise: 2 stars, standard (de_morgan_not_or) -/

theorem de_morgan_not_or : ∀ P Q : Prop, ~ (P \/ Q) -> ~ P /\ ~ Q := by
  sorry

/- **** Exercise: 1 star, standard, optional (not_S_inverse_pred) -/

theorem not_S_pred_n : ~ (∀ n : nat, S (pred n) = n) := by
  sorry

theorem not_true_is_false : ∀ b : bool, b ≠ true -> b = false := by
  intro b
  cases b <;> intro h
  · exact False.elim (h rfl)
  · rfl

theorem not_true_is_false' : ∀ b : bool, b ≠ true -> b = false := by
  intro b h
  cases b <;> simp at h ⊢

/- ================================================================= -/
/- ** Truth -/

theorem True_is_true : True := by
  exact True.intro

/-
Although `True` is usually uninteresting as a goal or hypothesis, it is useful
in definitions where a branch should be trivially satisfied.
-/

def disc_fn (n : nat) : Prop :=
  match n with
  | 0 => True
  | _ + 1 => False

theorem disc_example : ∀ n, ~ (O = S n) := by
  intro n contra
  have h : disc_fn O := by
    simp [disc_fn]
  rw [contra] at h
  simp [disc_fn] at h

/- **** Exercise: 2 stars, advanced, optional (nil_is_not_cons) -/

theorem nil_is_not_cons : ∀ X (x : X) (xs : list X), ~ ([p| |] = x :: xs) := by
  sorry

/- ================================================================= -/
/- ** Logical Equivalence -/

/-
The connective `P <-> Q` is the conjunction of the implications `P -> Q` and
`Q -> P`.
-/

theorem iff_sym : ∀ P Q : Prop, (P <-> Q) -> (Q <-> P) := by
  intro P Q h
  constructor
  · exact h.mpr
  · exact h.mp

theorem not_true_iff_false : ∀ b : bool, (b ≠ true) <-> b = false := by
  intro b
  cases b <;> constructor <;> intro h <;> simp at *

theorem apply_iff_example1 : ∀ P Q R : Prop, (P <-> Q) -> (Q -> R) -> (P -> R) := by
  intro P Q R hiff h hp
  exact h (hiff.mp hp)

theorem apply_iff_example2 : ∀ P Q R : Prop, (P <-> Q) -> (P -> R) -> (Q -> R) := by
  intro P Q R hiff h hq
  exact h (hiff.mpr hq)

/- **** Exercise: 1 star, standard, optional (iff_properties) -/

theorem iff_refl : ∀ P : Prop, P <-> P := by
  sorry

theorem iff_trans : ∀ P Q R : Prop, (P <-> Q) -> (Q <-> R) -> (P <-> R) := by
  sorry

/- **** Exercise: 3 stars, standard (or_distributes_over_and) -/

theorem or_distributes_over_and : ∀ P Q R : Prop,
    P \/ (Q /\ R) <-> (P \/ Q) /\ (P \/ R) := by
  sorry

/- ================================================================= -/
/- ** Setoids and Logical Equivalence -/

/-
Rocq imports a setoid library so that `rewrite` can work with logical
equivalences, not just equalities. Lean already has propositional extensionality
available, so rewriting with `↔` is part of everyday practice.
-/

theorem mul_eq_0 : ∀ n m, n * m = 0 <-> n = 0 \/ m = 0 := by
  intro n m
  constructor
  · exact mult_is_O n m
  · exact factor_is_O n m

theorem or_assoc : ∀ P Q R : Prop, P \/ (Q \/ R) <-> (P \/ Q) \/ R := by
  intro P Q R
  constructor
  · intro h
    rcases h with hP | hQR
    · exact Or.inl (Or.inl hP)
    · rcases hQR with hQ | hR
      · exact Or.inl (Or.inr hQ)
      · exact Or.inr hR
  · intro h
    rcases h with hPQ | hR
    · rcases hPQ with hP | hQ
      · exact Or.inl hP
      · exact Or.inr (Or.inl hQ)
    · exact Or.inr (Or.inr hR)

theorem mul_eq_0_ternary : ∀ n m p, n * m * p = 0 <-> n = 0 \/ m = 0 \/ p = 0 := by
  intro n m p
  rw [mul_eq_0, mul_eq_0, or_assoc]

/- ================================================================= -/
/- ** Existential Quantification -/

/-
To prove an existential, we provide a witness and then verify the required
property for that witness.
-/

def Even (x : nat) := ∃ n : nat, x = double n

#check Even

theorem four_is_Even : Even 4 := by
  unfold Even
  refine ⟨2, ?_⟩
  rfl

theorem exists_example_2 : ∀ n,
    (∃ m, n = 4 + m) ->
    (∃ o, n = 2 + o) := by
  intro n h
  rcases h with ⟨m, hm⟩
  refine ⟨2 + m, ?_⟩
  calc
    n = 4 + m := hm
    _ = (2 + 2) + m := by rfl
    _ = 2 + (2 + m) := by rw [Nat.add_assoc]

/- **** Exercise: 1 star, standard, especially useful (dist_not_exists) -/

theorem dist_not_exists : ∀ (X : Type) (P : X -> Prop),
    (∀ x, P x) -> ~ (∃ x, ~ P x) := by
  sorry

/- **** Exercise: 2 stars, standard (dist_exists_or) -/

theorem dist_exists_or : ∀ (X : Type) (P Q : X -> Prop),
    (∃ x, P x \/ Q x) <-> (∃ x, P x) \/ (∃ x, Q x) := by
  sorry

/- **** Exercise: 3 stars, standard, optional (leb_plus_exists) -/

theorem leb_plus_exists : ∀ n m, leb n m = true -> ∃ x, m = n + x := by
  sorry

theorem plus_exists_leb : ∀ n m, (∃ x, m = n + x) -> leb n m = true := by
  sorry

/- ################################################################# -/
/- * Programming with Propositions -/

/-
Just as in Rocq, we can define propositions recursively.
-/

def In {A : Type} (x : A) : list A -> Prop
  | [p| |] => False
  | x' :: l' => x' = x \/ In x l'

theorem In_example_1 : In 4 [p| 1; 2; 3; 4; 5 |] := by
  simp [In]

theorem In_example_2 : ∀ n, In n [p| 2; 4 |] -> ∃ n', n = 2 * n' := by
  intro n h
  have h' : 2 = n \/ 4 = n := by
    simpa [In] using h
  rcases h' with h2 | h4
  · exact ⟨1, h2.symm⟩
  · exact ⟨2, h4.symm⟩

theorem In_map : ∀ (A B : Type) (f : A -> B) (l : list A) (x : A),
    In x l -> In (f x) (map f l) := by
  intro A B f l x hx
  induction l with
  | nil =>
      simp [In] at hx
  | cons x' l' ih =>
      simp [In, map] at hx ⊢
      rcases hx with h | h
      · left
        rw [h]
      · right
        exact ih h

/- **** Exercise: 2 stars, standard (In_map_iff) -/

theorem In_map_iff : ∀ (A B : Type) (f : A -> B) (l : list A) (y : B),
    In y (map f l) <-> ∃ x, f x = y /\ In x l := by
  intro A B f l y
  constructor
  · induction l with
    | nil =>
        intro h
        simp [In, map] at h
    | cons x l' ih =>
        sorry
  · sorry

/- **** Exercise: 2 stars, standard (In_app_iff) -/

theorem In_app_iff : ∀ A l l' (a : A), In a (l ++ l') <-> In a l \/ In a l' := by
  intro A l
  induction l with
  | nil =>
      intro l' a
      sorry
  | cons a' l' ih =>
      sorry

/- **** Exercise: 3 stars, standard, especially useful (All) -/

def All {T : Type} (P : T -> Prop) : list T -> Prop := by
  sorry

theorem All_In : ∀ T (P : T -> Prop) (l : list T), (∀ x, In x l -> P x) <-> All P l := by
  sorry

/- **** Exercise: 2 stars, standard, optional (combine_odd_even) -/

def combine_odd_even (Podd Peven : nat -> Prop) : nat -> Prop := by
  sorry

theorem combine_odd_even_intro : ∀ (Podd Peven : nat -> Prop) (n : nat),
    (odd n = true -> Podd n) ->
    (odd n = false -> Peven n) ->
    combine_odd_even Podd Peven n := by
  sorry

theorem combine_odd_even_elim_odd : ∀ (Podd Peven : nat -> Prop) (n : nat),
    combine_odd_even Podd Peven n -> odd n = true -> Podd n := by
  sorry

theorem combine_odd_even_elim_even : ∀ (Podd Peven : nat -> Prop) (n : nat),
    combine_odd_even Podd Peven n -> odd n = false -> Peven n := by
  sorry

/- ################################################################# -/
/- * Applying Theorems to Arguments -/

/-
Lean, like Rocq, treats proofs as first-class objects. Theorems can be applied
to arguments much like ordinary functions.
-/

#check plus
#check @rev

#check add_comm
#check plus_id_example

theorem add_comm3 : ∀ x y z : nat, x + (y + z) = (z + y) + x := by
  intro x y z
  rw [add_comm x (y + z)]
  rw [add_comm y z]

/-
As in earlier chapters, rewriting twice with a commutativity theorem can undo
our own progress. The usual repair is to derive or apply a more specialized
instance.
-/

theorem add_comm3_take2 : ∀ x y z : nat, x + (y + z) = (z + y) + x := by
  intro x y z
  rw [add_comm]
  have h : y + z = z + y := by
    rw [add_comm]
  rw [h]

theorem add_comm3_take3 : ∀ x y z : nat, x + (y + z) = (z + y) + x := by
  intro x y z
  rw [add_comm]
  rw [add_comm y z]

theorem add_comm3_take4 : ∀ x y z : nat, x + (y + z) = (z + y) + x := by
  intro x y z
  rw [add_comm x (y + z)]
  rw [add_comm y z]

theorem in_not_nil : ∀ A (x : A) (l : list A), In x l -> l <> [p| |] := by
  intro A x l h
  intro hl
  rw [hl] at h
  exact False.elim h

/-
One quantified variable in `in_not_nil` does not appear in its conclusion, so
plain `apply` cannot always infer everything we want.
-/

theorem in_not_nil_42_take2 : ∀ l : list nat, In 42 l -> l <> [p| |] := by
  intro l h
  apply in_not_nil (x := 42)
  exact h

theorem in_not_nil_42_take3 : ∀ l : list nat, In 42 l -> l <> [p| |] := by
  intro l h
  have h' := in_not_nil nat 42 l h
  exact h'

theorem in_not_nil_42_take4 : ∀ l : list nat, In 42 l -> l <> [p| |] := by
  intro l h
  exact in_not_nil nat 42 l h

theorem in_not_nil_42_take5 : ∀ l : list nat, In 42 l -> l <> [p| |] := by
  intro l h
  exact in_not_nil _ _ _ h

theorem lemma_application_ex :
    ∀ {n : nat} {ns : list nat}, In n (map (fun m => m * 0) ns) -> n = 0 := by
  intro n ns h
  have h' := (In_map_iff nat nat (fun m => m * 0) ns n).mp h
  rcases h' with ⟨m, hm, _⟩
  rw [mul_0_r] at hm
  exact hm.symm

/- ################################################################# -/
/- * Working with Decidable Properties -/

/-
As in Rocq, boolean computations and propositions each have their own strengths.
Booleans are computable and work directly with `if` and pattern matching;
propositions support rewriting and richer logical structure.
-/

theorem even_42_bool : even 42 = true := by
  rfl

theorem even_42_prop : Even 42 := by
  unfold Even
  refine ⟨21, ?_⟩
  rfl

theorem even_double : ∀ k, even (double k) = true := by
  intro k
  induction k with
  | zero => rfl
  | succ k' ih => simpa [double] using ih

/- **** Exercise: 3 stars, standard (even_double_conv) -/

theorem even_double_conv : ∀ n, ∃ k, n = if even n then double k else S (double k) := by
  sorry

theorem even_bool_prop : ∀ n, even n = true <-> Even n := by
  intro n
  constructor
  · intro h
    rcases even_double_conv n with ⟨k, hk⟩
    rw [hk, h]
    refine ⟨k, ?_⟩
    rfl
  · intro h
    rcases h with ⟨k, hk⟩
    rw [hk]
    exact even_double k

theorem eqb_eq : ∀ n1 n2 : nat, eqb n1 n2 = true <-> n1 = n2 := by
  intro n1 n2
  constructor
  · exact Tactics.eqb_true n1 n2
  · intro h
    rw [h, eqb_refl]

/-
Rocq shows a failed attempt to define `is_even_prime` by branching on a
proposition. Lean has the same restriction in ordinary computational code: an
`if` needs a decidable proposition or a boolean. The boolean version is the one
we actually use.
-/

def is_even_prime (n : nat) :=
  if eqb n 2 then true else false

theorem even_1000 : Even 1000 := by
  exact (even_bool_prop 1000).mp (by native_decide)

theorem even_1000' : even 1000 = true := by
  rfl

theorem even_1000'' : Even 1000 := by
  exact (even_bool_prop 1000).mp (by native_decide)

theorem not_even_1001 : even 1001 = false := by
  rfl

theorem not_even_1001' : ~ Even 1001 := by
  rw [← (even_bool_prop 1001)]
  intro h
  cases h

theorem plus_eqb_example : ∀ n m p : nat, eqb n m = true -> eqb (n + p) (m + p) = true := by
  intro n m p h
  have h' : n = m := (eqb_eq n m).mp h
  rw [h']
  exact (eqb_eq (m + p) (m + p)).mpr rfl

/- **** Exercise: 2 stars, standard (logical_connectives) -/

theorem andb_true_iff : ∀ b1 b2 : bool, b1 && b2 = true <-> b1 = true /\ b2 = true := by
  sorry

theorem orb_true_iff : ∀ b1 b2 : bool, b1 || b2 = true <-> b1 = true \/ b2 = true := by
  sorry

/- **** Exercise: 1 star, standard (eqb_neq) -/

theorem eqb_neq : ∀ x y : nat, eqb x y = false <-> x ≠ y := by
  sorry

/- **** Exercise: 3 stars, standard (eqb_list) -/

def eqb_list {A : Type} (eqb : A -> A -> bool) (l1 l2 : list A) : bool := by
  sorry

theorem eqb_list_true_iff : ∀ A (eqb : A -> A -> bool),
    (∀ a1 a2, eqb a1 a2 = true <-> a1 = a2) ->
    ∀ l1 l2, eqb_list eqb l1 l2 = true <-> l1 = l2 := by
  sorry

/- **** Exercise: 2 stars, standard, especially useful (All_forallb) -/

/-
As in the Rocq chapter, we copy `forallb` here so the chapter remains self-
contained.
-/

def forallb {X : Type} (test : X -> bool) (l : list X) : bool := by
  sorry

theorem forallb_true_iff : ∀ X test (l : list X),
    forallb test l = true <-> All (fun x => test x = true) l := by
  sorry

/- ################################################################# -/
/- * The Logic of Rocq -/

/-
Rocq's underlying logic differs in some important ways from the classical set-
theoretic foundations commonly used in ordinary mathematics. We close the
chapter with two major examples.
-/

/- ================================================================= -/
/- ** Functional Extensionality -/

/-
Equality of functions is a good example. Some equalities are provable just by
simplification.
-/

theorem function_equality_ex1 : (fun x => 3 + x) = (fun x => pred 4 + x) := by
  rfl

/-
But more interesting function equalities require an extensionality principle.
Unlike Rocq, Lean already provides function extensionality as a theorem, so we
package it here under the familiar chapter name instead of postulating it as an
axiom.
-/

theorem functional_extensionality {X Y : Type} {f g : X -> Y} :
    (∀ x : X, f x = g x) -> f = g := by
  intro h
  funext x
  exact h x

theorem function_equality_ex2 : (fun x => plus x 1) = (fun x => plus 1 x) := by
  apply functional_extensionality
  intro x
  induction x with
  | zero => rfl
  | succ x ih => simp [plus, ih]

/- **** Exercise: 4 stars, standard (tr_rev_correct) -/

def rev_append {X : Type} (l1 l2 : list X) : list X :=
  match l1 with
  | [p| |] => l2
  | x :: l1' => rev_append l1' (x :: l2)

def tr_rev {X : Type} (l : list X) : list X :=
  rev_append l [p| |]

theorem tr_rev_correct : ∀ X, @tr_rev X = @rev X := by
  sorry

/- ================================================================= -/
/- ** Classical vs. Constructive Logic -/

def excluded_middle := ∀ P : Prop, P \/ ~ P

/-
If a proposition is reflected by a boolean, we can recover a restricted form of
excluded middle by simply checking the boolean.
-/

theorem restricted_excluded_middle : ∀ (P : Prop) (b : bool), (P <-> b = true) -> P \/ ~ P := by
  intro P b h
  by_cases hb : b = true
  · left
    exact h.mpr hb
  · right
    intro hp
    exact hb (h.mp hp)

theorem restricted_excluded_middle_eq : ∀ n m : nat, n = m \/ n ≠ m := by
  intro n m
  apply restricted_excluded_middle (P := n = m) (b := eqb n m)
  exact Iff.symm (eqb_eq n m)

/- **** Exercise: 3 stars, standard (excluded_middle_irrefutable) -/

theorem excluded_middle_irrefutable : ∀ P : Prop, ~~ (P \/ ~ P) := by
  intro P h
  apply h
  right
  intro hp
  apply h
  left
  exact hp

/- **** Exercise: 3 stars, advanced (not_exists_dist) -/

theorem not_exists_dist :
    excluded_middle ->
    ∀ (X : Type) (P : X -> Prop), (~ (∃ x, ~ P x)) -> (∀ x, P x) := by
  intro em X P h x
  cases em (P x) with
  | inl hp => exact hp
  | inr hnp => exact False.elim (h ⟨x, hnp⟩)

/- **** Exercise: 5 stars, standard, optional (classical_axioms) -/

def peirce := ∀ P Q : Prop, ((P -> Q) -> P) -> P

def double_negation_elimination := ∀ P : Prop, ~~ P -> P

def de_morgan_not_and_not := ∀ P Q : Prop, ~(~ P /\ ~ Q) -> P \/ Q

def implies_to_or := ∀ P Q : Prop, (P -> Q) -> (~ P \/ Q)

def consequentia_mirabilis := ∀ P : Prop, (~ P -> P) -> P

end Logic
