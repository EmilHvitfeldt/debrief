# File-level time summary

Aggregates profiling time by source file. Requires source references
(use `devtools::load_all()` for best results).

## Usage

``` r
pv_file_summary(x)
```

## Arguments

- x:

  A profvis object.

## Value

A data frame with columns:

- `filename`: Source file path

- `samples`: Number of profiling samples

- `time_ms`: Time in milliseconds

- `pct`: Percentage of total time

## Examples

``` r
p <- pv_example()
pv_file_summary(p)
#>     filename samples time_ms pct
#> 1   R/main.R       5      50 100
#> 2  R/utils.R       2      20  40
#> 3 R/helper.R       1      10  20
```
