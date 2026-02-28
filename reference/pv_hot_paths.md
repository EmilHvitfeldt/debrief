# Hot call paths

Returns the most common complete call stacks. This shows which execution
paths through the code consume the most time.

## Usage

``` r
pv_hot_paths(x, n = NULL, include_source = TRUE)
```

## Arguments

- x:

  A profvis object.

- n:

  Maximum number of paths to return. If `NULL`, returns all.

- include_source:

  If `TRUE` and source references are available, include file:line
  information in the path labels.

## Value

A data frame with columns:

- `stack`: The call path (functions separated by arrows)

- `samples`: Number of profiling samples with this exact path

- `time_ms`: Time in milliseconds

- `pct`: Percentage of total time

## Examples

``` r
p <- pv_example()
pv_hot_paths(p)
#>                                                                                                     stack
#> 1                             process_data → generate_data (example_code.R:5) → rnorm (example_code.R:13)
#> 2                  process_data → generate_data (example_code.R:5) → x[i] <- rnorm(1) (example_code.R:13)
#> 3                                                         process_data → generate_data (example_code.R:5)
#> 4 process_data → transform_data (example_code.R:6) → result[i] <- sqrt(abs(x[i])) * 2 (example_code.R:21)
#>   samples time_ms  pct
#> 1       6      30 42.9
#> 2       4      20 28.6
#> 3       3      15 21.4
#> 4       1       5  7.1
```
