import Std

set_option autoImplicit false

abbrev nat := Nat

abbrev O : nat := 0
abbrev S : nat → nat := Nat.succ

def pred : nat → nat := Nat.pred

/-
* Basics: Functional Programming in Lean

This file is a Lean-oriented translation of `rocq/lf/Basics.v`. It keeps the
chapter-style commentary and the overall progression of the original while
adapting individual definitions and proofs to Lean 4.

As in the Software Foundations sources, proved material is fully translated,
while student exercises are left as `sorry` unless the source had already
completed them. In a few places the surrounding prose is adjusted because Lean
and Rocq differ in details such as conditionals, namespace syntax, or tactic
names.
-/

/- ################################################################# -/
/- * Introduction -/

/-
The functional style of programming is founded on simple mathematical
intuitions: if a procedure has no side effects, then understanding it amounts
to understanding how it maps inputs to outputs. This direct connection between
programs and mathematical objects supports both formal proofs and informal
reasoning.

The other sense in which functional programming is "functional" is that it
emphasizes functions as first-class values: values that can be passed around,
returned, stored in data structures, and manipulated just like other data.

Other common features of functional languages include algebraic data types,
pattern matching, and rich type systems supporting abstraction and code reuse.
Lean offers all of these features.

The first half of this chapter introduces some key elements of Lean's native
functional programming language. The second half introduces the proof patterns
that correspond to the Rocq tactics used in the original chapter.
-/

/- ################################################################# -/
/- * Homework Submission Guidelines -/

/-
If you are using Software Foundations in a course, your instructor may use
automatic scripts to help grade your homework. To keep those scripts happy,
the same basic advice from the Rocq chapter still applies here.

- Do not change the names of exercises.
- Do not delete exercises.
- It is fine to add helper definitions or lemmas before the theorem you are
  asked to prove.
- If you leave an exercise incomplete, mark it with `sorry` so the file still
  elaborates and the missing part is visible.

The original Rocq chapter comes with a matching test script, `BasicsTest.v`.
This Lean translation does not yet have a parallel Lean test file, so the main
sanity check is simply to run Lean on the chapter itself.
-/

/- ################################################################# -/
/- * Data and Functions -/

/-
One notable thing about Rocq, and likewise about the small fragments of Lean we
use in this chapter, is how little needs to be assumed at the beginning. We
start with simple inductive datatypes and define functions over them by pattern
matching. The point is not that Lean lacks built-in booleans, numbers, or other
conveniences; rather, it is pedagogically useful to rebuild familiar notions in
small steps and examine their behavior directly.
-/

/- ================================================================= -/
/- ** Enumerated Types -/

/-
An enumerated datatype is one whose definition simply lists its constructors.
Once such a type is defined, functions over its values are usually written by
matching on the possible constructors.
-/

/- ================================================================= -/
/- ** Days of the Week -/

/-
One of the first examples in the Rocq chapter is the type of days of the week.
It is a simple enumeration, which makes it a good place to start learning the
syntax of datatype declarations and pattern matching.
-/

inductive Day where
  | monday
  | tuesday
  | wednesday
  | thursday
  | friday
  | saturday
  | sunday
  deriving Repr, DecidableEq

abbrev day := Day

open Day

/-
The new type is called `day`, and its members are `monday`, `tuesday`, and so
on.

Having defined `day`, we can write functions that operate on days.
-/

def next_working_day (d : day) : day :=
  match d with
  | monday => tuesday
  | tuesday => wednesday
  | wednesday => thursday
  | thursday => friday
  | friday => monday
  | saturday => monday
  | sunday => monday

/-
As in most functional languages, the argument and result types are written
explicitly here. Lean can often infer them, but keeping them in the source
makes definitions easier to read when we are just starting out.

Once a function has been defined, we can try it on a few examples.
-/

#eval next_working_day friday
-- monday

#eval next_working_day (next_working_day saturday)
-- tuesday

theorem test_next_working_day :
    next_working_day (next_working_day saturday) = tuesday := by
  rfl

/-
The original Rocq chapter uses `Compute` to show evaluation results and
`Example` declarations to record small expected equalities. In Lean, `#eval`
serves the same first purpose, while theorems proved by `rfl` play the role of
those tiny executable specifications. The proof term `rfl` says that both sides
reduce to exactly the same expression.

As in Rocq, we can use the host system's string library later in the chapter.
Here that functionality comes from `Std`.
-/

/- ================================================================= -/
/- ** Booleans -/

/-
For the sake of building things up from first principles, the Rocq chapter
defines its own booleans. In Lean we reuse the built-in `Bool`, but we still
define the chapter's boolean operations explicitly so that later proofs talk
about these definitions rather than library lemmas hidden behind notation.

The last two definitions below illustrate Lean's syntax for multi-argument
functions, and the following examples collectively form a truth table for `orb`.
-/

def negb (b : Bool) : Bool :=
  match b with
  | true => false
  | false => true

def andb (b1 : Bool) (b2 : Bool) : Bool :=
  match b1 with
  | true => b2
  | false => false

def orb (b1 : Bool) (b2 : Bool) : Bool :=
  match b1 with
  | true => true
  | false => b2

theorem test_orb1 : orb true false = true := by
  rfl

theorem test_orb2 : orb false false = false := by
  rfl

theorem test_orb3 : orb false true = true := by
  rfl

theorem test_orb4 : orb true true = true := by
  rfl

theorem test_orb5 : orb false (orb false true) = true := by
  rfl

/-
These examples are also an opportunity to show one more feature of the
language: conditionals. The next three definitions are equivalent to the ones
above, just written using `if ... then ... else ...` instead of `match`.
-/

def negb' (b : Bool) : Bool :=
  if b then false else true

def andb' (b1 : Bool) (b2 : Bool) : Bool :=
  if b1 then b2 else false

def orb' (b1 : Bool) (b2 : Bool) : Bool :=
  if b1 then true else b2

/-
Rocq's `if` expression can branch on any two-constructor inductive. Lean's
`if` is less general: it branches on booleans or propositions with a
decidability instance. So for the next datatype we use pattern matching rather
than a generalized conditional.
-/

inductive Bw where
  | bw_black
  | bw_white
  deriving Repr, DecidableEq

abbrev bw := Bw

open Bw

def invert (x : bw) : bw :=
  match x with
  | bw_black => bw_white
  | bw_white => bw_black

#eval invert bw_black
-- bw_white

#eval invert bw_white
-- bw_black

/- **** Exercise: 1 star, standard (nandb) -/

def nandb (b1 : Bool) (b2 : Bool) : Bool := by
  sorry

theorem test_nandb1 : nandb true false = true := by
  sorry

theorem test_nandb2 : nandb false false = true := by
  sorry

theorem test_nandb3 : nandb false true = true := by
  sorry

theorem test_nandb4 : nandb true true = false := by
  sorry

/- **** Exercise: 1 star, standard (andb3) -/

def andb3 (b1 : Bool) (b2 : Bool) (b3 : Bool) : Bool := by
  sorry

theorem test_andb31 : andb3 true true true = true := by
  sorry

theorem test_andb32 : andb3 false true true = false := by
  sorry

theorem test_andb33 : andb3 true false true = false := by
  sorry

theorem test_andb34 : andb3 true true false = false := by
  sorry

/- ================================================================= -/
/- ** Types -/

/-
Every expression in Lean has a type describing what sort of thing it computes.
The `#check` command asks Lean to print the type of an expression, or verify it
against an explicitly supplied type annotation.

Functions are values too. Their types are function types, written with arrows.
So `Bool -> Bool` can be read as: given an input of type `Bool`, this function
produces an output of type `Bool`.
-/

#check true
#check (true : Bool)
#check (negb true : Bool)
#check (negb : Bool → Bool)

/- ================================================================= -/
/- ** New Types from Old -/

/-
The datatypes we have seen so far are finite enumerations. We can also build
new types whose constructors take arguments, allowing the shape of one datatype
to depend on values from another.

This is one of the main reasons algebraic datatypes are so expressive: new data
can be assembled from old data in a disciplined way, and pattern matching keeps
the corresponding functions explicit about the cases they handle.
-/

inductive Rgb where
  | red
  | green
  | blue
  deriving Repr, DecidableEq

abbrev rgb := Rgb

open Rgb

inductive Color where
  | black
  | white
  | primary (p : rgb)
  deriving Repr, DecidableEq

abbrev color := Color

open Color

def monochrome (c : color) : Bool :=
  match c with
  | black => true
  | white => true
  | primary _ => false

def isred (c : color) : Bool :=
  match c with
  | black => false
  | white => false
  | primary red => true
  | primary _ => false

/- ================================================================= -/
/- ** Modules -/

/-
Rocq uses modules to delimit the scope of definitions. Lean's closest everyday
equivalent is the namespace. We use namespaces in the same spirit here: to keep
small local examples from polluting the rest of the chapter while still making
it possible to refer to them with qualified names.

After leaving the namespace, the inner definition is still available, but only
under its qualified name.
-/

namespace Playground

def foo : rgb := blue

end Playground

def foo : Bool := true

#check (Playground.foo : rgb)
#check (foo : Bool)

/- ================================================================= -/
/- ** Tuples -/

/-
A constructor with multiple arguments can be used to package several values at
once, giving us tuple-like data. The `nybble` example mirrors the Rocq text and
also lets us demonstrate matching on several constructor arguments at once.

The constructor acts as a wrapper around its contents, and pattern matching is
the way we unwrap that package again.
-/

namespace TuplePlayground

inductive Bit where
  | B1
  | B0
  deriving Repr, DecidableEq

abbrev bit := Bit

open Bit

inductive Nybble where
  | bits (b0 b1 b2 b3 : bit)
  deriving Repr, DecidableEq

abbrev nybble := Nybble

open Nybble

#check (bits B1 B0 B1 B0 : nybble)

/-
As in the Rocq text, the `bits` constructor is just a wrapper. Pattern
matching lets us open it back up and inspect the four components.
-/

def all_zero (nb : nybble) : Bool :=
  match nb with
  | bits B0 B0 B0 B0 => true
  | bits _ _ _ _ => false

#eval all_zero (bits B1 B0 B1 B0)
-- false

#eval all_zero (bits B0 B0 B0 B0)
-- true

end TuplePlayground

/- ================================================================= -/
/- ** Numbers -/

/-
The Rocq chapter temporarily introduces its own unary natural numbers inside a
module so they do not interfere with the standard library. We do the same with
a namespace. Outside that namespace, the rest of the chapter returns to Lean's
built-in `Nat`, while keeping the familiar abbreviations `O` and `S` around so
the prose and statements remain close to the original.

The key idea is that natural numbers are not introduced by listing all of their
values. Instead, we give constructors for zero and successor, and that is enough
to describe an infinite datatype.
-/

namespace NatPlayground

inductive nat where
  | O
  | S (n : nat)
  deriving Repr, DecidableEq

inductive otherNat where
  | stop
  | tick (foo : otherNat)
  deriving Repr, DecidableEq

def pred (n : nat) : nat :=
  match n with
  | .O => .O
  | .S n' => n'

end NatPlayground

#check (S (S (S (S O))))

def minustwo (n : nat) : nat :=
  match n with
  | 0 => 0
  | 1 => 0
  | Nat.succ (Nat.succ n') => n'

#eval minustwo 4
-- 2

#check (S : nat → nat)
#check (pred : nat → nat)
#check (minustwo : nat → nat)

def even : nat → Bool
  | 0 => true
  | 1 => false
  | Nat.succ (Nat.succ n') => even n'

/-
For more interesting computations over naturals, plain pattern matching is not
enough; we also need recursion. The definition of `even` works by reducing the
problem on `n` to the smaller problem on `n - 2`.
-/

def odd (n : nat) : Bool :=
  negb (even n)

theorem test_odd1 : odd 1 = true := by
  rfl

theorem test_odd2 : odd 4 = false := by
  rfl

namespace NatPlayground2

def plus : nat → nat → nat
  | 0, m => m
  | Nat.succ n', m => Nat.succ (plus n' m)

#eval plus 3 2
-- 5

def mult : nat → nat → nat
  | 0, _ => 0
  | Nat.succ n', m => plus m (mult n' m)

theorem test_mult1 : mult 3 3 = 9 := by
  rfl

def minus : nat → nat → nat
  | 0, _ => 0
  | Nat.succ n, 0 => Nat.succ n
  | Nat.succ n', Nat.succ m' => minus n' m'

end NatPlayground2

def exp (base power : nat) : nat :=
  match power with
  | 0 => 1
  | Nat.succ p => base * exp base p

/- **** Exercise: 1 star, standard (factorial) -/

def factorial (n : nat) : nat := by
  sorry

theorem test_factorial1 : factorial 3 = 6 := by
  sorry

theorem test_factorial2 : factorial 5 = 10 * 12 := by
  sorry

#check (((0 : nat) + 1) + 1 : nat)

def eqb : nat → nat → Bool
  | 0, 0 => true
  | 0, Nat.succ _ => false
  | Nat.succ _, 0 => false
  | Nat.succ n', Nat.succ m' => eqb n' m'

def leb : nat → nat → Bool
  | 0, _ => true
  | Nat.succ _, 0 => false
  | Nat.succ n', Nat.succ m' => leb n' m'

theorem test_leb1 : leb 2 2 = true := by
  rfl

theorem test_leb2 : leb 2 4 = true := by
  rfl

theorem test_leb3 : leb 4 2 = false := by
  rfl

theorem test_leb3' : leb 4 2 = false := by
  rfl

/- **** Exercise: 1 star, standard (ltb) -/

def ltb (n m : nat) : Bool := by
  sorry

theorem test_ltb1 : ltb 2 2 = false := by
  sorry

theorem test_ltb2 : ltb 2 4 = true := by
  sorry

theorem test_ltb3 : ltb 4 2 = false := by
  sorry

/- ################################################################# -/
/- * Proof by Simplification -/

/-
Now that we have looked at a few datatypes and functions, we can turn to
stating and proving properties of their behavior. Many of the early examples in
this chapter are proved simply by reducing both sides of an equality until they
become obviously the same.

In Rocq this is often presented as `simpl` followed by `reflexivity`. In Lean,
the corresponding moves are usually `simp` and `rfl`, though the precise split
of labor between the two tactics is slightly different.

The central idea is unchanged: if both sides compute to the same value, then
the equality follows immediately.
-/

theorem plus_1_1 : 1 + 1 = 2 := by
  simp

theorem plus_O_n : ∀ n : nat, 0 + n = n := by
  intro n
  simp

theorem plus_O_n' : ∀ n : nat, 0 + n = n := by
  intro n
  simp

theorem plus_O_n'' : ∀ n : nat, 0 + n = n := by
  intro m
  simp

theorem plus_1_l : ∀ n : nat, 1 + n = S n := by
  intro n
  simpa [S] using Nat.one_add n

theorem mult_0_l : ∀ n : nat, 0 * n = 0 := by
  intro n
  simp

/- ################################################################# -/
/- * Proof by Rewriting -/

/-
Simple computation is not always enough. When a theorem includes a hypothesis
such as `n = m`, we want to replace one side by the other in the goal. In Rocq
this is done with `rewrite`; in Lean the everyday equivalent is `rw`.

The basic idea is the same: once the goal has been rewritten using the given
hypothesis, both sides of the equality often become identical.

This is our first real example of using information from the context, rather
than just computing with the definitions in the goal.
-/

theorem plus_id_example : ∀ n m : nat,
    n = m → n + n = m + m := by
  intro n m h
  rw [h]

/- **** Exercise: 1 star, standard (plus_id_exercise) -/

theorem plus_id_exercise : ∀ n m o : nat,
    n = m → m = o → n + m = m + o := by
  sorry

/-
Lean's arithmetic library contains the same facts that the Rocq chapter points
to here, but under different names. We package them with chapter-local names
so the later discussion can stay close to the original.
-/

theorem mult_n_O : ∀ n : nat, 0 = n * 0 := by
  intro n
  simp

theorem mult_n_Sm : ∀ n m : nat, n * m + n = n * S m := by
  intro n m
  simpa [Nat.mul_succ]

#check mult_n_O
#check mult_n_Sm

theorem mult_n_0_m_0 : ∀ p q : nat, (p * 0) + (q * 0) = 0 := by
  intro p q
  rw [← mult_n_O p, ← mult_n_O q]

/- **** Exercise: 1 star, standard (mult_n_1) -/

theorem mult_n_1 : ∀ p : nat, p * 1 = p := by
  sorry

/- ################################################################# -/
/- * Proof by Case Analysis -/

/-
In the original Rocq file, the first proof attempt here is shown and then
aborted because simplification gets stuck on an unknown number. Lean has the
same issue. We keep the failed attempt as prose and give the finished proof
below.

The remedy is to consider the possible shapes of the unknown value separately.
Rocq uses the `destruct` tactic for this purpose; Lean uses `cases`. Each case
then becomes a smaller goal in which more computation is possible.

As in the book, this is the point where proofs stop being just calculation and
start branching on the structure of data.
-/

theorem plus_1_neq_0 : ∀ n : nat, eqb (n + 1) 0 = false := by
  intro n
  cases n <;> rfl

theorem negb_involutive : ∀ b : Bool, negb (negb b) = b := by
  intro b
  cases b <;> rfl

theorem andb_commutative : ∀ b c : Bool, andb b c = andb c b := by
  intro b c
  cases b <;> cases c <;> rfl

theorem andb_commutative' : ∀ b c : Bool, andb b c = andb c b := by
  intro b c
  cases b <;> cases c <;> rfl

theorem andb3_exchange :
    ∀ b c d : Bool, andb (andb b c) d = andb (andb b d) c := by
  intro b c d
  cases b <;> cases c <;> cases d <;> rfl

/- **** Exercise: 2 stars, standard (andb_true_elim2) -/

theorem andb_true_elim2 : ∀ b c : Bool,
    andb b c = true → c = true := by
  sorry

theorem plus_1_neq_0' : ∀ n : nat, eqb (n + 1) 0 = false
  | 0 => rfl
  | Nat.succ _ => rfl

theorem andb_commutative'' : ∀ b c : Bool, andb b c = andb c b
  | true, true => rfl
  | true, false => rfl
  | false, true => rfl
  | false, false => rfl

/- **** Exercise: 1 star, standard (zero_nbeq_plus_1) -/

theorem zero_nbeq_plus_1 : ∀ n : nat, eqb 0 (n + 1) = false := by
  sorry

/- ================================================================= -/
/- ** More on Notation (Optional) -/

/-
Lean also attaches precedence and associativity information to notations. The
details differ from Rocq's notation scopes, but the basic purpose is the same:
they tell the parser how to group expressions such as `1 + 2 * 3 * 4`.

So the moral of the original section still applies: notation is helpful, but it
is only surface syntax. The underlying definitions are what matter in proofs.
-/

/- ================================================================= -/
/- ** Fixpoints and Structural Recursion (Optional) -/

/-
For most interesting computations over numbers, plain pattern matching is not
enough; we also need recursion. Lean, like Rocq, checks that recursive calls
are made on structurally smaller arguments unless we provide a more elaborate
termination argument.
-/

def plus' : nat → nat → nat
  | 0, m => m
  | Nat.succ n', m => Nat.succ (plus' n' m)

/-
Lean, like Rocq, insists that recursive definitions be structurally recursive
or otherwise accompanied by a termination argument. This guarantees that the
functions we define in the logical core terminate on all inputs.
-/

/- ################################################################# -/
/- * More Exercises -/

/-
The rest of the chapter collects a few additional exercises that use the same
core ideas: writing functions by pattern matching, then proving elementary
properties by simplification, rewriting, and case analysis.
-/

/- ================================================================= -/
/- ** Warmups -/

/-
These exercises are small, but they start combining the proof techniques from
the previous sections instead of using only direct computation.
-/

/- **** Exercise: 1 star, standard (identity_fn_applied_twice) -/

theorem identity_fn_applied_twice :
    ∀ (f : Bool → Bool),
      (∀ x : Bool, f x = x) →
      ∀ b : Bool, f (f b) = b := by
  sorry

/- **** Exercise: 1 star, standard (negation_fn_applied_twice) -/

theorem negation_fn_applied_twice :
    ∀ (f : Bool → Bool),
      (∀ x : Bool, f x = negb x) →
      ∀ b : Bool, f (f b) = b := by
  sorry

def manual_grade_for_negation_fn_applied_twice : Option (Nat × String) :=
  none

/- **** Exercise: 3 stars, standard, optional (andb_eq_orb) -/

theorem andb_eq_orb :
    ∀ b c : Bool,
      andb b c = orb b c →
      b = c := by
  sorry

/- ================================================================= -/
/- ** Course Late Policies, Formalized -/

/-
This section mirrors one of the more "program-like" parts of the Rocq chapter.
We model a late-days grading policy using small inductive datatypes and helper
functions, then state the expected properties of those definitions.
-/

namespace LateDays

inductive Letter where
  | A | B | C | D | F
  deriving Repr, DecidableEq

abbrev letter := Letter

open Letter

inductive Modifier where
  | Plus | Natural | Minus
  deriving Repr, DecidableEq

abbrev modifier := Modifier

open Modifier

inductive Grade' where
  | Grade (l : letter) (m : modifier)
  deriving Repr, DecidableEq

abbrev grade := Grade'

open Grade'

inductive Comparison where
  | Eq
  | Lt
  | Gt
  deriving Repr, DecidableEq

abbrev comparison := Comparison

def letter_comparison (l1 l2 : letter) : comparison :=
  match l1, l2 with
  | A, A => Comparison.Eq
  | A, _ => Comparison.Gt
  | B, A => Comparison.Lt
  | B, B => Comparison.Eq
  | B, _ => Comparison.Gt
  | C, A => Comparison.Lt
  | C, B => Comparison.Lt
  | C, C => Comparison.Eq
  | C, _ => Comparison.Gt
  | D, A => Comparison.Lt
  | D, B => Comparison.Lt
  | D, C => Comparison.Lt
  | D, D => Comparison.Eq
  | D, _ => Comparison.Gt
  | F, A => Comparison.Lt
  | F, B => Comparison.Lt
  | F, C => Comparison.Lt
  | F, D => Comparison.Lt
  | F, F => Comparison.Eq

#eval letter_comparison B A
-- Lt

#eval letter_comparison D D
-- Eq

#eval letter_comparison B F
-- Gt

/- **** Exercise: 1 star, standard (letter_comparison) -/

theorem letter_comparison_Eq :
    ∀ l : letter, letter_comparison l l = Comparison.Eq := by
  sorry

def modifier_comparison (m1 m2 : modifier) : comparison :=
  match m1, m2 with
  | Plus, Plus => Comparison.Eq
  | Plus, _ => Comparison.Gt
  | Natural, Plus => Comparison.Lt
  | Natural, Natural => Comparison.Eq
  | Natural, Minus => Comparison.Gt
  | Minus, Plus => Comparison.Lt
  | Minus, Natural => Comparison.Lt
  | Minus, Minus => Comparison.Eq

/- **** Exercise: 2 stars, standard (grade_comparison) -/

def grade_comparison (g1 g2 : grade) : comparison := by
  sorry

theorem test_grade_comparison1 :
    grade_comparison (Grade A Minus) (Grade B Plus) = Comparison.Gt := by
  sorry

theorem test_grade_comparison2 :
    grade_comparison (Grade A Minus) (Grade A Plus) = Comparison.Lt := by
  sorry

theorem test_grade_comparison3 :
    grade_comparison (Grade F Plus) (Grade F Plus) = Comparison.Eq := by
  sorry

theorem test_grade_comparison4 :
    grade_comparison (Grade B Minus) (Grade C Plus) = Comparison.Gt := by
  sorry

def lower_letter (l : letter) : letter :=
  match l with
  | A => B
  | B => C
  | C => D
  | D => F
  | F => F

theorem lower_letter_F_is_F : lower_letter F = F := by
  rfl

/- **** Exercise: 2 stars, standard (lower_letter_lowers) -/

theorem lower_letter_lowers :
    ∀ l : letter,
      letter_comparison F l = Comparison.Lt →
      letter_comparison (lower_letter l) l = Comparison.Lt := by
  sorry

/- **** Exercise: 2 stars, standard (lower_grade) -/

def lower_grade (g : grade) : grade := by
  sorry

theorem lower_grade_A_Plus :
    lower_grade (Grade A Plus) = Grade A Natural := by
  sorry

theorem lower_grade_A_Natural :
    lower_grade (Grade A Natural) = Grade A Minus := by
  sorry

theorem lower_grade_A_Minus :
    lower_grade (Grade A Minus) = Grade B Plus := by
  sorry

theorem lower_grade_B_Plus :
    lower_grade (Grade B Plus) = Grade B Natural := by
  sorry

theorem lower_grade_F_Natural :
    lower_grade (Grade F Natural) = Grade F Minus := by
  sorry

theorem lower_grade_twice :
    lower_grade (lower_grade (Grade B Minus)) = Grade C Natural := by
  sorry

theorem lower_grade_thrice :
    lower_grade (lower_grade (lower_grade (Grade B Minus))) = Grade C Minus := by
  sorry

theorem lower_grade_F_Minus :
    lower_grade (Grade F Minus) = Grade F Minus := by
  sorry

/- **** Exercise: 3 stars, standard (lower_grade_lowers) -/

theorem lower_grade_lowers :
    ∀ g : grade,
      grade_comparison (Grade F Minus) g = Comparison.Lt →
      grade_comparison (lower_grade g) g = Comparison.Lt := by
  sorry

def apply_late_policy (late_days : nat) (g : grade) : grade :=
  if ltb late_days 9 then g
  else if ltb late_days 17 then lower_grade g
  else if ltb late_days 21 then lower_grade (lower_grade g)
  else lower_grade (lower_grade (lower_grade g))

theorem apply_late_policy_unfold :
    ∀ (late_days : nat) (g : grade),
      apply_late_policy late_days g =
        (if ltb late_days 9 then g
         else if ltb late_days 17 then lower_grade g
         else if ltb late_days 21 then lower_grade (lower_grade g)
         else lower_grade (lower_grade (lower_grade g))) := by
  intro late_days g
  rfl

/- **** Exercise: 2 stars, standard (no_penalty_for_mostly_on_time) -/

theorem no_penalty_for_mostly_on_time :
    ∀ (late_days : nat) (g : grade),
      ltb late_days 9 = true →
      apply_late_policy late_days g = g := by
  sorry

/- **** Exercise: 2 stars, standard (grade_lowered_once) -/

theorem grade_lowered_once :
    ∀ (late_days : nat) (g : grade),
      ltb late_days 9 = false →
      ltb late_days 17 = true →
      apply_late_policy late_days g = lower_grade g := by
  sorry

end LateDays

/- ================================================================= -/
/- ** Binary Numerals -/

/-
The final exercise generalizes unary numerals to a binary representation. As in
the original chapter, the low-order bit is kept on the left because that makes
recursive processing simpler.
-/

inductive Bin where
  | Z
  | B0 (n : Bin)
  | B1 (n : Bin)
  deriving Repr, DecidableEq

abbrev bin := Bin

open Bin

/- **** Exercise: 3 stars, standard (binary) -/

def incr (m : bin) : bin := by
  sorry

def bin_to_nat (m : bin) : nat := by
  sorry

theorem test_bin_incr1 : incr (B1 Z) = B0 (B1 Z) := by
  sorry

theorem test_bin_incr2 : incr (B0 (B1 Z)) = B1 (B1 Z) := by
  sorry

theorem test_bin_incr3 : incr (B1 (B1 Z)) = B0 (B0 (B1 Z)) := by
  sorry

theorem test_bin_incr4 : bin_to_nat (B0 (B1 Z)) = 2 := by
  sorry

theorem test_bin_incr5 :
    bin_to_nat (incr (B1 Z)) = 1 + bin_to_nat (B1 Z) := by
  sorry

theorem test_bin_incr6 :
    bin_to_nat (incr (incr (B1 Z))) = 2 + bin_to_nat (B1 Z) := by
  sorry

theorem test_bin_incr7 :
    bin_to_nat (B0 (B0 (B0 (B1 Z)))) = 8 := by
  sorry

/- ################################################################# -/
/- * Optional: Testing Your Solutions -/

/-
The Rocq chapter closes by describing how to run the accompanying test script.
For this Lean translation, the corresponding lightweight check is simply to ask
Lean to elaborate the file:

  elan run leanprover/lean4-nightly:nightly-2026-03-02 lean lean/lf/Basics.lean

This chapter deliberately leaves student exercises as `sorry`, so the file is
meant to be readable and typecheckable rather than fully solved.
-/
