module HMTS.Prelude where

open import Level
open import Function
open import Relation.Nullary
open import Relation.Nullary.Decidable
open import Relation.Binary.PropositionalEquality
open import Data.Bool
open import Data.Nat   as Nat
open import Data.Fin
open import Data.Unit
open import Data.Maybe as Maybe
open import Data.Product
open import Data.List  as List
open import Data.Vec   as Vec hiding (lookup; _∈_; module _∈_)
open import Category.Monad
open RawMonad  {{...}} public hiding (pure)

infix 4 _∈_

-- I imported this from `Data.List.Any' first,
-- but it's less cumbersome to just redefine.
data _∈_ {α} {A : Set α} (x : A) : List A -> Set α where
  vz  : ∀     {xs} -> x ∈ x ∷ xs 
  vs_ : ∀ {y} {xs} -> x ∈ xs -> x ∈ y ∷ xs

instance
  Maybe-monad : ∀ {ℓ} -> RawMonad {ℓ} Maybe
  Maybe-monad = Maybe.monad

_==_ : ℕ -> ℕ -> Bool
n == m = ⌊ n Nat.≟ m ⌋

_∈?_ : ℕ -> List ℕ -> Bool
n ∈? ns = List.any (_==_ n) ns

lookup : ∀ {α} {A : Set α} -> ℕ -> List (ℕ × A) -> Maybe A
lookup n  []            = nothing
lookup n ((m , x) ∷ xs) = if n == m then just x else lookup n xs

delete : ℕ -> List ℕ -> List ℕ
delete n  []      = []
delete n (m ∷ ms) = if n == m then ms else m ∷ delete n ms 

union : List ℕ -> List ℕ -> List ℕ
union ns ms = ns List.++ List.foldr delete ms ns

lookup-in : ∀ {α n} {A : Set α} i -> (xs : Vec A n) -> Vec.lookup i xs ∈ toList xs
lookup-in  zero   (x ∷ xs) = vz
lookup-in (suc i) (x ∷ xs) = vs (lookup-in i xs) 

_>>=ᵀ_ : ∀ {α} {A : Set α} {b : A -> Level}
       -> (mx : Maybe A) -> (B : ∀ x -> Set (b x)) -> Set (maybe b Level.zero mx)
nothing >>=ᵀ B = ⊤
just x  >>=ᵀ B = B x

_>>=⊤_ : ∀ {α} {A : Set α} {b : A -> Level} {B : ∀ x -> Set (b x)}
       -> (mx : Maybe A) -> (∀ x -> B x) -> mx >>=ᵀ B
nothing >>=⊤ f = _
just x  >>=⊤ f = f x

next : ℕ -> ℕ
next = Nat.suc
