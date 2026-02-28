# Detect recursive functions

Identifies functions that call themselves (directly recursive) or appear
multiple times in the same call stack. Recursive functions in hot paths
are often optimization targets.

## Usage

``` r
pv_recursive(x)
```

## Arguments

- x:

  A profvis object.

## Value

A data frame with columns:

- `label`: Function name

- `max_depth`: Maximum recursion depth observed

- `avg_depth`: Average recursion depth when recursive

- `recursive_samples`: Number of samples where function appears multiple
  times

- `total_samples`: Total samples where function appears

- `pct_recursive`: Percentage of appearances that are recursive

- `total_ms`: Total time on call stack

- `pct_time`: Percentage of total profile time

## Examples

``` r
p <- pv_example("recursive")
pv_recursive(p)
#>     label max_depth avg_depth recursive_samples total_samples pct_recursive
#> 1 recurse         5         4                 3             3           100
#>   total_ms pct_time
#> 1       30      100
```
