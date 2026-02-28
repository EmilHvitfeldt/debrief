# Show source context for a specific location

Displays source code around a specific file and line number with
profiling information for each line.

## Usage

``` r
pv_source_context(x, filename, linenum = NULL, context = 10)
```

## Arguments

- x:

  A profvis object.

- filename:

  The source file to examine.

- linenum:

  The line number to center on. If `NULL`, shows the hottest line in the
  file.

- context:

  Number of lines to show before and after.

## Value

Invisibly returns a data frame with line-by-line profiling data.

## Examples

``` r
p <- pv_example()
pv_source_context(p, "R/main.R", linenum = 10)
#> ====================================================================== 
#>                            SOURCE: R/main.R
#> ====================================================================== 
#> 
#> Lines 1-16 (centered on 10)
#> 
#>   Time   Mem   Line  Source
#> ---------------------------------------------------------------------- 
#>         -     -    1: # Main file
#>         -     -    2: outer <- function() {
#>         -     -    3: 
#>         -     -    4:   x <- 1
#>         -     -    5:   y <- 2
#>         -     -    6:   inner()
#>         -     -    7: }
#>         -     -    8: 
#>         -     -    9: inner <- function() {
#> >>>    50   0.0   10:   result <- deep()
#>         -     -   11:   result
#>         -     -   12: }
#>         -     -   13: 
#>         -     -   14: 
#>        30 150.0   15: 
#>         -     -   16:   z <- heavy_computation()
#> ---------------------------------------------------------------------- 
#> Time in ms, Memory in MB
```
