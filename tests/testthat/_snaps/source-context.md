# pv_source_context snapshot

    Code
      pv_source_context(p, "R/main.R")
    Output
      Showing context around hottest line: 10
      
      ## SOURCE: R/main.R
      
      
      Lines 1-15 (centered on 10)
      
        Time   Mem   Line  Source
      ---------------------------------------------------------------------- 
              -     -    1: # Main file
              -     -    2: outer <- function() {
              -     -    3:   x <- 1
              -     -    4:   y <- 2
              -     -    5:   inner()
              -     -    6: }
              -     -    7: 
              -     -    8: inner <- function() {
              -     -    9:   result <- deep()
      >>>    50   0.0   10:   result
              -     -   11: }
              -     -   12: 
              -     -   13: 
              -     -   14: 
             30 150.0   15:   z <- heavy_computation()
      ---------------------------------------------------------------------- 
      Time in ms, Memory in MB

# pv_source_context handles non-existent file

    Code
      pv_source_context(p, "nonexistent.R")
    Output
      File not found in profiling data.
      Available files:
         R/main.R 
         R/utils.R 
         R/helper.R 

# pv_source_context auto-selects hottest line when linenum is NULL

    Code
      pv_source_context(p, "R/main.R", linenum = NULL)
    Output
      Showing context around hottest line: 10
      
      ## SOURCE: R/main.R
      
      
      Lines 1-15 (centered on 10)
      
        Time   Mem   Line  Source
      ---------------------------------------------------------------------- 
              -     -    1: # Main file
              -     -    2: outer <- function() {
              -     -    3:   x <- 1
              -     -    4:   y <- 2
              -     -    5:   inner()
              -     -    6: }
              -     -    7: 
              -     -    8: inner <- function() {
              -     -    9:   result <- deep()
      >>>    50   0.0   10:   result
              -     -   11: }
              -     -   12: 
              -     -   13: 
              -     -   14: 
             30 150.0   15:   z <- heavy_computation()
      ---------------------------------------------------------------------- 
      Time in ms, Memory in MB

# pv_source_context respects linenum parameter

    Code
      pv_source_context(p, "R/main.R", linenum = 5)
    Output
      ## SOURCE: R/main.R
      
      
      Lines 1-15 (centered on 5)
      
        Time   Mem   Line  Source
      ---------------------------------------------------------------------- 
              -     -    1: # Main file
              -     -    2: outer <- function() {
              -     -    3:   x <- 1
              -     -    4:   y <- 2
      >>>     -     -    5:   inner()
              -     -    6: }
              -     -    7: 
              -     -    8: inner <- function() {
              -     -    9:   result <- deep()
             50   0.0   10:   result
              -     -   11: }
              -     -   12: 
              -     -   13: 
              -     -   14: 
             30 150.0   15:   z <- heavy_computation()
      ---------------------------------------------------------------------- 
      Time in ms, Memory in MB

# pv_print_file_summary snapshot

    Code
      pv_print_file_summary(p)
    Output
      ## FILE SUMMARY
      
      
          50 ms (100.0%)  R/main.R
          20 ms ( 40.0%)  R/utils.R
          10 ms ( 20.0%)  R/helper.R

# pv_print_file_summary handles no source refs

    Code
      pv_print_file_summary(p)
    Output
      No source location data available.
      Use devtools::load_all() to enable source references.

