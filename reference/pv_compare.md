# Compare two profvis profiles

Compares two profiling runs to show what changed. Useful for measuring
the impact of optimizations.

## Usage

``` r
pv_compare(before, after, n = 20)
```

## Arguments

- before:

  A profvis object (before optimization).

- after:

  A profvis object (after optimization).

- n:

  Number of top functions to compare.

## Value

A list with:

- `summary`: Overall comparison summary

- `by_function`: Function-by-function comparison

- `improved`: Functions that got faster

- `regressed`: Functions that got slower

## Examples

``` r
p1 <- pv_example()
p2 <- pv_example()
pv_compare(p1, p2)
#> $summary
#>            metric before after        change
#> 1 Total time (ms)     50    50 +0 ms (+0.0%)
#> 2         Samples      5     5            +0
#> 3         Speedup      1     1         1.00x
#> 
#> $by_function
#>    label before_ms after_ms diff_ms pct_change
#> 1   deep        20       20       0          0
#> 2 helper        10       10       0          0
#> 3  inner        10       10       0          0
#> 4  outer        10       10       0          0
#> 
#> $improved
#> [1] label      before_ms  after_ms   diff_ms    pct_change
#> <0 rows> (or 0-length row.names)
#> 
#> $regressed
#> [1] label      before_ms  after_ms   diff_ms    pct_change
#> <0 rows> (or 0-length row.names)
#> 
```
