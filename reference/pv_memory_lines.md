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
#>            location    mem_mb                            label       filename
#> 1 example_code.R:13 2.6303101                            rnorm example_code.R
#> 2  example_code.R:5 0.5630035                    generate_data example_code.R
#> 3 example_code.R:21 0.3564835 result[i] <- sqrt(abs(x[i])) * 2 example_code.R
#>   linenum
#> 1      13
#> 2       5
#> 3      21
```
