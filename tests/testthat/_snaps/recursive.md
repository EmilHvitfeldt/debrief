# pv_print_recursive snapshot for recursive profile

    Code
      pv_print_recursive(p)
    Output
      ====================================================================== 
                               RECURSIVE FUNCTIONS
      ====================================================================== 
      
      Functions that appear multiple times in the same call stack.
      High recursion depth + high time = optimization opportunity.
      
      Function                       MaxDepth AvgDepth   Total ms      Pct
      ---------------------------------------------------------------------- 
      recurse                               5      4.0         30   100.0%
      
      Note: MaxDepth = max times function appears in single stack

# pv_print_recursive handles non-recursive profile

    Code
      pv_print_recursive(p)
    Output
      No recursive functions detected in the profile.

