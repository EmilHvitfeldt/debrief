
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

## Quick Start

``` r
library(profvis)
library(debrief)

# Profile some code
p <- profvis({
  # your code here
})

# Get help on available functions
pv_help()

# Start with a summary
pv_print_debrief(p)
```

## Typical Workflow

debrief is designed for iterative profiling. Each function prints “Next
steps” suggestions to guide you deeper:

    1. pv_print_debrief(p)
     -> Overview: identifies hot functions and lines

    2. pv_focus(p, "hot_function")
     -> Deep dive: time breakdown, callers, callees, source

    3. pv_hot_lines(p)
     -> Exact lines: find the specific code consuming time

    4. pv_source_context(p, "file.R")
     -> Code view: see source with profiling data overlay

    5. pv_suggestions(p)
     -> Actions: get specific optimization recommendations

The `pv_help()` function lists all available functions by category.

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
#>     10 ms (  5.6%)  .bincode
#>     10 ms (  5.6%)  anyDuplicated.default
#>     10 ms (  5.6%)  apply
#>     10 ms (  5.6%)  factor
#>     10 ms (  5.6%)  match.arg
#>     10 ms (  5.6%)  runif
#>     10 ms (  5.6%)  unlist
#> 
#> ### TOP FUNCTIONS BY TOTAL TIME
#>    180 ms (100.0%)  FUN
#>    180 ms (100.0%)  lapply
#>    180 ms (100.0%)  process_data
#>    130 ms ( 72.2%)  summarize_data
#>    110 ms ( 61.1%)  paste
#>     30 ms ( 16.7%)  clean_data
#>     20 ms ( 11.1%)  cut.default
#>     20 ms ( 11.1%)  generate_data
#>     10 ms (  5.6%)  .bincode
#>     10 ms (  5.6%)  [.data.frame
#> 
#> ### HOT LINES (by self-time)
#>    120 ms ( 66.7%)  analysis.R:22
#>                    list(
#>     10 ms (  5.6%)  analysis.R:10
#>                    y <- runif(n)
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
#> 10 ms (5.6%) - 1 samples:
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> clean_data (analysis.R:4)
#>   -> [.data.frame (analysis.R:15)
#>   -> anyDuplicated.default
#> 
#> 10 ms (5.6%) - 1 samples:
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> clean_data (analysis.R:4)
#>   -> cut.default
#>   -> .bincode
#> 
#> 10 ms (5.6%) - 1 samples:
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> clean_data (analysis.R:4)
#>   -> cut.default
#>   -> factor
#> 
#> 10 ms (5.6%) - 1 samples:
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> generate_data (analysis.R:3)
#>   -> data.frame (analysis.R:11)
#>   -> make.names
#>   -> order
#>   -> match.arg
#> 
#> ### MEMORY ALLOCATION (by function)
#>    41.03 MB paste
#>    10.01 MB anyDuplicated.default
#>     2.90 MB match.arg
#>     2.38 MB runif
#>     0.61 MB unlist
#> 
#> ### MEMORY ALLOCATION (by line)
#>    41.03 MB analysis.R:22
#>             list(
#>     2.38 MB analysis.R:10
#>             y <- runif(n)
#> 
#> ### Next steps
#> pv_focus(p, "paste")
#> pv_source_context(p, "analysis.R")
#> pv_suggestions(p)
#> pv_help()
```

### Time Analysis

Analyze where time is spent:

``` r
# Self-time: time spent directly in each function
pv_self_time(p)
#>                   label samples time_ms  pct
#> 1                 paste      11     110 61.1
#> 2              .bincode       1      10  5.6
#> 3 anyDuplicated.default       1      10  5.6
#> 4                 apply       1      10  5.6
#> 5                factor       1      10  5.6
#> 6             match.arg       1      10  5.6
#> 7                 runif       1      10  5.6
#> 8                unlist       1      10  5.6

# Total time: time spent in function + all its callees
pv_total_time(p)
#>                    label samples time_ms   pct
#> 1                    FUN      18     180 100.0
#> 2                 lapply      18     180 100.0
#> 3           process_data      18     180 100.0
#> 4         summarize_data      13     130  72.2
#> 5                  paste      11     110  61.1
#> 6             clean_data       3      30  16.7
#> 7            cut.default       2      20  11.1
#> 8          generate_data       2      20  11.1
#> 9               .bincode       1      10   5.6
#> 10          [.data.frame       1      10   5.6
#> 11 anyDuplicated.default       1      10   5.6
#> 12                 apply       1      10   5.6
#> 13  as.matrix.data.frame       1      10   5.6
#> 14              colMeans       1      10   5.6
#> 15            data.frame       1      10   5.6
#> 16                factor       1      10   5.6
#> 17            make.names       1      10   5.6
#> 18             match.arg       1      10   5.6
#> 19                 order       1      10   5.6
#> 20                 runif       1      10   5.6
#> 21                unlist       1      10   5.6

# Filter to significant functions only
pv_self_time(p, min_pct = 5) # >= 5% of time
#>                   label samples time_ms  pct
#> 1                 paste      11     110 61.1
#> 2              .bincode       1      10  5.6
#> 3 anyDuplicated.default       1      10  5.6
#> 4                 apply       1      10  5.6
#> 5                factor       1      10  5.6
#> 6             match.arg       1      10  5.6
#> 7                 runif       1      10  5.6
#> 8                unlist       1      10  5.6
```

### Hot Spots

Find the hottest lines and call paths:

``` r
# Hot source lines with context
pv_print_hot_lines(p, n = 5, context = 3)
#> ## HOT SOURCE LINES
#> 
#> 
#> Rank 1: analysis.R:22 (120 ms, 66.7%)
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
#> Rank 2: analysis.R:10 (10 ms, 5.6%)
#> Function: runif
#> 
#>         7: 
#>         8: generate_data <- function(n) {
#>         9:   x <- rnorm(n)
#> >      10:   y <- runif(n)
#>        11:   data.frame(x = x, y = y, z = x * y)
#>        12: }
#>        13: 
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
#> Rank 2: 10 ms (5.6%) - 1 samples
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> clean_data (analysis.R:4)
#>   -> [.data.frame (analysis.R:15)
#>   -> anyDuplicated.default
#> 
#> Rank 3: 10 ms (5.6%) - 1 samples
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> clean_data (analysis.R:4)
#>   -> cut.default
#>   -> .bincode
#> 
#> Rank 4: 10 ms (5.6%) - 1 samples
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> clean_data (analysis.R:4)
#>   -> cut.default
#>   -> factor
#> 
#> Rank 5: 10 ms (5.6%) - 1 samples
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> generate_data (analysis.R:3)
#>   -> data.frame (analysis.R:11)
#>   -> make.names
#>   -> order
#>   -> match.arg
#> 
#> Rank 6: 10 ms (5.6%) - 1 samples
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> generate_data (analysis.R:3)
#>   -> runif (analysis.R:10)
#> 
#> Rank 7: 10 ms (5.6%) - 1 samples
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> summarize_data (analysis.R:5)
#>   -> apply (analysis.R:22)
#> 
#> Rank 8: 10 ms (5.6%) - 1 samples
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> summarize_data (analysis.R:5)
#>   -> colMeans (analysis.R:22)
#>   -> as.matrix.data.frame
#>   -> unlist
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
#>   Total time:       30 ms ( 16.7%)  - time on call stack
#>   Self time:         0 ms (  0.0%)  - time at top of stack
#>   Child time:       30 ms ( 16.7%)  - time in callees
#>   Appearances:       3 samples
#> 
#> ### Called By
#>       3 calls (100.0%)  process_data
#> 
#> ### Calls To
#>       2 calls ( 66.7%)  cut.default
#>       1 calls ( 33.3%)  [.data.frame
#> 
#> ### Source Locations
#>   No self-time with source info.
#> 
#> ### Next steps
#> pv_focus(p, "cut.default")
#> pv_callers(p, "clean_data")
#> pv_focus(p, "process_data")
```

### Call Relationships

Understand who calls what:

``` r
# Who calls this function?
pv_callers(p, "clean_data")
#>          label samples pct
#> 1 process_data       3 100

# What does this function call?
pv_callees(p, "process_data")
#>            label samples  pct
#> 1 summarize_data      13 72.2
#> 2     clean_data       3 16.7
#> 3  generate_data       2 11.1

# Full caller/callee analysis
pv_print_callers_callees(p, "summarize_data")
#> ## FUNCTION ANALYSIS: summarize_data
#> 
#> 
#> Total time: 130 ms (72.2% of profile)
#> Appearances: 13 samples
#> 
#> ### Called by
#>      13 samples (100.0%)  process_data
#> 
#> ### Calls to
#>      11 samples ( 84.6%)  paste
#>       1 samples (  7.7%)  apply
#>       1 samples (  7.7%)  colMeans
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
#>    41.03 MB paste
#>    10.01 MB anyDuplicated.default
#>     2.90 MB match.arg
#>     2.38 MB runif
#>     0.61 MB unlist
#> 
#> ### Next steps
#> pv_focus(p, "paste")
#> pv_gc_pressure(p)

# Memory by source line
pv_print_memory(p, n = 10, by = "line")
#> ## MEMORY ALLOCATION BY LINE
#> 
#> 
#>    41.03 MB analysis.R:22
#>             list(
#>     2.38 MB analysis.R:10
#>             y <- runif(n)
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
#> [======================================================================]   lapply (100.0%)
#> [======================================================================]     FUN (100.0%)
#> [======================================================================]       process_data (100.0%)
#> [===================================================                   ]         summarize_data (72.2%)
#> [============                                                          ]         clean_data (16.7%)
#> [========                                                              ]         generate_data (11.1%)
#> [===========================================                           ]           paste (61.1%)
#> [========                                                              ]           cut.default (11.1%)
#> [====                                                                  ]           runif (5.6%)
#> [====                                                                  ]           data.frame (5.6%)
#> [====                                                                  ]           apply (5.6%)
#> [====                                                                  ]           [.data.frame (5.6%)
#> [====                                                                  ]           colMeans (5.6%)
#> [====                                                                  ]             factor (5.6%)
#> [====                                                                  ]             .bincode (5.6%)
#> [====                                                                  ]             make.names (5.6%)
#> [====                                                                  ]             anyDuplicated.default (5.6%)
#> [====                                                                  ]             as.matrix.data.frame (5.6%)
#> [====                                                                  ]               order (5.6%)
#> [====                                                                  ]               unlist (5.6%)
#> [====                                                                  ]                 match.arg (5.6%)
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
#> Run pv_help() to see all available functions.

# Get actionable optimization suggestions
pv_print_suggestions(p)
#> ## OPTIMIZATION SUGGESTIONS
#> 
#> 
#> ### Priority 1
#> 
#> category: hot line
#> location: analysis.R:22
#> action: Optimize hot line (66.7%)
#> pattern: paste
#> potential_impact: 120 ms (66.7%)
#> 
#> category: hot line
#> location: analysis.R:10
#> action: Optimize hot line (5.6%)
#> pattern: runif
#> potential_impact: 10 ms (5.6%)
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
#> 2              .bincode       1      10  5.6
#> 3 anyDuplicated.default       1      10  5.6
#> 4                 apply       1      10  5.6
#> 5                factor       1      10  5.6
#> 6             match.arg       1      10  5.6
#> 7                 runif       1      10  5.6
#> 8                unlist       1      10  5.6
```

## Available Functions

| Category | Functions |
|----|----|
| Overview | `pv_help()`, `pv_debrief()`, `pv_print_debrief()`, `pv_example()` |
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
