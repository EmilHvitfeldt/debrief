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

``` R
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
```

The
[`pv_help()`](https://emilhvitfeldt.github.io/debrief/reference/pv_help.md)
function lists all available functions by category.

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
[`pv_print_debrief()`](https://emilhvitfeldt.github.io/debrief/reference/pv_print_debrief.md):

``` r
pv_print_debrief(p)
#> ## PROFILING SUMMARY
#> 
#> 
#> Total time: 190 ms (19 samples @ 10 ms interval)
#> Source references: available
#> 
#> 
#> ### TOP FUNCTIONS BY SELF-TIME
#>    120 ms ( 63.2%)  paste
#>     20 ms ( 10.5%)  .bincode
#>     10 ms (  5.3%)  <GC>
#>     10 ms (  5.3%)  aperm.default
#>     10 ms (  5.3%)  apply
#>     10 ms (  5.3%)  complete.cases
#>     10 ms (  5.3%)  constantFoldCall
#> 
#> ### TOP FUNCTIONS BY TOTAL TIME
#>    180 ms ( 94.7%)  FUN
#>    180 ms ( 94.7%)  lapply
#>    180 ms ( 94.7%)  process_data
#>    130 ms ( 68.4%)  summarize_data
#>    120 ms ( 63.2%)  paste
#>     50 ms ( 26.3%)  clean_data
#>     20 ms ( 10.5%)  .bincode
#>     20 ms ( 10.5%)  apply
#>     20 ms ( 10.5%)  cut.default
#>     20 ms ( 10.5%)  scale.default
#> 
#> ### HOT LINES (by self-time)
#>    130 ms ( 68.4%)  analysis.R:22
#>                    list(
#> 
#> ### HOT CALL PATHS
#> 
#> 120 ms (63.2%) - 12 samples:
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> summarize_data (analysis.R:5)
#>   -> paste (analysis.R:22)
#> 
#> 20 ms (10.5%) - 2 samples:
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> clean_data (analysis.R:4)
#>   -> cut.default
#>   -> .bincode
#> 
#> 10 ms (5.3%) - 1 samples:
#>     base::tryCatch
#>   -> compiler:::tryCmpfun (analysis.R:3)
#>   -> cmpfun
#>   -> genCode
#>   -> cmp
#>   -> cmpCall
#>   -> tryInline
#>   -> h
#>   -> cmp
#>   -> cmpCall
#>   -> cmpCallSymFun
#>   -> cmpCallArgs
#>   -> genCode
#>   -> cmp
#>   -> constantFold
#>   -> constantFoldCall
#> 
#> 10 ms (5.3%) - 1 samples:
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> clean_data (analysis.R:4)
#>   -> complete.cases
#> 
#> 10 ms (5.3%) - 1 samples:
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> clean_data (analysis.R:4)
#>   -> scale.default
#>   -> apply
#>   -> FUN
#>   -> <GC>
#> 
#> ### MEMORY ALLOCATION (by function)
#>    35.97 MB paste
#>    18.78 MB aperm.default
#>    10.87 MB <GC>
#>     3.43 MB apply
#>     3.28 MB complete.cases
#> 
#> ### MEMORY ALLOCATION (by line)
#>    39.40 MB analysis.R:22
#>             list(
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
#>              label samples time_ms  pct
#> 1            paste      12     120 63.2
#> 2         .bincode       2      20 10.5
#> 3             <GC>       1      10  5.3
#> 4    aperm.default       1      10  5.3
#> 5            apply       1      10  5.3
#> 6   complete.cases       1      10  5.3
#> 7 constantFoldCall       1      10  5.3

# Total time: time spent in function + all its callees
pv_total_time(p)
#>                   label samples time_ms  pct
#> 1                   FUN      18     180 94.7
#> 2                lapply      18     180 94.7
#> 3          process_data      18     180 94.7
#> 4        summarize_data      13     130 68.4
#> 5                 paste      12     120 63.2
#> 6            clean_data       5      50 26.3
#> 7              .bincode       2      20 10.5
#> 8                 apply       2      20 10.5
#> 9           cut.default       2      20 10.5
#> 10        scale.default       2      20 10.5
#> 11                 <GC>       1      10  5.3
#> 12        aperm.default       1      10  5.3
#> 13       base::tryCatch       1      10  5.3
#> 14                  cmp       1      10  5.3
#> 15              cmpCall       1      10  5.3
#> 16          cmpCallArgs       1      10  5.3
#> 17        cmpCallSymFun       1      10  5.3
#> 18               cmpfun       1      10  5.3
#> 19 compiler:::tryCmpfun       1      10  5.3
#> 20       complete.cases       1      10  5.3
#> 21         constantFold       1      10  5.3
#> 22     constantFoldCall       1      10  5.3
#> 23              genCode       1      10  5.3
#> 24                    h       1      10  5.3
#> 25                sweep       1      10  5.3
#> 26            tryInline       1      10  5.3

# Filter to significant functions only
pv_self_time(p, min_pct = 5) # >= 5% of time
#>              label samples time_ms  pct
#> 1            paste      12     120 63.2
#> 2         .bincode       2      20 10.5
#> 3             <GC>       1      10  5.3
#> 4    aperm.default       1      10  5.3
#> 5            apply       1      10  5.3
#> 6   complete.cases       1      10  5.3
#> 7 constantFoldCall       1      10  5.3
```

### Hot Spots

Find the hottest lines and call paths:

``` r
# Hot source lines with context
pv_print_hot_lines(p, n = 5, context = 3)
#> ## HOT SOURCE LINES
#> 
#> 
#> Rank 1: analysis.R:22 (130 ms, 68.4%)
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
#> 
#> ### Next steps
#> pv_focus(p, "paste")
#> pv_source_context(p, "analysis.R")

# Hot call paths
pv_print_hot_paths(p, n = 10)
#> ## HOT CALL PATHS
#> 
#> 
#> Rank 1: 120 ms (63.2%) - 12 samples
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> summarize_data (analysis.R:5)
#>   -> paste (analysis.R:22)
#> 
#> Rank 2: 20 ms (10.5%) - 2 samples
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> clean_data (analysis.R:4)
#>   -> cut.default
#>   -> .bincode
#> 
#> Rank 3: 10 ms (5.3%) - 1 samples
#>     base::tryCatch
#>   -> compiler:::tryCmpfun (analysis.R:3)
#>   -> cmpfun
#>   -> genCode
#>   -> cmp
#>   -> cmpCall
#>   -> tryInline
#>   -> h
#>   -> cmp
#>   -> cmpCall
#>   -> cmpCallSymFun
#>   -> cmpCallArgs
#>   -> genCode
#>   -> cmp
#>   -> constantFold
#>   -> constantFoldCall
#> 
#> Rank 4: 10 ms (5.3%) - 1 samples
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> clean_data (analysis.R:4)
#>   -> complete.cases
#> 
#> Rank 5: 10 ms (5.3%) - 1 samples
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> clean_data (analysis.R:4)
#>   -> scale.default
#>   -> apply
#>   -> FUN
#>   -> <GC>
#> 
#> Rank 6: 10 ms (5.3%) - 1 samples
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> clean_data (analysis.R:4)
#>   -> scale.default
#>   -> sweep
#>   -> aperm.default
#> 
#> Rank 7: 10 ms (5.3%) - 1 samples
#>     lapply
#>   -> FUN
#>   -> process_data
#>   -> summarize_data (analysis.R:5)
#>   -> apply (analysis.R:22)
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
#>   Total time:       50 ms ( 26.3%)  - time on call stack
#>   Self time:         0 ms (  0.0%)  - time at top of stack
#>   Child time:       50 ms ( 26.3%)  - time in callees
#>   Appearances:       5 samples
#> 
#> ### Called By
#>       5 calls (100.0%)  process_data
#> 
#> ### Calls To
#>       2 calls ( 40.0%)  cut.default
#>       2 calls ( 40.0%)  scale.default
#>       1 calls ( 20.0%)  complete.cases
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
#> 1 process_data       5 100

# What does this function call?
pv_callees(p, "process_data")
#>            label samples  pct
#> 1 summarize_data      13 72.2
#> 2     clean_data       5 27.8

# Full caller/callee analysis
pv_print_callers_callees(p, "summarize_data")
#> ## FUNCTION ANALYSIS: summarize_data
#> 
#> 
#> Total time: 130 ms (68.4% of profile)
#> Appearances: 13 samples
#> 
#> ### Called by
#>      13 samples (100.0%)  process_data
#> 
#> ### Calls to
#>      12 samples ( 92.3%)  paste
#>       1 samples (  7.7%)  apply
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
#>    35.97 MB paste
#>    18.78 MB aperm.default
#>    10.87 MB <GC>
#>     3.43 MB apply
#>     3.28 MB complete.cases
#>     0.82 MB constantFoldCall
#> 
#> ### Next steps
#> pv_focus(p, "paste")
#> pv_gc_pressure(p)

# Memory by source line
pv_print_memory(p, n = 10, by = "line")
#> ## MEMORY ALLOCATION BY LINE
#> 
#> 
#>    39.40 MB analysis.R:22
#>             list(
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
#> Total time: 190 ms | Width: 70 chars | Min: 2%
#> 
#> [======================================================================] (root) 100%
#> [==================================================================    ]   lapply (94.7%)
#> [====                                                                  ]   base::tryCatch (5.3%)
#> [==================================================================    ]     FUN (94.7%)
#> [====                                                                  ]     compiler:::tryCmpfun (5.3%)
#> [==================================================================    ]       process_data (94.7%)
#> [====                                                                  ]       cmpfun (5.3%)
#> [================================================                      ]         summarize_data (68.4%)
#> [==================                                                    ]         clean_data (26.3%)
#> [====                                                                  ]         genCode (5.3%)
#> [============================================                          ]           paste (63.2%)
#> [=======                                                               ]           cut.default (10.5%)
#> [=======                                                               ]           scale.default (10.5%)
#> [====                                                                  ]           cmp (5.3%)
#> [====                                                                  ]           complete.cases (5.3%)
#> [====                                                                  ]           apply (5.3%)
#> [=======                                                               ]             .bincode (10.5%)
#> [====                                                                  ]             cmpCall (5.3%)
#> [====                                                                  ]             apply (5.3%)
#> [====                                                                  ]             sweep (5.3%)
#> [====                                                                  ]               tryInline (5.3%)
#> [====                                                                  ]               FUN (5.3%)
#> [====                                                                  ]               aperm.default (5.3%)
#> [====                                                                  ]                 h (5.3%)
#> [====                                                                  ]                 <GC> (5.3%)
#> [====                                                                  ]                   cmp (5.3%)
#> [====                                                                  ]                     cmpCall (5.3%)
#> [====                                                                  ]                       cmpCallSymFun (5.3%)
#> [====                                                                  ]                         cmpCallArgs (5.3%)
#> [====                                                                  ]                           genCode (5.3%)
#> [====                                                                  ]                             cmp (5.3%)
#> [====                                                                  ]                               constantFold (5.3%)
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
#> before_ms: 300
#> after_ms: 210
#> diff_ms: -90
#> speedup: 1.43x
#> 
#> ### Biggest Changes
#> Function                           Before      After       Diff   Change
#> c                                     260          0       -260    -100%
#> head                                    0        100       +100      new
#> rnorm                                   0         60        +60      new
#> paste                                   0         10        +10      new
#> 
#> ### Top Improvements
#>   c: 260 -> 0 (-260 ms)
#> 
#> ### Regressions
#>   head: 0 -> 100 (+100 ms)
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
#> action: Optimize hot line (68.4%)
#> pattern: paste
#> potential_impact: 130 ms (68.4%)
#> 
#> ### Priority 2
#> 
#> category: hot function
#> location: paste
#> action: Profile in isolation (63.2% self-time)
#> pattern: paste
#> potential_impact: 120 ms (63.2%)
#> 
#> ### Priority 3
#> 
#> category: string operations
#> location: paste
#> action: Optimize string operations (63.2%)
#> pattern: string ops in loops, regex without fixed=TRUE
#> replacement: pre-compute, fixed=TRUE, stringi package
#> potential_impact: Up to 60 ms (32%)
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
#>              label samples time_ms  pct
#> 1            paste      12     120 63.2
#> 2         .bincode       2      20 10.5
#> 3             <GC>       1      10  5.3
#> 4    aperm.default       1      10  5.3
#> 5            apply       1      10  5.3
#> 6   complete.cases       1      10  5.3
#> 7 constantFoldCall       1      10  5.3
```

## Available Functions

| Category          | Functions                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
|-------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Overview          | [`pv_help()`](https://emilhvitfeldt.github.io/debrief/reference/pv_help.md), [`pv_debrief()`](https://emilhvitfeldt.github.io/debrief/reference/pv_debrief.md), [`pv_print_debrief()`](https://emilhvitfeldt.github.io/debrief/reference/pv_print_debrief.md), [`pv_example()`](https://emilhvitfeldt.github.io/debrief/reference/pv_example.md)                                                                                                                            |
| Time Analysis     | [`pv_self_time()`](https://emilhvitfeldt.github.io/debrief/reference/pv_self_time.md), [`pv_total_time()`](https://emilhvitfeldt.github.io/debrief/reference/pv_total_time.md)                                                                                                                                                                                                                                                                                              |
| Hot Spots         | [`pv_hot_lines()`](https://emilhvitfeldt.github.io/debrief/reference/pv_hot_lines.md), [`pv_hot_paths()`](https://emilhvitfeldt.github.io/debrief/reference/pv_hot_paths.md), [`pv_worst_line()`](https://emilhvitfeldt.github.io/debrief/reference/pv_worst_line.md), [`pv_print_hot_lines()`](https://emilhvitfeldt.github.io/debrief/reference/pv_print_hot_lines.md), [`pv_print_hot_paths()`](https://emilhvitfeldt.github.io/debrief/reference/pv_print_hot_paths.md) |
| Memory            | [`pv_memory()`](https://emilhvitfeldt.github.io/debrief/reference/pv_memory.md), [`pv_memory_lines()`](https://emilhvitfeldt.github.io/debrief/reference/pv_memory_lines.md), [`pv_print_memory()`](https://emilhvitfeldt.github.io/debrief/reference/pv_print_memory.md)                                                                                                                                                                                                   |
| Call Analysis     | [`pv_callers()`](https://emilhvitfeldt.github.io/debrief/reference/pv_callers.md), [`pv_callees()`](https://emilhvitfeldt.github.io/debrief/reference/pv_callees.md), [`pv_call_depth()`](https://emilhvitfeldt.github.io/debrief/reference/pv_call_depth.md), [`pv_call_stats()`](https://emilhvitfeldt.github.io/debrief/reference/pv_call_stats.md)                                                                                                                      |
| Function Analysis | [`pv_focus()`](https://emilhvitfeldt.github.io/debrief/reference/pv_focus.md), [`pv_recursive()`](https://emilhvitfeldt.github.io/debrief/reference/pv_recursive.md)                                                                                                                                                                                                                                                                                                        |
| Source Context    | [`pv_source_context()`](https://emilhvitfeldt.github.io/debrief/reference/pv_source_context.md), [`pv_file_summary()`](https://emilhvitfeldt.github.io/debrief/reference/pv_file_summary.md)                                                                                                                                                                                                                                                                                |
| Visualization     | [`pv_flame()`](https://emilhvitfeldt.github.io/debrief/reference/pv_flame.md), [`pv_flame_condense()`](https://emilhvitfeldt.github.io/debrief/reference/pv_flame_condense.md)                                                                                                                                                                                                                                                                                              |
| Comparison        | [`pv_compare()`](https://emilhvitfeldt.github.io/debrief/reference/pv_compare.md), [`pv_print_compare()`](https://emilhvitfeldt.github.io/debrief/reference/pv_print_compare.md), [`pv_compare_many()`](https://emilhvitfeldt.github.io/debrief/reference/pv_compare_many.md), [`pv_print_compare_many()`](https://emilhvitfeldt.github.io/debrief/reference/pv_print_compare_many.md)                                                                                      |
| Diagnostics       | [`pv_gc_pressure()`](https://emilhvitfeldt.github.io/debrief/reference/pv_gc_pressure.md), [`pv_suggestions()`](https://emilhvitfeldt.github.io/debrief/reference/pv_suggestions.md)                                                                                                                                                                                                                                                                                        |
| Export            | [`pv_to_json()`](https://emilhvitfeldt.github.io/debrief/reference/pv_to_json.md), [`pv_to_list()`](https://emilhvitfeldt.github.io/debrief/reference/pv_to_list.md)                                                                                                                                                                                                                                                                                                        |

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
