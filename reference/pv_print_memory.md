# Print memory allocation summary

Print memory allocation summary

## Usage

``` r
pv_print_memory(x, n = 10, by = c("function", "line"))
```

## Arguments

- x:

  A profvis object.

- n:

  Number of top allocators to show.

- by:

  Either "function" or "line".

## Value

Invisibly returns the memory data frame.

## Examples

``` r
p <- pv_example()
pv_print_memory(p, by = "function")
#> ====================================================================== 
#>                     MEMORY ALLOCATION BY FUNCTION
#> ====================================================================== 
#> 
#>   150.00 MB inner
#>   100.00 MB deep
#>    50.00 MB helper
pv_print_memory(p, by = "line")
#> ====================================================================== 
#>                       MEMORY ALLOCATION BY LINE
#> ====================================================================== 
#> 
#>   150.00 MB R/main.R:15
#>   100.00 MB R/utils.R:5
#>             x <- rnorm(1000)
#>    50.00 MB R/helper.R:20
```
