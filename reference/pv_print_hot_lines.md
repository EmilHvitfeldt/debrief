# Print hot lines with source context

Prints the hot source lines along with surrounding code context.

## Usage

``` r
pv_print_hot_lines(x, n = 5, context = 3)
```

## Arguments

- x:

  A profvis object.

- n:

  Number of hot lines to show.

- context:

  Number of lines to show before and after each hotspot.

## Value

Invisibly returns the hot lines data frame.

## Examples

``` r
p <- pv_example()
pv_print_hot_lines(p, n = 5, context = 3)
#> ====================================================================== 
#>                            HOT SOURCE LINES
#> ====================================================================== 
#> 
#> Rank 1: R/utils.R:5 (20 ms, 40.0%)
#> Function: deep
#> 
#>         2: deep <- function() {
#>         3:   Sys.sleep(0.01)
#>         4:   42
#>  >>>    5:   x <- rnorm(1000)
#>         6: }
#> 
#> Rank 2: R/helper.R:20 (10 ms, 20.0%)
#> Function: helper
#> 
#>        17: 
#>        18: 
#>        19: 
#>  >>>   20: 
#>        21:   do_work()
#> 
#> Rank 3: R/main.R:10 (10 ms, 20.0%)
#> Function: outer
#> 
#>         7: }
#>         8: 
#>         9: inner <- function() {
#>  >>>   10:   result <- deep()
#>        11:   result
#>        12: }
#>        13: 
#> 
#> Rank 4: R/main.R:15 (10 ms, 20.0%)
#> Function: inner
#> 
#>        12: }
#>        13: 
#>        14: 
#>  >>>   15: 
#>        16:   z <- heavy_computation()
#> 
```
