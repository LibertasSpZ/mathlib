/-
Copyright (c) 2020 Simon Hudon. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Author: Simon Hudon
-/

import order.omega_complete_partial_order
import order.category.Preorder
import category_theory.limits.shapes.products
import category_theory.limits.shapes.equalizers
import category_theory.limits.shapes.constructions.limits_of_products_and_equalizers

/-!
# Category of types with a omega complete partial order

In this file, we bundle the class `omega_complete_partial_order` into a
concrete category and prove that continuous functions also form
a `omega_complete_partial_order`.

## Main definitions

 * `ωCPO`
   * an instance of `category` and `concrete_category`

 -/

open category_theory

universes u v

/-- The category of types with a omega complete partial order. -/
def ωCPO : Type (u+1) := bundled omega_complete_partial_order

namespace ωCPO

open omega_complete_partial_order

instance : bundled_hom @continuous_hom :=
{ to_fun := @continuous_hom.to_fun,
  id := @continuous_hom.id,
  comp := @continuous_hom.comp,
  hom_ext := @continuous_hom.coe_inj }

attribute [derive [has_coe_to_sort, large_category, concrete_category]] ωCPO

/-- Construct a bundled ωCPO from the underlying type and typeclass. -/
def of (α : Type*) [omega_complete_partial_order α] : ωCPO := bundled.of α

instance : inhabited ωCPO := ⟨of punit⟩

instance (α : ωCPO) : omega_complete_partial_order α := α.str

section

open category_theory.limits

def make_product {J : Type v} (f : J → ωCPO.{v}) : fan f :=
@fan.mk _ _ _ _ (of (Π j, f j))
begin
  intro j,
  exact continuous_hom.of_mono (pi.monotone_apply j) (λ c, rfl),
end

def is_prod (J : Type v) (f : J → ωCPO) : is_limit (make_product f) :=
{ lift := λ s,
  begin
    refine ⟨λ t j, s.π.app j t, λ x y h j, (s.π.app j).monotone h, λ x, funext (λ j, (s.π.app j).continuous x)⟩,
  end,
  uniq' := λ s m w,
  begin
    ext t j,
    change m t j = s.π.app j t,
    rw ← w j,
    refl,
  end }.

instance has_prod (J : Type v) (f : J → ωCPO.{v}) : has_product f :=
has_limit.mk ⟨_, is_prod _ f⟩

instance : has_products ωCPO.{v} :=
λ J, { has_limit := λ F, has_limit_of_iso discrete.nat_iso_functor.symm }

def subtype_monotone {α : Type*} [preorder α] (p : α → Prop) :
  subtype p →ₘ α :=
{ to_fun := λ x, x.1, monotone' := λ x y h, h }

def subtype_order {α : Type*} [omega_complete_partial_order α] (p : α → Prop)
  (hp : ∀ (c : chain α), (∀ i ∈ c, p i) → p (ωSup c)) :
  omega_complete_partial_order (subtype p) :=
omega_complete_partial_order.lift
  (subtype_monotone p)
  (λ c, ⟨ωSup _, hp (c.map (subtype_monotone p)) (λ i ⟨n, q⟩, q.symm ▸ (c n).2)⟩)
  (λ x y h, h)
  (λ c, rfl)

instance kernel_cpo {α β : Type*} [omega_complete_partial_order α] [omega_complete_partial_order β]
  (f g : α →𝒄 β) : omega_complete_partial_order {a : α // f a = g a} :=
subtype_order _ $ λ c hc,
begin
  rw [f.continuous, g.continuous],
  congr' 1,
  apply preorder_hom.ext,
  intro a,
  apply hc _ ⟨_, rfl⟩,
end

def include_kernel {α β : Type*} [omega_complete_partial_order α] [omega_complete_partial_order β]
  (f g : α →𝒄 β) :
  {a : α // f a = g a} →𝒄 α :=
continuous_hom.of_mono (subtype_monotone _) (λ c, rfl)

def make_equalizer {X Y : ωCPO.{v}} (f g : X ⟶ Y) :
  fork f g :=
@fork.of_ι _ _ _ _ _ _ (ωCPO.of {a // f a = g a}) (include_kernel f g) (continuous_hom.ext _ _ (λ x, x.2))

def is_equalizer {X Y : ωCPO.{v}} (f g : X ⟶ Y) : is_limit (make_equalizer f g) :=
fork.is_limit.mk' _ $ λ s,
⟨{ to_fun := λ x, ⟨s.ι x, by { apply congr_fun (congr_arg continuous_hom.to_fun s.condition : _ = _) }⟩,
    monotone' := λ x y h, s.ι.monotone h,
    cont := λ x, subtype.ext (s.ι.continuous x) },
  by { ext, refl },
  λ m hm,
  begin
    ext,
    apply congr_fun (congr_arg continuous_hom.to_fun hm : _ = _),
  end⟩

instance has_eq : has_equalizers ωCPO.{v} :=
@has_equalizers_of_has_limit_parallel_pair _ _ $
λ X Y f g, has_limit.mk ⟨make_equalizer f g, is_equalizer f g⟩

instance : has_limits ωCPO.{v} := limits_from_equalizers_and_products

end


end ωCPO
