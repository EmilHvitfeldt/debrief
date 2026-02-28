# Compare multiple profvis profiles

Compares multiple profiling runs to identify the fastest. Useful for
comparing different optimization approaches.

## Usage

``` r
pv_compare_many(...)
```

## Arguments

- ...:

  Named profvis objects to compare, or a single named list of profvis
  objects.

## Value

A data frame with columns:

- `name`: Profile name

- `time_ms`: Total time in milliseconds

- `samples`: Number of samples

- `vs_fastest`: How much slower than the fastest (e.g., "1.5x")

- `rank`: Rank from fastest (1) to slowest

## Examples

``` r
p1 <- pv_example()
p2 <- pv_example("gc")
p3 <- pv_example("recursive")
pv_compare_many(baseline = p1, gc_heavy = p2, recursive = p3)
#>        name time_ms samples vs_fastest rank
#> 1 recursive      30       3    fastest    1
#> 2  baseline      70      14      2.33x    2
#> 3  gc_heavy     100      10      3.33x    3

# Or pass a named list
profiles <- list(baseline = p1, gc_heavy = p2)
pv_compare_many(profiles)
#>       name time_ms samples vs_fastest rank
#> 1 baseline      70      14    fastest    1
#> 2 gc_heavy     100      10      1.43x    2
```
