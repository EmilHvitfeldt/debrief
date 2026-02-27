# pv_print_memory by function snapshot

    Code
      pv_print_memory(p, by = "function")
    Output
      ====================================================================== 
                          MEMORY ALLOCATION BY FUNCTION
      ====================================================================== 
      
        150.00 MB inner
        100.00 MB deep
         50.00 MB helper
      
      Tip: For line-level detail: pv_print_memory(p, by = "line")
      Tip: Investigate top allocator: pv_focus(p, "inner")

# pv_print_memory by line snapshot

    Code
      pv_print_memory(p, by = "line")
    Output
      ====================================================================== 
                            MEMORY ALLOCATION BY LINE
      ====================================================================== 
      
        150.00 MB R/main.R:15
                  z <- heavy_computation()
        100.00 MB R/utils.R:5
                  x <- rnorm(1000)
         50.00 MB R/helper.R:20
                  do_work()
      
      Tip: For function-level summary: pv_print_memory(p, by = "function")
      Tip: Investigate function: pv_focus(p, "inner")

# pv_print_memory handles no source refs for line mode

    Code
      pv_print_memory(p, by = "line")
    Output
      No source location data available.
      Use devtools::load_all() to enable source references.

