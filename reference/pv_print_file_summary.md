# Print file summary

Print file summary

## Usage

``` r
pv_print_file_summary(x)
```

## Arguments

- x:

  A profvis object.

## Value

Invisibly returns the file summary data frame.

## Examples

``` r
p <- pv_example()
pv_print_file_summary(p)
#> ====================================================================== 
#>                              FILE SUMMARY
#> ====================================================================== 
#> 
#>     50 ms (100.0%)  R/main.R
#>     20 ms ( 40.0%)  R/utils.R
#>     10 ms ( 20.0%)  R/helper.R
```
