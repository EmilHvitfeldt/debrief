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
#>    label mem_mb
#> 1  inner    150
#> 2   deep    100
#> 3 helper     50
```
