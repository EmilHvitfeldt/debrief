# pv_print_debrief snapshot

    Code
      pv_print_debrief(p)
    Output
      ## PROFILING SUMMARY
      
      
      Total time: 50 ms (5 samples @ 10 ms interval)
      Source references: available
      
      
      ### TOP FUNCTIONS BY SELF-TIME
          20 ms ( 40.0%)  deep
          10 ms ( 20.0%)  helper
          10 ms ( 20.0%)  inner
          10 ms ( 20.0%)  outer
      
      ### TOP FUNCTIONS BY TOTAL TIME
          50 ms (100.0%)  outer
          30 ms ( 60.0%)  inner
          20 ms ( 40.0%)  deep
          10 ms ( 20.0%)  helper
      
      ### HOT LINES (by self-time)
          20 ms ( 40.0%)  R/utils.R:5
                         x <- rnorm(1000)
          10 ms ( 20.0%)  R/helper.R:20
                         do_work()
          10 ms ( 20.0%)  R/main.R:10
                         result
          10 ms ( 20.0%)  R/main.R:15
                         z <- heavy_computation()
      
      ### HOT CALL PATHS
      
      20 ms (40.0%) - 2 samples:
          outer (R/main.R:10)
        -> inner (R/main.R:15)
        -> deep (R/utils.R:5)
      
      10 ms (20.0%) - 1 samples:
          outer (R/main.R:10)
      
      10 ms (20.0%) - 1 samples:
          outer (R/main.R:10)
        -> helper (R/helper.R:20)
      
      10 ms (20.0%) - 1 samples:
          outer (R/main.R:10)
        -> inner (R/main.R:15)
      
      ### MEMORY ALLOCATION (by function)
        150.00 MB inner
        100.00 MB deep
         50.00 MB helper
      
      ### MEMORY ALLOCATION (by line)
        150.00 MB R/main.R:15
                  z <- heavy_computation()
        100.00 MB R/utils.R:5
                  x <- rnorm(1000)
         50.00 MB R/helper.R:20
                  do_work()

# pv_print_debrief handles no source refs

    Code
      pv_print_debrief(p)
    Output
      ## PROFILING SUMMARY
      
      
      Total time: 30 ms (3 samples @ 10 ms interval)
      Source references: not available (use devtools::load_all())
      
      
      ### TOP FUNCTIONS BY SELF-TIME
          10 ms ( 33.3%)  bar
          10 ms ( 33.3%)  baz
          10 ms ( 33.3%)  foo
      
      ### TOP FUNCTIONS BY TOTAL TIME
          30 ms (100.0%)  foo
          10 ms ( 33.3%)  bar
          10 ms ( 33.3%)  baz
      
      ### HOT CALL PATHS
      
      10 ms (33.3%) - 1 samples:
          foo
      
      10 ms (33.3%) - 1 samples:
          foo
        -> bar
      
      10 ms (33.3%) - 1 samples:
          foo
        -> baz
      
      ### MEMORY ALLOCATION (by function)
         50.00 MB bar
         50.00 MB baz

