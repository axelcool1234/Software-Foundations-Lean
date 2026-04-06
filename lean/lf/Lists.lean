import lf.Induction

set_option autoImplicit false

/- ################################################################# -/
/- * Lists: Working with Structured Data -/

/-
This chapter is a Lean-oriented translation of `rocq/lf/Lists.v`. Like the
Rocq original, it continues the progression from simple inductive datatypes to
slightly richer structured data: pairs, lists, options, and a small partial-map
datatype.

The chapter depends naturally on the previous one, so we import
`lf.Induction` rather than restating its definitions. As elsewhere in this
repository, worked material is translated into ordinary Lean proofs, while
student exercises remain as `sorry` unless the source chapter already solved
them.
-/

namespace NatList

/- ################################################################# -/
/- * Pairs of Numbers -/

/-
In an inductive definition, each constructor may take any number of arguments.
The constructors we have seen so far took zero arguments, like `true`, or one,
like `S`. Here is a constructor taking two.
-/

inductive natprod where
  | pair (n1 n2 : nat)
  deriving Repr, DecidableEq

/-
This says that a pair of naturals is built by applying `pair` to two natural
numbers.

Rocq introduces notation `(x, y)` for this custom pair type. Lean already uses
that notation for the standard product type, so to avoid confusion we keep the
constructor name `pair` explicit in code and mention the difference here in the
surrounding prose.
-/

#check (natprod.pair 3 5 : natprod)

/-
We can extract the two components of a pair by pattern matching.
-/

def fst (p : natprod) : nat :=
  match p with
  | natprod.pair x _ => x

def snd (p : natprod) : nat :=
  match p with
  | natprod.pair _ y => y

#eval fst (natprod.pair 3 5)
-- 3

def fst' (p : natprod) : nat :=
  match p with
  | natprod.pair x _ => x

def snd' (p : natprod) : nat :=
  match p with
  | natprod.pair _ y => y

def swap_pair (p : natprod) : natprod :=
  match p with
  | natprod.pair x y => natprod.pair y x

/-
As in the Rocq text, it is worth distinguishing pattern matching on a single
pair from matching on multiple values at once. Lean has both ideas too, even if
the syntax is not identical.
-/

theorem surjective_pairing' : ∀ n m : nat,
    natprod.pair n m = natprod.pair (fst (natprod.pair n m)) (snd (natprod.pair n m)) := by
  intro n m
  rfl

/-
This slightly artificial formulation reduces all the way by computation alone.
The more natural statement needs case analysis to expose the shape of the pair.
-/

theorem surjective_pairing : ∀ p : natprod,
    p = natprod.pair (fst p) (snd p) := by
  intro p
  cases p with
  | pair n m =>
      rfl

/-
Unlike `nat`, the type `natprod` has only one constructor, so case analysis
produces only one branch.
-/

/- **** Exercise: 1 star, standard (snd_fst_is_swap) -/

theorem snd_fst_is_swap : ∀ p : natprod,
    natprod.pair (snd p) (fst p) = swap_pair p := by
  sorry

/- **** Exercise: 1 star, standard, optional (fst_swap_is_snd) -/

theorem fst_swap_is_snd : ∀ p : natprod, fst (swap_pair p) = snd p := by
  sorry

/- ################################################################# -/
/- * Lists of Numbers -/

/-
Generalizing pairs, we can describe a list of naturals as either the empty list
or a natural number together with another list.
-/

inductive natlist where
  | nil
  | cons (n : nat) (l : natlist)
  deriving Repr, DecidableEq

infixr:67 " ::: " => natlist.cons

syntax "[|" sepBy(term, "; ") "|]" : term

macro_rules
  | `([| |]) => `(natlist.nil)
  | `([| $x:term |]) => `(natlist.cons $x natlist.nil)
  | `([| $x:term; $xs:term;* |]) => `(natlist.cons $x [| $xs;* |])

/-
Rocq can reuse its standard square-bracket notation for this custom datatype.
Lean's ordinary `[ ... ]` notation is already reserved for the standard library
type `List`, so we use the custom form `[| ... |]` for values of `natlist`.
The point is the same: we want a readable notation for nested applications of
`cons`.
-/

def mylist : natlist := natlist.cons 1 (natlist.cons 2 (natlist.cons 3 natlist.nil))

def mylist1 : natlist := 1 ::: (2 ::: (3 ::: natlist.nil))
def mylist2 : natlist := 1 ::: 2 ::: 3 ::: natlist.nil
def mylist3 : natlist := [| 1; 2; 3 |]

/-
Again, the details of precedence are not the main point. What matters is that
the notation lets us read and write lists in a way that mirrors the Rocq text.
-/

/- *** Repeat -/

/-
The function `repeat` produces a list of a given length in which every element
is the same natural number.
-/

def «repeat» (n count : nat) : natlist :=
  match count with
  | 0 => natlist.nil
  | Nat.succ count' => n ::: «repeat» n count'

/- *** Length -/

/-
The function `length` counts the number of elements in a list.
-/

def length (l : natlist) : nat :=
  match l with
  | natlist.nil => 0
  | _ ::: t => Nat.succ (length t)

/- *** Append -/

/-
The function `app` concatenates two lists.
-/

def app (l1 l2 : natlist) : natlist :=
  match l1 with
  | natlist.nil => l2
  | h ::: t => h ::: app t l2

infixr:65 " ++ " => app

theorem test_app1 : [| 1; 2; 3 |] ++ [| 4; 5 |] = [| 1; 2; 3; 4; 5 |] := by
  rfl

theorem test_app2 : natlist.nil ++ [| 4; 5 |] = [| 4; 5 |] := by
  rfl

theorem test_app3 : [| 1; 2; 3 |] ++ natlist.nil = [| 1; 2; 3 |] := by
  rfl

/- *** Head and Tail -/

/-
Here are two more useful functions for working with lists. As in the Rocq
chapter, `hd` takes a default value to return on the empty list.
-/

def hd (default : nat) (l : natlist) : nat :=
  match l with
  | natlist.nil => default
  | h ::: _ => h

def tl (l : natlist) : natlist :=
  match l with
  | natlist.nil => natlist.nil
  | _ ::: t => t

theorem test_hd1 : hd 0 [| 1; 2; 3 |] = 1 := by
  rfl

theorem test_hd2 : hd 0 [| |] = 0 := by
  rfl

theorem test_tl : tl [| 1; 2; 3 |] = [| 2; 3 |] := by
  rfl

/- *** Exercises -/

/- **** Exercise: 2 stars, standard, especially useful (list_funs) -/

/-
Complete the definitions of `nonzeros`, `oddmembers`, and
`countoddmembers`. The tests illustrate the intended behavior.
-/

def nonzeros (l : natlist) : natlist := by
  sorry

theorem test_nonzeros : nonzeros [| 0; 1; 0; 2; 3; 0; 0 |] = [| 1; 2; 3 |] := by
  sorry

def oddmembers (l : natlist) : natlist := by
  sorry

theorem test_oddmembers : oddmembers [| 0; 1; 0; 2; 3; 0; 0 |] = [| 1; 3 |] := by
  sorry

/-
For `countoddmembers`, the point is to encourage a definition in terms of the
functions already introduced rather than a fresh recursion.
-/

def countoddmembers (l : natlist) : nat := by
  sorry

theorem test_countoddmembers1 : countoddmembers [| 1; 0; 3; 1; 4; 5 |] = 4 := by
  sorry

theorem test_countoddmembers2 : countoddmembers [| 0; 2; 4 |] = 0 := by
  sorry

theorem test_countoddmembers3 : countoddmembers natlist.nil = 0 := by
  sorry

/- **** Exercise: 3 stars, advanced (alternate) -/

/-
Define `alternate`, which interleaves two lists. In Lean, just as in Rocq, the
cleanest structurally recursive definition matches on both lists together.
-/

def alternate (l1 l2 : natlist) : natlist := by
  sorry

theorem test_alternate1 : alternate [| 1; 2; 3 |] [| 4; 5; 6 |] = [| 1; 4; 2; 5; 3; 6 |] := by
  sorry

theorem test_alternate2 : alternate [| 1 |] [| 4; 5; 6 |] = [| 1; 4; 5; 6 |] := by
  sorry

theorem test_alternate3 : alternate [| 1; 2; 3 |] [| 4 |] = [| 1; 4; 2; 3 |] := by
  sorry

theorem test_alternate4 : alternate [| |] [| 20; 30 |] = [| 20; 30 |] := by
  sorry

/- *** Bags via Lists -/

/-
A bag, or multiset, is like a set except that elements may appear more than
once. One simple representation is just a list.
-/

abbrev bag := natlist

/- **** Exercise: 3 stars, standard, especially useful (bag_functions) -/

/-
Complete the basic bag operations `count`, `sum`, `add`, and `member`.
-/

def count (v : nat) (s : bag) : nat := by
  sorry

theorem test_count1 : count 1 [| 1; 2; 3; 1; 4; 1 |] = 3 := by
  sorry

theorem test_count2 : count 6 [| 1; 2; 3; 1; 4; 1 |] = 0 := by
  sorry

/-
Multiset `sum` is analogous to set union, except that multiplicities are added.
As in the Rocq source, the point is to define it in terms of an already-known
operation.
-/

def sum : bag → bag → bag := by
  sorry

theorem test_sum1 : count 1 (sum [| 1; 2; 3 |] [| 1; 4; 1 |]) = 3 := by
  sorry

def add (v : nat) (s : bag) : bag := by
  sorry

theorem test_add1 : count 1 (add 1 [| 1; 4; 1 |]) = 3 := by
  sorry

theorem test_add2 : count 5 (add 1 [| 1; 4; 1 |]) = 0 := by
  sorry

def member (v : nat) (s : bag) : bool := by
  sorry

theorem test_member1 : member 1 [| 1; 4; 1 |] = true := by
  sorry

theorem test_member2 : member 2 [| 1; 4; 1 |] = false := by
  sorry

/- **** Exercise: 3 stars, standard, optional (bag_more_functions) -/

def remove_one (v : nat) (s : bag) : bag := by
  sorry

theorem test_remove_one1 : count 5 (remove_one 5 [| 2; 1; 5; 4; 1 |]) = 0 := by
  sorry

theorem test_remove_one2 : count 5 (remove_one 5 [| 2; 1; 4; 1 |]) = 0 := by
  sorry

theorem test_remove_one3 : count 4 (remove_one 5 [| 2; 1; 4; 5; 1; 4 |]) = 2 := by
  sorry

theorem test_remove_one4 : count 5 (remove_one 5 [| 2; 1; 5; 4; 5; 1; 4 |]) = 1 := by
  sorry

def remove_all (v : nat) (s : bag) : bag := by
  sorry

theorem test_remove_all1 : count 5 (remove_all 5 [| 2; 1; 5; 4; 1 |]) = 0 := by
  sorry

theorem test_remove_all2 : count 5 (remove_all 5 [| 2; 1; 4; 1 |]) = 0 := by
  sorry

theorem test_remove_all3 : count 4 (remove_all 5 [| 2; 1; 4; 5; 1; 4 |]) = 2 := by
  sorry

theorem test_remove_all4 : count 5 (remove_all 5 [| 2; 1; 5; 4; 5; 1; 4; 5; 1; 4 |]) = 0 := by
  sorry

def included (s1 s2 : bag) : bool := by
  sorry

theorem test_included1 : included [| 1; 2 |] [| 2; 1; 4; 1 |] = true := by
  sorry

theorem test_included2 : included [| 1; 2; 2 |] [| 2; 1; 4; 1 |] = false := by
  sorry

/- **** Exercise: 2 stars, standard, optional (add_inc_count) -/

theorem add_inc_count : ∀ s : bag, ∀ v : nat,
    count v (add v s) = S (count v s) := by
  sorry

def manual_grade_for_add_inc_count : Option (nat × String) := none

/- ################################################################# -/
/- * Reasoning About Lists -/

/-
As with natural numbers, some facts about lists follow by computation alone,
while others require case analysis or induction.
-/

theorem nil_app : ∀ l : natlist, natlist.nil ++ l = l := by
  intro l
  rfl

/-
Here the left-hand side reduces directly because the match in the definition of
`app` can see that its first argument is `nil`.
-/

theorem tl_length_pred : ∀ l : natlist, pred (length l) = length (tl l) := by
  intro l
  cases l with
  | nil =>
      rfl
  | cons n l' =>
      rfl

/-
Usually, though, the interesting theorems about lists need induction.
-/

/- ================================================================= -/
/- ** Induction on Lists -/

/-
Induction on a list mirrors induction on a natural number. To prove some
property `P l` for every list `l`, we show it for the empty list and then show
that, if it holds for a smaller list `l'`, it also holds for `n ::: l'`.
-/

theorem app_assoc : ∀ l1 l2 l3 : natlist,
    (l1 ++ l2) ++ l3 = l1 ++ (l2 ++ l3) := by
  intro l1 l2 l3
  induction l1 with
  | nil =>
      rfl
  | cons n l1' ih =>
      simp [app, ih]

/-
As in the Rocq development, the induction hypothesis is the key resource in the
nonempty case. The structure of the proof closely follows the structure of the
definition of `app`.
-/

/- *** Generalizing Statements -/

/-
Sometimes an attempted induction gets stuck because the induction hypothesis is
too weak. The cure is to generalize the statement so that the induction
hypothesis becomes stronger.

The Rocq chapter makes this point by starting with a proof attempt that keeps
both copies of `repeat` synchronized too rigidly. After inducting on the first
counter, the induction hypothesis talks only about `repeat n c' ++ repeat n c'`,
while the successor case really wants to compare against `repeat n (c' + S c')`.
Lean runs into the same issue: the proof gets easier only after we generalize
the second summand and ask for a theorem that works for any `c2`.
-/

theorem repeat_plus : ∀ c1 c2 n : nat,
    «repeat» n c1 ++ «repeat» n c2 = «repeat» n (c1 + c2) := by
  intro c1 c2 n
  induction c1 with
  | zero =>
      simp [«repeat», app]
  | succ c1 ih =>
      rw [Nat.succ_add]
      simp [«repeat», app, ih]

/- *** Reversing a List -/

/-
For a more interesting inductive example, define list reversal in terms of
append.
-/

def rev (l : natlist) : natlist :=
  match l with
  | natlist.nil => natlist.nil
  | h ::: t => rev t ++ [| h |]

theorem test_rev1 : rev [| 1; 2; 3 |] = [| 3; 2; 1 |] := by
  rfl

theorem test_rev2 : rev natlist.nil = natlist.nil := by
  rfl

/-
As in the Rocq chapter, the direct proof that reversal preserves length gets
stuck until we first prove a more general lemma about appending a singleton.
The interesting point is not just that the first proof fails, but why it fails:
after simplifying `rev (n ::: l')`, the goal contains an append, while the
induction hypothesis says something only about `length (rev l')`. Rewriting by
the induction hypothesis helps a little, but it does not explain how appending
one more element changes length.

The Rocq text then shows a second failed attempt with a lemma specialized to
reversed lists. That version is still too narrow. The useful idea is to step
back once more and prove a fact about arbitrary lists, because that stronger
statement is exactly what the reversal proof needs.
-/

theorem app_length_S : ∀ l : natlist, ∀ n : nat, length (l ++ [| n |]) = Nat.succ (length l) := by
  intro l n
  induction l with
  | nil =>
      rfl
  | cons m l' ih =>
      simpa [app, length] using congrArg Nat.succ ih

theorem rev_length : ∀ l : natlist, length (rev l) = length l := by
  intro l
  induction l with
  | nil =>
      rfl
  | cons n l' ih =>
      simp [rev]
      rw [app_length_S, ih]
      rfl

/-
The singleton lemma is useful on its own, but it also points toward a still
more general statement about the length of any append. This is the same
pedagogical pattern as before: once a narrowly targeted helper lemma works, it
is worth asking whether a cleaner and more reusable version is available.
-/

theorem app_length : ∀ l1 l2 : natlist, length (l1 ++ l2) = length l1 + length l2 := by
  intro l1 l2
  induction l1 with
  | nil =>
      simp [app, length]
  | cons n l1' ih =>
      rw [app, length, length, ih, Nat.succ_add]

/-
The Rocq chapter includes informal proofs here too. The same pedagogical moral
applies in Lean: a compact tactic script may be correct, but a learner still
benefits from prose that points out where the induction hypothesis is used.
For `app_length`, the induction is on the first list; the empty case is just
computation, and the nonempty case reduces to the induction hypothesis after
one application of the definitions of `app` and `length`.
-/

/- ================================================================= -/
/- ** [Search] -/

/-
Rocq's `Search` command helps locate already-proved lemmas. Lean offers a
similar idea through editor support and commands such as `#check` and `#find`.
The exact interface differs, but the lesson is the same: theorem search is a
normal part of proof development.

For instance, if you want to remember a theorem about `rev`, it is often enough
to search the current file or ask the editor for declarations involving that
name. And if you suspect a theorem like commutativity of addition already
exists, search tools are faster and more reliable than guessing names.
-/

#check app_assoc
#check rev_length
#check add_comm

/- ================================================================= -/
/- ** List Exercises, Part 1 -/

/- **** Exercise: 3 stars, standard (list_exercises) -/

theorem app_nil_r : ∀ l : natlist, l ++ natlist.nil = l := by
  sorry

theorem rev_app_distr : ∀ l1 l2 : natlist, rev (l1 ++ l2) = rev l2 ++ rev l1 := by
  sorry

/-
An involution is a function that is its own inverse. Reversal is the running
example here.
-/

theorem rev_involutive : ∀ l : natlist, rev (rev l) = l := by
  sorry

theorem app_assoc4 : ∀ l1 l2 l3 l4 : natlist,
    l1 ++ (l2 ++ (l3 ++ l4)) = ((l1 ++ l2) ++ l3) ++ l4 := by
  sorry

theorem nonzeros_app : ∀ l1 l2 : natlist,
    nonzeros (l1 ++ l2) = (nonzeros l1 ++ nonzeros l2) := by
  sorry

/- **** Exercise: 2 stars, standard (eqblist) -/

def eqblist (l1 l2 : natlist) : bool := by
  sorry

theorem test_eqblist1 : eqblist natlist.nil natlist.nil = true := by
  sorry

theorem test_eqblist2 : eqblist [| 1; 2; 3 |] [| 1; 2; 3 |] = true := by
  sorry

theorem test_eqblist3 : eqblist [| 1; 2; 3 |] [| 1; 2; 4 |] = false := by
  sorry

theorem eqblist_refl : ∀ l : natlist, true = eqblist l l := by
  sorry

/- ================================================================= -/
/- ** List Exercises, Part 2 -/

/-
These exercises return to bags and then connect the chapter's results about
reversal with more abstract properties such as injectivity.
-/

/- **** Exercise: 1 star, standard (count_member_nonzero) -/

theorem count_member_nonzero : ∀ s : bag, leb 1 (count 1 (1 ::: s)) = true := by
  sorry

/-
The next lemma about `leb` is worked out in the source chapter and is useful in
later developments too.
-/

theorem leb_n_Sn : ∀ n : nat, leb n (S n) = true := by
  intro n
  induction n with
  | zero =>
      rfl
  | succ n ih =>
      simpa [leb] using ih

/- **** Exercise: 3 stars, advanced (remove_does_not_increase_count) -/

theorem remove_does_not_increase_count : ∀ s : bag,
    leb (count 0 (remove_one 0 s)) (count 0 s) = true := by
  sorry

/- **** Exercise: 3 stars, standard, optional (bag_count_sum) -/

/-
As in the Rocq chapter, this slot is deliberately left for the reader to state
and prove an interesting theorem of their own about `count` and `sum`.
-/

/- **** Exercise: 3 stars, advanced (involution_injective) -/

theorem involution_injective : ∀ f : nat → nat,
    (∀ n : nat, n = f (f n)) → (∀ n1 n2 : nat, f n1 = f n2 → n1 = n2) := by
  sorry

/- **** Exercise: 2 stars, advanced (rev_injective) -/

theorem rev_injective : ∀ l1 l2 : natlist, rev l1 = rev l2 → l1 = l2 := by
  sorry

/- ################################################################# -/
/- * Options -/

/-
If a function may fail to return an ordinary answer, it is often better to make
that possibility explicit in the return type. The chapter illustrates this with
lookup in a list.
-/

def nth_bad (l : natlist) (n : nat) : nat :=
  match l with
  | natlist.nil => 42
  | a ::: l' =>
      match n with
      | 0 => a
      | Nat.succ n' => nth_bad l' n'

/-
Returning `42` on failure is not very informative, so we introduce an option
type of naturals and return either `Some n` or `None`.
-/

inductive natoption where
  | Some (n : nat)
  | None
  deriving Repr, DecidableEq

def nth_error (l : natlist) (n : nat) : natoption :=
  match l with
  | natlist.nil => natoption.None
  | a ::: l' =>
      match n with
      | 0 => natoption.Some a
      | Nat.succ n' => nth_error l' n'

theorem test_nth_error1 : nth_error [| 4; 5; 6; 7 |] 0 = natoption.Some 4 := by
  rfl

theorem test_nth_error2 : nth_error [| 4; 5; 6; 7 |] 3 = natoption.Some 7 := by
  rfl

theorem test_nth_error3 : nth_error [| 4; 5; 6; 7 |] 9 = natoption.None := by
  rfl

def option_elim (d : nat) (o : natoption) : nat :=
  match o with
  | natoption.Some n' => n'
  | natoption.None => d

/- **** Exercise: 2 stars, standard (hd_error) -/

def hd_error (l : natlist) : natoption := by
  sorry

theorem test_hd_error1 : hd_error [| |] = natoption.None := by
  sorry

theorem test_hd_error2 : hd_error [| 1 |] = natoption.Some 1 := by
  sorry

theorem test_hd_error3 : hd_error [| 5; 6 |] = natoption.Some 5 := by
  sorry

/- **** Exercise: 1 star, standard, optional (option_elim_hd) -/

theorem option_elim_hd : ∀ l : natlist, ∀ default : nat,
    hd default l = option_elim default (hd_error l) := by
  sorry

end NatList

/- ################################################################# -/
/- * Partial Maps -/

/-
As a final example, the chapter builds a tiny partial-map datatype. This is not
meant to compete with Lean's library map types; it is another exercise in how
to define and reason about inductive data structures.
-/

/-
Lean already has a global identifier named `id`, so we name this datatype
`SFId` while keeping the theorem names parallel to the Rocq source.
-/

inductive SFId where
  | Id (n : nat)
  deriving Repr, DecidableEq

def eqb_id (x1 x2 : SFId) : bool :=
  match x1, x2 with
  | SFId.Id n1, SFId.Id n2 => eqb n1 n2

/- **** Exercise: 1 star, standard (eqb_id_refl) -/

theorem eqb_id_refl : ∀ x : SFId, eqb_id x x = true := by
  sorry

namespace PartialMap

open NatList

inductive partial_map where
  | empty
  | record (i : SFId) (v : nat) (m : partial_map)
  deriving Repr

/-
An update simply adds a new record at the front. A lookup walks down the chain
until it either finds the key it wants or runs out of records.
-/

def update (d : partial_map) (x : SFId) (value : nat) : partial_map :=
  partial_map.record x value d

def find (x : SFId) (d : partial_map) : NatList.natoption :=
  match d with
  | partial_map.empty => NatList.natoption.None
  | partial_map.record y v d' =>
      if eqb_id x y then NatList.natoption.Some v else find x d'

/- **** Exercise: 1 star, standard (update_eq) -/

theorem update_eq : ∀ d : partial_map, ∀ x : SFId, ∀ v : nat,
    find x (update d x v) = NatList.natoption.Some v := by
  sorry

/- **** Exercise: 1 star, standard (update_neq) -/

theorem update_neq : ∀ d : partial_map, ∀ x y : SFId, ∀ o : nat,
    eqb_id x y = false → find x (update d y o) = find x d := by
  sorry

end PartialMap
