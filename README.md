
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

First, create a profvis profile of some code. To get source references
in the profile, write your code to a file and source it with
`keep.source = TRUE`:

``` r
library(profvis)
library(debrief)

# Write functions to a temp file for source references
example_code <- '
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
'

writeLines(example_code, "analysis.R")
source("analysis.R", keep.source = TRUE)

# Profile the data pipeline
p <- profvis({
  results <- lapply(1:5, function(i) process_data(1e5))
})

unlink("analysis.R")
```

### Quick Summary

Get a comprehensive overview with `pv_print_debrief()`:

``` r
pv_print_debrief(p)
#> ## PROFILING SUMMARY
#> 
#> 
#> Total time: 180 ms (18 samples @ 10 ms interval)
#> Source references: available
#> 
#> 
#> ### TOP FUNCTIONS BY SELF-TIME
#>    110 ms ( 61.1%)  paste
#>     20 ms ( 11.1%)  rnorm
#>     10 ms (  5.6%)  .bincode
#>     10 ms (  5.6%)  anyDuplicated.default
#>     10 ms (  5.6%)  is.na
#>     10 ms (  5.6%)  max
#>     10 ms (  5.6%)  var
#> 
#> ### TOP FUNCTIONS BY TOTAL TIME
#>    160 ms ( 88.9%)  FUN
#>    160 ms ( 88.9%)  lapply
#>    160 ms ( 88.9%)  process_data
#>    120 ms ( 66.7%)  summarize_data
#>    110 ms ( 61.1%)  paste
#>     20 ms ( 11.1%)  base::tryCatch
#>     20 ms ( 11.1%)  clean_data
#>     20 ms ( 11.1%)  generate_data
#>     20 ms ( 11.1%)  rnorm
#>     10 ms (  5.6%)  .bincode
#> 
#> ### HOT LINES (by self-time)
#>    110 ms ( 61.1%)  analysis.R:22
#>                    list(
#>     20 ms ( 11.1%)  analysis.R:9
#>                    x <- rnorm(n)
#> 
#> ### HOT CALL PATHS
#> 
#> 110 ms (61.1%) - 11 samples:
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> summarize_data (analysis.R:5)
#>   -> paste (analysis.R:22)
#> 
#> 20 ms (11.1%) - 2 samples:
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> generate_data (analysis.R:3)
#>   -> rnorm (analysis.R:9)
#> 
#> 10 ms (5.6%) - 1 samples:
#>     base::tryCatch
#>   -> is.na
#> 
#> 10 ms (5.6%) - 1 samples:
#>     base::tryCatch
#>   -> max
#> 
#> 10 ms (5.6%) - 1 samples:
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> clean_data (analysis.R:4)
#>   -> [.data.frame (analysis.R:15)
#>   -> anyDuplicated.default
#> 
#> ### MEMORY ALLOCATION (by function)
#>    44.85 MB paste
#>    10.01 MB anyDuplicated.default
#>     2.99 MB rnorm
#> 
#> ### MEMORY ALLOCATION (by line)
#>    44.85 MB analysis.R:22
#>             list(
#>     2.99 MB analysis.R:9
#>             x <- rnorm(n)
#> 
#> ### Next steps
#> pv_focus(p, "paste")
#> pv_source_context(p, "analysis.R")
#> pv_suggestions(p)
```

### Time Analysis

Analyze where time is spent:

``` r
# Self-time: time spent directly in each function
pv_self_time(p)
#>                   label samples time_ms  pct
#> 1                 paste      11     110 61.1
#> 2                 rnorm       2      20 11.1
#> 3              .bincode       1      10  5.6
#> 4 anyDuplicated.default       1      10  5.6
#> 5                 is.na       1      10  5.6
#> 6                   max       1      10  5.6
#> 7                   var       1      10  5.6

# Total time: time spent in function + all its callees
pv_total_time(p)
#>                    label samples time_ms  pct
#> 1                    FUN      16     160 88.9
#> 2                 lapply      16     160 88.9
#> 3           process_data      16     160 88.9
#> 4         summarize_data      12     120 66.7
#> 5                  paste      11     110 61.1
#> 6         base::tryCatch       2      20 11.1
#> 7             clean_data       2      20 11.1
#> 8          generate_data       2      20 11.1
#> 9                  rnorm       2      20 11.1
#> 10              .bincode       1      10  5.6
#> 11          [.data.frame       1      10  5.6
#> 12 anyDuplicated.default       1      10  5.6
#> 13                 apply       1      10  5.6
#> 14           cut.default       1      10  5.6
#> 15                 is.na       1      10  5.6
#> 16                   max       1      10  5.6
#> 17                   var       1      10  5.6

# Filter to significant functions only
pv_self_time(p, min_pct = 5) # >= 5% of time
#>                   label samples time_ms  pct
#> 1                 paste      11     110 61.1
#> 2                 rnorm       2      20 11.1
#> 3              .bincode       1      10  5.6
#> 4 anyDuplicated.default       1      10  5.6
#> 5                 is.na       1      10  5.6
#> 6                   max       1      10  5.6
#> 7                   var       1      10  5.6
```

### Hot Spots

Find the hottest lines and call paths:

``` r
# Hot source lines with context
pv_print_hot_lines(p, n = 5, context = 3)
#> ## HOT SOURCE LINES
#> 
#> 
#> Rank 1: analysis.R:22 (110 ms, 61.1%)
#> Function: paste
#> 
#>        19: }
#>        20: 
#>        21: summarize_data <- function(df) {
#> >      22:   list(
#>        23:     means = colMeans(df[, c("x", "y", "z")]),
#>        24:     sds = apply(df[, c("x", "y", "z")], 2, sd),
#>        25:     counts = table(df$category),
#> 
#> Rank 2: analysis.R:9 (20 ms, 11.1%)
#> Function: rnorm
#> 
#>         6: }
#>         7: 
#>         8: generate_data <- function(n) {
#> >       9:   x <- rnorm(n)
#>        10:   y <- runif(n)
#>        11:   data.frame(x = x, y = y, z = x * y)
#>        12: }
#> 
#> 
#> ### Next steps
#> pv_focus(p, "paste")
#> pv_source_context(p, "analysis.R")

# Hot call paths
pv_print_hot_paths(p, n = 10)
#> ## HOT CALL PATHS
#> 
#> 
#> Rank 1: 110 ms (61.1%) - 11 samples
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> summarize_data (analysis.R:5)
#>   -> paste (analysis.R:22)
#> 
#> Rank 2: 20 ms (11.1%) - 2 samples
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> generate_data (analysis.R:3)
#>   -> rnorm (analysis.R:9)
#> 
#> Rank 3: 10 ms (5.6%) - 1 samples
#>     base::tryCatch
#>   -> is.na
#> 
#> Rank 4: 10 ms (5.6%) - 1 samples
#>     base::tryCatch
#>   -> max
#> 
#> Rank 5: 10 ms (5.6%) - 1 samples
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> clean_data (analysis.R:4)
#>   -> [.data.frame (analysis.R:15)
#>   -> anyDuplicated.default
#> 
#> Rank 6: 10 ms (5.6%) - 1 samples
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> clean_data (analysis.R:4)
#>   -> cut.default
#>   -> .bincode
#> 
#> Rank 7: 10 ms (5.6%) - 1 samples
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> summarize_data (analysis.R:5)
#>   -> apply (analysis.R:22)
#>   -> FUN
#>   -> var
#> 
#> 
#> ### Next steps
#> pv_focus(p, "paste")
#> pv_flame(p)
```

### Function Analysis

Deep dive into a specific function:

``` r
pv_focus(p, "clean_data")
#> ## FOCUS: clean_data
#> 
#> 
#> ### Time Analysis
#>   Total time:       20 ms ( 11.1%)  - time on call stack
#>   Self time:         0 ms (  0.0%)  - time at top of stack
#>   Child time:       20 ms ( 11.1%)  - time in callees
#>   Appearances:       2 samples
#> 
#> ### Called By
#>       2 calls (100.0%)  process_data
#> 
#> ### Calls To
#>       1 calls ( 50.0%)  [.data.frame
#>       1 calls ( 50.0%)  cut.default
#> 
#> ### Source Locations
#>   No self-time with source info.
#> 
#> ### Next steps
#> pv_focus(p, "[.data.frame")
#> pv_callers(p, "clean_data")
#> pv_focus(p, "process_data")
```

### Call Relationships

Understand who calls what:

``` r
# Who calls this function?
pv_callers(p, "clean_data")
#>          label samples pct
#> 1 process_data       2 100

# What does this function call?
pv_callees(p, "process_data")
#>            label samples  pct
#> 1 summarize_data      12 75.0
#> 2     clean_data       2 12.5
#> 3  generate_data       2 12.5

# Full caller/callee analysis
pv_print_callers_callees(p, "summarize_data")
#> ## FUNCTION ANALYSIS: summarize_data
#> 
#> 
#> Total time: 120 ms (66.7% of profile)
#> Appearances: 12 samples
#> 
#> ### Called by
#>      12 samples (100.0%)  process_data
#> 
#> ### Calls to
#>      11 samples ( 91.7%)  paste
#>       1 samples (  8.3%)  apply
#> 
#> ### Next steps
#> pv_focus(p, "summarize_data")
#> pv_focus(p, "process_data")
#> pv_focus(p, "paste")
```

### Memory Analysis

Track memory allocations:

``` r
# Memory by function
pv_print_memory(p, n = 10, by = "function")
#> ## MEMORY ALLOCATION BY FUNCTION
#> 
#> 
#>    44.85 MB paste
#>    10.01 MB anyDuplicated.default
#>     2.99 MB rnorm
#> 
#> ### Next steps
#> pv_focus(p, "paste")
#> pv_gc_pressure(p)

# Memory by source line
pv_print_memory(p, n = 10, by = "line")
#> ## MEMORY ALLOCATION BY LINE
#> 
#> 
#>    44.85 MB analysis.R:22
#>             list(
#>     2.99 MB analysis.R:9
#>             x <- rnorm(n)
#> 
#> ### Next steps
#> pv_focus(p, "paste")
#> pv_source_context(p, "analysis.R")
```

### Text-based Flame Graph

Visualize the call tree:

``` r
pv_flame(p, width = 70, min_pct = 2)
#> ## FLAME GRAPH (text)
#> 
#> 
#> Total time: 180 ms | Width: 70 chars | Min: 2%
#> 
#> [======================================================================] (root) 100%
#> [==============================================================        ]   lapply (88.9%)
#> [========                                                              ]   base::tryCatch (11.1%)
#> [==============================================================        ]     FUN (88.9%)
#> [====                                                                  ]     max (5.6%)
#> [====                                                                  ]     is.na (5.6%)
#> [==============================================================        ]       process_data (88.9%)
#> [===============================================                       ]         summarize_data (66.7%)
#> [========                                                              ]         clean_data (11.1%)
#> [========                                                              ]         generate_data (11.1%)
#> [===========================================                           ]           paste (61.1%)
#> [========                                                              ]           rnorm (11.1%)
#> [====                                                                  ]           cut.default (5.6%)
#> [====                                                                  ]           apply (5.6%)
#> [====                                                                  ]           [.data.frame (5.6%)
#> [====                                                                  ]             .bincode (5.6%)
#> [====                                                                  ]             FUN (5.6%)
#> [====                                                                  ]             anyDuplicated.default (5.6%)
#> [====                                                                  ]               var (5.6%)
#> 
#> Legend: [====] = time spent, width proportional to time
#> 
#> ### Next steps
#> pv_focus(p, "lapply")
#> pv_hot_paths(p)
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
#> ## PROFILE COMPARISON
#> 
#> 
#> 
#> ### Overall
#> before_ms: 270
#> after_ms: 200
#> diff_ms: -70
#> speedup: 1.35x
#> 
#> ### Biggest Changes
#> Function                           Before      After       Diff   Change
#> c                                     220          0       -220    -100%
#> head                                    0         90        +90      new
#> rnorm                                   0         60        +60      new
#> <GC>                                   50         40        -10     -20%
#> paste                                   0         10        +10      new
#> 
#> ### Top Improvements
#>   c: 220 -> 0 (-220 ms)
#>   <GC>: 50 -> 40 (-10 ms)
#> 
#> ### Regressions
#>   head: 0 -> 90 (+90 ms)
#>   rnorm: 0 -> 60 (+60 ms)
#>   paste: 0 -> 10 (+10 ms)
#> 
#> ### Next steps
#> pv_focus(p_before, "c")
#> pv_focus(p_after, "c")

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
#> ## MULTI-PROFILE COMPARISON
#> 
#> 
#> Rank  Profile                    Time (ms)  Samples vs Fastest
#>   1*  dataframe_ops                    130       13    fastest
#>   2   vectorized                       200       20      1.54x
#>   3   growing_vector                   270       27      2.08x
#> 
#> * = fastest
```

### Diagnostics

Detect GC pressure and get optimization suggestions:

``` r
# Detect GC pressure (indicates memory allocation issues)
pv_print_gc_pressure(p)
#> ## GC PRESSURE
#> 
#> 
#> No significant GC pressure detected (<10% of time).

# Get actionable optimization suggestions
pv_print_suggestions(p)
#> ## OPTIMIZATION SUGGESTIONS
#> 
#> 
#> ### Priority 1
#> 
#> category: hot line
#> location: analysis.R:22
#> action: Optimize hot line (61.1%)
#> pattern: paste
#> potential_impact: 110 ms (61.1%)
#> 
#> category: hot line
#> location: analysis.R:9
#> action: Optimize hot line (11.1%)
#> pattern: rnorm
#> potential_impact: 20 ms (11.1%)
#> 
#> ### Priority 2
#> 
#> category: hot function
#> location: paste
#> action: Profile in isolation (61.1% self-time)
#> pattern: paste
#> potential_impact: 110 ms (61.1%)
#> 
#> ### Priority 3
#> 
#> category: string operations
#> location: paste
#> action: Optimize string operations (61.1%)
#> pattern: string ops in loops, regex without fixed=TRUE
#> replacement: pre-compute, fixed=TRUE, stringi package
#> potential_impact: Up to 55 ms (31%)
#> 
#> 
#> ### Next steps
#> pv_hot_lines(p)
#> pv_gc_pressure(p)
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
#> 1                 paste      11     110 61.1
#> 2                 rnorm       2      20 11.1
#> 3              .bincode       1      10  5.6
#> 4 anyDuplicated.default       1      10  5.6
#> 5                 is.na       1      10  5.6
#> 6                   max       1      10  5.6
#> 7                   var       1      10  5.6
```

## Available Functions

| Category | Functions |
|----|----|
| Overview | `pv_debrief()`, `pv_print_debrief()`, `pv_example()` |
| Time Analysis | `pv_self_time()`, `pv_total_time()` |
| Hot Spots | `pv_hot_lines()`, `pv_hot_paths()`, `pv_worst_line()`, `pv_print_hot_lines()`, `pv_print_hot_paths()` |
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
