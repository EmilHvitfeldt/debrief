# Export profiling results as a list

Returns all profiling analysis results as a nested R list, useful for
programmatic access to results without JSON serialization.

## Usage

``` r
pv_to_list(
  x,
  include = c("summary", "self_time", "total_time", "hot_lines", "memory", "gc_pressure",
    "suggestions", "recursive"),
  system_info = FALSE
)
```

## Arguments

- x:

  A profvis object.

- include:

  Character vector specifying which analyses to include. Same options as
  [`pv_to_json()`](https://emilhvitfeldt.github.io/debrief/reference/pv_to_json.md).

- system_info:

  If `TRUE`, includes R version and platform info in metadata.

## Value

A named list containing the requested analyses.

## Examples

``` r
p <- pv_example()
results <- pv_to_list(p)
names(results)
#> [1] "metadata"    "summary"     "self_time"   "total_time"  "hot_lines"  
#> [6] "memory"      "gc_pressure" "suggestions" "recursive"  
results$self_time
#>    label samples time_ms pct
#> 1   deep       2      20  40
#> 2 helper       1      10  20
#> 3  inner       1      10  20
#> 4  outer       1      10  20
```
