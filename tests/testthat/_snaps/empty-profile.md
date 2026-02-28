# empty profile errors with helpful message

    Code
      pv_self_time(empty_prof)
    Condition
      Error:
      ! Profile contains no samples.
      Your code ran too fast to capture any profiling data.
      Try wrapping your code in a loop: for (i in 1:10) { ... }
      Increase the iteration count until samples appear.

---

    Code
      pv_total_time(empty_prof)
    Condition
      Error:
      ! Profile contains no samples.
      Your code ran too fast to capture any profiling data.
      Try wrapping your code in a loop: for (i in 1:10) { ... }
      Increase the iteration count until samples appear.

---

    Code
      pv_debrief(empty_prof)
    Condition
      Error:
      ! Profile contains no samples.
      Your code ran too fast to capture any profiling data.
      Try wrapping your code in a loop: for (i in 1:10) { ... }
      Increase the iteration count until samples appear.

---

    Code
      pv_print_debrief(empty_prof)
    Condition
      Error:
      ! Profile contains no samples.
      Your code ran too fast to capture any profiling data.
      Try wrapping your code in a loop: for (i in 1:10) { ... }
      Increase the iteration count until samples appear.

---

    Code
      pv_worst_line(empty_prof)
    Condition
      Error:
      ! Profile contains no samples.
      Your code ran too fast to capture any profiling data.
      Try wrapping your code in a loop: for (i in 1:10) { ... }
      Increase the iteration count until samples appear.

---

    Code
      pv_hot_lines(empty_prof)
    Condition
      Error:
      ! Profile contains no samples.
      Your code ran too fast to capture any profiling data.
      Try wrapping your code in a loop: for (i in 1:10) { ... }
      Increase the iteration count until samples appear.

---

    Code
      pv_hot_paths(empty_prof)
    Condition
      Error:
      ! Profile contains no samples.
      Your code ran too fast to capture any profiling data.
      Try wrapping your code in a loop: for (i in 1:10) { ... }
      Increase the iteration count until samples appear.

---

    Code
      pv_flame(empty_prof)
    Condition
      Error:
      ! Profile contains no samples.
      Your code ran too fast to capture any profiling data.
      Try wrapping your code in a loop: for (i in 1:10) { ... }
      Increase the iteration count until samples appear.

---

    Code
      pv_memory(empty_prof)
    Condition
      Error:
      ! Profile contains no samples.
      Your code ran too fast to capture any profiling data.
      Try wrapping your code in a loop: for (i in 1:10) { ... }
      Increase the iteration count until samples appear.

---

    Code
      pv_callers(empty_prof, "foo")
    Condition
      Error:
      ! Profile contains no samples.
      Your code ran too fast to capture any profiling data.
      Try wrapping your code in a loop: for (i in 1:10) { ... }
      Increase the iteration count until samples appear.

---

    Code
      pv_callees(empty_prof, "foo")
    Condition
      Error:
      ! Profile contains no samples.
      Your code ran too fast to capture any profiling data.
      Try wrapping your code in a loop: for (i in 1:10) { ... }
      Increase the iteration count until samples appear.

---

    Code
      pv_focus(empty_prof, "foo")
    Condition
      Error:
      ! Profile contains no samples.
      Your code ran too fast to capture any profiling data.
      Try wrapping your code in a loop: for (i in 1:10) { ... }
      Increase the iteration count until samples appear.

---

    Code
      pv_suggestions(empty_prof)
    Condition
      Error:
      ! Profile contains no samples.
      Your code ran too fast to capture any profiling data.
      Try wrapping your code in a loop: for (i in 1:10) { ... }
      Increase the iteration count until samples appear.

---

    Code
      pv_gc_pressure(empty_prof)
    Condition
      Error:
      ! Profile contains no samples.
      Your code ran too fast to capture any profiling data.
      Try wrapping your code in a loop: for (i in 1:10) { ... }
      Increase the iteration count until samples appear.

---

    Code
      pv_recursive(empty_prof)
    Condition
      Error:
      ! Profile contains no samples.
      Your code ran too fast to capture any profiling data.
      Try wrapping your code in a loop: for (i in 1:10) { ... }
      Increase the iteration count until samples appear.

---

    Code
      pv_call_stats(empty_prof)
    Condition
      Error:
      ! Profile contains no samples.
      Your code ran too fast to capture any profiling data.
      Try wrapping your code in a loop: for (i in 1:10) { ... }
      Increase the iteration count until samples appear.

---

    Code
      pv_call_depth(empty_prof)
    Condition
      Error:
      ! Profile contains no samples.
      Your code ran too fast to capture any profiling data.
      Try wrapping your code in a loop: for (i in 1:10) { ... }
      Increase the iteration count until samples appear.

---

    Code
      pv_file_summary(empty_prof)
    Condition
      Error:
      ! Profile contains no samples.
      Your code ran too fast to capture any profiling data.
      Try wrapping your code in a loop: for (i in 1:10) { ... }
      Increase the iteration count until samples appear.

---

    Code
      pv_source_context(empty_prof, "foo.R")
    Condition
      Error:
      ! Profile contains no samples.
      Your code ran too fast to capture any profiling data.
      Try wrapping your code in a loop: for (i in 1:10) { ... }
      Increase the iteration count until samples appear.

---

    Code
      pv_to_json(empty_prof)
    Condition
      Error:
      ! Profile contains no samples.
      Your code ran too fast to capture any profiling data.
      Try wrapping your code in a loop: for (i in 1:10) { ... }
      Increase the iteration count until samples appear.

---

    Code
      pv_to_list(empty_prof)
    Condition
      Error:
      ! Profile contains no samples.
      Your code ran too fast to capture any profiling data.
      Try wrapping your code in a loop: for (i in 1:10) { ... }
      Increase the iteration count until samples appear.

# compare functions error on empty profile

    Code
      pv_compare(empty_prof, valid_prof)
    Condition
      Error:
      ! Profile contains no samples.
      Your code ran too fast to capture any profiling data.
      Try wrapping your code in a loop: for (i in 1:10) { ... }
      Increase the iteration count until samples appear.

---

    Code
      pv_compare(valid_prof, empty_prof)
    Condition
      Error:
      ! Profile contains no samples.
      Your code ran too fast to capture any profiling data.
      Try wrapping your code in a loop: for (i in 1:10) { ... }
      Increase the iteration count until samples appear.

---

    Code
      pv_compare_many(a = empty_prof, b = valid_prof)
    Condition
      Error:
      ! Profile contains no samples.
      Your code ran too fast to capture any profiling data.
      Try wrapping your code in a loop: for (i in 1:10) { ... }
      Increase the iteration count until samples appear.

