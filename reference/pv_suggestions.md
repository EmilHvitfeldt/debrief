# Generate optimization suggestions

Analyzes the profile and generates specific, actionable optimization
suggestions based on detected patterns and hotspots.

## Usage

``` r
pv_suggestions(x)
```

## Arguments

- x:

  A profvis object.

## Value

A data frame with columns:

- `priority`: 1 (highest) to 5 (lowest)

- `category`: Type of optimization (e.g., "data structure", "algorithm")

- `suggestion`: The optimization suggestion

- `location`: Where to apply the optimization

- `potential_impact`: Estimated time that could be saved

## Examples

``` r
p <- pv_example("gc")
pv_suggestions(p)
#>   priority     category
#> 1        1     hot line
#> 2        2       memory
#> 3        2 hot function
#>                                                                                                                                                                               suggestion
#> 1                                                                                               Line 'work' at R/work.R:5 consumes 60.0% of time. Focus optimization efforts here first.
#> 2 High GC overhead detected. Pre-allocate vectors/lists to final size instead of growing them. Avoid creating unnecessary intermediate objects. Consider reusing objects where possible.
#> 3                                                            Function 'work' has highest self-time (60.0%). Profile this function in isolation to find micro-optimization opportunities.
#>                     location  potential_impact
#> 1                 R/work.R:5     60 ms (60.0%)
#> 2 memory allocation hotspots Up to 20 ms (20%)
#> 3                       work     60 ms (60.0%)
```
