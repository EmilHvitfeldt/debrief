# Text-based flame graph

Generates an ASCII representation of a flame graph showing the
hierarchical breakdown of time spent in the call tree.

## Usage

``` r
pv_flame(x, width = 70, min_pct = 2, max_depth = 15)
```

## Arguments

- x:

  A profvis object.

- width:

  Width of the flame graph in characters.

- min_pct:

  Minimum percentage to show (filters small slices).

- max_depth:

  Maximum depth to display.

## Value

Invisibly returns the flame data structure.

## Examples

``` r
p <- pv_example()
pv_flame(p)
#> ====================================================================== 
#>                           FLAME GRAPH (text)
#> ====================================================================== 
#> 
#> Total time: 50 ms | Width: 70 chars | Min: 2%
#> 
#> [======================================================================] (root) 100%
#> [======================================================================]   outer (100.0%)
#> [==========================================                            ]     inner (60.0%)
#> [==============                                                        ]     helper (20.0%)
#> [============================                                          ]       deep (40.0%)
#> 
#> Legend: [====] = time spent, width proportional to time
```
