# Print caller/callee analysis for a function

Shows both callers (who calls this function) and callees (what this
function calls) in a single view.

## Usage

``` r
pv_print_callers_callees(x, func, n = 10)
```

## Arguments

- x:

  A profvis object.

- func:

  The function name to analyze.

- n:

  Maximum number of callers/callees to show.

## Value

Invisibly returns a list with `callers` and `callees` data frames.

## Examples

``` r
p <- pv_example()
pv_print_callers_callees(p, "inner")
#> ====================================================================== 
#>                        FUNCTION ANALYSIS: inner
#> ====================================================================== 
#> 
#> Total time: 30 ms (60.0% of profile)
#> Appearances: 3 samples
#> 
#> --- Called by --------------------------------------------------
#>       3 samples (100.0%)  outer
#> 
#> --- Calls to ---------------------------------------------------
#>       2 samples ( 66.7%)  deep
#> 
```
