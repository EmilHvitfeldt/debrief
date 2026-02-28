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

  - `"default"`: A typical profile with multiple functions and source
    refs

  - `"no_source"`: A profile without source references

  - `"recursive"`: A profile with recursive function calls

  - `"gc"`: A profile with garbage collection pressure

## Value

A profvis object that can be used with all debrief functions.

## Examples

``` r
# Get default example data
p <- pv_example()
pv_self_time(p)
#>    label samples time_ms pct
#> 1   deep       2      20  40
#> 2 helper       1      10  20
#> 3  inner       1      10  20
#> 4  outer       1      10  20

# Get example with recursive calls
p_recursive <- pv_example("recursive")
pv_recursive(p_recursive)
#>     label max_depth avg_depth recursive_samples total_samples pct_recursive
#> 1 recurse         5         4                 3             3           100
#>   total_ms pct_time
#> 1       30      100
```
