# pv_print_gc_pressure snapshot with high GC

    Code
      pv_print_gc_pressure(p)
    Output
      ====================================================================== 
                                   GC PRESSURE
      ====================================================================== 
      
      [!!!] GC consuming 40.0% of time (40 ms)
      
      High garbage collection overhead (40.0% of time). Indicates excessive memory allocation. Look for growing vectors, repeated data frame operations, or unnecessary copies. 

# pv_print_gc_pressure snapshot with no GC

    Code
      pv_print_gc_pressure(p)
    Output
      ====================================================================== 
                                   GC PRESSURE
      ====================================================================== 
      
      No significant GC pressure detected (<10% of time).

# pv_print_suggestions snapshot with GC pressure

    Code
      pv_print_suggestions(p)
    Output
      ====================================================================== 
                             OPTIMIZATION SUGGESTIONS
      ====================================================================== 
      
      Suggestions are ordered by priority (1 = highest impact).
      
      === Priority 1 ===
      
      [hot line] R/work.R:5
          Line 'work' at R/work.R:5 consumes 60.0% of time. Focus optimization efforts here first.
          Potential impact: 60 ms (60.0%)
      
      === Priority 2 ===
      
      [memory] memory allocation hotspots
          High GC overhead detected. Pre-allocate vectors/lists to final size instead of growing them. Avoid creating unnecessary intermediate objects. Consider reusing objects where possible.
          Potential impact: Up to 20 ms (20%)
      
      [hot function] work
          Function 'work' has highest self-time (60.0%). Profile this function in isolation to find micro-optimization opportunities.
          Potential impact: 60 ms (60.0%)
      

# pv_print_suggestions handles profile with no suggestions

    Code
      pv_print_suggestions(p)
    Output
      ====================================================================== 
                             OPTIMIZATION SUGGESTIONS
      ====================================================================== 
      
      Suggestions are ordered by priority (1 = highest impact).
      
      === Priority 2 ===
      
      [hot function] x
          Function 'x' has highest self-time (100.0%). Profile this function in isolation to find micro-optimization opportunities.
          Potential impact: 10 ms (100.0%)
      

