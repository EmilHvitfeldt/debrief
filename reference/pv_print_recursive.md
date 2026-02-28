# Print recursive functions analysis

Print recursive functions analysis

## Usage

``` r
pv_print_recursive(x)
```

## Arguments

- x:

  A profvis object.

## Value

Invisibly returns the recursive functions data frame.

## Examples

``` r
p <- pv_example("recursive")
pv_print_recursive(p)
#> ====================================================================== 
#>                          RECURSIVE FUNCTIONS
#> ====================================================================== 
#> 
#> Functions that appear multiple times in the same call stack.
#> High recursion depth + high time = optimization opportunity.
#> 
#> Function                       MaxDepth AvgDepth   Total ms      Pct
#> ---------------------------------------------------------------------- 
#> recurse                               5      4.0         30   100.0%
#> 
#> Note: MaxDepth = max times function appears in single stack
```
