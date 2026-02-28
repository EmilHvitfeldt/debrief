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
#>                                                            stack samples
#> 1 outer (R/main.R:10) → inner (R/main.R:15) → deep (R/utils.R:5)       2
#> 2                                            outer (R/main.R:10)       1
#> 3                   outer (R/main.R:10) → helper (R/helper.R:20)       1
#> 4                      outer (R/main.R:10) → inner (R/main.R:15)       1
#>   time_ms pct
#> 1      20  40
#> 2      10  20
#> 3      10  20
#> 4      10  20
```
