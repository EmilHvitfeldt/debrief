# Memory allocation by function

Returns memory allocation aggregated by function name.

## Usage

``` r
pv_memory(x, n = NULL)
```

## Arguments

- x:

  A profvis object.

- n:

  Maximum number of functions to return. If `NULL`, returns all.

## Value

A data frame with columns:

- `label`: Function name

- `mem_mb`: Memory allocated in megabytes

## Examples

``` r
p <- pv_example()
pv_memory(p)
#>                              label    mem_mb
#> 1                            rnorm 1.3752670
#> 2                 x[i] <- rnorm(1) 1.2550430
#> 3                    generate_data 0.5630035
#> 4 result[i] <- sqrt(abs(x[i])) * 2 0.3564835
```
