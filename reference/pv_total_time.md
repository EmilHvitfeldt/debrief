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
#>    label samples time_ms pct
#> 1  outer       5      50 100
#> 2  inner       3      30  60
#> 3   deep       2      20  40
#> 4 helper       1      10  20

# Only functions with >= 50% total time
pv_total_time(p, min_pct = 50)
#>   label samples time_ms pct
#> 1 outer       5      50 100
#> 2 inner       3      30  60
```
