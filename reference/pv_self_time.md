# Self-time summary by function

Returns the time spent directly in each function (at the top of the call
stack). This shows where CPU cycles are actually being consumed.

## Usage

``` r
pv_self_time(x, n = NULL, min_pct = 0, min_time_ms = 0)
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

- `samples`: Number of profiling samples

- `time_ms`: Time in milliseconds

- `pct`: Percentage of total time

## Examples

``` r
p <- pv_example()
pv_self_time(p)
#>                              label samples time_ms  pct
#> 1                            rnorm       6      30 42.9
#> 2                 x[i] <- rnorm(1)       4      20 28.6
#> 3                    generate_data       3      15 21.4
#> 4 result[i] <- sqrt(abs(x[i])) * 2       1       5  7.1

# Only functions with >= 5% self-time
pv_self_time(p, min_pct = 5)
#>                              label samples time_ms  pct
#> 1                            rnorm       6      30 42.9
#> 2                 x[i] <- rnorm(1)       4      20 28.6
#> 3                    generate_data       3      15 21.4
#> 4 result[i] <- sqrt(abs(x[i])) * 2       1       5  7.1
```
