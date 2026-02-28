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
#>                              label calls total_ms self_ms child_ms ms_per_call
#> 1                     process_data     1       70       0       70        70.0
#> 2                    generate_data     2       65      15       50        32.5
#> 3                            rnorm     4       30      30        0         7.5
#> 4                 x[i] <- rnorm(1)     4       20      20        0         5.0
#> 5 result[i] <- sqrt(abs(x[i])) * 2     1        5       5        0         5.0
#> 6                   transform_data     1        5       0        5         5.0
#>     pct
#> 1 100.0
#> 2  92.9
#> 3  42.9
#> 4  28.6
#> 5   7.1
#> 6   7.1
```
