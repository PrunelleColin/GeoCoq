Require Import GeoCoq.Tarski_dev.Ch12_parallel_inter_dec.
Require Import Morphisms.
Require Import GeoCoq.Axioms.hilbert_axioms.

Section T.

Context `{TE:Tarski_2D_euclidean}.

(** We need a notion of line. *)

Definition Line := @Couple Tpoint.
Definition Lin := build_couple Tpoint.

Definition Incident (A : Tpoint) (l : Line) := Col A (P1 l) (P2 l).

(** * Group I Combination *)

(** For every pair of distinct points there is a line containing them. *)

Lemma axiom_line_existence : forall A B, A<>B -> exists l, Incident A l /\ Incident B l.
Proof.
intros.
exists (Lin A B H).
unfold Incident.
intuition.
Qed.

(** We need a notion of equality over lines. *)

Definition Eq : relation Line := fun l m => forall X, Incident X l <-> Incident X m.

Infix "=l=" := Eq (at level 70):type_scope.

Lemma incident_eq : forall A B l, forall H : A<>B,
 Incident A l -> Incident B l ->
 (Lin A B H) =l= l.
Proof.
intros.
unfold Eq.
intros.
unfold Incident in *.
replace (P1 (Lin A B H)) with A.
replace (P2 (Lin A B H)) with B.
2:auto.
2:auto.
split;intro.
assert (T:=Cond l).
elim (eq_dec_points X B); intro.
subst X.
auto.
assert (Col (P1 l) A B).
eapply col_transitivity_1;try apply T;Col.
assert (Col (P2 l) A B) by eCol.
assert (Col B (P2 l) X).
eCol.
assert (Col B (P1 l) X).
eCol.
eapply col_transitivity_2.
assert (B<>X) by auto.
apply H8.
Col.
Col.


assert (U:=Cond l).
elim (eq_dec_points X (P1 l)); intro.
smart_subst X.
eCol.

assert (Col (P1 l) X A).
eCol.
assert (Col (P1 l) X B).
eCol.
eapply col_transitivity_1.
apply H3.
Col.
Col.
Qed.

(** Our equality is an equivalence relation. *)

Lemma eq_transitivity : forall l m n, l =l= m -> m =l= n -> l =l= n.
Proof.
unfold Eq,Incident.
intros.
assert (T:=H X).
assert (V:= H0 X).
split;intro;intuition.
Qed.

Lemma eq_reflexivity : forall l, l =l= l.
Proof.
intros.
unfold Eq.
intuition.
Qed.

Lemma eq_symmetry : forall l m, l =l= m -> m =l= l.
unfold Eq.
intros.
assert (T:=H X).
intuition.
Qed.

Instance Eq_Equiv : Equivalence Eq.
Proof.
split.
unfold Reflexive.
apply eq_reflexivity.
unfold Symmetric.
apply eq_symmetry.
unfold Transitive.
apply eq_transitivity.
Qed.


(** The equality is compatible with Incident *)

Lemma eq_incident : forall A l m, l =l= m ->
 (Incident A l <-> Incident A m).
Proof.
intros.
split;intros;
unfold Eq in *;
assert (T:= H A);
intuition.
Qed.

Instance incident_Proper (A:Tpoint) :
Proper (Eq ==>iff) (Incident A).
intros a b H .
apply eq_incident.
assumption.
Qed.

Lemma axiom_Incid_morphism :
 forall P l m, Incident P l -> Eq l m -> Incident P m.
Proof.
intros.
destruct (eq_incident P l m H0).
intuition.
Qed.

Lemma axiom_Incid_dec : forall P l, Incident P l \/ ~Incident P l.
Proof.
intros.
unfold Incident.
apply Col_dec.
Qed.

(** There is only one line going through two points. *)
Lemma axiom_line_uniqueness : forall A B l m, A <> B ->
 (Incident A l) -> (Incident B l) -> (Incident A m) -> (Incident B m) ->
 l =l= m.
Proof.
intros.
assert ((Lin A B H) =l= l).
eapply incident_eq;assumption.
assert ((Lin A B H) =l= m).
eapply incident_eq;assumption.
rewrite <- H4.
assumption.
Qed.

(** Every line contains at least two points. *)

Lemma axiom_two_points_on_line : forall l,
  { A : Tpoint & { B | Incident B l /\ Incident A l /\ A <> B}}.
Proof.
intros.
exists (P1 l).
exists (P2 l).
unfold Incident.
repeat split;Col.
exact (Cond l).
Qed.

(** Definition of the collinearity predicate.
 We say that three points are collinear if they belongs to the same line. *)

Definition Col_H := fun A B C =>
  exists l, Incident A l /\ Incident B l /\ Incident C l.

(** We show that the notion of collinearity we just defined is equivalent to the
 notion of collinearity of Tarski. *)

Lemma cols_coincide_1 : forall A B C, Col_H A B C -> Col A B C.
Proof.
intros.
unfold Col_H in H.
DecompExAnd H l.
unfold Incident in *.
assert (T:=Cond l).
assert (Col (P1 l) A B).
eapply col_transitivity_1;try apply T;Col.
assert (Col (P1 l) A C).
eapply col_transitivity_1;try apply T;Col.
elim (eq_dec_points (P1 l) A); intro.
smart_subst A.
eapply col_transitivity_1;try apply T;Col.
eapply col_transitivity_2;try apply H2;Col.
Qed.

Lemma cols_coincide_2 : forall A B C, Col A B C -> Col_H A B C.
Proof.
intros.
unfold Col_H.
elim (eq_dec_points A B); intro.
subst B.
elim (eq_dec_points A C); intro.
subst C.
assert (exists B, A<>B).
eapply another_point.
DecompEx H0 B.
exists (Lin A B H1).
unfold Incident;intuition.
exists (Lin A C H0).
unfold Incident;intuition.
exists (Lin A B H0).
unfold Incident;intuition.
Qed.


Lemma cols_coincide : forall A B C, Col A B C <-> Col_H A B C.
Proof.
intros.
split.
apply cols_coincide_2.
apply cols_coincide_1.
Qed.

(** There exists three non collinear points. *)

Lemma axiom_plan : exists l, exists P, ~ Incident P l.
Proof.
assert (T:=lower_dim_ex).
DecompEx T A.
DecompEx H B.
DecompEx H0 C.
assert (~ Col A B  C) by auto.
assert_diffs.
exists (Lin A B H4).
exists C.
unfold Incident.
simpl.
Col.
Qed.

Lemma axiom_plan' :
 exists A , exists B, exists C, ~ Col_H A B C.
Proof.
assert (T:=lower_dim_ex).
DecompEx T A.
DecompEx H B.
DecompEx H0 C.
assert (~ Col_H A B C).
unfold not;intro.
assert (Col A B C).
apply cols_coincide_1.
auto.
intuition.

exists A.
exists B.
exists C.
auto.
Qed.

(** * Group II Order *)

(** Definition of the Between predicate of Hilbert.
    Note that it is different from the Between of Tarski.
    The Between of Hilbert is strict. *)

Definition Between_H A B C  :=
  Bet A B C /\ A <> B /\ B <> C /\ A <> C.

Lemma axiom_between_col :
 forall A B C, Between_H A B C -> Col_H A B C.
Proof.
intros.
unfold Col_H, Between_H in *.
DecompAndAll.
exists (Lin A B H2).
unfold Incident.
intuition.
Qed.

Lemma axiom_between_diff :
 forall A B C, Between_H A B C -> A<>C.
Proof.
intros.
unfold Between_H in *.
intuition.
Qed.

(** If B is between A and C, it is also between C and A. *)

Lemma axiom_between_comm : forall A B C, Between_H A B C -> Between_H C B A.
Proof.
unfold Between_H in |- *.
intros.
intuition.
Qed.



Lemma axiom_between_out :
 forall A B, A <> B -> exists C, Between_H A B C.
Proof.
intros.
prolong A B C A B.
exists C.
unfold Between_H.
repeat split;
auto;
intro;
treat_equalities;
tauto.
Qed.

Lemma axiom_between_only_one :
 forall A B C,
 Between_H A B C -> ~ Between_H B C A.
Proof.
unfold Between_H in |- *.
intros.
intro;
spliter.
assert (B=C) by
 (apply (between_equality B C A);Between).
solve [intuition].
Qed.

Lemma between_one : forall A B C,
 A<>B -> A<>C -> B<>C -> Col A B C ->
 Between_H A B C \/ Between_H B C A \/ Between_H B A C.
Proof.
intros.
unfold Col, Between_H in *.
intuition.
Qed.


Lemma axiom_between_one : forall A B C,
 A<>B -> A<>C -> B<>C -> Col_H A B C ->
 Between_H A B C \/ Between_H B C A \/ Between_H B A C.
Proof.
intros.
apply between_one;try assumption.
apply cols_coincide_1.
assumption.
Qed.

(** Axiom of Pasch, (Hilbert version). *)

(** First we define a predicate which means that the line l intersects the segment AB. *)

Definition cut := fun l A B => ~Incident A l /\ ~Incident B l /\ exists I, Incident I l /\ Between_H A I B.

(** We show that this definition is equivalent to the predicate TS of Tarski. *)

Lemma cut_two_sides : forall l A B, cut l A B <-> TS (P1 l) (P2 l) A B.
Proof.
intros.
unfold cut.
unfold TS.
split.
intros.
spliter.
repeat split; intuition.
ex_and H1 T.
exists T.
unfold Incident in H1.
unfold Between_H in *.
intuition.

intros.
spliter.
ex_and H1 T.
unfold Incident.
repeat split; try assumption.
exists T.
split.
assumption.
unfold Between_H.
repeat split.
assumption.
intro.
subst.
contradiction.
intro.
subst.
contradiction.
intro.
treat_equalities.
contradiction.
Qed.

Lemma axiom_pasch : forall A B C l,
 ~ Col_H A B C -> ~ Incident C l ->
 cut l A B -> cut l A C \/ cut l B C.
Proof.
intros.
apply cut_two_sides in H1.
assert(~Col A B C).
intro.
apply H.
apply cols_coincide_2.
assumption.

assert(HH:=H1).
unfold TS in HH.
spliter.

unfold Incident in H0.

assert(HH:= one_or_two_sides (P1 l)(P2 l) A C H3 H0 ).

induction HH.
left.
apply <-cut_two_sides.
assumption.
right.
apply <-cut_two_sides.
apply l9_2.
eapply l9_8_2.
apply H1.
assumption.
Qed.

Lemma Incid_line :
 forall P A B l, A<>B ->
 Incident A l -> Incident B l -> Col P A B -> Incident P l.
Proof.
intros.
unfold Incident in *.
destruct l as [C D HCD].
simpl in *.
assert (Col D A B) by eCol.
assert (Col C A B) by eCol.
assert (Col A D P) by eCol.
assert (Col A D C) by eCol.
elim (eq_dec_points A D); intro.
subst.
clear H3 H5 H6.
eCol.
eCol.
Qed.




(** * Goup IV Congruence *)

(** The cong predicate of Hilbert is the same as the one of Tarski: *)

Definition Hcong:=Cong.

Definition outH := fun P A B => Between_H P A B \/ Between_H P B A \/ (P <> A /\ A = B).

Lemma out_outH : forall P A B, Out P A B -> outH P A B.
unfold Out.
unfold outH.
intros.
spliter.
induction H1.

induction (eq_dec_points A B).
right; right.
split; auto.
left.
unfold Between_H.
repeat split; auto.


induction (eq_dec_points A B).
right; right.
split; auto.
right; left.
unfold Between_H.
repeat split; auto.
Qed.

Lemma axiom_hcong_1_existence : forall A B A' P l,
  A <> B -> A' <> P ->
  Incident A' l -> Incident P l ->
  exists B', Incident B' l /\ outH A' P B' /\ Hcong A' B' A B.
Proof.
intros; destruct (l6_11_existence A' A B P) as [B' [HOut HCong]]; auto.
exists B'; repeat split; try apply out_outH, l6_6; auto; unfold Incident in *.
assert_cols; destruct l; simpl in *; ColR.
Qed.

Lemma axiom_hcong_1_uniqueness :
 forall A B l M A' B' A'' B'', A <> B -> Incident M l ->
  Incident A' l -> Incident B' l ->
  Incident A'' l -> Incident B'' l ->
  Between_H A' M B' -> Hcong M A' A B ->
  Hcong M B' A B -> Between_H A'' M B'' ->
  Hcong M A'' A B -> Hcong M B'' A B ->
  (A' = A'' /\ B' = B'') \/ (A' = B'' /\ B' = A'').
Proof.
unfold Hcong.
unfold Between_H.
unfold Incident.
intros.
spliter.

assert(A' <> M /\ A'' <> M /\ B' <> M /\ B'' <> M /\ A' <> B' /\ A'' <> B'').
repeat split; intro; treat_equalities; tauto.
spliter.

induction(out_dec M A' A'').
left.
assert(A' = A'').
eapply (l6_11_uniqueness M A B A''); try assumption.
apply out_trivial.
assumption.

split.
assumption.
subst A''.

eapply (l6_11_uniqueness M A B B''); try assumption.

unfold Out.
repeat split; try assumption.
eapply l5_2.
apply H18.
assumption.
assumption.
apply out_trivial.
assumption.

right.
apply not_out_bet in H23.

assert(A' = B'').
eapply (l6_11_uniqueness M A B A'); try assumption.
apply out_trivial.
assumption.

unfold Out.
repeat split; try assumption.

eapply l5_2.
apply H18.
assumption.
apply between_symmetry.
assumption.

split.
assumption.

subst B''.
eapply (l6_11_uniqueness M A B B'); try assumption.
apply out_trivial.
assumption.
unfold Out.
repeat split; try assumption.
eapply l5_2.
apply H20.
apply between_symmetry.
assumption.
assumption.
eapply col3.
apply (Cond l).
Col.
Col.
Col.
Qed.

(** As a remark we also prove another version of this axiom as formalized in Isabelle by
Phil Scott. *)

Definition same_side_scott E A B := E <> A /\ E <> B /\ Col_H E A B /\ ~ Between_H A E B.

Remark axiom_hcong_scott:
 forall P Q A C, A <> C -> P <> Q ->
  exists B, same_side_scott A B C  /\ Hcong P Q A B.
Proof.
intros.
unfold same_side_scott.
assert (exists X : Tpoint, Out A X C /\ Cong A X P Q).
apply l6_11_existence;auto.
decompose [ex and] H1;clear H1.
exists x.
repeat split.
unfold Out in H3.
intuition.
unfold Out in H3.
intuition.
apply cols_coincide_2.
apply out_col;assumption.


unfold Out in H3.
unfold Between_H.
intro.
decompose [and] H3;clear H3.
decompose [and] H1;clear H1.
clear H8.
destruct H7.
assert (A = x).
eapply between_equality;eauto.
intuition.
assert (A = C).
eapply between_equality;eauto.
apply between_symmetry.
auto.
intuition.
unfold Hcong.
Cong.
Qed.

(** Transivity of congruence. *)

Lemma axiom_hcong_trans : forall A B C D E F, Hcong A B C D -> Hcong A B E F -> Hcong C D E F.
Proof.
unfold Hcong.
intros.
apply cong_symmetry.
apply cong_symmetry in H0.
eapply cong_transitivity;eauto.
Qed.

(** Reflexivity of congruence. *)

Lemma axiom_hcong_refl : forall A B , Hcong A B A B.
Proof.
unfold Hcong.
intros.
Cong.
Qed.

(** We define when two segments do not intersect. *)

Definition disjoint := fun A B C D => ~ exists P, Between_H A P B /\ Between_H C P D.

(** Note that two disjoint segments may share one of their extremities. *)

Lemma col_disjoint_bet : forall A B C, Col_H A B C -> disjoint A B B C -> Bet A B C.
Proof.
intros.
apply cols_coincide_1 in H.
unfold disjoint in H0.

induction (eq_dec_points A B).
subst  B.
apply between_trivial2.
induction (eq_dec_points B C).
subst  C.
apply between_trivial.

unfold Col in H.
induction H.
assumption.

induction H.
apply False_ind.
apply H0.
assert(exists M, Midpoint M B C) by(apply midpoint_existence).
ex_and H3 M.
exists M.
unfold Midpoint in H4.
spliter.
split.
unfold Between_H.
repeat split.
apply between_symmetry.
eapply between_exchange4.
apply H3.
assumption.
intro.
treat_equalities.
(*
apply between_symmetry in H.
apply between_equality in H.
treat_equalities.
*)
tauto.
(*
apply between_symmetry.
assumption.
*)
intro.
treat_equalities.
tauto.
assumption.
unfold Between_H.
repeat split.
assumption.
intro.
treat_equalities.
tauto.
intro.
treat_equalities.
tauto.
assumption.

apply False_ind.
apply H0.
assert(exists M, Midpoint M A B) by(apply midpoint_existence).
ex_and H3 M.
exists M.
unfold Midpoint in H4.
spliter.
split.
unfold Between_H.
repeat split.
assumption.
intro.
treat_equalities.
tauto.
intro.
treat_equalities.
tauto.
assumption.

unfold Between_H.
repeat split.

eapply between_exchange4.
apply between_symmetry.
apply H3.
apply between_symmetry.
assumption.
intro.
treat_equalities.
tauto.
intro.
treat_equalities.
intuition.
assumption.
Qed.


Lemma axiom_hcong_3 : forall A B C A' B' C',
   Col_H A B C -> Col_H A' B' C' ->
  disjoint A B B C -> disjoint A' B' B' C' ->
  Hcong A B A' B' -> Hcong B C B' C' -> Hcong A C A' C'.
Proof.
unfold Hcong.
intros.
assert(Bet A B C).
eapply col_disjoint_bet.
assumption.
assumption.

assert(Bet A' B' C').
eapply col_disjoint_bet.
assumption.
assumption.
eapply l2_11;eauto.
Qed.

Lemma exists_not_incident : forall A B : Tpoint, forall  HH : A <> B , exists C, ~ Incident C (Lin A B HH).
Proof.
intros.
unfold Incident.
assert(HC:=not_col_exists A B HH).
ex_and HC C.
exists C.
intro.
apply H.
simpl in H0.
Col.
Qed.

Definition same_side := fun A B l => exists P, cut l A P /\ cut l B P.

(** Same side predicate corresponds to OS of Tarski. *)

Lemma same_side_one_side : forall A B l, same_side A B l -> OS (P1 l) (P2 l) A B.
Proof.
unfold same_side.
intros.
ex_and H P.
apply cut_two_sides in H.
apply cut_two_sides in H0.
eapply l9_8_1.
apply H.
apply H0.
Qed.



Lemma one_side_same_side : forall A B l, OS (P1 l) (P2 l) A B -> same_side A B l.
Proof.
intros.
unfold same_side.
unfold OS in H.
ex_and H P.
exists P.
unfold cut.
unfold Incident.
unfold TS in H.
unfold TS in H0.
spliter.
repeat split; auto.
ex_and H4 T.
exists T.
unfold Between_H.
repeat split; auto.
intro.
subst T.
contradiction.
intro.
subst T.
contradiction.
intro.
subst P.
apply between_identity in H5.
subst T.
contradiction.
ex_and H2 T.
exists T.
unfold Between_H.
repeat split; auto.
intro.
subst T.
contradiction.
intro.
subst T.
contradiction.
intro.
subst P.
apply between_identity in H5.
subst T.
contradiction.
Qed.

Definition same_side' := fun A B X Y => X<>Y /\ forall l, Incident X l -> Incident Y l -> same_side A B l.

Lemma OS_distinct : forall P Q A B,
  OS P Q A B -> P<>Q.
Proof.
intros.
apply one_side_not_col123 in H.
assert_diffs;assumption.
Qed.


Lemma OS_same_side' :
 forall P Q A B, OS P Q A B -> same_side' A B P Q.
Proof.
intros.
unfold same_side'.
intros.
split.
apply OS_distinct with A B;assumption.
intros.

apply  one_side_same_side.
destruct l.
unfold Incident in *.
simpl in *.
apply col2_os__os with P Q;try assumption;ColR.
Qed.

Lemma same_side_OS :
 forall P Q A B, same_side' P Q A B -> OS A B P Q.
Proof.
intros.
unfold same_side' in *.
destruct H.
destruct (axiom_line_existence A B H).
destruct H1.
assert (T:=H0 x H1 H2).
assert (U:=same_side_one_side P Q x T).
destruct x.
unfold Incident in *.
simpl in *.
apply col2_os__os with P1 P2;Col.
Qed.

(** This is equivalent to the out predicate of Tarski. *)

Lemma outH_out : forall P A B, outH P A B -> Out P A B.
Proof.
unfold outH.
unfold Out.
intros.
induction H.
unfold Between_H in H.
spliter.
repeat split; auto.
induction H.
unfold Between_H in H.
spliter.
repeat split; auto.
spliter.
repeat split.
auto.
subst B.
auto.
subst B.
left.
apply between_trivial.
Qed.

(** The 2D version of the fourth congruence axiom **)

Lemma incident_col : forall M l, Incident M l -> Col M (P1 l)(P2 l).
Proof.
unfold Incident.
intros.
assumption.
Qed.

Lemma col_incident : forall M l, Col M (P1 l)(P2 l) -> Incident M l.
Proof.
unfold Incident.
intros.
assumption.
Qed.

Lemma Bet_Between_H : forall A B C,
 Bet A B C -> A<>B -> B<>C -> Between_H A B C.
Proof.
intros.
unfold Between_H.
repeat split;try assumption.
intro.
subst.
treat_equalities.
intuition.
Qed.

Lemma axiom_cong_5' : forall A B C A' B' C', ~ Col_H A B C -> ~ Col_H A' B' C' ->
           Hcong A B A' B' -> Hcong A C A' C' -> CongA B A C B' A' C' -> CongA A B C A' B' C'.
Proof.
intros A B C A' B' C'.
intros.
unfold Hcong in *.
assert (T:=l11_49 B A C B' A' C').
assert (~ Col A B C).
intro.
apply cols_coincide_2 in H4.
intuition.
assert_diffs.
intuition.
Qed.


Lemma axiom_hcong_4_existence :  forall A B C O X P,
   ~ Col_H P O X -> ~ Col_H A B C ->
  exists Y, CongA A B C X O Y  (* /\ ~Col O X Y *) /\ same_side' P Y O X.
Proof.
intros.
rewrite <- cols_coincide in H.
rewrite <- cols_coincide in H0.

assert(~Col X O P).
intro.
apply H.
Col.
assert(HH:=angle_construction_1 A B C X O P H0 H1).

ex_and HH Y.

exists Y.
split.
assumption.
apply OS_same_side'.
apply invert_one_side.
apply one_side_symmetry.
assumption.
Qed.

Lemma same_side_trans :
 forall A B C l,
  same_side A B l -> same_side B C l -> same_side A C l.
Proof.
intros.
apply one_side_same_side.
apply same_side_one_side in H.
apply same_side_one_side in H0.
eapply one_side_transitivity.
apply H.
assumption.
Qed.

Lemma same_side_sym :
 forall A B l,
  same_side A B l -> same_side B A l.
Proof.
intros.
apply one_side_same_side.
apply same_side_one_side in H.
apply one_side_symmetry.
assumption.
Qed.


Lemma axiom_hcong_4_uniqueness :
  forall A B C O P X Y Y', ~ Col_H P O X  -> ~ Col_H A B C -> CongA A B C X O Y -> CongA A B C X O Y' -> 
  same_side' P Y O X -> same_side' P Y' O X -> outH O Y Y'.
Proof.
intros.
rewrite <- cols_coincide in H.
rewrite <- cols_coincide in H0.
assert (T:CongA X O Y X O Y').
eapply conga_trans.
apply conga_sym.
apply H1.
assumption.

apply conga__or_out_ts in T.
induction T.
apply out_outH.
assumption.

apply same_side_OS in H3.
apply same_side_OS in H4.
exfalso.
assert (OS O X Y Y').
apply one_side_transitivity with P.
apply one_side_symmetry.
assumption.
assumption.
apply invert_one_side in H6.
apply l9_9 in H5.
intuition.
Qed.

Lemma axiom_conga_comm : forall A B C,
 ~ Col_H A B C -> CongA A B C C B A.
Proof.
intros.
rewrite <- cols_coincide in H.
assert_diffs.
apply conga_pseudo_refl;auto.
Qed.

Lemma axiom_cong_permr : forall A B C D, Hcong A B C D -> Hcong A B D C.
Proof.
intros;unfold Hcong.
Cong.
Qed.

Lemma axiom_congaH_outH_congaH :
 forall A B C D E F A' C' D' F' : Tpoint,
  CongA A B C D E F ->
  Between_H B A A' \/ Between_H B A' A \/ B <> A /\ A = A' ->
  Between_H B C C' \/ Between_H B C' C \/ B <> C /\ C = C' ->
  Between_H E D D' \/ Between_H E D' D \/ E <> D /\ D = D' ->
  Between_H E F F' \/ Between_H E F' F \/ E <> F /\ F = F' ->
  CongA A' B C' D' E F'.
Proof.
intros.
apply out_conga with A C D F;auto using outH_out.
Qed.

Lemma axiom_conga_permlr:
forall A B C D E F : Tpoint, CongA A B C D E F -> CongA C B A F E D.
Proof.
intros.
auto using conga_right_comm, conga_left_comm.
Qed.

Lemma axiom_inter_dec : forall l m,
  (exists P, Incident P l /\ Incident P m) \/ ~ (exists P, Incident P l /\ Incident P m).
Proof.
intros l m;
elim (Ch12_parallel_inter_dec.inter_dec (P1 l) (P2 l) (P1 m) (P2 m));
intro; [left|right]; auto.
Qed.

Lemma axiom_conga_refl : forall A B C, ~ Col_H A B C -> CongA A B C A B C.
Proof.
intros A B C H. apply Ch11_angles.conga_refl;
intro; subst; apply H; apply cols_coincide; Col.
Qed.

End T.

Section Hilbert_neutral_to_Tarski_neutral.

Context `{TE:Tarski_2D_euclidean}.

Lemma PAneqPB : PA <> PB.
Proof.
assert (T:= lower_dim).
intro.
rewrite H in *.
apply T.
left.
Between.
Qed.

Definition l0 := Lin PA PB PAneqPB.

Lemma plan : ~ Incident PC l0.
Proof.
unfold Incident.
unfold Col.
assert (T:= lower_dim).
unfold l0;simpl.
intro;apply T.
intuition.
Qed.

Instance Hilbert_neutral_follows_from_Tarski_neutral : Hilbert_neutral_2D.
Proof.
 exact (Build_Hilbert_neutral_2D Tpoint Line Eq Eq_Equiv Incident
       axiom_Incid_morphism axiom_Incid_dec eq_dec_points axiom_line_existence axiom_line_uniqueness axiom_two_points_on_line l0 PC plan
       Between_H axiom_between_col axiom_between_diff axiom_between_comm axiom_between_out
       axiom_between_only_one axiom_pasch
       Hcong axiom_cong_permr axiom_hcong_trans axiom_hcong_1_existence
       axiom_hcong_3 CongA axiom_conga_refl axiom_conga_comm axiom_conga_permlr axiom_cong_5' axiom_congaH_outH_congaH axiom_hcong_4_existence axiom_hcong_4_uniqueness).
Defined.

End Hilbert_neutral_to_Tarski_neutral.

Section Hilbert_Euclidean_to_Tarski_Euclidean.

Context `{TE:Tarski_2D_euclidean}.

(** * Group Parallels *)

(** We use a definition of parallel which is valid only in 2D: *)

Definition Para l m := ~ exists X, Incident X l /\ Incident X m.

Lemma Para_Par : forall A B C D, forall HAB: A<>B, forall HCD: C<>D,
 Para (Lin A B HAB) (Lin C D HCD) -> Par A B C D.
Proof.
intros.
unfold Para in H.
unfold Incident in *;simpl in *.
unfold Par.
left.
unfold Par_strict.
repeat split;auto;try apply all_coplanar.
Qed.

Lemma axiom_euclid_uniqueness :
  forall l P m1 m2,
  ~ Incident P l ->
   Para l m1 -> Incident P m1 ->
   Para l m2 -> Incident P m2 ->
   Eq m1 m2.
Proof.
intros.
destruct l as [A B HAB].
destruct m1 as [C D HCD].
destruct m2 as [C' D' HCD'].
unfold Incident in *;simpl in *.
apply Para_Par in H0.
apply Para_Par in H2.
elim (parallel_uniqueness A B C D C' D' P H0 H1 H2 H3);intros.
apply axiom_line_uniqueness with C' D';
unfold Incident;simpl;Col.
Qed.

Instance Hilbert_euclidean_follows_from_Tarski_euclidean : Hilbert_euclidean_2D Hilbert_neutral_follows_from_Tarski_neutral.
Proof.
split.
apply axiom_euclid_uniqueness.
Qed.

End Hilbert_Euclidean_to_Tarski_Euclidean.