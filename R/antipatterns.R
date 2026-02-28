#' Detect GC pressure
#'
#' Analyzes the profile to detect excessive garbage collection, which is a
#' universal indicator of memory allocation issues in R code.
#'
#' @param x A profvis object.
#' @param threshold Minimum GC percentage to report (default 10). Set lower to
#'   detect smaller GC overhead.
#'
#' @return A data frame with columns:
#'   - `severity`: "high" (>25%), "medium" (>15%), or "low" (>threshold%)
#'   - `pct`: Percentage of total time spent in GC
#'   - `time_ms`: Time spent in garbage collection
#'   - `description`: Explanation of the issue
#'
#' Returns an empty data frame (0 rows) if GC is below the threshold.
#'
#' @details
#' GC pressure above 10% typically indicates the code is allocating and
#' discarding memory faster than necessary. Common causes include:
#' - Growing vectors with `c(x, new)` instead of pre-allocation
#' - Building data frames row-by-row with `rbind()`
#' - Creating unnecessary copies of large objects
#' - String concatenation in loops
#'
#' @examples
#' p <- pv_example("gc")
#' pv_gc_pressure(p)
#'
#' # More sensitive detection
#' pv_gc_pressure(p, threshold = 5)
#'
#' # No GC pressure in default example
#' p2 <- pv_example()
#' pv_gc_pressure(p2)
#' @export
pv_gc_pressure <- function(x, threshold = 10) {
  check_profvis(x)
  check_empty_profile(x)

  prof <- extract_prof(x)
  interval_ms <- extract_interval(x)
  total_samples <- extract_total_samples(x)

  # Detect GC pressure - the one universal anti-pattern signal
  gc_times <- unique(prof$time[prof$label == "<GC>"])

  if (length(gc_times) == 0) {
    return(empty_gc_pressure_df())
  }

  time_ms <- length(gc_times) * interval_ms
  pct <- round(100 * length(gc_times) / total_samples, 1)

  # Only report if GC exceeds threshold
  if (pct <= threshold) {
    return(empty_gc_pressure_df())
  }

  severity <- if (pct > 25) {
    "high"
  } else if (pct > 15) {
    "medium"
  } else {
    "low"
  }

  data.frame(
    severity = severity,
    pct = pct,
    time_ms = time_ms,
    description = sprintf(
      "High garbage collection overhead (%.1f%% of time). Indicates excessive memory allocation. Look for growing vectors, repeated data frame operations, or unnecessary copies.",
      pct
    ),
    stringsAsFactors = FALSE
  )
}

empty_gc_pressure_df <- function() {
  data.frame(
    severity = character(),
    pct = numeric(),
    time_ms = numeric(),
    description = character(),
    stringsAsFactors = FALSE
  )
}

#' Print GC pressure analysis
#'
#' @param x A profvis object.
#' @param threshold Minimum GC percentage to report (default 10).
#'
#' @return Invisibly returns the GC pressure data frame.
#'
#' @examples
#' p <- pv_example("gc")
#' pv_print_gc_pressure(p)
#'
#' @export
pv_print_gc_pressure <- function(x, threshold = 10) {
  check_profvis(x)
  check_empty_profile(x)

  gc_data <- pv_gc_pressure(x, threshold = threshold)

  cat_header("GC PRESSURE")
  cat("\n")

  if (nrow(gc_data) == 0) {
    cat(sprintf(
      "No significant GC pressure detected (<%d%% of time).\n",
      threshold
    ))
    return(invisible(gc_data))
  }

  row <- gc_data[1, ]
  severity_icon <- switch(
    row$severity,
    high = "[!!!]",
    medium = "[!!]",
    low = "[!]"
  )

  cat(sprintf(
    "%s GC consuming %.1f%% of time (%.0f ms)\n\n",
    severity_icon,
    row$pct,
    row$time_ms
  ))
  cat(row$description, "\n")

  invisible(gc_data)
}
