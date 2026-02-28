
<!-- README.md is generated from README.Rmd. Please edit that file -->

# debrief

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/debrief)](https://CRAN.R-project.org/package=debrief)
[![R-CMD-check](https://github.com/EmilHvitfeldt/debrief/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/EmilHvitfeldt/debrief/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/EmilHvitfeldt/debrief/graph/badge.svg)](https://app.codecov.io/gh/EmilHvitfeldt/debrief)
<!-- badges: end -->

debrief provides text-based summaries and analysis tools for
[profvis](https://rstudio.github.io/profvis/) profiling output. It’s
designed for terminal workflows and AI agent consumption, offering views
including hotspot analysis, call trees, source context, caller/callee
relationships, and memory allocation breakdowns.

## Installation

You can install the development version of debrief from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("emilhvitfeldt/debrief")
```

## Example

First, create a profvis profile of some code:

``` r
library(profvis)
library(debrief)

# Define some functions to profile
process_data <- function(n) {
  raw <- generate_data(n)
  cleaned <- clean_data(raw)
  summarize_data(cleaned)
}

generate_data <- function(n) {
  x <- rnorm(n)
  y <- runif(n)

  data.frame(x = x, y = y, z = x * y)
}

clean_data <- function(df) {
  df <- df[complete.cases(df), ]
  df$x_scaled <- scale(df$x)
  df$category <- cut(df$y, breaks = 5)
  df
}

summarize_data <- function(df) {
  list(
    means = colMeans(df[, c("x", "y", "z")]),
    sds = apply(df[, c("x", "y", "z")], 2, sd),
    counts = table(df$category),
    text = paste(round(df$x, 2), collapse = ", ")
  )
}

# Profile the data pipeline
p <- profvis({
  results <- lapply(1:5, function(i) process_data(1e5))
})
```

### Quick Summary

Get a comprehensive overview with `pv_summary()`:

``` r
pv_summary(p)
#> ====================================================================== 
#>                           PROFILING SUMMARY
#> ====================================================================== 
#> 
#> Total time: 180 ms (18 samples @ 10 ms interval)
#> Source references: not available (use devtools::load_all())
#> 
#> 
#> --- TOP FUNCTIONS BY SELF-TIME ---------------------------------------
#>    120 ms ( 66.7%)  paste
#>     20 ms ( 11.1%)  anyDuplicated.default
#>     10 ms (  5.6%)  [.data.frame
#>     10 ms (  5.6%)  apply
#>     10 ms (  5.6%)  factor
#>     10 ms (  5.6%)  unlist
#> 
#> --- TOP FUNCTIONS BY TOTAL TIME --------------------------------------
#>    180 ms (100.0%)  FUN
#>    180 ms (100.0%)  lapply
#>    180 ms (100.0%)  process_data
#>    140 ms ( 77.8%)  summarize_data
#>    120 ms ( 66.7%)  paste
#>     40 ms ( 22.2%)  clean_data
#>     30 ms ( 16.7%)  [.data.frame
#>     20 ms ( 11.1%)  anyDuplicated.default
#>     10 ms (  5.6%)  apply
#>     10 ms (  5.6%)  as.matrix.data.frame
#> 
#> --- HOT CALL PATHS ---------------------------------------------------
#> 
#> 120 ms (66.7%) - 12 samples:
#>     lapply
#>   → FUN
#>   → process_data
#>   → summarize_data
#>   → paste
#> 
#> 20 ms (11.1%) - 2 samples:
#>     lapply
#>   → FUN
#>   → process_data
#>   → clean_data
#>   → [.data.frame
#>   → anyDuplicated.default
#> 
#> 10 ms (5.6%) - 1 samples:
#>     lapply
#>   → FUN
#>   → process_data
#>   → clean_data
#>   → [.data.frame
#> 
#> 10 ms (5.6%) - 1 samples:
#>     lapply
#>   → FUN
#>   → process_data
#>   → clean_data
#>   → cut.default
#>   → factor
#> 
#> 10 ms (5.6%) - 1 samples:
#>     lapply
#>   → FUN
#>   → process_data
#>   → summarize_data
#>   → apply
#> 
#> --- MEMORY ALLOCATION (by function) ----------------------------------
#>    38.57 MB paste
#>    20.01 MB anyDuplicated.default
#>     6.34 MB [.data.frame
#> ----------------------------------------------------------------------
```

### Time Analysis

Analyze where time is spent:

``` r
# Self-time: time spent directly in each function
pv_self_time(p)
#>                   label samples time_ms  pct
#> 1                 paste      12     120 66.7
#> 2 anyDuplicated.default       2      20 11.1
#> 3          [.data.frame       1      10  5.6
#> 4                 apply       1      10  5.6
#> 5                factor       1      10  5.6
#> 6                unlist       1      10  5.6

# Total time: time spent in function + all its callees
pv_total_time(p)
#>                    label samples time_ms   pct
#> 1                    FUN      18     180 100.0
#> 2                 lapply      18     180 100.0
#> 3           process_data      18     180 100.0
#> 4         summarize_data      14     140  77.8
#> 5                  paste      12     120  66.7
#> 6             clean_data       4      40  22.2
#> 7           [.data.frame       3      30  16.7
#> 8  anyDuplicated.default       2      20  11.1
#> 9                  apply       1      10   5.6
#> 10  as.matrix.data.frame       1      10   5.6
#> 11              colMeans       1      10   5.6
#> 12           cut.default       1      10   5.6
#> 13                factor       1      10   5.6
#> 14                unlist       1      10   5.6

# Filter to significant functions only
pv_self_time(p, min_pct = 5) # >= 5% of time
#>                   label samples time_ms  pct
#> 1                 paste      12     120 66.7
#> 2 anyDuplicated.default       2      20 11.1
#> 3          [.data.frame       1      10  5.6
#> 4                 apply       1      10  5.6
#> 5                factor       1      10  5.6
#> 6                unlist       1      10  5.6
```

### Hot Spots

Find the hottest lines and call paths:

``` r
# Hot source lines with context
pv_print_hot_lines(p, n = 5, context = 3)
#> No source location data available.
#> Use devtools::load_all() to enable source references.

# Hot call paths
pv_print_hot_paths(p, n = 10)
#> ====================================================================== 
#>                             HOT CALL PATHS
#> ====================================================================== 
#> 
#> Rank 1: 120 ms (66.7%) - 12 samples
#>     lapply
#>   → FUN
#>   → process_data
#>   → summarize_data
#>   → paste
#> 
#> Rank 2: 20 ms (11.1%) - 2 samples
#>     lapply
#>   → FUN
#>   → process_data
#>   → clean_data
#>   → [.data.frame
#>   → anyDuplicated.default
#> 
#> Rank 3: 10 ms (5.6%) - 1 samples
#>     lapply
#>   → FUN
#>   → process_data
#>   → clean_data
#>   → [.data.frame
#> 
#> Rank 4: 10 ms (5.6%) - 1 samples
#>     lapply
#>   → FUN
#>   → process_data
#>   → clean_data
#>   → cut.default
#>   → factor
#> 
#> Rank 5: 10 ms (5.6%) - 1 samples
#>     lapply
#>   → FUN
#>   → process_data
#>   → summarize_data
#>   → apply
#> 
#> Rank 6: 10 ms (5.6%) - 1 samples
#>     lapply
#>   → FUN
#>   → process_data
#>   → summarize_data
#>   → colMeans
#>   → as.matrix.data.frame
#>   → unlist
```

### Function Analysis

Deep dive into a specific function:

``` r
pv_focus(p, "clean_data")
#> ====================================================================== 
#>                           FOCUS: clean_data
#> ====================================================================== 
#> 
#> --- Time Analysis ---------------------------------------------------
#>   Total time:       40 ms ( 22.2%)  - time on call stack
#>   Self time:         0 ms (  0.0%)  - time at top of stack
#>   Child time:       40 ms ( 22.2%)  - time in callees
#>   Appearances:       4 samples
#> 
#> --- Called By -------------------------------------------------------
#>       4 calls (100.0%)  process_data
#> 
#> --- Calls To --------------------------------------------------------
#>       3 calls ( 75.0%)  [.data.frame
#>       1 calls ( 25.0%)  cut.default
#> 
#> --- Source Locations ------------------------------------------------
#>   Source references not available.
#>   Use devtools::load_all() to enable.
#> 
#> ----------------------------------------------------------------------
```

### Call Relationships

Understand who calls what:

``` r
# Who calls this function?
pv_callers(p, "clean_data")
#>          label samples pct
#> 1 process_data       4 100

# What does this function call?
pv_callees(p, "process_data")
#>            label samples  pct
#> 1 summarize_data      14 77.8
#> 2     clean_data       4 22.2

# Full caller/callee analysis
pv_print_callers_callees(p, "summarize_data")
#> ====================================================================== 
#>                   FUNCTION ANALYSIS: summarize_data
#> ====================================================================== 
#> 
#> Total time: 140 ms (77.8% of profile)
#> Appearances: 14 samples
#> 
#> --- Called by --------------------------------------------------
#>      14 samples (100.0%)  process_data
#> 
#> --- Calls to ---------------------------------------------------
#>      12 samples ( 85.7%)  paste
#>       1 samples (  7.1%)  apply
#>       1 samples (  7.1%)  colMeans
```

### Memory Analysis

Track memory allocations:

``` r
# Memory by function
pv_print_memory(p, n = 10, by = "function")
#> ====================================================================== 
#>                     MEMORY ALLOCATION BY FUNCTION
#> ====================================================================== 
#> 
#>    38.57 MB paste
#>    20.01 MB anyDuplicated.default
#>     6.34 MB [.data.frame

# Memory by source line
pv_print_memory(p, n = 10, by = "line")
#> No source location data available.
#> Use devtools::load_all() to enable source references.
```

### Text-based Flame Graph

Visualize the call tree:

``` r
pv_flame(p, width = 70, min_pct = 2)
#> ====================================================================== 
#>                           FLAME GRAPH (text)
#> ====================================================================== 
#> 
#> Total time: 180 ms | Width: 70 chars | Min: 2%
#> 
#> [======================================================================] (root) 100%
#> [======================================================================]   lapply (100.0%)
#> [======================================================================]     FUN (100.0%)
#> [======================================================================]       process_data (100.0%)
#> [======================================================                ]         summarize_data (77.8%)
#> [================                                                      ]         clean_data (22.2%)
#> [===============================================                       ]           paste (66.7%)
#> [============                                                          ]           [.data.frame (16.7%)
#> [====                                                                  ]           colMeans (5.6%)
#> [====                                                                  ]           apply (5.6%)
#> [====                                                                  ]           cut.default (5.6%)
#> [========                                                              ]             anyDuplicated.default (11.1%)
#> [====                                                                  ]             as.matrix.data.frame (5.6%)
#> [====                                                                  ]             factor (5.6%)
#> [====                                                                  ]               unlist (5.6%)
#> 
#> Legend: [====] = time spent, width proportional to time
```

### Compare Profiles

Measure optimization impact:

``` r
# Approach 1: Growing vectors in a loop (slow)
p_slow <- profvis({
  result <- c()
  for (i in 1:20000) {
    result <- c(result, sqrt(i) * log(i))
  }
})

# Approach 2: Vectorized with memory allocation
p_fast <- profvis({
  x <- rnorm(5e6)
  y <- cumsum(x)
  z <- paste(head(round(x, 2), 50000), collapse = ", ")
})

# Compare two profiles
pv_print_compare(p_slow, p_fast)
#> ====================================================================== 
#>                           PROFILE COMPARISON
#> ====================================================================== 
#> 
#> --- Overall ----------------------------------------------------------
#> IMPROVED: 270 ms -> 210 ms (1.3x faster, saved 60 ms)
#> 
#> --- Biggest Changes --------------------------------------------------
#> Function                           Before      After       Diff   Change
#> ------------------------------------------------------------------------ 
#> c                                     140          0       -140    -100%
#> head                                    0        100       +100      new
#> <GC>                                  130         40        -90     -69%
#> rnorm                                   0         60        +60      new
#> paste                                   0         10        +10      new
#> 
#> --- Top Improvements ------------------------------------------------
#>   c: 140 ms -> 0 ms (saved 140 ms)
#>   <GC>: 130 ms -> 40 ms (saved 90 ms)
#> 
#> --- Regressions -----------------------------------------------------
#>   head: 0 ms -> 100 ms (added 100 ms)
#>   rnorm: 0 ms -> 60 ms (added 60 ms)
#>   paste: 0 ms -> 10 ms (added 10 ms)

# Approach 3: Data frame operations
p_dataframe <- profvis({
  df <- data.frame(
    a = rnorm(1e6),
    b = runif(1e6),
    c = sample(letters, 1e6, replace = TRUE)
  )
  df$d <- df$a * df$b
  result <- aggregate(d ~ c, data = df, FUN = mean)
})

# Compare all three approaches
pv_print_compare_many(
  growing_vector = p_slow,
  vectorized = p_fast,
  dataframe_ops = p_dataframe
)
#> ====================================================================== 
#>                        MULTI-PROFILE COMPARISON
#> ====================================================================== 
#> 
#> Rank  Profile                    Time (ms)  Samples vs Fastest
#> -------------------------------------------------------------- 
#>   1*  dataframe_ops                    130       13    fastest
#>   2   vectorized                       210       21      1.62x
#>   3   growing_vector                   270       27      2.08x
#> 
#> * = fastest
```

### Diagnostics

Detect GC pressure and get optimization suggestions:

``` r
# Detect GC pressure (indicates memory allocation issues)
pv_print_gc_pressure(p)
#> ====================================================================== 
#>                              GC PRESSURE
#> ====================================================================== 
#> 
#> No significant GC pressure detected (<10% of time).

# Get actionable optimization suggestions
pv_print_suggestions(p)
#> ====================================================================== 
#>                        OPTIMIZATION SUGGESTIONS
#> ====================================================================== 
#> 
#> Suggestions are ordered by priority (1 = highest impact).
#> 
#> === Priority 1 ===
#> 
#> [data structure] [.data.frame / [[.data.frame
#>     Replace data frame row subsetting with vector indexing. Instead of `df[i, ]$col`, use `df$col[i]` or pre-extract columns as vectors before loops/recursion.
#>     Potential impact: Up to 24 ms (13%)
#> 
#> === Priority 2 ===
#> 
#> [hot function] paste
#>     Function 'paste' has highest self-time (66.7%). Profile this function in isolation to find micro-optimization opportunities.
#>     Potential impact: 120 ms (66.7%)
#> 
#> === Priority 3 ===
#> 
#> [string operations] paste
#>     String operations are significant (66.7%). Consider: (1) pre-computing strings outside loops, (2) using fixed=TRUE in grep/gsub when not using regex, (3) using stringi package for heavy string processing.
#>     Potential impact: Up to 60 ms (33%)
```

### Export for AI Agents

Export structured data for programmatic access:

``` r
# Export as R list for programmatic access
results <- pv_to_list(p)
names(results)
#> [1] "metadata"    "summary"     "self_time"   "total_time"  "hot_lines"  
#> [6] "memory"      "gc_pressure" "suggestions" "recursive"

# Data frame of functions by self-time
results$self_time
#>                   label samples time_ms  pct
#> 1                 paste      12     120 66.7
#> 2 anyDuplicated.default       2      20 11.1
#> 3          [.data.frame       1      10  5.6
#> 4                 apply       1      10  5.6
#> 5                factor       1      10  5.6
#> 6                unlist       1      10  5.6
```

## Available Functions

| Category | Functions |
|----|----|
| Overview | `pv_summary()`, `pv_example()` |
| Time Analysis | `pv_self_time()`, `pv_total_time()` |
| Hot Spots | `pv_hot_lines()`, `pv_hot_paths()`, `pv_print_hot_lines()`, `pv_print_hot_paths()` |
| Memory | `pv_memory()`, `pv_memory_lines()`, `pv_print_memory()` |
| Call Analysis | `pv_callers()`, `pv_callees()`, `pv_call_depth()`, `pv_call_stats()` |
| Function Analysis | `pv_focus()`, `pv_recursive()` |
| Source Context | `pv_source_context()`, `pv_file_summary()` |
| Visualization | `pv_flame()`, `pv_flame_condense()` |
| Comparison | `pv_compare()`, `pv_print_compare()`, `pv_compare_many()`, `pv_print_compare_many()` |
| Diagnostics | `pv_gc_pressure()`, `pv_suggestions()` |
| Export | `pv_to_json()`, `pv_to_list()` |

### Filtering Support

Time and hot spot functions support filtering:

``` r
# Filter by percentage threshold
pv_self_time(p, min_pct = 5)
pv_hot_lines(p, min_pct = 10)

# Filter by time threshold
pv_self_time(p, min_time_ms = 100)

# Limit number of results
pv_self_time(p, n = 10)

# Combine filters
pv_hot_lines(p, n = 5, min_pct = 2, min_time_ms = 10)
```
