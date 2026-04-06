import Std

set_option autoImplicit false

/-
This file is a scaffold translated from `rocq/lf/IndProp.v`.
Preserve the chapter structure, prose, examples, and pedagogical flow
of the original as you fill in the Lean translation.
-/

/- ################################################################# -/
/- * IndProp: Inductively Defined Propositions -/

/- ################################################################# -/
/- * Inductively Defined Propositions -/

/- ================================================================= -/
/- ** Example: The Collatz Conjecture -/

/- ================================================================= -/
/- ** Example: Binary relation for comparing numbers -/

/- ================================================================= -/
/- ** Example: Transitive Closure -/

/- ================================================================= -/
/- ** Example: Reflexive and Transitive Closure -/

/- **** Exercise: 1 star, standard, optional (clos_refl_trans_sym) -/

/- ================================================================= -/
/- ** Example: Permutations -/

/- **** Exercise: 1 star, standard, optional (perm) -/

/- ================================================================= -/
/- ** Example: Evenness (yet again) -/

/- **** Exercise: 1 star, standard (ev_double) -/

/- ================================================================= -/
/- ** Constructing Evidence for Permutations -/

/- **** Exercise: 1 star, standard (Perm3) -/

/- ################################################################# -/
/- * Using Evidence in Proofs -/

/- ================================================================= -/
/- ** Destructing and Inverting Evidence -/

/- **** Exercise: 1 star, standard (le_inversion) -/

/- **** Exercise: 1 star, standard (inversion_practice) -/

/- **** Exercise: 1 star, standard (ev5_nonsense) -/

/- ================================================================= -/
/- ** Induction on Evidence -/

/- **** Exercise: 2 stars, standard (ev_sum) -/

/- **** Exercise: 3 stars, advanced, especially useful (ev_ev__ev) -/

/- **** Exercise: 3 stars, standard, optional (ev_plus_plus) -/

/- ================================================================= -/
/- ** Multiple Induction Hypotheses -/

/- **** Exercise: 4 stars, advanced, optional (ev'_ev) -/

/- **** Exercise: 2 stars, standard (Perm3_In) -/

/- **** Exercise: 1 star, standard, optional (Perm3_NotIn) -/

/- **** Exercise: 2 stars, standard, optional (NotPerm3) -/

/- ################################################################# -/
/- * Exercising with Inductive Relations -/

/- **** Exercise: 3 stars, standard, especially useful (le_facts) -/

/- **** Exercise: 2 stars, standard, especially useful (plus_le_facts1) -/

/- **** Exercise: 2 stars, standard, especially useful (plus_le_facts2) -/

/- **** Exercise: 3 stars, standard, optional (lt_facts) -/

/- **** Exercise: 4 stars, standard, optional (leb_le) -/

/- **** Exercise: 3 stars, standard, especially useful (R_provability) -/

/- **** Exercise: 3 stars, standard, optional (R_fact) -/

/- **** Exercise: 4 stars, advanced (subsequence) -/

/- **** Exercise: 2 stars, standard, optional (R_provability2) -/

/- **** Exercise: 2 stars, standard, optional (total_relation) -/

/- **** Exercise: 2 stars, standard, optional (empty_relation) -/

/- ################################################################# -/
/- * Case Study: Regular Expressions -/

/- ================================================================= -/
/- ** Definitions -/

/- ================================================================= -/
/- ** Examples -/

/- **** Exercise: 3 stars, standard (exp_match_ex1) -/

/- **** Exercise: 2 stars, standard, optional (EmptyStr_not_needed) -/

/- **** Exercise: 4 stars, standard (re_not_empty) -/

/- ================================================================= -/
/- ** The [remember] Tactic -/

/- **** Exercise: 4 stars, standard, optional (exp_match_ex2) -/

/- ================================================================= -/
/- ** The "Weak" Pumping Lemma -/

/- **** Exercise: 2 stars, standard (weak_pumping_char) -/

/- **** Exercise: 3 stars, standard (weak_pumping_app) -/

/- **** Exercise: 3 stars, standard (weak_pumping_union_l) -/

/- **** Exercise: 2 stars, standard, optional (weak_pumping_star_zero) -/

/- **** Exercise: 4 stars, standard, optional (weak_pumping_star_app) -/

/- ================================================================= -/
/- ** The (Strong) Pumping Lemma -/

/- **** Exercise: 5 stars, advanced, optional (pumping) -/

/- ################################################################# -/
/- * Case Study: Improving Reflection -/

/- **** Exercise: 2 stars, standard, especially useful (reflect_iff) -/

/- **** Exercise: 3 stars, standard, especially useful (eqbP_practice) -/

/- ################################################################# -/
/- * Additional Exercises -/

/- **** Exercise: 3 stars, standard, especially useful (nostutter_defn) -/

/- **** Exercise: 4 stars, advanced (filter_challenge) -/

/- **** Exercise: 5 stars, advanced, optional (filter_challenge_2) -/

/- **** Exercise: 4 stars, standard, optional (palindromes) -/

/- **** Exercise: 5 stars, standard, optional (palindrome_converse) -/

/- **** Exercise: 4 stars, advanced, optional (NoDup) -/

/- **** Exercise: 5 stars, advanced, optional (pigeonhole_principle) -/

/- ================================================================= -/
/- ** Extended Exercise: A Verified Regular-Expression Matcher -/

/- **** Exercise: 3 stars, standard, optional (app_ne) -/

/- **** Exercise: 3 stars, standard, optional (star_ne) -/

/- **** Exercise: 2 stars, standard, optional (match_eps) -/

/- **** Exercise: 3 stars, standard, optional (match_eps_refl) -/

/- **** Exercise: 3 stars, standard, optional (derive) -/

/- **** Exercise: 4 stars, standard, optional (derive_corr) -/

/- **** Exercise: 2 stars, standard, optional (regex_match) -/

/- **** Exercise: 3 stars, standard, optional (regex_match_correct) -/
