# Print call depth breakdown

Print call depth breakdown

## Usage

``` r
pv_print_call_depth(x)
```

## Arguments

- x:

  A profvis object.

## Value

Invisibly returns the call depth data frame.

## Examples

``` r
p <- pv_example()
pv_print_call_depth(p)
#> ====================================================================== 
#>                          CALL DEPTH BREAKDOWN
#> ====================================================================== 
#> 
#> Depth  Time (ms)   Pct   Top functions
#> ---------------------------------------------------------------------- 
#>     1        50  100.0%  outer
#>     2        40   80.0%  inner, helper
#>     3        20   40.0%  deep
```
