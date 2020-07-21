/-
Copyright (c) 2020 Aaron Anderson. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Author:  Aaron Anderson, Jalex Stark.
-/
import linear_algebra.matrix
import data.rel
import combinatorics.simple_graph

open_locale classical big_operators
open finset matrix simple_graph
noncomputable theory

universes u v
variables {α : Type u} [fintype α] [decidable_eq α]
variables {β : Type u} [fintype β] [decidable_eq β]
variables {γ : Type u} [fintype γ] [decidable_eq γ]

lemma symmetric.eq_inv {r : rel α α} (h : symmetric r) : r.inv = r :=
by { unfold symmetric at h, ext, split; apply h, }

section defn
variable (r : rel α β)
variables (R : Type v) [semiring R]


def rel_matrix : matrix α β R :=
λ (a : α) (b : β), if r a b then 1 else 0

end defn

variables {R : Type v} [semiring R]

section general
variable {r : rel α β}

@[simp]
lemma rel_matrix_apply (a : α) (b : β) :
  rel_matrix r R a b = ite (r a b) 1 0 := rfl

-- bad name
@[simp] lemma rel_matrix_val_idem (a : α) (b : β) :
 (rel_matrix r R a b) * (rel_matrix r R a b) = (rel_matrix r R a b) :=
by { unfold rel_matrix, split_ifs; simp [h], }

@[simp]
lemma transpose_rel_matrix :
 (rel_matrix r R).transpose = rel_matrix r.inv R := rfl

@[simp]
lemma rel_matrix_dot_product (a : α) (vec : β → R) :
  dot_product (rel_matrix r R a) vec = ∑ b in univ.filter (r a), vec b :=
by simp [dot_product, sum_filter]

@[simp]
lemma dot_product_rel_matrix (a : α) (vec : β → R) :
  dot_product vec (rel_matrix r R a) = ∑ b in univ.filter (r a), vec b :=
by simp [dot_product, sum_filter]

@[simp]
lemma rel_matrix_mul_apply (M : matrix β γ R) (a : α) (c : γ) :
((rel_matrix r R).mul M) a c = ∑ b in univ.filter (r a), (M b) c :=
by rw [mul_val, ← dot_product, rel_matrix_dot_product]

@[simp]
lemma mul_rel_matrix_apply (M : matrix γ α R) (c : γ) (b : β) :
  (M.mul (rel_matrix r R)) c b = ∑ a in univ.filter (r.inv b), M c a :=
by {rw [mul_val, ← dot_product, ← dot_product_rel_matrix], refl, }

end general

section same_type
variable {r : rel α α}

lemma transpose_rel_matrix_eq_of_symmetric (h : symmetric r) :
 (rel_matrix r R).transpose = rel_matrix r R := by rw [transpose_rel_matrix, h.eq_inv]

theorem traceless_rel_matrix_of_irrefl (h : irreflexive r) :
  matrix.trace α R R (rel_matrix r R) = 0 :=
begin
  simp only [trace_diag, filter_congr_decidable, diag_apply, sum_boole, rel_matrix_apply],
  rw ← nat.cast_zero, congr, rw finset.card_eq_zero, ext, simp [h a],
end

end same_type

namespace simple_graph

section adjacency_matrix

variables (G : simple_graph α) (R)

def adjacency_matrix : matrix α α R := rel_matrix G.adj R

variable {R}

--@[simp] lemma adjacency_matrix_def : G.adjacency_matrix R = rel_matrix G.adj R := rfl

-- bad name
@[simp] lemma adjacency_matrix_val_idem (i j : α) :
 (G.adjacency_matrix R i j) * (G.adjacency_matrix R i j) = G.adjacency_matrix R i j :=
rel_matrix_val_idem i j

theorem transpose_adjacency_matrix : (G.adjacency_matrix R).transpose = (G.adjacency_matrix R) :=
transpose_rel_matrix_eq_of_symmetric G.sym

@[simp]
lemma adjacency_matrix_apply (v w : α) : G.adjacency_matrix R v w = ite (G.adj v w) 1 0 := rfl

@[simp]
lemma adjacency_matrix_dot_product (v : α) (vec : α → R) :
  dot_product (G.adjacency_matrix R v) vec = ∑ u in neighbors G v, vec u :=
rel_matrix_dot_product v vec

@[simp]
lemma dot_product_adjacency_matrix (v : α) (vec : α → R) :
  dot_product vec (G.adjacency_matrix R v) = ∑ u in neighbors G v, vec u :=
dot_product_rel_matrix v vec

@[simp]
lemma adjacency_matrix_mul_apply (M : matrix α α R) (v w : α) :
  (G.adjacency_matrix R * M) v w = ∑ u in neighbors G v, M u w := rel_matrix_mul_apply M v w

@[simp]
lemma mul_adjacency_matrix_apply (M : matrix α α R) (v w : α) :
  (M * G.adjacency_matrix R) v w = ∑ u in neighbors G w, M v u :=
by { unfold neighbors, rw ← G.sym.eq_inv, apply mul_rel_matrix_apply, }

variable (R)
theorem adj_mat_traceless : matrix.trace α R R (G.adjacency_matrix R) = 0 := by simp
variable {R}

theorem adj_mat_sq_apply_eq (i : α) :
  ((G.adjacency_matrix R) * (G.adjacency_matrix R)) i i = degree G i :=
by simp [degree]

variable {G}

lemma adj_mat_mul_const_vec_of_regular {d : ℕ} {r : R} (hd : regular_graph G d) :
  (G.adjacency_matrix R).mul_vec (λ j : α, r) = λ _, d * r :=
by { ext, rw [← hd x, matrix.mul_vec, adjacency_matrix_dot_product]; simp [degree] }

end adjacency_matrix

end simple_graph
