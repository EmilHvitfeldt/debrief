# Print hot paths in readable format

Print hot paths in readable format

## Usage

``` r
pv_print_hot_paths(x, n = 10, include_source = TRUE)
```

## Arguments

- x:

  A profvis object.

- n:

  Number of paths to show.

- include_source:

  Include source references in output.

## Value

Invisibly returns the hot paths data frame.

## Examples

``` r
p <- pv_example()
pv_print_hot_paths(p, n = 3)
#> ====================================================================== 
#>                             HOT CALL PATHS
#> ====================================================================== 
#> 
#> Rank 1: 20 ms (40.0%) - 2 samples
#>     outer (R/main.R:10)
#>   → inner (R/main.R:15)
#>   → deep (R/utils.R:5)
#> 
#> Rank 2: 10 ms (20.0%) - 1 samples
#>     outer (R/main.R:10)
#> 
#> Rank 3: 10 ms (20.0%) - 1 samples
#>     outer (R/main.R:10)
#>   → helper (R/helper.R:20)
#> 
```
