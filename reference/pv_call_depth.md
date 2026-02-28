# Call depth breakdown

Shows time distribution across different call stack depths. Useful for
understanding how deeply nested the hot code paths are.

## Usage

``` r
pv_call_depth(x)
```

## Arguments

- x:

  A profvis object.

## Value

A data frame with columns:

- `depth`: Call stack depth (1 = top level)

- `samples`: Number of profiling samples at this depth

- `time_ms`: Time in milliseconds

- `pct`: Percentage of total time

- `top_funcs`: Most common functions at this depth

## Examples

``` r
p <- pv_example()
pv_call_depth(p)
#>   depth samples time_ms pct     top_funcs
#> 1     1       5      50 100         outer
#> 2     2       4      40  80 inner, helper
#> 3     3       2      20  40          deep
```
