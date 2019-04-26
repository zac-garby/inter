# inter

A library for working with intervals in Haskell. Features include:

 - Various interval types:
     - Bounded on both sides (e.g. `[1,10]`)
     - Bounded on one side (e.g. `[1,2..]`, `[..,10,11]`)
     - Unbounded (e.g. `[..]`)
 - Various interval operations:
     - Intersection
     - Union
     - Difference
     - Complement
 - Efficient storage:
     - `[1,1000000000]` uses as much memory as `[1,5]`, only end-points are stored.
 - Useful functions:
     - Get all values which are inside an interval
     - Check if a value is inside an interval. O(n), where n is the depth of the interval (n is _not_ the number of elements in the interval, but put simply the amount of nesting of interval operations). Will be O(1) in the majority of uses.

```
Data.Interval> 1 :-> 10
[1,10]

Data.Interval> (1 :-> 5) `Intersect` (3 :-> 10)
([1,5] ∩ [3,10])

Data.Interval> Above 0
[0,1..]

Data.Interval> elements $ (1 :-> 5) `Intersect` (3 :-> 10)
[3, 4, 5]

Data.Interval> Above 100 `contains` 1e+100
True
```