# pv_print_call_depth snapshot

    Code
      pv_print_call_depth(p)
    Output
      ## CALL DEPTH BREAKDOWN
      
      
      Depth  Time (ms)   Pct   Top functions
          1        50  100.0%  outer
          2        40   80.0%  inner, helper
          3        20   40.0%  deep

# pv_print_callers_callees snapshot

    Code
      pv_print_callers_callees(p, "inner")
    Output
      ## FUNCTION ANALYSIS: inner
      
      
      Total time: 30 ms (60.0% of profile)
      Appearances: 3 samples
      
      ### Called by
            3 samples (100.0%)  outer
      
      ### Calls to
            2 samples ( 66.7%)  deep
      

# pv_print_call_stats snapshot

    Code
      pv_print_call_stats(p)
    Output
      ## CALL STATISTICS
      
      
      Function                               Calls   Total ms    Self ms    ms/call    Pct
      outer                                      1         50         10      50.00 100.0%
      inner                                      2         30         10      15.00  60.0%
      deep                                       2         20         20      10.00  40.0%
      helper                                     1         10         10      10.00  20.0%

