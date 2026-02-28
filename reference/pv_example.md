# Example profvis data

Creates an example profvis object for use in examples and testing. This
avoids the need to run actual profiling code in examples.

## Usage

``` r
pv_example(type = c("default", "no_source", "recursive", "gc"))
```

## Arguments

- type:

  Type of example data to create:

  - `"default"`: A real profile captured from example code with source
    refs

  - `"no_source"`: A synthetic profile without source references

  - `"recursive"`: A synthetic profile with recursive function calls

  - `"gc"`: A synthetic profile with garbage collection pressure

## Value

A profvis object that can be used with all debrief functions.

## Examples

``` r
# Get default example data
p <- pv_example()
pv_self_time(p)
#>                              label samples time_ms  pct
#> 1                            rnorm       6      30 42.9
#> 2                 x[i] <- rnorm(1)       4      20 28.6
#> 3                    generate_data       3      15 21.4
#> 4 result[i] <- sqrt(abs(x[i])) * 2       1       5  7.1

# Get example with recursive calls
p_recursive <- pv_example("recursive")
pv_recursive(p_recursive)
#>     label max_depth avg_depth recursive_samples total_samples pct_recursive
#> 1 recurse         5         4                 3             3           100
#>   total_ms pct_time
#> 1       30      100
```
