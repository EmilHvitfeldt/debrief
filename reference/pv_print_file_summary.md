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
#>     70 ms (100.0%)  example_code.R
```
