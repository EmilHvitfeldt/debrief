# Focused analysis of a specific function

Provides a comprehensive analysis of a single function including time
breakdown, callers, callees, and source context if available.

## Usage

``` r
pv_focus(x, func, context = 5)
```

## Arguments

- x:

  A profvis object.

- func:

  The function name to analyze.

- context:

  Number of source lines to show around hotspots.

## Value

Invisibly returns a list with all analysis components.

## Examples

``` r
p <- pv_example()
pv_focus(p, "inner")
#> ====================================================================== 
#>                              FOCUS: inner
#> ====================================================================== 
#> 
#> --- Time Analysis ---------------------------------------------------
#>   Total time:       30 ms ( 60.0%)  - time on call stack
#>   Self time:        10 ms ( 20.0%)  - time at top of stack
#>   Child time:       20 ms ( 40.0%)  - time in callees
#>   Appearances:       3 samples
#> 
#> --- Called By -------------------------------------------------------
#>       3 calls (100.0%)  outer
#> 
#> --- Calls To --------------------------------------------------------
#>       2 calls ( 66.7%)  deep
#> 
#> --- Source Locations ------------------------------------------------
#> Hot lines (by self-time):
#>      10 ms (20.0%)  R/main.R:15
#> 
#> --- Source Context: R/main.R -----------------------------------------
#>        10:   result <- deep()
#>        11:   result
#>        12: }
#>        13: 
#>        14: 
#>  >>>   15: 
#>        16:   z <- heavy_computation()
#> 
#> ----------------------------------------------------------------------
```
