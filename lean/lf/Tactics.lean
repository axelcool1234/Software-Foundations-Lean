import lf.Poly

set_option autoImplicit false

namespace Tactics

open Poly
open Poly.OptionPlayground.option

/- ################################################################# -/
/- * Tactics: More Basic Tactics -/

/-
This chapter introduces several additional proof strategies and tactics that let
us begin proving more interesting properties of functional programs.

We will see

- how to use auxiliary lemmas in both forward- and backward-style proofs,
- how to reason about data constructors, especially their injectivity and
  disjointness,
- how to strengthen an induction hypothesis when a direct induction gets stuck,
- and a few more details about case analysis.

The Rocq chapter imports `Poly`, so this Lean translation does the same. That
lets us reuse the chapter-local polymorphic lists, options, products, and the
`[p| ... |]` list notation introduced there.
-/

/- ################################################################# -/
/- * The [apply] Tactic -/

/-
We often encounter situations where the goal to be proved is exactly the same
as some hypothesis in the context or some previously proved lemma.
-/

theorem silly1 : ∀ n m : nat,
    n = m ->
    n = m := by
  intro n m eq

  /-
  Here we could finish by rewriting with `eq` and then using `rfl`. But, as in
  the Rocq chapter, we can also finish in a single step with `apply`.
  -/

  apply eq

/-
The `apply` tactic also works with conditional hypotheses and lemmas. If the
statement being applied is an implication, its premises become new subgoals.
-/

theorem silly2 : ∀ n m o p : nat,
    n = m ->
    (n = m -> [p| n; o |] = [p| m; p |]) ->
    [p| n; o |] = [p| m; p |] := by
  intro n m o p eq1 eq2
  apply eq2
  apply eq1

/-
Typically, when we use `apply H`, the statement `H` begins with universally
quantified variables. Lean matches the current goal against the conclusion of
`H` and tries to infer suitable instantiations for those variables.
-/

theorem silly2a : ∀ n m : nat,
    prod.pair n n = prod.pair m m ->
    (∀ q r : nat, prod.pair q q = prod.pair r r -> [p| q |] = [p| r |]) ->
    [p| n |] = [p| m |] := by
  intro n m eq1 eq2
  apply eq2
  apply eq1

/- **** Exercise: 2 stars, standard, optional (silly_ex) -/

theorem silly_ex : ∀ p,
    (∀ n, even n = true -> even (S n) = false) ->
    (∀ n, even n = false -> odd n = true) ->
    even p = true ->
    odd (S p) = true := by
  sorry

/-
To use `apply`, the conclusion of the fact being applied must match the goal
exactly, perhaps after simplification. For example, it will not directly solve
an equality whose two sides are swapped.
-/

theorem silly3 : ∀ n m : nat,
    n = m ->
    m = n := by
  intro n m h

  /-
  Here `apply h` does not work directly, because the goal has the equality in
  the opposite direction. The tactic `symm` plays the same role as Rocq's
  `symmetry` here.
  -/

  symm
  apply h

/- **** Exercise: 2 stars, standard (apply_exercise1) -/

/-
You can use `apply` with previously defined theorems, not just local
hypotheses. In the Rocq chapter this exercise points back to the theorem that
reversal is involutive.
-/

theorem rev_exercise1 : ∀ (l l' : list nat),
    l = rev l' ->
    l' = rev l := by
  intro l l' h
  rw [h]
  symm
  exact rev_involutive nat l'

/- **** Exercise: 1 star, standard, optional (apply_rewrite) -/

/-
Briefly explain the difference between `apply` and `rewrite`. In what
situations can both be used effectively?
-/

/- ################################################################# -/
/- * The [apply with] Tactic -/

/-
The following small example uses a rewrite followed by an `apply` to get from
`[a; b]` to `[e; f]`.
-/

theorem trans_eq_example : ∀ a b c d e f : nat,
    [p| a; b |] = [p| c; d |] ->
    [p| c; d |] = [p| e; f |] ->
    [p| a; b |] = [p| e; f |] := by
  intro a b c d e f eq1 eq2
  rw [eq1]
  apply eq2

/-
Since this pattern is common, we can package it up as a separate theorem saying
that equality is transitive.
-/

theorem trans_eq : ∀ (X : Type) (x y z : X),
    x = y -> y = z -> x = z := by
  intro X x y z eq1 eq2
  rw [eq1, eq2]

/-
To apply `trans_eq` to a concrete goal, we need to tell Lean what the middle
term should be. This is the same idea as Rocq's `apply ... with ...`.
-/

theorem trans_eq_example' : ∀ a b c d e f : nat,
    [p| a; b |] = [p| c; d |] ->
    [p| c; d |] = [p| e; f |] ->
    [p| a; b |] = [p| e; f |] := by
  intro a b c d e f eq1 eq2
  apply trans_eq (y := [p| c; d |])
  · apply eq1
  · apply eq2

/-
Lean also has a `trans` tactic that plays the same role as Rocq's
`transitivity`.
-/

theorem trans_eq_example'' : ∀ a b c d e f : nat,
    [p| a; b |] = [p| c; d |] ->
    [p| c; d |] = [p| e; f |] ->
    [p| a; b |] = [p| e; f |] := by
  intro a b c d e f eq1 eq2
  apply trans_eq (y := [p| c; d |])
  · exact eq1
  · exact eq2

/- **** Exercise: 3 stars, standard, optional (trans_eq_exercise) -/

theorem trans_eq_exercise : ∀ n m o p : nat,
    m = minustwo o ->
    n + p = m ->
    n + p = minustwo o := by
  sorry

/- ################################################################# -/
/- * The [injection] and [discriminate] Tactics -/

/-
The definition of natural numbers does not merely say that every number is
either `O` or `S n`. It also packages two structural facts:

- constructors are injective, and
- distinct constructors are disjoint.

The same principles apply to every inductively defined type.
-/

/-
We can prove the injectivity of `S` directly by using the predecessor function.
-/

theorem S_injective : ∀ n m : nat,
    S n = S m ->
    n = m := by
  intro n m h1
  have h2 : n = pred (S n) := by
    rfl
  rw [h2, h1]
  rfl

/-
Rocq's `assert` tactic, used above, introduces a local lemma that must first be
proved. Lean's `have` is the direct analogue.

As a more convenient alternative, Lean also supports the `injection` tactic,
which exploits constructor injectivity directly.
-/

theorem S_injective' : ∀ n m : nat,
    S n = S m ->
    n = m := by
  intro n m h
  injection h

/-
Here is a slightly richer example where injectivity yields more than one piece
of information.
-/

theorem injection_ex1 : ∀ n m o : nat,
    [p| n; m |] = [p| o; o |] ->
    n = m := by
  intro n m o h
  injection h with h1 h2
  have hm : m = o := by
    injection h2
  rw [h1, hm]

/- **** Exercise: 3 stars, standard (injection_ex3) -/

theorem injection_ex3 : ∀ (X : Type) (x y z : X) (l j : list X),
    x :: y :: l = z :: j ->
    j = z :: l ->
    x = y := by
  sorry

/-
Disjointness says that values built from different constructors can never be
equal. In Lean, as in Rocq, an impossible equality lets us conclude anything we
want.
-/

theorem discriminate_ex1 : ∀ n m : nat,
    false = true ->
    n = m := by
  intro n m contra
  cases contra

theorem discriminate_ex2 : ∀ n : nat,
    S n = O ->
    2 + 2 = 5 := by
  intro n contra
  cases contra

/-
These examples illustrate the principle of explosion: from a contradiction, any
conclusion follows.
-/

/- **** Exercise: 1 star, standard (discriminate_ex3) -/

theorem discriminate_ex3 :
    ∀ (X : Type) (x y z : X) (l j : list X),
      x :: y :: l = [p| |] ->
      x = z := by
  sorry

/-
We can also use constructor disjointness to relate `eqb` and propositional
equality.
-/

theorem eqb_0_l : ∀ n,
    eqb 0 n = true -> n = 0 := by
  intro n
  cases n with
  | zero =>
      intro h
      rfl
  | succ n' =>
      intro h
      simp [eqb] at h

/-
The converse direction of constructor injectivity is a special case of a more
general fact about functions.
-/

theorem f_equal : ∀ (A B : Type) (f : A -> B) (x y : A),
    x = y -> f x = f y := by
  intro A B f x y eq
  rw [eq]

theorem eq_implies_succ_equal : ∀ n m : nat,
    n = m -> S n = S m := by
  intro n m h
  apply f_equal
  apply h

/-
Lean also has a tactic named `f_equal`, just as Rocq does.
-/

theorem eq_implies_succ_equal' : ∀ n m : nat,
    n = m -> S n = S m := by
  intro n m h
  apply congrArg Nat.succ
  exact h

/- ################################################################# -/
/- * Using Tactics on Hypotheses -/

/-
By default, most tactics work on the goal and leave the context unchanged. But
many tactics also have variants that work on hypotheses.
-/

theorem S_inj : ∀ (n m : nat) (b : bool),
    eqb (S n) (S m) = b ->
    eqb n m = b := by
  intro n m b h
  simpa [eqb] using h

/-
Similarly, `apply L at H` performs forward reasoning: if `L` has the shape
`X -> Y` and `H` matches `X`, then `H` is replaced by a proof of `Y`.
-/

theorem silly4 : ∀ n m p q : nat,
    (n = m -> p = q) ->
    m = n ->
    q = p := by
  intro n m p q eq h
  symm at h
  have h' := eq h
  symm at h'
  exact h'

/-
Forward reasoning starts from what is given and pushes consequences forward.
Backward reasoning starts from the goal and asks what would suffice to prove it.
Rocq and Lean both support both styles, though everyday proof scripts often lean
toward the backward style.
-/

/- ################################################################# -/
/- * Specializing Hypotheses -/

/-
Another useful tactic is `specialize`, which refines an overly general
hypothesis by fixing some of its quantified variables.
-/

theorem specialize_example : ∀ n,
    (∀ m, m * n = 0) ->
    n = 0 := by
  intro n h
  specialize h 1
  simpa using h

/- **** Exercise: 3 stars, standard (nth_error_always_none) -/

/-
Use `specialize` to prove the following lemma, following the same model.
-/

theorem nth_error_always_none : ∀ (l : list nat),
    (∀ i, nth_error l i = None) ->
    l = [p| |] := by
  sorry

/-
In Lean, one common way to specialize a globally available theorem is to first
bind a specialized instance with `have` and then apply it.
-/

theorem trans_eq_example''' : ∀ a b c d e f : nat,
    [p| a; b |] = [p| c; d |] ->
    [p| c; d |] = [p| e; f |] ->
    [p| a; b |] = [p| e; f |] := by
  intro a b c d e f eq1 eq2
  have h := trans_eq (X := list nat) (x := [p| a; b |]) (y := [p| c; d |]) (z := [p| e; f |])
  apply h
  · exact eq1
  · exact eq2

/- ################################################################# -/
/- * Varying the Induction Hypothesis -/

/-
Sometimes it is important to control the exact form of the induction hypothesis.
In particular, we may need to be careful about which assumptions we introduce
before invoking induction.

Suppose we want to show that `double` is injective. The key lesson is that if
we introduce too many variables before induction, we can end up with an
induction hypothesis that is too weak to finish the proof.
-/

/-
A successful proof keeps `m` universally quantified when the induction on `n`
begins.
-/

theorem double_injective : ∀ n m,
    double n = double m ->
    n = m := by
  intro n
  induction n with
  | zero =>
      intro m eq
      cases m with
      | zero => rfl
      | succ m' => cases eq
  | succ n' ihn =>
      intro m eq
      cases m with
      | zero => cases eq
      | succ m' =>
          apply congrArg Nat.succ
          apply ihn
          simpa [double] using eq

/-
The same strategic issue appears in later proofs. The point is not merely that
induction works, but that it often matters a great deal which variables are
still generic when the induction hypothesis is formed.
-/

/- **** Exercise: 2 stars, standard (eqb_true) -/

theorem eqb_true : ∀ n m,
    eqb n m = true -> n = m := by
  sorry

/- **** Exercise: 2 stars, advanced, optional (eqb_true_informal) -/

/-
Give a careful informal proof of `eqb_true`, stating the induction hypothesis
explicitly and being as explicit as possible about quantifiers.
-/

def manual_grade_for_informal_proof : Option (nat × String) := none

/- **** Exercise: 3 stars, standard, especially useful (plus_n_n_injective) -/

theorem plus_n_n_injective : ∀ n m : nat,
    n + n = m + m ->
    n = m := by
  sorry

/-
Doing fewer `intros` before induction is not always enough. Sometimes we need
to put a variable back into the goal so that the induction hypothesis becomes
sufficiently general.

In Rocq this is presented with `generalize dependent`. In Lean, the everyday
equivalent is usually `revert`.
-/

theorem double_injective_take2 : ∀ n m,
    double n = double m ->
    n = m := by
  intro n m
  revert n
  induction m with
  | zero =>
      intro n eq
      cases n with
      | zero => rfl
      | succ n' => cases eq
  | succ m' ihm =>
      intro n eq
      cases n with
      | zero => cases eq
      | succ n' =>
          apply congrArg Nat.succ
          apply ihm
          simpa [double] using eq

/- ################################################################# -/
/- * Rewriting with conditional statements -/

/-
Suppose we want to show that addition is the inverse of subtraction under a
hypothesis saying that no truncation occurs. The start of the proof follows the
same pattern as before: we induct on `n` before introducing `m`, so that the
induction hypothesis remains general enough.

Rocq highlights that rewriting with a conditional statement can create new
subgoals for its premises. In Lean it is often more direct to instantiate the
induction hypothesis explicitly and rewrite with the resulting equality.
-/

theorem sub_add_leb : ∀ n m, leb n m = true -> (m - n) + n = m := by
  intro n
  induction n with
  | zero =>
      intro m h
      simp [leb] at h ⊢
  | succ n' ihn =>
      intro m h
      cases m with
      | zero =>
          simp [leb] at h
      | succ m' =>
          simp [leb] at h
          simp
          rw [<- plus_n_Sm]
          rw [ihn m' h]

/- **** Exercise: 3 stars, standard, especially useful (gen_dep_practice) -/

theorem nth_error_after_last : ∀ (n : nat) (X : Type) (l : list X),
    length l = n ->
    nth_error l n = None := by
  sorry

/- ################################################################# -/
/- * Unfolding Definitions -/

/-
Sometimes we need to unfold a definition by hand before we can make progress.
-/

def square (n : nat) := n * n

theorem square_mult : ∀ n m, square (n * m) = square n * square m := by
  intro n m
  unfold square
  rw [mult_assoc]
  have h : n * m * n = n * n * m := by
    rw [mul_comm, mult_assoc]
  rw [h, mult_assoc]

/-
Automatic unfolding is helpful, but conservative. Lean behaves much like Rocq
here: it unfolds when doing so leads to immediate simplification, but it will
not blindly expand every definition.
-/

def foo (_x : nat) := 5

theorem silly_fact_1 : ∀ m, foo m + 1 = foo (m + 1) + 1 := by
  intro m
  simp [foo]

def bar (x : nat) :=
  match x with
  | 0 => 5
  | _ => 5

/-
Here a direct simplification gets stuck because the hidden match does not yet
know whether its scrutinee is zero or a successor. Case analysis resolves that.
-/

theorem silly_fact_2 : ∀ m, bar m + 1 = bar (m + 1) + 1 := by
  intro m
  cases m with
  | zero => simp [bar]
  | succ m' => simp [bar]

/-
Alternatively, we can expose the hidden match ourselves by unfolding `bar`
before doing the case split.
-/

theorem silly_fact_2' : ∀ m, bar m + 1 = bar (m + 1) + 1 := by
  intro m
  unfold bar
  cases m with
  | zero => rfl
  | succ m' => rfl

/- ################################################################# -/
/- * Using [destruct] on Compound Expressions -/

/-
We have seen many examples where case analysis is performed on variables. Just
as in Rocq, we can also reason by cases on the result of a compound expression.
-/

def sillyfun (n : nat) : bool :=
  if eqb n 3 then false
  else if eqb n 5 then false
  else false

theorem sillyfun_false : ∀ n : nat, sillyfun n = false := by
  intro n
  unfold sillyfun
  cases h3 : eqb n 3
  · rfl
  · cases h5 : eqb n 5 <;> rfl

/- **** Exercise: 3 stars, standard (combine_split) -/

/-
Here is the implementation of `split` mentioned in the `Poly` chapter.
-/

def split {X Y : Type} (l : list (prod X Y)) : prod (list X) (list Y) :=
  match l with
  | [p| |] => prod.pair [p| |] [p| |]
  | prod.pair x y :: t =>
      match split t with
      | prod.pair lx ly => prod.pair (x :: lx) (y :: ly)

theorem combine_split : ∀ X Y (l : list (prod X Y)) l1 l2,
    split l = prod.pair l1 l2 ->
    combine l1 l2 = l := by
  sorry

/-
When we do case analysis on a compound expression, retaining an equation for the
result can be essential. Lean's `cases h : e` is the direct parallel of Rocq's
`destruct e eqn:h`.
-/

def sillyfun1 (n : nat) : bool :=
  if eqb n 3 then true
  else if eqb n 5 then true
  else false

theorem sillyfun1_odd : ∀ n : nat,
    sillyfun1 n = true ->
    odd n = true := by
  intro n eq
  cases h3 : eqb n 3
  · have hn3 : n = 3 := eqb_true n 3 h3
    rw [hn3]
    rfl
  · simp [sillyfun1, h3] at eq
    cases h5 : eqb n 5
    · have hn5 : n = 5 := eqb_true n 5 h5
      rw [hn5]
      rfl
    · simp [h5] at eq

/- **** Exercise: 2 stars, standard (destruct_eqn_practice) -/

theorem bool_fn_applied_thrice :
    ∀ (f : bool -> bool) (b : bool),
      f (f (f b)) = f b := by
  sorry

/- ################################################################# -/
/- * Review -/

/-
We have now discussed many of the most fundamental Rocq tactics and their Lean
counterparts. Later chapters will introduce a few more and then begin leaning
on automation, but this is already enough to do a substantial amount of work.

The main characters in this chapter were:

- `intro`
- `rfl`
- `apply`
- `apply ... at ...`
- `specialize`
- `simp`
- `rw`
- `symm`
- `trans`
- `unfold`
- `cases`
- `induction`
- `injection`
- `have`
- `revert`
- `f_equal`

The names are not always identical to Rocq's, but the proof ideas are the same.
-/

/- ################################################################# -/
/- * Additional Exercises -/

/- **** Exercise: 3 stars, standard (eqb_sym) -/

theorem eqb_sym : ∀ n m : nat,
    eqb n m = eqb m n := by
  sorry

/- **** Exercise: 3 stars, advanced, optional (eqb_sym_informal) -/

/-
Give an informal proof corresponding to your formal proof of `eqb_sym`.
-/

/- **** Exercise: 3 stars, standard, optional (eqb_trans) -/

theorem eqb_trans : ∀ n m p,
    eqb n m = true ->
    eqb m p = true ->
    eqb n p = true := by
  sorry

/- **** Exercise: 3 stars, advanced (split_combine) -/

/-
Complete the definition of `split_combine_statement` with a property expressing
that `split` is an inverse of `combine`, accounting for the base cases where
`combine` may discard extra elements.
-/

def split_combine_statement : Prop := by
  sorry

theorem split_combine : split_combine_statement := by
  sorry

def manual_grade_for_split_combine : Option (nat × String) := none

/- **** Exercise: 3 stars, advanced (filter_exercise) -/

theorem filter_exercise : ∀ (X : Type) (test : X -> bool) (x : X) (l lf : list X),
    filter test l = x :: lf ->
    test x = true := by
  sorry

/- **** Exercise: 4 stars, advanced, especially useful (forall_exists_challenge) -/

/-
Define recursive functions `forallb` and `existsb`, then a nonrecursive version
`existsb'` in terms of `forallb` and `negb`, and finally prove that they agree.
-/

def forallb {X : Type} (test : X -> bool) (l : list X) : bool := by
  sorry

theorem test_forallb_1 : forallb odd [p| 1; 3; 5; 7; 9 |] = true := by
  sorry

theorem test_forallb_2 : forallb negb [p| false; false |] = true := by
  sorry

theorem test_forallb_3 : forallb even [p| 0; 2; 4; 5 |] = false := by
  sorry

theorem test_forallb_4 : forallb (eqb 5) [p| |] = true := by
  sorry

def existsb {X : Type} (test : X -> bool) (l : list X) : bool := by
  sorry

theorem test_existsb_1 : existsb (eqb 5) [p| 0; 2; 3; 6 |] = false := by
  sorry

theorem test_existsb_2 : existsb (andb true) [p| true; true; false |] = true := by
  sorry

theorem test_existsb_3 : existsb odd [p| 1; 0; 0; 0; 0; 3 |] = true := by
  sorry

theorem test_existsb_4 : existsb even [p| |] = false := by
  sorry

def existsb' {X : Type} (test : X -> bool) (l : list X) : bool := by
  sorry

theorem existsb_existsb' : ∀ (X : Type) (test : X -> bool) (l : list X),
    existsb test l = existsb' test l := by
  sorry

end Tactics
