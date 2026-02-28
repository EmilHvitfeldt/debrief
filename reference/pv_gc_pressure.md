# Detect GC pressure

Analyzes the profile to detect excessive garbage collection, which is a
universal indicator of memory allocation issues in R code.

## Usage

``` r
pv_gc_pressure(x, threshold = 10)
```

## Arguments

- x:

  A profvis object.

- threshold:

  Minimum GC percentage to report (default 10). Set lower to detect
  smaller GC overhead.

## Value

A data frame with columns:

- `severity`: "high" (\>25%), "medium" (\>15%), or "low" (\>threshold%)

- `pct`: Percentage of total time spent in GC

- `time_ms`: Time spent in garbage collection

- `issue`: Short description of the problem

- `cause`: What typically causes this issue

- `actions`: Comma-separated list of things to look for

Returns an empty data frame (0 rows) if GC is below the threshold.

## Details

GC pressure above 10% typically indicates the code is allocating and
discarding memory faster than necessary. Common causes include:

- Growing vectors with `c(x, new)` instead of pre-allocation

- Building data frames row-by-row with
  [`rbind()`](https://rdrr.io/r/base/cbind.html)

- Creating unnecessary copies of large objects

- String concatenation in loops

## Examples

``` r
p <- pv_example("gc")
pv_gc_pressure(p)
#>   severity pct time_ms                    issue                       cause
#> 1     high  40      40 High GC overhead (40.0%) Excessive memory allocation
#>                                                        actions
#> 1 growing vectors, repeated data frame ops, unnecessary copies

# More sensitive detection
pv_gc_pressure(p, threshold = 5)
#>   severity pct time_ms                    issue                       cause
#> 1     high  40      40 High GC overhead (40.0%) Excessive memory allocation
#>                                                        actions
#> 1 growing vectors, repeated data frame ops, unnecessary copies

# No GC pressure in default example
p2 <- pv_example()
pv_gc_pressure(p2)
#> [1] severity pct      time_ms  issue    cause    actions 
#> <0 rows> (or 0-length row.names)
```
