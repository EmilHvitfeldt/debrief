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
#> ## OPTIMIZATION SUGGESTIONS
#> 
#> 
#> ### Priority 1
#> 
#> category: hot line
#> location: R/work.R:5
#> action: Optimize hot line (60.0%)
#> pattern: work
#> potential_impact: 60 ms (60.0%)
#> 
#> ### Priority 2
#> 
#> category: memory
#> location: memory allocation hotspots
#> action: Reduce memory allocation
#> pattern: c(x, new), rbind(), growing vectors
#> replacement: pre-allocate to final size
#> potential_impact: Up to 20 ms (20%)
#> 
#> category: hot function
#> location: work
#> action: Profile in isolation (60.0% self-time)
#> pattern: work
#> potential_impact: 60 ms (60.0%)
#> 
#> 
#> ### Next steps
#> pv_hot_lines(p)
#> pv_gc_pressure(p)
```
