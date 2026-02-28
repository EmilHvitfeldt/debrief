# Memory allocation by source line

Returns memory allocation aggregated by source location. Requires source
references (use `devtools::load_all()` for best results).

## Usage

``` r
pv_memory_lines(x, n = NULL)
```

## Arguments

- x:

  A profvis object.

- n:

  Maximum number of lines to return. If `NULL`, returns all.

## Value

A data frame with columns:

- `location`: File path and line number

- `label`: Function name at this location

- `filename`: Source file path

- `linenum`: Line number

- `mem_mb`: Memory allocated in megabytes

## Examples

``` r
p <- pv_example()
pv_memory_lines(p)
#>        location mem_mb  label   filename linenum
#> 1   R/main.R:15    150  inner   R/main.R      15
#> 2   R/utils.R:5    100   deep  R/utils.R       5
#> 3 R/helper.R:20     50 helper R/helper.R      20
```
