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

- `location`: Where to apply the optimization

- `action`: What to do

- `pattern`: Code pattern to look for (or NA)

- `replacement`: Suggested replacement (or NA)

- `potential_impact`: Estimated time that could be saved

## Examples

``` r
p <- pv_example("gc")
pv_suggestions(p)
#>   priority     category                   location
#> 1        1     hot line                 R/work.R:5
#> 2        2       memory memory allocation hotspots
#> 3        2 hot function                       work
#>                                   action                             pattern
#> 1              Optimize hot line (60.0%)                                work
#> 2               Reduce memory allocation c(x, new), rbind(), growing vectors
#> 3 Profile in isolation (60.0% self-time)                                work
#>                  replacement  potential_impact
#> 1                       <NA>     60 ms (60.0%)
#> 2 pre-allocate to final size Up to 20 ms (20%)
#> 3                       <NA>     60 ms (60.0%)
```
