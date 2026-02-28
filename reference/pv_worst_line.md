# Get the single hottest line

Returns the hottest source line with full context. Useful for quickly
identifying the \#1 optimization target.

## Usage

``` r
pv_worst_line(x, context = 5)
```

## Arguments

- x:

  A profvis object.

- context:

  Number of source lines to include before and after.

## Value

A list with:

- `location`: File path and line number (e.g., "R/foo.R:42")

- `label`: Function name

- `filename`: Source file path

- `linenum`: Line number

- `time_ms`: Time in milliseconds

- `pct`: Percentage of total time

- `code`: The source line

- `context`: Vector of surrounding source lines

- `callers`: Data frame of functions that call this location

Returns `NULL` if no source references are available.

## Examples

``` r
p <- pv_example()
pv_worst_line(p)
#> $location
#> [1] "example_code.R:13"
#> 
#> $label
#> [1] "rnorm"
#> 
#> $filename
#> [1] "example_code.R"
#> 
#> $linenum
#> [1] 13
#> 
#> $time_ms
#> [1] 50
#> 
#> $pct
#> [1] 71.4
#> 
#> $code
#> [1] "x[i] <- rnorm(1)"
#> 
#> $context
#>  [1] "}"                               ""                               
#>  [3] "generate_data <- function(n) {"  "  x <- numeric(n)"              
#>  [5] "  for (i in seq_len(n)) {"       "    x[i] <- rnorm(1)"           
#>  [7] "  }"                             "  x"                            
#>  [9] "}"                               ""                               
#> [11] "transform_data <- function(x) {"
#> 
#> $callers
#>           label samples pct
#> 1 generate_data       6 100
#> 
```
