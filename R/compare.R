#' Compare two profvis profiles
#'
#' Compares two profiling runs to show what changed. Useful for measuring
#' the impact of optimizations.
#'
#' @param before A profvis object (before optimization).
#' @param after A profvis object (after optimization).
#' @param n Number of top functions to compare.
#'
#' @return A list with:
#'   - `summary`: Overall comparison summary
#'   - `by_function`: Function-by-function comparison
#'   - `improved`: Functions that got faster
#'   - `regressed`: Functions that got slower
#'
#' @examples
#' \dontrun{
#' p1 <- profvis::profvis(slow_function())
#' # ... make optimizations ...
#' p2 <- profvis::profvis(fast_function())
#' pv_compare(p1, p2)
#' }
#' @export
pv_compare <- function(before, after, n = 20) {
  check_profvis(before)
  check_profvis(after)

  # Get timing info
  before_interval <- extract_interval(before)
  after_interval <- extract_interval(after)

  before_samples <- extract_total_samples(before)
  after_samples <- extract_total_samples(after)

  before_time <- before_samples * before_interval
  after_time <- after_samples * after_interval

  # Summary
  time_diff <- after_time - before_time
  time_pct_change <- round(100 * (after_time - before_time) / before_time, 1)
  speedup <- round(before_time / after_time, 2)

  summary_df <- data.frame(
    metric = c("Total time (ms)", "Samples", "Speedup"),
    before = c(before_time, before_samples, 1.0),
    after = c(after_time, after_samples, speedup),
    change = c(
      sprintf("%+.0f ms (%+.1f%%)", time_diff, time_pct_change),
      sprintf("%+d", after_samples - before_samples),
      sprintf("%.2fx", speedup)
    ),
    stringsAsFactors = FALSE
  )

  # Function-by-function comparison (self-time)
  before_self <- pv_self_time(before)
  after_self <- pv_self_time(after)

  # Merge
  all_funcs <- union(before_self$label, after_self$label)
  func_comparison <- lapply(all_funcs, function(func) {
    before_row <- before_self[before_self$label == func, ]
    after_row <- after_self[after_self$label == func, ]

    before_ms <- if (nrow(before_row) > 0) before_row$time_ms[1] else 0
    after_ms <- if (nrow(after_row) > 0) after_row$time_ms[1] else 0

    diff_ms <- after_ms - before_ms
    if (before_ms > 0) {
      pct_change <- round(100 * (after_ms - before_ms) / before_ms, 1)
    } else if (after_ms > 0) {
      pct_change <- Inf
    } else {
      pct_change <- 0
    }

    data.frame(
      label = func,
      before_ms = before_ms,
      after_ms = after_ms,
      diff_ms = diff_ms,
      pct_change = pct_change,
      stringsAsFactors = FALSE
    )
  })

  func_df <- do.call(rbind, func_comparison)
  func_df <- func_df[order(-abs(func_df$diff_ms)), ]
  rownames(func_df) <- NULL

  # Split into improved/regressed
  improved <- func_df[func_df$diff_ms < -5, ] # At least 5ms improvement
  improved <- improved[order(improved$diff_ms), ]

  regressed <- func_df[func_df$diff_ms > 5, ] # At least 5ms regression
  regressed <- regressed[order(-regressed$diff_ms), ]

  list(
    summary = summary_df,
    by_function = head(func_df, n),
    improved = improved,
    regressed = regressed
  )
}

#' Print profile comparison
#'
#' @param before A profvis object (before optimization).
#' @param after A profvis object (after optimization).
#' @param n Number of functions to show in detailed comparison.
#'
#' @return Invisibly returns the comparison list.
#' @export
pv_print_compare <- function(before, after, n = 15) {
  check_profvis(before)
  check_profvis(after)

  comp <- pv_compare(before, after, n = n)

  cat_header("PROFILE COMPARISON")
  cat("\n")

  # Summary
  cat("--- Overall ", strrep("-", 58), "\n", sep = "")
  before_time <- comp$summary$before[1]
  after_time <- comp$summary$after[1]
  speedup <- comp$summary$after[3]

  if (after_time < before_time) {
    cat(sprintf(
      "IMPROVED: %.0f ms -> %.0f ms (%.1fx faster, saved %.0f ms)\n\n",
      before_time,
      after_time,
      speedup,
      before_time - after_time
    ))
  } else if (after_time > before_time) {
    cat(sprintf(
      "REGRESSED: %.0f ms -> %.0f ms (%.1fx slower, added %.0f ms)\n\n",
      before_time,
      after_time,
      1 / speedup,
      after_time - before_time
    ))
  } else {
    cat(sprintf("NO CHANGE: %.0f ms\n\n", before_time))
  }

  # Top changes
  cat("--- Biggest Changes ", strrep("-", 50), "\n", sep = "")
  cat(sprintf(
    "%-30s %10s %10s %10s %8s\n",
    "Function",
    "Before",
    "After",
    "Diff",
    "Change"
  ))
  cat(strrep("-", 72), "\n")

  for (i in seq_len(min(n, nrow(comp$by_function)))) {
    row <- comp$by_function[i, ]
    if (abs(row$diff_ms) < 1) {
      next
    } # Skip tiny changes

    label <- truncate_string(row$label, 30)
    change_str <- if (is.finite(row$pct_change)) {
      sprintf("%+.0f%%", row$pct_change)
    } else {
      "new"
    }

    cat(sprintf(
      "%-30s %10.0f %10.0f %+10.0f %8s\n",
      label,
      row$before_ms,
      row$after_ms,
      row$diff_ms,
      change_str
    ))
  }

  # Improved functions
  if (nrow(comp$improved) > 0) {
    cat("\n--- Top Improvements ", strrep("-", 48), "\n", sep = "")
    for (i in seq_len(min(5, nrow(comp$improved)))) {
      row <- comp$improved[i, ]
      cat(sprintf(
        "  %s: %.0f ms -> %.0f ms (saved %.0f ms)\n",
        truncate_string(row$label, 35),
        row$before_ms,
        row$after_ms,
        -row$diff_ms
      ))
    }
  }

  # Regressed functions
  if (nrow(comp$regressed) > 0) {
    cat("\n--- Regressions ", strrep("-", 53), "\n", sep = "")
    for (i in seq_len(min(5, nrow(comp$regressed)))) {
      row <- comp$regressed[i, ]
      cat(sprintf(
        "  %s: %.0f ms -> %.0f ms (added %.0f ms)\n",
        truncate_string(row$label, 35),
        row$before_ms,
        row$after_ms,
        row$diff_ms
      ))
    }
  }

  cat("\n")

  invisible(comp)
}
