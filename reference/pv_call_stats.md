# Call statistics summary

Shows call count, total time, self time, and time per call for each
function. This is especially useful for identifying functions that are
called many times (where per-call optimization or reducing call count
would help).

## Usage

``` r
pv_call_stats(x, n = NULL)
```

## Arguments

- x:

  A profvis object.

- n:

  Maximum number of functions to return. If `NULL`, returns all.

## Value

A data frame with columns:

- `label`: Function name

- `calls`: Estimated number of calls (based on stack appearances)

- `total_ms`: Total time on call stack

- `self_ms`: Time at top of stack (self time)

- `child_ms`: Time in callees

- `ms_per_call`: Average milliseconds per call

- `pct`: Percentage of total profile time

## Examples

``` r
p <- pv_example()
pv_call_stats(p)
#>    label calls total_ms self_ms child_ms ms_per_call pct
#> 1  outer     1       50      10       40          50 100
#> 2  inner     2       30      10       20          15  60
#> 3   deep     2       20      20        0          10  40
#> 4 helper     1       10      10        0          10  20
```
