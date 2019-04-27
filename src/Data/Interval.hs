module Data.Interval
    ( Interval (..)
    , single
    , elements
    , contains
    ) where

import Data.List (nub)

-- | Represents either a single interval or a combination of multiple.
-- | Intervals could be combined in various ways, for example intersection
-- | or union.
-- | A given value is a member of the interval if it is between the lower and
-- | upper bounds (inclusive).
data Interval a
    = All
    | a :-> a
    | Above a
    | Below a
    | Intersect (Interval a) (Interval a)
    | Union (Interval a) (Interval a)
    | Difference (Interval a) (Interval a)
    | Complement (Interval a)
    deriving Eq

instance (Enum a, Show a) => Show (Interval a) where
    show All = "[..]"
    show (low :-> high) = "[" ++ show low ++ "," ++ show high ++ "]"
    show (Above low) = "[" ++ show low ++ "," ++ show (succ low) ++ "..]"
    show (Below high) = "[.." ++ show (pred high) ++ "," ++ show high ++ "]"
    show (Intersect a b) = "(" ++ show a ++ " ∩ " ++ show b ++ ")"
    show (Union a b) = "(" ++ show a ++ " ∪ " ++ show b ++ ")"
    show (Difference a b) = "(" ++ show a ++ " \\ " ++ show b ++ ")"
    show (Complement All) = "[]"
    show (Complement a) = "(except " ++ show a ++ ")"

instance Semigroup (Interval a) where
    (<>) = Union

instance Monoid (Interval a) where
    mempty = Complement All

-- | Returns an interval containing just one element.
single :: a -> Interval a
single x = x :-> x

-- | Returns a list of all of the values contained inside the interval, under certain
-- | conditions. Namely, *all* of the elements cannot be retrieved if:
-- |   --> The interval is an All or Complement type
-- |   --> The interval contains a real-valued type, such as Double. This is because there
-- |        are an infinite number of values in any non-empty interval and so they can't all
-- |        all be listed. However, values which are an integer distance away from one end
-- |        of the interval will be listed.
-- | Therefore, this function is partial - use with caution.
elements :: (Ord a, Enum a) => Interval a -> [a]
elements All = error "cannot get all elements of All, since there's no reasonable place to begin counting in general."
elements (low :-> high) = [low..high]
elements (Above low) = [low..]
elements (Below high) = high : elements (Below (pred high))
elements (Intersect a b) = [ x | x <- elements a, b `contains` x ]
elements (Union a b) = nub $ elements a ++ elements b
elements (Difference a b) = [ x | x <- elements a, not (b `contains` x) ]
elements (Complement All) = []
elements (Complement a) = error "cannot get all elements of Complement, since there's reasonable place to begin counting in general"

-- | Returns True if the given value is contained inside the interval.
-- | O(n) where n is the nesting-depth of the interval, for example (1 :-> 10) will have
-- | n = 1 and Intersect (Above 5) (Below 10) has n = 3.
contains :: (Ord a) => Interval a -> a -> Bool
contains All _ = True
contains (low :-> high) x = x >= low && x <= high
contains (Above low) x = x >= low
contains (Below high) x = x <= high
contains (Intersect a b) x = a `contains` x && b `contains` x
contains (Union a b) x = a `contains` x || b `contains` x
contains (Difference a b) x = a `contains` x && (Complement b) `contains` x
contains (Complement a) x = not (a `contains` x)