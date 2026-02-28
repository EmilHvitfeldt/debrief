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
#>   depth samples time_ms   pct
#> 1     1      14      70 100.0
#> 2     2      14      70 100.0
#> 3     3      11      55  78.6
#>                                                   top_funcs
#> 1                                              process_data
#> 2                             generate_data, transform_data
#> 3 rnorm, x[i] <- rnorm(1), result[i] <- sqrt(abs(x[i])) * 2
```
