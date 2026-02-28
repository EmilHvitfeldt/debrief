# Condensed flame graph

Shows a simplified, condensed view of the flame graph focusing on the
hottest paths.

## Usage

``` r
pv_flame_condense(x, n = 10, width = 50)
```

## Arguments

- x:

  A profvis object.

- n:

  Number of hot paths to show.

- width:

  Width of bars.

## Value

Invisibly returns a data frame with path, samples, and pct columns.
