
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
#> Total time: 190 ms (19 samples @ 10 ms interval)
#> Source references: not available (use devtools::load_all())
#> 
#> 
#> --- TOP FUNCTIONS BY SELF-TIME ---------------------------------------
#>    110 ms ( 57.9%)  paste
#>     20 ms ( 10.5%)  complete.cases
#>     10 ms (  5.3%)  [.data.frame
#>     10 ms (  5.3%)  anyDuplicated.default
#>     10 ms (  5.3%)  aperm.default
#>     10 ms (  5.3%)  colMeans
#>     10 ms (  5.3%)  factor
#>     10 ms (  5.3%)  is.na
#> 
#> --- TOP FUNCTIONS BY TOTAL TIME --------------------------------------
#>    180 ms ( 94.7%)  FUN
#>    180 ms ( 94.7%)  lapply
#>    180 ms ( 94.7%)  process_data
#>    130 ms ( 68.4%)  summarize_data
#>    110 ms ( 57.9%)  paste
#>     50 ms ( 26.3%)  clean_data
#>     20 ms ( 10.5%)  [.data.frame
#>     20 ms ( 10.5%)  complete.cases
#>     10 ms (  5.3%)  anyDuplicated.default
#>     10 ms (  5.3%)  aperm.default
#> 
#> --- HOT CALL PATHS ---------------------------------------------------
#> 
#> 110 ms (57.9%) - 11 samples:
#>     lapply
#>   → FUN
#>   → process_data
#>   → summarize_data
#>   → paste
#> 
#> 20 ms (10.5%) - 2 samples:
#>     lapply
#>   → FUN
#>   → process_data
#>   → clean_data
#>   → complete.cases
#> 
#> 10 ms (5.3%) - 1 samples:
#>     base::tryCatch
#>   → is.na
#> 
#> 10 ms (5.3%) - 1 samples:
#>     lapply
#>   → FUN
#>   → process_data
#>   → clean_data
#>   → [.data.frame
#> 
#> 10 ms (5.3%) - 1 samples:
#>     lapply
#>   → FUN
#>   → process_data
#>   → clean_data
#>   → [.data.frame
#>   → anyDuplicated.default
#> 
#> --- MEMORY ALLOCATION (by function) ----------------------------------
#>    50.99 MB paste
#>    10.01 MB anyDuplicated.default
#>     9.01 MB [.data.frame
#>     6.57 MB complete.cases
#> ----------------------------------------------------------------------
```

### Time Analysis

Analyze where time is spent:

``` r
# Self-time: time spent directly in each function
pv_self_time(p)
#>                   label samples time_ms  pct
#> 1                 paste      11     110 57.9
#> 2        complete.cases       2      20 10.5
#> 3          [.data.frame       1      10  5.3
#> 4 anyDuplicated.default       1      10  5.3
#> 5         aperm.default       1      10  5.3
#> 6              colMeans       1      10  5.3
#> 7                factor       1      10  5.3
#> 8                 is.na       1      10  5.3

# Total time: time spent in function + all its callees
pv_total_time(p)
#>                    label samples time_ms  pct
#> 1                    FUN      18     180 94.7
#> 2                 lapply      18     180 94.7
#> 3           process_data      18     180 94.7
#> 4         summarize_data      13     130 68.4
#> 5                  paste      11     110 57.9
#> 6             clean_data       5      50 26.3
#> 7           [.data.frame       2      20 10.5
#> 8         complete.cases       2      20 10.5
#> 9  anyDuplicated.default       1      10  5.3
#> 10         aperm.default       1      10  5.3
#> 11                 apply       1      10  5.3
#> 12        base::tryCatch       1      10  5.3
#> 13              colMeans       1      10  5.3
#> 14           cut.default       1      10  5.3
#> 15                factor       1      10  5.3
#> 16                 is.na       1      10  5.3

# Filter to significant functions only
pv_self_time(p, min_pct = 5) # >= 5% of time
#>                   label samples time_ms  pct
#> 1                 paste      11     110 57.9
#> 2        complete.cases       2      20 10.5
#> 3          [.data.frame       1      10  5.3
#> 4 anyDuplicated.default       1      10  5.3
#> 5         aperm.default       1      10  5.3
#> 6              colMeans       1      10  5.3
#> 7                factor       1      10  5.3
#> 8                 is.na       1      10  5.3
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
#> Rank 1: 110 ms (57.9%) - 11 samples
#>     lapply
#>   → FUN
#>   → process_data
#>   → summarize_data
#>   → paste
#> 
#> Rank 2: 20 ms (10.5%) - 2 samples
#>     lapply
#>   → FUN
#>   → process_data
#>   → clean_data
#>   → complete.cases
#> 
#> Rank 3: 10 ms (5.3%) - 1 samples
#>     base::tryCatch
#>   → is.na
#> 
#> Rank 4: 10 ms (5.3%) - 1 samples
#>     lapply
#>   → FUN
#>   → process_data
#>   → clean_data
#>   → [.data.frame
#> 
#> Rank 5: 10 ms (5.3%) - 1 samples
#>     lapply
#>   → FUN
#>   → process_data
#>   → clean_data
#>   → [.data.frame
#>   → anyDuplicated.default
#> 
#> Rank 6: 10 ms (5.3%) - 1 samples
#>     lapply
#>   → FUN
#>   → process_data
#>   → clean_data
#>   → cut.default
#>   → factor
#> 
#> Rank 7: 10 ms (5.3%) - 1 samples
#>     lapply
#>   → FUN
#>   → process_data
#>   → summarize_data
#>   → apply
#>   → aperm.default
#> 
#> Rank 8: 10 ms (5.3%) - 1 samples
#>     lapply
#>   → FUN
#>   → process_data
#>   → summarize_data
#>   → colMeans
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
#>   Total time:       50 ms ( 26.3%)  - time on call stack
#>   Self time:         0 ms (  0.0%)  - time at top of stack
#>   Child time:       50 ms ( 26.3%)  - time in callees
#>   Appearances:       5 samples
#> 
#> --- Called By -------------------------------------------------------
#>       5 calls (100.0%)  process_data
#> 
#> --- Calls To --------------------------------------------------------
#>       2 calls ( 40.0%)  [.data.frame
#>       2 calls ( 40.0%)  complete.cases
#>       1 calls ( 20.0%)  cut.default
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
#> 1 process_data       5 100

# What does this function call?
pv_callees(p, "process_data")
#>            label samples  pct
#> 1 summarize_data      13 72.2
#> 2     clean_data       5 27.8

# Full caller/callee analysis
pv_print_callers_callees(p, "summarize_data")
#> ====================================================================== 
#>                   FUNCTION ANALYSIS: summarize_data
#> ====================================================================== 
#> 
#> Total time: 130 ms (68.4% of profile)
#> Appearances: 13 samples
#> 
#> --- Called by --------------------------------------------------
#>      13 samples (100.0%)  process_data
#> 
#> --- Calls to ---------------------------------------------------
#>      11 samples ( 84.6%)  paste
#>       1 samples (  7.7%)  apply
#>       1 samples (  7.7%)  colMeans
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
#>    50.99 MB paste
#>    10.01 MB anyDuplicated.default
#>     9.01 MB [.data.frame
#>     6.57 MB complete.cases

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
#> Total time: 190 ms | Width: 70 chars | Min: 2%
#> 
#> [======================================================================] (root) 100%
#> [==================================================================    ]   lapply (94.7%)
#> [====                                                                  ]   base::tryCatch (5.3%)
#> [==================================================================    ]     FUN (94.7%)
#> [====                                                                  ]     is.na (5.3%)
#> [==================================================================    ]       process_data (94.7%)
#> [================================================                      ]         summarize_data (68.4%)
#> [==================                                                    ]         clean_data (26.3%)
#> [=========================================                             ]           paste (57.9%)
#> [=======                                                               ]           complete.cases (10.5%)
#> [=======                                                               ]           [.data.frame (10.5%)
#> [====                                                                  ]           cut.default (5.3%)
#> [====                                                                  ]           apply (5.3%)
#> [====                                                                  ]           colMeans (5.3%)
#> [====                                                                  ]             factor (5.3%)
#> [====                                                                  ]             aperm.default (5.3%)
#> [====                                                                  ]             anyDuplicated.default (5.3%)
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
#> IMPROVED: 300 ms -> 210 ms (1.4x faster, saved 90 ms)
#> 
#> --- Biggest Changes --------------------------------------------------
#> Function                           Before      After       Diff   Change
#> ------------------------------------------------------------------------ 
#> c                                     270          0       -270    -100%
#> head                                    0        100       +100      new
#> rnorm                                   0         60        +60      new
#> <GC>                                   20         40        +20    +100%
#> sqrt                                   10          0        -10    -100%
#> paste                                   0         10        +10      new
#> 
#> --- Top Improvements ------------------------------------------------
#>   c: 270 ms -> 0 ms (saved 270 ms)
#>   sqrt: 10 ms -> 0 ms (saved 10 ms)
#> 
#> --- Regressions -----------------------------------------------------
#>   head: 0 ms -> 100 ms (added 100 ms)
#>   rnorm: 0 ms -> 60 ms (added 60 ms)
#>   <GC>: 20 ms -> 40 ms (added 20 ms)
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
#>   1*  dataframe_ops                    140       14    fastest
#>   2   vectorized                       210       21      1.50x
#>   3   growing_vector                   300       30      2.14x
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
#> === Priority 2 ===
#> 
#> [hot function] paste
#>     Function 'paste' has highest self-time (57.9%). Profile this function in isolation to find micro-optimization opportunities.
#>     Potential impact: 110 ms (57.9%)
#> 
#> === Priority 3 ===
#> 
#> [string operations] paste
#>     String operations are significant (57.9%). Consider: (1) pre-computing strings outside loops, (2) using fixed=TRUE in grep/gsub when not using regex, (3) using stringi package for heavy string processing.
#>     Potential impact: Up to 55 ms (29%)
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
#> 1                 paste      11     110 57.9
#> 2        complete.cases       2      20 10.5
#> 3          [.data.frame       1      10  5.3
#> 4 anyDuplicated.default       1      10  5.3
#> 5         aperm.default       1      10  5.3
#> 6              colMeans       1      10  5.3
#> 7                factor       1      10  5.3
#> 8                 is.na       1      10  5.3
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
