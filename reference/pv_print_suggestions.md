# Print optimization suggestions

Print optimization suggestions

## Usage

``` r
pv_print_suggestions(x)
```

## Arguments

- x:

  A profvis object.

## Value

Invisibly returns the suggestions data frame.

## Examples

``` r
p <- pv_example("gc")
pv_print_suggestions(p)
#> ====================================================================== 
#>                        OPTIMIZATION SUGGESTIONS
#> ====================================================================== 
#> 
#> Suggestions are ordered by priority (1 = highest impact).
#> 
#> === Priority 1 ===
#> 
#> [hot line] R/work.R:5
#>     Line 'work' at R/work.R:5 consumes 60.0% of time. Focus optimization efforts here first.
#>     Potential impact: 60 ms (60.0%)
#> 
#> === Priority 2 ===
#> 
#> [memory] memory allocation hotspots
#>     High GC overhead detected. Pre-allocate vectors/lists to final size instead of growing them. Avoid creating unnecessary intermediate objects. Consider reusing objects where possible.
#>     Potential impact: Up to 20 ms (20%)
#> 
#> [hot function] work
#>     Function 'work' has highest self-time (60.0%). Profile this function in isolation to find micro-optimization opportunities.
#>     Potential impact: 60 ms (60.0%)
#> 
```
