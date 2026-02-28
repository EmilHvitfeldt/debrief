# Focused analysis of a specific function

Provides a comprehensive analysis of a single function including time
breakdown, callers, callees, and source context if available.

## Usage

``` r
pv_focus(x, func, context = 5)
```

## Arguments

- x:

  A profvis object.

- func:

  The function name to analyze.

- context:

  Number of source lines to show around hotspots.

## Value

Invisibly returns a list with all analysis components.

## Examples

``` r
p <- pv_example()
pv_focus(p, "inner")
#> Function 'inner' not found in profiling data.
#> 
#> Available functions (top 20 by time):
#>   process_data
#>   generate_data
#>   rnorm
#>   x[i] <- rnorm(1)
#>   result[i] <- sqrt(abs(x[i])) * 2
#>   transform_data
```
