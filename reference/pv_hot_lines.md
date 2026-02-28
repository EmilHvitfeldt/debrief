# Hot source lines by self-time

Returns the source lines where the most CPU time is spent. Requires
source references (use `devtools::load_all()` for best results).

## Usage

``` r
pv_hot_lines(x, n = NULL, min_pct = 0, min_time_ms = 0)
```

## Arguments

- x:

  A profvis object.

- n:

  Maximum number of lines to return. If `NULL`, returns all that pass
  the filters.

- min_pct:

  Minimum percentage of total time to include (default 0).

- min_time_ms:

  Minimum time in milliseconds to include (default 0).

## Value

A data frame with columns:

- `location`: File path and line number (e.g., "R/foo.R:42")

- `label`: Function name at this location

- `filename`: Source file path

- `linenum`: Line number

- `samples`: Number of profiling samples

- `time_ms`: Time in milliseconds

- `pct`: Percentage of total time

## Examples

``` r
p <- pv_example()
pv_hot_lines(p)
#>        location samples  label   filename linenum time_ms pct
#> 1   R/utils.R:5       2   deep  R/utils.R       5      20  40
#> 2 R/helper.R:20       1 helper R/helper.R      20      10  20
#> 3   R/main.R:10       1  outer   R/main.R      10      10  20
#> 4   R/main.R:15       1  inner   R/main.R      15      10  20

# Only lines with >= 10% of time
pv_hot_lines(p, min_pct = 10)
#>        location samples  label   filename linenum time_ms pct
#> 1   R/utils.R:5       2   deep  R/utils.R       5      20  40
#> 2 R/helper.R:20       1 helper R/helper.R      20      10  20
#> 3   R/main.R:10       1  outer   R/main.R      10      10  20
#> 4   R/main.R:15       1  inner   R/main.R      15      10  20
```
