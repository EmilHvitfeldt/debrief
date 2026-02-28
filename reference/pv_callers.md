# Get callers of a function

Returns the functions that call a specified function, based on profiling
data. Shows who invokes the target function.

## Usage

``` r
pv_callers(x, func)
```

## Arguments

- x:

  A profvis object.

- func:

  The function name to analyze.

## Value

A data frame with columns:

- `label`: Caller function name

- `samples`: Number of times this caller appeared

- `pct`: Percentage of calls from this caller

## Examples

``` r
p <- pv_example()
pv_callers(p, "inner")
#> Function 'inner' not found in profiling data.
#> [1] label   samples pct    
#> <0 rows> (or 0-length row.names)
```
