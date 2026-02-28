# debrief

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

Get a comprehensive overview with
[`pv_summary()`](https://emilhvitfeldt.github.io/debrief/reference/pv_summary.md):

``` r
pv_summary(p)
#> ====================================================================== 
#>                           PROFILING SUMMARY
#> ====================================================================== 
#> 
#> Total time: 190 ms (19 samples @ 10 ms interval)
#> Source references: available
#> 
#> 
#> --- TOP FUNCTIONS BY SELF-TIME ---------------------------------------
#>    120 ms ( 63.2%)  paste
#>     20 ms ( 10.5%)  .bincode
#>     10 ms (  5.3%)  anyDuplicated.default
#>     10 ms (  5.3%)  complete.cases
#>     10 ms (  5.3%)  rnorm
#>     10 ms (  5.3%)  table
#>     10 ms (  5.3%)  unlist
#> 
#> --- TOP FUNCTIONS BY TOTAL TIME --------------------------------------
#>    190 ms (100.0%)  FUN
#>    190 ms (100.0%)  lapply
#>    190 ms (100.0%)  process_data
#>    140 ms ( 73.7%)  summarize_data
#>    120 ms ( 63.2%)  paste
#>     40 ms ( 21.1%)  clean_data
#>     20 ms ( 10.5%)  .bincode
#>     20 ms ( 10.5%)  cut.default
#>     10 ms (  5.3%)  [.data.frame
#>     10 ms (  5.3%)  anyDuplicated.default
#> 
#> --- HOT LINES (by self-time) -----------------------------------------
#>    130 ms ( 68.4%)  analysis.R:22
#>                    list(
#>     10 ms (  5.3%)  analysis.R:9
#>                    x <- rnorm(n)
#> 
#> --- HOT CALL PATHS ---------------------------------------------------
#> 
#> 120 ms (63.2%) - 12 samples:
#>     lapply
#>   → FUN
#>   → process_data
#>   → summarize_data (analysis.R:5)
#>   → paste (analysis.R:22)
#> 
#> 20 ms (10.5%) - 2 samples:
#>     lapply
#>   → FUN
#>   → process_data
#>   → clean_data (analysis.R:4)
#>   → cut.default
#>   → .bincode
#> 
#> 10 ms (5.3%) - 1 samples:
#>     lapply
#>   → FUN
#>   → process_data
#>   → clean_data (analysis.R:4)
#>   → [.data.frame (analysis.R:15)
#>   → anyDuplicated.default
#> 
#> 10 ms (5.3%) - 1 samples:
#>     lapply
#>   → FUN
#>   → process_data
#>   → clean_data (analysis.R:4)
#>   → complete.cases
#> 
#> 10 ms (5.3%) - 1 samples:
#>     lapply
#>   → FUN
#>   → process_data
#>   → generate_data (analysis.R:3)
#>   → rnorm (analysis.R:9)
#> 
#> --- MEMORY ALLOCATION (by function) ----------------------------------
#>    55.07 MB paste
#>    10.01 MB anyDuplicated.default
#>     3.29 MB complete.cases
#>     1.62 MB rnorm
#>     0.76 MB table
#> 
#> --- MEMORY ALLOCATION (by line) --------------------------------------
#>    55.83 MB analysis.R:22
#>             list(
#>     1.62 MB analysis.R:9
#>             x <- rnorm(n)
#> ----------------------------------------------------------------------
```

### Time Analysis

Analyze where time is spent:

``` r
# Self-time: time spent directly in each function
pv_self_time(p)
#>                   label samples time_ms  pct
#> 1                 paste      12     120 63.2
#> 2              .bincode       2      20 10.5
#> 3 anyDuplicated.default       1      10  5.3
#> 4        complete.cases       1      10  5.3
#> 5                 rnorm       1      10  5.3
#> 6                 table       1      10  5.3
#> 7                unlist       1      10  5.3

# Total time: time spent in function + all its callees
pv_total_time(p)
#>                    label samples time_ms   pct
#> 1                    FUN      19     190 100.0
#> 2                 lapply      19     190 100.0
#> 3           process_data      19     190 100.0
#> 4         summarize_data      14     140  73.7
#> 5                  paste      12     120  63.2
#> 6             clean_data       4      40  21.1
#> 7               .bincode       2      20  10.5
#> 8            cut.default       2      20  10.5
#> 9           [.data.frame       1      10   5.3
#> 10 anyDuplicated.default       1      10   5.3
#> 11  as.matrix.data.frame       1      10   5.3
#> 12              colMeans       1      10   5.3
#> 13        complete.cases       1      10   5.3
#> 14         generate_data       1      10   5.3
#> 15                 rnorm       1      10   5.3
#> 16                 table       1      10   5.3
#> 17                unlist       1      10   5.3

# Filter to significant functions only
pv_self_time(p, min_pct = 5) # >= 5% of time
#>                   label samples time_ms  pct
#> 1                 paste      12     120 63.2
#> 2              .bincode       2      20 10.5
#> 3 anyDuplicated.default       1      10  5.3
#> 4        complete.cases       1      10  5.3
#> 5                 rnorm       1      10  5.3
#> 6                 table       1      10  5.3
#> 7                unlist       1      10  5.3
```

### Hot Spots

Find the hottest lines and call paths:

``` r
# Hot source lines with context
pv_print_hot_lines(p, n = 5, context = 3)
#> ====================================================================== 
#>                            HOT SOURCE LINES
#> ====================================================================== 
#> 
#> Rank 1: analysis.R:22 (130 ms, 68.4%)
#> Function: paste
#> 
#>        19: }
#>        20: 
#>        21: summarize_data <- function(df) {
#>  >>>   22:   list(
#>        23:     means = colMeans(df[, c("x", "y", "z")]),
#>        24:     sds = apply(df[, c("x", "y", "z")], 2, sd),
#>        25:     counts = table(df$category),
#> 
#> Rank 2: analysis.R:9 (10 ms, 5.3%)
#> Function: rnorm
#> 
#>         6: }
#>         7: 
#>         8: generate_data <- function(n) {
#>  >>>    9:   x <- rnorm(n)
#>        10:   y <- runif(n)
#>        11:   data.frame(x = x, y = y, z = x * y)
#>        12: }

# Hot call paths
pv_print_hot_paths(p, n = 10)
#> ====================================================================== 
#>                             HOT CALL PATHS
#> ====================================================================== 
#> 
#> Rank 1: 120 ms (63.2%) - 12 samples
#>     lapply
#>   → FUN
#>   → process_data
#>   → summarize_data (analysis.R:5)
#>   → paste (analysis.R:22)
#> 
#> Rank 2: 20 ms (10.5%) - 2 samples
#>     lapply
#>   → FUN
#>   → process_data
#>   → clean_data (analysis.R:4)
#>   → cut.default
#>   → .bincode
#> 
#> Rank 3: 10 ms (5.3%) - 1 samples
#>     lapply
#>   → FUN
#>   → process_data
#>   → clean_data (analysis.R:4)
#>   → [.data.frame (analysis.R:15)
#>   → anyDuplicated.default
#> 
#> Rank 4: 10 ms (5.3%) - 1 samples
#>     lapply
#>   → FUN
#>   → process_data
#>   → clean_data (analysis.R:4)
#>   → complete.cases
#> 
#> Rank 5: 10 ms (5.3%) - 1 samples
#>     lapply
#>   → FUN
#>   → process_data
#>   → generate_data (analysis.R:3)
#>   → rnorm (analysis.R:9)
#> 
#> Rank 6: 10 ms (5.3%) - 1 samples
#>     lapply
#>   → FUN
#>   → process_data
#>   → summarize_data (analysis.R:5)
#>   → colMeans (analysis.R:22)
#>   → as.matrix.data.frame
#>   → unlist
#> 
#> Rank 7: 10 ms (5.3%) - 1 samples
#>     lapply
#>   → FUN
#>   → process_data
#>   → summarize_data (analysis.R:5)
#>   → table (analysis.R:22)
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
#>   Total time:       40 ms ( 21.1%)  - time on call stack
#>   Self time:         0 ms (  0.0%)  - time at top of stack
#>   Child time:       40 ms ( 21.1%)  - time in callees
#>   Appearances:       4 samples
#> 
#> --- Called By -------------------------------------------------------
#>       4 calls (100.0%)  process_data
#> 
#> --- Calls To --------------------------------------------------------
#>       2 calls ( 50.0%)  cut.default
#>       1 calls ( 25.0%)  [.data.frame
#>       1 calls ( 25.0%)  complete.cases
#> 
#> --- Source Locations ------------------------------------------------
#>   No self-time with source info.
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
#> 1 summarize_data      14 73.7
#> 2     clean_data       4 21.1
#> 3  generate_data       1  5.3

# Full caller/callee analysis
pv_print_callers_callees(p, "summarize_data")
#> ====================================================================== 
#>                   FUNCTION ANALYSIS: summarize_data
#> ====================================================================== 
#> 
#> Total time: 140 ms (73.7% of profile)
#> Appearances: 14 samples
#> 
#> --- Called by --------------------------------------------------
#>      14 samples (100.0%)  process_data
#> 
#> --- Calls to ---------------------------------------------------
#>      12 samples ( 85.7%)  paste
#>       1 samples (  7.1%)  colMeans
#>       1 samples (  7.1%)  table
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
#>    55.07 MB paste
#>    10.01 MB anyDuplicated.default
#>     3.29 MB complete.cases
#>     1.62 MB rnorm
#>     0.76 MB table

# Memory by source line
pv_print_memory(p, n = 10, by = "line")
#> ====================================================================== 
#>                       MEMORY ALLOCATION BY LINE
#> ====================================================================== 
#> 
#>    55.83 MB analysis.R:22
#>             list(
#>     1.62 MB analysis.R:9
#>             x <- rnorm(n)
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
#> [======================================================================]   lapply (100.0%)
#> [======================================================================]     FUN (100.0%)
#> [======================================================================]       process_data (100.0%)
#> [====================================================                  ]         summarize_data (73.7%)
#> [===============                                                       ]         clean_data (21.1%)
#> [====                                                                  ]         generate_data (5.3%)
#> [============================================                          ]           paste (63.2%)
#> [=======                                                               ]           cut.default (10.5%)
#> [====                                                                  ]           colMeans (5.3%)
#> [====                                                                  ]           rnorm (5.3%)
#> [====                                                                  ]           complete.cases (5.3%)
#> [====                                                                  ]           table (5.3%)
#> [====                                                                  ]           [.data.frame (5.3%)
#> [=======                                                               ]             .bincode (10.5%)
#> [====                                                                  ]             as.matrix.data.frame (5.3%)
#> [====                                                                  ]             anyDuplicated.default (5.3%)
#> [====                                                                  ]               unlist (5.3%)
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
#> IMPROVED: 260 ms -> 210 ms (1.2x faster, saved 50 ms)
#> 
#> --- Biggest Changes --------------------------------------------------
#> Function                           Before      After       Diff   Change
#> ------------------------------------------------------------------------ 
#> c                                     200          0       -200    -100%
#> head                                    0         90        +90      new
#> rnorm                                   0         60        +60      new
#> <GC>                                   60         40        -20     -33%
#> paste                                   0         20        +20      new
#> 
#> --- Top Improvements ------------------------------------------------
#>   c: 200 ms -> 0 ms (saved 200 ms)
#>   <GC>: 60 ms -> 40 ms (saved 20 ms)
#> 
#> --- Regressions -----------------------------------------------------
#>   head: 0 ms -> 90 ms (added 90 ms)
#>   rnorm: 0 ms -> 60 ms (added 60 ms)
#>   paste: 0 ms -> 20 ms (added 20 ms)

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
#>   1*  dataframe_ops                    120       12    fastest
#>   2   vectorized                       210       21      1.75x
#>   3   growing_vector                   260       26      2.17x
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
#> [hot line] analysis.R:22
#>     Line 'paste' at analysis.R:22 consumes 68.4% of time. Focus optimization efforts here first.
#>     Potential impact: 130 ms (68.4%)
#> 
#> [hot line] analysis.R:9
#>     Line 'rnorm' at analysis.R:9 consumes 5.3% of time. Focus optimization efforts here first.
#>     Potential impact: 10 ms (5.3%)
#> 
#> === Priority 2 ===
#> 
#> [hot function] paste
#>     Function 'paste' has highest self-time (63.2%). Profile this function in isolation to find micro-optimization opportunities.
#>     Potential impact: 120 ms (63.2%)
#> 
#> === Priority 3 ===
#> 
#> [string operations] paste
#>     String operations are significant (63.2%). Consider: (1) pre-computing strings outside loops, (2) using fixed=TRUE in grep/gsub when not using regex, (3) using stringi package for heavy string processing.
#>     Potential impact: Up to 60 ms (32%)
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
#> 1                 paste      12     120 63.2
#> 2              .bincode       2      20 10.5
#> 3 anyDuplicated.default       1      10  5.3
#> 4        complete.cases       1      10  5.3
#> 5                 rnorm       1      10  5.3
#> 6                 table       1      10  5.3
#> 7                unlist       1      10  5.3
```

## Available Functions

| Category          | Functions                                                                                                                                                                                                                                                                                                                                                                              |
|-------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Overview          | [`pv_summary()`](https://emilhvitfeldt.github.io/debrief/reference/pv_summary.md), [`pv_example()`](https://emilhvitfeldt.github.io/debrief/reference/pv_example.md)                                                                                                                                                                                                                   |
| Time Analysis     | [`pv_self_time()`](https://emilhvitfeldt.github.io/debrief/reference/pv_self_time.md), [`pv_total_time()`](https://emilhvitfeldt.github.io/debrief/reference/pv_total_time.md)                                                                                                                                                                                                         |
| Hot Spots         | [`pv_hot_lines()`](https://emilhvitfeldt.github.io/debrief/reference/pv_hot_lines.md), [`pv_hot_paths()`](https://emilhvitfeldt.github.io/debrief/reference/pv_hot_paths.md), [`pv_print_hot_lines()`](https://emilhvitfeldt.github.io/debrief/reference/pv_print_hot_lines.md), [`pv_print_hot_paths()`](https://emilhvitfeldt.github.io/debrief/reference/pv_print_hot_paths.md)     |
| Memory            | [`pv_memory()`](https://emilhvitfeldt.github.io/debrief/reference/pv_memory.md), [`pv_memory_lines()`](https://emilhvitfeldt.github.io/debrief/reference/pv_memory_lines.md), [`pv_print_memory()`](https://emilhvitfeldt.github.io/debrief/reference/pv_print_memory.md)                                                                                                              |
| Call Analysis     | [`pv_callers()`](https://emilhvitfeldt.github.io/debrief/reference/pv_callers.md), [`pv_callees()`](https://emilhvitfeldt.github.io/debrief/reference/pv_callees.md), [`pv_call_depth()`](https://emilhvitfeldt.github.io/debrief/reference/pv_call_depth.md), [`pv_call_stats()`](https://emilhvitfeldt.github.io/debrief/reference/pv_call_stats.md)                                 |
| Function Analysis | [`pv_focus()`](https://emilhvitfeldt.github.io/debrief/reference/pv_focus.md), [`pv_recursive()`](https://emilhvitfeldt.github.io/debrief/reference/pv_recursive.md)                                                                                                                                                                                                                   |
| Source Context    | [`pv_source_context()`](https://emilhvitfeldt.github.io/debrief/reference/pv_source_context.md), [`pv_file_summary()`](https://emilhvitfeldt.github.io/debrief/reference/pv_file_summary.md)                                                                                                                                                                                           |
| Visualization     | [`pv_flame()`](https://emilhvitfeldt.github.io/debrief/reference/pv_flame.md), [`pv_flame_condense()`](https://emilhvitfeldt.github.io/debrief/reference/pv_flame_condense.md)                                                                                                                                                                                                         |
| Comparison        | [`pv_compare()`](https://emilhvitfeldt.github.io/debrief/reference/pv_compare.md), [`pv_print_compare()`](https://emilhvitfeldt.github.io/debrief/reference/pv_print_compare.md), [`pv_compare_many()`](https://emilhvitfeldt.github.io/debrief/reference/pv_compare_many.md), [`pv_print_compare_many()`](https://emilhvitfeldt.github.io/debrief/reference/pv_print_compare_many.md) |
| Diagnostics       | [`pv_gc_pressure()`](https://emilhvitfeldt.github.io/debrief/reference/pv_gc_pressure.md), [`pv_suggestions()`](https://emilhvitfeldt.github.io/debrief/reference/pv_suggestions.md)                                                                                                                                                                                                   |
| Export            | [`pv_to_json()`](https://emilhvitfeldt.github.io/debrief/reference/pv_to_json.md), [`pv_to_list()`](https://emilhvitfeldt.github.io/debrief/reference/pv_to_list.md)                                                                                                                                                                                                                   |

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
