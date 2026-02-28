# pv_print_hot_lines snapshot

    Code
      pv_print_hot_lines(p, n = 3)
    Output
      ====================================================================== 
                                 HOT SOURCE LINES
      ====================================================================== 
      
      Rank 1: R/utils.R:5 (20 ms, 40.0%)
      Function: deep
      
              2: deep <- function() {
              3:   Sys.sleep(0.01)
              4:   42
       >>>    5:   x <- rnorm(1000)
              6: }
      
      Rank 2: R/helper.R:20 (10 ms, 20.0%)
      Function: helper
      
             17: 
             18: 
             19: 
       >>>   20:   do_work()
      
      Rank 3: R/main.R:10 (10 ms, 20.0%)
      Function: outer
      
              7: 
              8: inner <- function() {
              9:   result <- deep()
       >>>   10:   result
             11: }
             12: 
             13: 
      

# pv_print_hot_lines handles no source refs

    Code
      pv_print_hot_lines(p)
    Output
      No source location data available.
      Use devtools::load_all() to enable source references.

# pv_print_hot_paths snapshot

    Code
      pv_print_hot_paths(p, n = 3)
    Output
      ====================================================================== 
                                  HOT CALL PATHS
      ====================================================================== 
      
      Rank 1: 20 ms (40.0%) - 2 samples
          outer (R/main.R:10)
        -> inner (R/main.R:15)
        -> deep (R/utils.R:5)
      
      Rank 2: 10 ms (20.0%) - 1 samples
          outer (R/main.R:10)
      
      Rank 3: 10 ms (20.0%) - 1 samples
          outer (R/main.R:10)
        -> helper (R/helper.R:20)
      

