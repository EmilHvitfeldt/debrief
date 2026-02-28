# pv_print_recursive snapshot for recursive profile

    Code
      pv_print_recursive(p)
    Output
      ## RECURSIVE FUNCTIONS
      
      
      Function                       MaxDepth AvgDepth   Total ms      Pct
      recurse                               5      4.0         30   100.0%
      
      ### Next steps
      pv_focus(p, "recurse")
      pv_suggestions(p)

# pv_print_recursive handles non-recursive profile

    Code
      pv_print_recursive(p)
    Output
      No recursive functions detected in the profile.

