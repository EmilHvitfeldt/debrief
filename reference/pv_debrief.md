# Comprehensive profiling data

Returns all profiling analysis in a single list for programmatic access.
This is the primary function for AI agents and scripts that need
comprehensive profiling data without printed output.

## Usage

``` r
pv_debrief(x, n = 10)
```

## Arguments

- x:

  A profvis object from
  [`profvis::profvis()`](https://profvis.r-lib.org/reference/profvis.html).

- n:

  Maximum number of items to include in each category (default 10).

## Value

A list containing:

- `total_time_ms`: Total profiling time in milliseconds

- `total_samples`: Number of profiling samples

- `interval_ms`: Sampling interval in milliseconds

- `has_source`: Whether source references are available

- `self_time`: Data frame of functions by self-time

- `total_time`: Data frame of functions by total time

- `hot_lines`: Data frame of hot source lines (or NULL if no source
  refs)

- `hot_paths`: Data frame of hot call paths

- `suggestions`: Data frame of optimization suggestions

- `gc_pressure`: Data frame of GC pressure analysis

- `memory`: Data frame of memory allocation by function

- `memory_lines`: Data frame of memory allocation by line (or NULL)

## Examples

``` r
p <- pv_example()
d <- pv_debrief(p)
names(d)
#>  [1] "total_time_ms" "total_samples" "interval_ms"   "has_source"   
#>  [5] "self_time"     "total_time"    "hot_lines"     "hot_paths"    
#>  [9] "suggestions"   "gc_pressure"   "memory"        "memory_lines" 
d$self_time
#>                              label samples time_ms  pct
#> 1                            rnorm       6      30 42.9
#> 2                 x[i] <- rnorm(1)       4      20 28.6
#> 3                    generate_data       3      15 21.4
#> 4 result[i] <- sqrt(abs(x[i])) * 2       1       5  7.1
```
