# Get callees of a function

Returns the functions that a specified function calls, based on
profiling data. Shows what the target function invokes.

## Usage

``` r
pv_callees(x, func)
```

## Arguments

- x:

  A profvis object.

- func:

  The function name to analyze.

## Value

A data frame with columns:

- `label`: Callee function name

- `samples`: Number of times this callee appeared

- `pct`: Percentage of calls to this callee

## Examples

``` r
p <- pv_example()
pv_callees(p, "outer")
#>    label samples pct
#> 1  inner       3  60
#> 2 helper       1  20
```
