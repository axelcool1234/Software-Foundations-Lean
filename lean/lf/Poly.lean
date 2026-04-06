import lf.Lists

set_option autoImplicit false

/- ################################################################# -/
/- * Poly: Polymorphism and Higher-Order Functions -/

/-
This chapter is a Lean-oriented translation of `rocq/lf/Poly.v`. It introduces
two related ideas: polymorphism, where datatypes and functions are abstracted
over other types, and higher-order functions, where functions themselves are
treated as data.

We import `lf.Lists` so that earlier material such as `odd`, `even`,
`minustwo`, and the textbook versions of `plus` and `mult` are available. To
avoid collisions with Lean's standard library names like `List`, `Prod`, and
`Option`, the textbook names in this chapter live inside the namespace `Poly`.

As elsewhere in this repository, worked examples are translated into ordinary
Lean code and proofs, while student exercises remain as `sorry` unless the Rocq
source had already solved them.
-/

namespace Poly

open NatPlayground2

/- ################################################################# -/
/- * Polymorphism -/

/-
In this chapter we continue the study of basic functional programming. The new
ideas are polymorphism, which lets us abstract over the types of data being
manipulated, and higher-order functions, which let us pass functions around as
values. We begin with polymorphism.
-/

/- ================================================================= -/
/- ** Polymorphic Lists -/

/-
In the previous chapter, we worked with lists containing only natural numbers.
Interesting programs need richer data: lists of booleans, lists of lists, and
so on. We could define a fresh datatype for each case, but that quickly becomes
repetitive.
-/

inductive boollist : Type where
  | bool_nil
  | bool_cons (b : bool) (l : boollist)

/-
This works, but it scales badly. We would need different constructor names for
every new datatype, along with fresh versions of every list-processing function
and every theorem about those functions.

To avoid that repetition, Lean supports polymorphic inductive definitions. Here
is a polymorphic list datatype.
-/

inductive list (X : Type) : Type where
  | nil
  | cons (x : X) (l : list X)

open list

infixr:67 " :: " => list.cons

syntax "[p|" sepBy(term, "; ") "|]" : term

macro_rules
  | `([p| |]) => `(nil)
  | `([p| $x:term |]) => `(cons $x nil)
  | `([p| $x:term; $xs:term;* |]) => `(cons $x [p| $xs;* |])

/-
This is just like the `natlist` definition from the previous chapter, except
that the element type is now the arbitrary parameter `X`. For any particular
type `X`, the type `list X` is the inductively defined type of lists whose
elements are drawn from `X`.

Because `lf.Lists` already defined a custom notation for lists of naturals, we
give the polymorphic lists of this chapter their own parallel notation:
`[p| ... |]`.
-/

#check list

/-
Lean already treats inductive parameters as implicit in constructors, so the
type argument is usually synthesized automatically. We use `@nil` and `@cons`
here to make those hidden parameters visible, since that matches the point of
the Rocq discussion.
-/

#check (@nil nat : list nat)

/-
Similarly, `@cons nat` adds a natural number to a list of naturals.
-/

#check (@cons nat 3 (@nil nat) : list nat)

/-
The full constructor types still expose the polymorphism.
-/

#check @nil
#check @cons

/-
Having to write explicit type arguments everywhere would be burdensome. We will
soon see ways of reducing that burden, but first it is useful to define a few
basic polymorphic functions explicitly.
-/

#check (@cons nat 2 (@cons nat 1 (@nil nat)) : list nat)

def «repeat» (X : Type) (x : X) (count : nat) : list X :=
  match count with
  | 0 => @nil X
  | Nat.succ count' => @cons X x («repeat» X x count')

/-
As with `nil` and `cons`, we can apply `repeat` first to a type and then to an
element of that type.
-/

theorem test_repeat1 :
    «repeat» nat 4 2 = @cons nat 4 (@cons nat 4 (@nil nat)) := by
  rfl

/-
Instantiating the type parameter differently yields lists of other kinds of
elements.
-/

theorem test_repeat2 :
    «repeat» bool false 1 = @cons bool false (@nil bool) := by
  rfl

/- **** Exercise: 2 stars, standard, optional (mumble_grumble) -/

namespace MumbleGrumble

inductive mumble : Type where
  | a
  | b (x : mumble) (y : nat)
  | c

inductive grumble (X : Type) : Type where
  | d (m : mumble)
  | e (x : X)

/-
Which of the following are well-typed elements of `grumble X` for some type
`X`?

- `d (b a 5)`
- `d mumble (b a 5)`
- `d bool (b a 5)`
- `e bool true`
- `e mumble (b c 0)`
- `e bool (b c 0)`
- `c`
-/

end MumbleGrumble

/- *** Type Annotation Inference -/

/-
Let us define `repeat` again, this time omitting its argument types. Lean can
infer them from the way the definition is used.
-/

def repeat' X x count :=
  match count with
  | 0 => @nil X
  | Nat.succ count' => @cons X x (repeat' X x count')

#check repeat'
#check «repeat»

/-
Lean infers exactly the same type as before. This is the same basic idea as in
Rocq: the elaborator uses the surrounding context to reconstruct omitted type
information. Explicit annotations are still useful as documentation, so we keep
using them frequently.
-/

/- *** Type Argument Synthesis -/

/-
Even when we do write type annotations, it is often redundant to repeat an
already obvious type argument. As in Rocq, Lean lets us use `_` as a hole when
we want elaboration to fill in a type from context.
-/

def repeat'' (X : Type) (x : X) (count : nat) : list X :=
  match count with
  | 0 => @nil _
  | Nat.succ count' => @cons _ x (repeat'' _ x count')

def list123 := @cons nat 1 (@cons nat 2 (@cons nat 3 (@nil nat)))

def list123' := @cons _ 1 (@cons _ 2 (@cons _ 3 (@nil _)))

/-
In this small example the savings are modest, but in larger terms holes can
make code considerably easier to read.
-/

/- *** Implicit Arguments -/

/-
Lean goes one step further than the Rocq presentation here: for constructors of
an inductive family like `list`, the type parameter is already implicit. So we
can usually write constructor applications without either an explicit type or a
hole.
-/

def list123'' := cons 1 (cons 2 (cons 3 nil))

/-
We can also declare ordinary function arguments as implicit by writing them in
curly braces.
-/

def repeat''' {X : Type} (x : X) (count : nat) : list X :=
  match count with
  | 0 => nil
  | Nat.succ count' => cons x (repeat''' x count')

/-
For inductive types themselves, however, making the parameter implicit changes
the meaning of the type name too. The following variant illustrates the point.
-/

inductive list' {X : Type} : Type where
  | nil'
  | cons' (x : X) (l : list' (X := X))

/-
Because `X` is implicit for the entire declaration, the type name is just
`list'`; we no longer write `list' nat` or `list' bool`. That is not what we
want for this chapter, so we keep the parameter explicit on the type itself.

Let us finish by rebuilding a few standard list-processing functions for our
new polymorphic lists.
-/

def app {X : Type} (l1 l2 : list X) : list X :=
  match l1 with
  | nil => l2
  | h :: t => h :: app t l2

def rev {X : Type} (l : list X) : list X :=
  match l with
  | nil => nil
  | h :: t => app (rev t) (h :: nil)

def length {X : Type} (l : list X) : nat :=
  match l with
  | nil => 0
  | _ :: l' => Nat.succ (length l')

theorem test_rev1 : rev (cons 1 (cons 2 nil)) = cons 2 (cons 1 nil) := by
  rfl

theorem test_rev2 : rev (cons true nil) = cons true nil := by
  rfl

theorem test_length1 : length (cons 1 (cons 2 (cons 3 nil))) = 3 := by
  rfl

/- *** Supplying Type Arguments Explicitly -/

/-
One small problem with implicit arguments is that sometimes Lean does not have
enough local information to determine a hidden type. A definition like

`def mynil := nil`

does not elaborate, because Lean has no way to know which element type the list
should use. We can help by supplying a type annotation.
-/

def mynil : list nat := nil

/-
Alternatively, we can prefix a name with `@` to expose its implicit arguments
so that we may provide them explicitly.
-/

#check @nil

def mynil' := @nil nat

/-
With implicit arguments and type argument synthesis in place, we can introduce a
readable notation for our custom lists.
-/

infixr:65 " ++ " => app

def list123''' := [p| 1; 2; 3 |]

/- *** Exercises -/

/- **** Exercise: 2 stars, standard (poly_exercises) -/

theorem app_nil_r : ∀ (X : Type) (l : list X), l ++ [p| |] = l := by
  sorry

theorem app_assoc : ∀ A (l m n : list A), l ++ m ++ n = (l ++ m) ++ n := by
  sorry

theorem app_length : ∀ (X : Type) (l1 l2 : list X),
    length (l1 ++ l2) = length l1 + length l2 := by
  sorry

/- **** Exercise: 2 stars, standard (more_poly_exercises) -/

theorem rev_app_distr : ∀ X (l1 l2 : list X),
    rev (l1 ++ l2) = rev l2 ++ rev l1 := by
  sorry

theorem rev_involutive : ∀ (X : Type) (l : list X), rev (rev l) = l := by
  sorry

/- ================================================================= -/
/- ** Polymorphic Pairs -/

/-
Following the same pattern, we can generalize pairs of numbers to polymorphic
pairs, also called products.
-/

inductive prod (X Y : Type) : Type where
  | pair (x : X) (y : Y)

/-
Rocq reuses the notations `(x, y)` and `X * Y` for these custom pairs. Lean
already reserves tuple notation and `×` for its standard product type, and
plain `*` is ordinary multiplication, so we keep the constructor `pair` and the
type former `prod` explicit here.
-/

def fst {X Y : Type} (p : prod X Y) : X :=
  match p with
  | prod.pair x _ => x

def snd {X Y : Type} (p : prod X Y) : Y :=
  match p with
  | prod.pair _ y => y

/-
The following function combines two lists into a list of pairs. In other
functional languages, it is often called `zip`.
-/

def combine {X Y : Type} (lx : list X) (ly : list Y) : list (prod X Y) :=
  match lx, ly with
  | nil, _ => nil
  | _, nil => nil
  | x :: tx, y :: ty => prod.pair x y :: combine tx ty

/- **** Exercise: 1 star, standard, optional (combine_checks) -/

/-
Try checking the following in Lean.

- What is the type of `@combine`?
- What does `combine [p| 1; 2 |] [p| false; false; true; true |]` evaluate to?
-/

/- **** Exercise: 2 stars, standard, especially useful (split) -/

/-
The function `split` is the right inverse of `combine`: it takes a list of
pairs and returns a pair of lists.
-/

def split {X Y : Type} (l : list (prod X Y)) : prod (list X) (list Y) := by
  sorry

theorem test_split :
    split [p| prod.pair 1 false; prod.pair 2 false |] =
      prod.pair [p| 1; 2 |] [p| false; false |] := by
  sorry

/- ================================================================= -/
/- ** Polymorphic Options -/

/-
Our last polymorphic type for now generalizes the `natoption` type from the
previous chapter. Lean already has a standard `Option`, but inside `Poly` we
can still use the textbook name `option` without confusion.
-/

namespace OptionPlayground

inductive option (X : Type) : Type where
  | Some (x : X)
  | None

end OptionPlayground

abbrev option := OptionPlayground.option

open OptionPlayground.option

/-
We can now rewrite `nth_error` so that it works for lists of any element type.
-/

def nth_error {X : Type} (l : list X) (n : nat) : option X :=
  match l with
  | nil => None
  | a :: l' =>
      match n with
      | 0 => Some a
      | Nat.succ n' => nth_error l' n'

theorem test_nth_error1 : nth_error [p| 4; 5; 6; 7 |] 0 = Some 4 := by
  rfl

theorem test_nth_error2 :
    nth_error [p| [p| 1 |]; [p| 2 |] |] 1 = Some [p| 2 |] := by
  rfl

theorem test_nth_error3 : nth_error [p| true |] 2 = None := by
  rfl

/- **** Exercise: 1 star, standard, optional (hd_error_poly) -/

def hd_error {X : Type} (l : list X) : option X := by
  sorry

#check @hd_error

theorem test_hd_error1 : hd_error [p| 1; 2 |] = Some 1 := by
  sorry

theorem test_hd_error2 :
    hd_error [p| [p| 1 |]; [p| 2 |] |] = Some [p| 1 |] := by
  sorry

/- ################################################################# -/
/- * Functions as Data -/

/-
Like most modern programming languages, Lean treats functions as first-class
values: they can be passed as arguments, returned as results, and stored in
data structures. That makes higher-order programming entirely natural.
-/

/- ================================================================= -/
/- ** Higher-Order Functions -/

/-
Functions that manipulate other functions are often called higher-order
functions. Here is a simple example.
-/

def doit3times {X : Type} (f : X -> X) (n : X) : X :=
  f (f (f n))

#check @doit3times

theorem test_doit3times : doit3times minustwo 9 = 3 := by
  rfl

theorem test_doit3times' : doit3times negb true = false := by
  rfl

/- ================================================================= -/
/- ** Filter -/

/-
Here is a more useful higher-order function. It takes a list and a predicate on
elements of that list and returns the sublist of elements satisfying the test.
-/

def filter {X : Type} (test : X -> bool) (l : list X) : list X :=
  match l with
  | nil => nil
  | h :: t =>
      if test h then h :: filter test t
      else filter test t

theorem test_filter1 : filter even [p| 1; 2; 3; 4 |] = [p| 2; 4 |] := by
  rfl

def length_is_1 {X : Type} (l : list X) : bool :=
  eqb (length l) 1

theorem test_filter2 :
    filter length_is_1 [p| [p| 1; 2 |]; [p| 3 |]; [p| 4 |]; [p| 5; 6; 7 |]; [p| |]; [p| 8 |] |] =
      [p| [p| 3 |]; [p| 4 |]; [p| 8 |] |] := by
  rfl

/-
As in the Rocq chapter, `filter` gives a concise definition of the function
that counts odd members of a list.
-/

def countoddmembers' (l : list nat) : nat :=
  length (filter odd l)

theorem test_countoddmembers'1 :
    countoddmembers' [p| 1; 0; 3; 1; 4; 5 |] = 4 := by
  rfl

theorem test_countoddmembers'2 : countoddmembers' [p| 0; 2; 4 |] = 0 := by
  rfl

theorem test_countoddmembers'3 : countoddmembers' nil = 0 := by
  rfl

/- ================================================================= -/
/- ** Anonymous Functions -/

/-
It is a little wasteful to give a top-level name to a helper function that we
intend to use only once. Higher-order programming frequently uses anonymous
functions for just this reason.
-/

theorem test_anon_fun' : doit3times (fun n => n * n) 2 = 256 := by
  rfl

/-
The expression `fun n => n * n` can be read as "the function that takes `n` and
returns `n * n`."

Here is the earlier `filter` example rewritten with an anonymous function.
-/

theorem test_filter2' :
    filter (fun l => eqb (length l) 1)
      [p| [p| 1; 2 |]; [p| 3 |]; [p| 4 |]; [p| 5; 6; 7 |]; [p| |]; [p| 8 |] |] =
      [p| [p| 3 |]; [p| 4 |]; [p| 8 |] |] := by
  rfl

/- **** Exercise: 2 stars, standard (filter_even_gt7) -/

def filter_even_gt7 (l : list nat) : list nat := by
  sorry

theorem test_filter_even_gt7_1 :
    filter_even_gt7 [p| 1; 2; 6; 9; 10; 3; 12; 8 |] = [p| 10; 12; 8 |] := by
  sorry

theorem test_filter_even_gt7_2 :
    filter_even_gt7 [p| 5; 2; 6; 19; 129 |] = [p| |] := by
  sorry

/- **** Exercise: 3 stars, standard (partition) -/

def partition {X : Type} (test : X -> bool) (l : list X) : prod (list X) (list X) := by
  sorry

theorem test_partition1 :
    partition odd [p| 1; 2; 3; 4; 5 |] =
      prod.pair [p| 1; 3; 5 |] [p| 2; 4 |] := by
  sorry

theorem test_partition2 :
    partition (fun _ => false) [p| 5; 9; 0 |] =
      prod.pair [p| |] [p| 5; 9; 0 |] := by
  sorry

/- ================================================================= -/
/- ** Map -/

/-
Another standard higher-order function is `map`, which applies a function to
each element of a list.
-/

def map {X Y : Type} (f : X -> Y) (l : list X) : list Y :=
  match l with
  | nil => nil
  | h :: t => f h :: map f t

theorem test_map1 : map (fun x => plus 3 x) [p| 2; 0; 2 |] = [p| 5; 3; 5 |] := by
  rfl

theorem test_map2 :
    map odd [p| 2; 1; 2; 5 |] = [p| false; true; false; true |] := by
  rfl

theorem test_map3 :
    map (fun n => [p| even n; odd n |]) [p| 2; 1; 2; 5 |] =
      [p| [p| true; false |]; [p| false; true |]; [p| true; false |]; [p| false; true |] |] := by
  rfl

/- *** Exercises -/

/- **** Exercise: 3 stars, standard (map_rev) -/

theorem map_rev : ∀ (X Y : Type) (f : X -> Y) (l : list X),
    map f (rev l) = rev (map f l) := by
  sorry

/- **** Exercise: 2 stars, standard, especially useful (flat_map) -/

def flat_map {X Y : Type} (f : X -> list Y) (l : list X) : list Y := by
  sorry

theorem test_flat_map1 :
    flat_map (fun n => [p| n; n; n |]) [p| 1; 5; 4 |] =
      [p| 1; 1; 1; 5; 5; 5; 4; 4; 4 |] := by
  sorry

/-
Lists are not the only inductive type on which `map` makes sense. Here is the
analogous operation for the `option` type.
-/

def option_map {X Y : Type} (f : X -> Y) (xo : option X) : option Y :=
  match xo with
  | None => None
  | Some x => Some (f x)

/- **** Exercise: 2 stars, standard, optional (implicit_args) -/

/-
As in the Rocq text, a useful experiment is to rewrite the definitions and uses
of `filter` and `map` with explicit type arguments everywhere and ask Lean to
check the result.
-/

/- ================================================================= -/
/- ** Fold -/

/-
An even more powerful higher-order function is `fold`. It is the inspiration
for the `reduce` operation in map/reduce frameworks.
-/

def fold {X Y : Type} (f : X -> Y -> Y) (l : list X) (b : Y) : Y :=
  match l with
  | nil => b
  | h :: t => f h (fold f t b)

/-
Intuitively, `fold` inserts the operator `f` between the elements of the list,
starting from a base case `b`.
-/

theorem fold_example1 :
    fold andb [p| true; true; false; true |] true = false := by
  rfl

theorem fold_example2 : fold mult [p| 1; 2; 3; 4 |] 1 = 24 := by
  rfl

theorem fold_example3 :
    fold app [p| [p| 1 |]; [p| |]; [p| 2; 3 |]; [p| 4 |] |] [p| |] =
      [p| 1; 2; 3; 4 |] := by
  rfl

theorem fold_example4 :
    fold (fun l n => length l + n) [p| [p| 1 |]; [p| |]; [p| 2; 3; 2 |]; [p| 4 |] |] 0 =
      5 := by
  rfl

/- **** Exercise: 1 star, standard, optional (fold_types_different) -/

/-
Observe that the type of `fold` is parameterized by two type variables, `X` and
`Y`. The example `fold_example4` shows one place where it is useful for them to
be different. It is worth thinking of other examples too.
-/

/- ================================================================= -/
/- ** Functions That Construct Functions -/

/-
Most of the higher-order functions we have seen so far take functions as
arguments. Let us now look at functions that return functions as results.
-/

def constfun {X : Type} (x : X) : nat -> X :=
  fun (_k : nat) => x

def ftrue := constfun true

theorem constfun_example1 : ftrue 0 = true := by
  rfl

theorem constfun_example2 : (constfun 5) 99 = 5 := by
  rfl

/-
The multiple-argument functions we have already seen can also be understood in
this way. For instance, here is the type of `plus`.
-/

#check plus

def plus3 := plus 3

#check plus3

theorem test_plus3 : plus3 4 = 7 := by
  rfl

theorem test_plus3' : doit3times plus3 0 = 9 := by
  rfl

theorem test_plus3'' : doit3times (plus 3) 0 = 9 := by
  rfl

/-
Similarly, we can partially apply `fold` to obtain a specialized function.
-/

def fold_plus := fold plus

#check fold_plus

/-
This is an instance of partial application. A type like `A -> B -> C` really
means `A -> (B -> C)`: a function taking an `A` and returning another function.
-/

/- ################################################################# -/
/- * Additional Exercises -/

namespace Exercises

/- **** Exercise: 2 stars, standard (fold_length) -/

def fold_length {X : Type} (l : list X) : nat :=
  fold (fun _ n => Nat.succ n) l 0

theorem test_fold_length1 : fold_length [p| 4; 7; 0 |] = 3 := by
  rfl

/-
Prove the correctness of `fold_length`. As in the Rocq chapter, unfolding the
definition before simplifying may be helpful.
-/

theorem fold_length_correct : ∀ X (l : list X), fold_length l = length l := by
  sorry

/- **** Exercise: 3 stars, standard (fold_map) -/

def fold_map {X Y : Type} (f : X -> Y) (l : list X) : list Y := by
  sorry

/-
Write down a theorem `fold_map_correct` stating that `fold_map` is correct, and
prove it.
-/

theorem fold_map_correct : ∀ (X Y : Type) (f : X -> Y) (l : list X),
    fold_map f l = map f l := by
  sorry

def manual_grade_for_fold_map : Option (nat × String) := none

/- **** Exercise: 2 stars, advanced (currying) -/

/-
The type `X -> Y -> Z` describes curried functions, while `prod X Y -> Z`
describes functions that consume a pair all at once. We can convert between the
two views.
-/

def prod_curry {X Y Z : Type} (f : prod X Y -> Z) (x : X) (y : Y) : Z :=
  f (prod.pair x y)

def prod_uncurry {X Y Z : Type} (f : X -> Y -> Z) (p : prod X Y) : Z := by
  sorry

theorem test_map1' : map (plus 3) [p| 2; 0; 2 |] = [p| 5; 3; 5 |] := by
  rfl

#check @prod_curry
#check @prod_uncurry

theorem uncurry_curry : ∀ (X Y Z : Type) (f : X -> Y -> Z) x y,
    prod_curry (prod_uncurry f) x y = f x y := by
  sorry

theorem curry_uncurry : ∀ (X Y Z : Type) (f : prod X Y -> Z) (p : prod X Y),
    prod_uncurry (prod_curry f) p = f p := by
  sorry

/- **** Exercise: 2 stars, advanced, optional (nth_error_informal) -/

/-
Recall the definition of `nth_error`:

```lean
def nth_error {X : Type} (l : list X) (n : nat) : option X :=
  match l with
  | nil => None
  | a :: l' =>
      match n with
      | 0 => Some a
      | Nat.succ n' => nth_error l' n'
```

Write a careful informal proof of the following theorem, making the induction
hypothesis explicit:

`forall X l n, length l = n -> @nth_error X l n = None`
-/

def manual_grade_for_informal_proof : Option (nat × String) := none

/- ================================================================= -/
/- ** Church Numerals (Advanced) -/

/-
The following exercises explore Church numerals, which represent natural
numbers as iterators: a numeral `n` is a function that takes another function
`f` and applies it `n` times.
-/

namespace Church

def cnat := ∀ X : Type, (X -> X) -> X -> X

/-
Iterating once means just applying the function once.
-/

def one : cnat :=
  fun (X : Type) (f : X -> X) (x : X) => f x

/-
Applying twice yields the Church numeral two.
-/

def two : cnat :=
  fun (X : Type) (f : X -> X) (x : X) => f (f x)

/-
Applying a function zero times means returning the argument unchanged.
-/

def zero : cnat :=
  fun (X : Type) (_f : X -> X) (x : X) => x

/-
More generally, a Church numeral packages the instruction "do it `n` times."
Our earlier `doit3times` is exactly the Church numeral three.
-/

def three : cnat := @doit3times

/-
We can also rewrite the same ideas with more suggestive names.
-/

def zero' : cnat :=
  fun (X : Type) (_succ : X -> X) (zero : X) => zero

def one' : cnat :=
  fun (X : Type) (succ : X -> X) (zero : X) => succ zero

def two' : cnat :=
  fun (X : Type) (succ : X -> X) (zero : X) => succ (succ zero)

/-
If we instantiate the iterator with the successor function on naturals and the
starting value `0`, we recover the expected Peano numerals.
-/

theorem zero_church_peano : zero nat S O = 0 := by
  rfl

theorem one_church_peano : one nat S O = 1 := by
  rfl

theorem two_church_peano : two nat S O = 2 := by
  rfl

/-
The interesting part is not just representing numbers but doing arithmetic with
them. The following exercises ask you to implement successor, addition,
multiplication, and exponentiation directly on Church numerals.
-/

/- **** Exercise: 2 stars, advanced (church_scc) -/

def scc (n : cnat) : cnat := by
  sorry

theorem scc_1 : scc zero = one := by
  sorry

theorem scc_2 : scc one = two := by
  sorry

theorem scc_3 : scc two = three := by
  sorry

/- **** Exercise: 3 stars, advanced (church_plus) -/

def plus (n m : cnat) : cnat := by
  sorry

theorem plus_1 : plus zero one = one := by
  sorry

theorem plus_2 : plus two three = plus three two := by
  sorry

theorem plus_3 : plus (plus two two) three = plus one (plus three three) := by
  sorry

/- **** Exercise: 3 stars, advanced (church_mult) -/

def mult (n m : cnat) : cnat := by
  sorry

theorem mult_1 : mult one one = one := by
  sorry

theorem mult_2 : mult zero (plus three three) = zero := by
  sorry

theorem mult_3 : mult two three = plus three three := by
  sorry

/- **** Exercise: 3 stars, advanced (church_exp) -/

def exp (n m : cnat) : cnat := by
  sorry

theorem exp_1 : exp two two = plus two two := by
  sorry

theorem exp_2 : exp three zero = one := by
  sorry

theorem exp_3 : exp three two = plus (mult two (mult two two)) one := by
  sorry

end Church
end Exercises
end Poly
