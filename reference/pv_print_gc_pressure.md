# Print GC pressure analysis

Print GC pressure analysis

## Usage

``` r
pv_print_gc_pressure(x, threshold = 10)
```

## Arguments

- x:

  A profvis object.

- threshold:

  Minimum GC percentage to report (default 10).

## Value

Invisibly returns the GC pressure data frame.

## Examples

``` r
p <- pv_example("gc")
pv_print_gc_pressure(p)
#> ====================================================================== 
#>                              GC PRESSURE
#> ====================================================================== 
#> 
#> [!!!] GC consuming 40.0% of time (40 ms)
#> 
#> High garbage collection overhead (40.0% of time). Indicates excessive memory allocation. Look for growing vectors, repeated data frame operations, or unnecessary copies. 
```
