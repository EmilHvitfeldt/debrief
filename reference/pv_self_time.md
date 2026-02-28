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
#>    label samples time_ms pct
#> 1   deep       2      20  40
#> 2 helper       1      10  20
#> 3  inner       1      10  20
#> 4  outer       1      10  20

# Only functions with >= 5% self-time
pv_self_time(p, min_pct = 5)
#>    label samples time_ms pct
#> 1   deep       2      20  40
#> 2 helper       1      10  20
#> 3  inner       1      10  20
#> 4  outer       1      10  20
```
