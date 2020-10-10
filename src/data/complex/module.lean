/-
Copyright (c) 2020 Alexander Bentkamp, Sébastien Gouëzel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Alexander Bentkamp, Sébastien Gouëzel
-/
import data.complex.basic
import algebra.algebra.basic
import linear_algebra.finite_dimensional

/-!
# Complex number as a vector space over `ℝ`

This file contains three instances:
* `ℂ` is an `ℝ` algebra;
* any complex vector space is a real vector space;
* the space of `ℝ`-linear maps from a real vector space to a complex vector space is a complex
  vector space.

It also defines three linear maps:

* `complex.linear_map.re`;
* `complex.linear_map.im`;
* `complex.linear_map.of_real`.

They are bundled versions of the real part, the imaginary part, and the embedding of `ℝ` in `ℂ`,
as `ℝ`-linear maps.
-/
noncomputable theory

namespace complex

instance algebra_over_reals : algebra ℝ ℂ := (complex.of_real).to_algebra

lemma is_basis_one_I : is_basis ℝ (coe : ({1, I} : set ℂ) → ℂ) :=
begin
  refine ⟨linear_independent_pair one_ne_zero $ λ a, mt (congr_arg im) (by simp [algebra.smul_def]),
    submodule.eq_top_iff'.2 $ λ z, _⟩,
  simp only [subtype.range_coe_subtype, set.set_of_mem_eq, submodule.mem_span_insert,
    exists_prop, submodule.mem_span_singleton],
  refine ⟨z.re, _, ⟨z.im, rfl⟩, _⟩,
  simp [algebra.smul_def]
end

instance : finite_dimensional ℝ ℂ :=
finite_dimensional.of_finite_basis is_basis_one_I $ (set.finite_singleton _).insert _

lemma dim_real_complex : vector_space.dim ℝ ℂ = 2 :=
by rw [← is_basis_one_I.mk_eq_dim'', ← finset.coe_singleton, ← finset.coe_insert,
  ← cardinal.finset_card, finset.card_insert]

end complex

/- Register as an instance (with low priority) the fact that a complex vector space is also a real
vector space. -/
instance module.complex_to_real (E : Type*) [add_comm_group E] [module ℂ E] : module ℝ E :=
semimodule.restrict_scalars' ℝ ℂ E
attribute [instance, priority 900] module.complex_to_real

instance (E : Type*) [add_comm_group E] [module ℝ E]
  (F : Type*) [add_comm_group F] [module ℂ F] : module ℂ (E →ₗ[ℝ] F) :=
linear_map.module_extend_scalars _ _ _ _

instance finite_dimensional.complex_to_real (E : Type*) [add_comm_group E] [module 

namespace complex

/-- Linear map version of the real part function, from `ℂ` to `ℝ`. -/
def linear_map.re : ℂ →ₗ[ℝ] ℝ :=
{ to_fun := λx, x.re,
  map_add' := by simp,
  map_smul' := λc x, by { change ((c : ℂ) * x).re = c * x.re, simp } }

@[simp] lemma linear_map.coe_re : ⇑linear_map.re = re := rfl

/-- Linear map version of the imaginary part function, from `ℂ` to `ℝ`. -/
def linear_map.im : ℂ →ₗ[ℝ] ℝ :=
{ to_fun := λx, x.im,
  map_add' := by simp,
  map_smul' := λc x, by { change ((c : ℂ) * x).im = c * x.im, simp } }

@[simp] lemma linear_map.coe_im : ⇑linear_map.im = im := rfl

/-- Linear map version of the canonical embedding of `ℝ` in `ℂ`. -/
def linear_map.of_real : ℝ →ₗ[ℝ] ℂ :=
{ to_fun := coe,
  map_add' := by simp,
  map_smul' := λc x, by { simp, refl } }

@[simp] lemma linear_map.coe_of_real : ⇑linear_map.of_real = coe := rfl

end complex
