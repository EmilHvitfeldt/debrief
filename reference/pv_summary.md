# Text-based summary of profvis output

Produces a comprehensive text summary of profiling data suitable for
terminal output or AI agent consumption.

## Usage

``` r
pv_summary(x, n_functions = 10, n_lines = 10, n_paths = 5, n_memory = 5)
```

## Arguments

- x:

  A profvis object from
  [`profvis::profvis()`](https://profvis.r-lib.org/reference/profvis.html).

- n_functions:

  Number of top functions to show (default 10).

- n_lines:

  Number of hot source lines to show (default 10).

- n_paths:

  Number of hot paths to show (default 5).

- n_memory:

  Number of memory hotspots to show (default 5).

## Value

Invisibly returns a list containing all computed summaries.

## Examples

``` r
p <- pv_example()
pv_summary(p)
#> ====================================================================== 
#>                           PROFILING SUMMARY
#> ====================================================================== 
#> 
#> Total time: 50 ms (5 samples @ 10 ms interval)
#> Source references: available
#> 
#> 
#> --- TOP FUNCTIONS BY SELF-TIME ---------------------------------------
#>     20 ms ( 40.0%)  deep
#>     10 ms ( 20.0%)  helper
#>     10 ms ( 20.0%)  inner
#>     10 ms ( 20.0%)  outer
#> 
#> --- TOP FUNCTIONS BY TOTAL TIME --------------------------------------
#>     50 ms (100.0%)  outer
#>     30 ms ( 60.0%)  inner
#>     20 ms ( 40.0%)  deep
#>     10 ms ( 20.0%)  helper
#> 
#> --- HOT LINES (by self-time) -----------------------------------------
#>     20 ms ( 40.0%)  R/utils.R:5
#>                    x <- rnorm(1000)
#>     10 ms ( 20.0%)  R/helper.R:20
#>     10 ms ( 20.0%)  R/main.R:10
#>                    result <- deep()
#>     10 ms ( 20.0%)  R/main.R:15
#> 
#> --- HOT CALL PATHS ---------------------------------------------------
#> 
#> 20 ms (40.0%) - 2 samples:
#>     outer (R/main.R:10)
#>   → inner (R/main.R:15)
#>   → deep (R/utils.R:5)
#> 
#> 10 ms (20.0%) - 1 samples:
#>     outer (R/main.R:10)
#> 
#> 10 ms (20.0%) - 1 samples:
#>     outer (R/main.R:10)
#>   → helper (R/helper.R:20)
#> 
#> 10 ms (20.0%) - 1 samples:
#>     outer (R/main.R:10)
#>   → inner (R/main.R:15)
#> 
#> --- MEMORY ALLOCATION (by function) ----------------------------------
#>   150.00 MB inner
#>   100.00 MB deep
#>    50.00 MB helper
#> 
#> --- MEMORY ALLOCATION (by line) --------------------------------------
#>   150.00 MB R/main.R:15
#>   100.00 MB R/utils.R:5
#>             x <- rnorm(1000)
#>    50.00 MB R/helper.R:20
#> ---------------------------------------------------------------------- 
```
