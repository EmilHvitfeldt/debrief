# Print call statistics

Print call statistics

## Usage

``` r
pv_print_call_stats(x, n = 20)
```

## Arguments

- x:

  A profvis object.

- n:

  Number of functions to show.

## Value

Invisibly returns the call stats data frame.

## Examples

``` r
p <- pv_example()
pv_print_call_stats(p)
#> ====================================================================== 
#>                            CALL STATISTICS
#> ====================================================================== 
#> 
#> Function                               Calls   Total ms    Self ms    ms/call    Pct
#> ------------------------------------------------------------------------------------- 
#> outer                                      1         50         10      50.00 100.0%
#> inner                                      2         30         10      15.00  60.0%
#> deep                                       2         20         20      10.00  40.0%
#> helper                                     1         10         10      10.00  20.0%
```
