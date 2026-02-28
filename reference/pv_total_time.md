# Total time summary by function

Returns the time spent in each function including all its callees. This
shows which functions are on the call stack when time is being spent.

## Usage

``` r
pv_total_time(x, n = NULL, min_pct = 0, min_time_ms = 0)
```

## Arguments

- x:

  A profvis object.

- n:

  Maximum number of functions to return. If `NULL`, returns all that
  pass the filters.

- min_pct:

  Minimum percentage of total time to include (default 0).

- min_time_ms:

  Minimum time in milliseconds to include (default 0).

## Value

A data frame with columns:

- `label`: Function name

- `samples`: Number of profiling samples where function appeared

- `time_ms`: Time in milliseconds

- `pct`: Percentage of total time

## Examples

``` r
p <- pv_example()
pv_total_time(p)
#>                              label samples time_ms   pct
#> 1                     process_data      14      70 100.0
#> 2                    generate_data      13      65  92.9
#> 3                            rnorm       6      30  42.9
#> 4                 x[i] <- rnorm(1)       4      20  28.6
#> 5 result[i] <- sqrt(abs(x[i])) * 2       1       5   7.1
#> 6                   transform_data       1       5   7.1

# Only functions with >= 50% total time
pv_total_time(p, min_pct = 50)
#>           label samples time_ms   pct
#> 1  process_data      14      70 100.0
#> 2 generate_data      13      65  92.9
```
