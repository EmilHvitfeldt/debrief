#' Self-time summary by function
#'
#' Returns the time spent directly in each function (at the top of the call
#' stack). This shows where CPU cycles are actually being consumed.
#'
#' @param x A profvis object.
#' @param n Maximum number of functions to return. If `NULL`, returns all that
#'   pass the filters.
#' @param min_pct Minimum percentage of total time to include (default 0).
#' @param min_time_ms Minimum time in milliseconds to include (default 0).
#'
#' @return A data frame with columns:
#'   - `label`: Function name
#'   - `samples`: Number of profiling samples
#'   - `time_ms`: Time in milliseconds
#'   - `pct`: Percentage of total time
#'
#' @examples
#' p <- pv_example()
#' pv_self_time(p)
#'
#' # Only functions with >= 5% self-time
#' pv_self_time(p, min_pct = 5)
#' @export
pv_self_time <- function(x, n = NULL, min_pct = 0, min_time_ms = 0) {
  check_profvis(x)

  prof <- extract_prof(x)
  interval_ms <- extract_interval(x)
  total_samples <- extract_total_samples(x)

  # Get the deepest frame for each time point (self-time)
  top_of_stack <- extract_top_of_stack(prof)

  counts <- table(top_of_stack$label)
  result <- data.frame(
    label = names(counts),
    samples = as.integer(counts),
    stringsAsFactors = FALSE
  )
  result$time_ms <- result$samples * interval_ms
  result$pct <- round(100 * result$samples / total_samples, 1)
  result <- result[order(-result$samples), ]
  rownames(result) <- NULL

  # Apply filters
  result <- result[result$pct >= min_pct & result$time_ms >= min_time_ms, ]

  if (!is.null(n)) {
    result <- head(result, n)
  }

  result
}

#' Total time summary by function
#'
#' Returns the time spent in each function including all its callees. This
#' shows which functions are on the call stack when time is being spent.
#'
#' @param x A profvis object.
#' @param n Maximum number of functions to return. If `NULL`, returns all that
#'   pass the filters.
#' @param min_pct Minimum percentage of total time to include (default 0).
#' @param min_time_ms Minimum time in milliseconds to include (default 0).
#'
#' @return A data frame with columns:
#'   - `label`: Function name
#'   - `samples`: Number of profiling samples where function appeared
#'   - `time_ms`: Time in milliseconds
#'   - `pct`: Percentage of total time
#'
#' @examples
#' p <- pv_example()
#' pv_total_time(p)
#'
#' # Only functions with >= 50% total time
#' pv_total_time(p, min_pct = 50)
#' @export
pv_total_time <- function(x, n = NULL, min_pct = 0, min_time_ms = 0) {
  check_profvis(x)

  prof <- extract_prof(x)
  interval_ms <- extract_interval(x)
  total_samples <- extract_total_samples(x)

  # Count unique time-label combinations
  unique_pairs <- unique(prof[, c("time", "label")])
  counts <- table(unique_pairs$label)

  result <- data.frame(
    label = names(counts),
    samples = as.integer(counts),
    stringsAsFactors = FALSE
  )
  result$time_ms <- result$samples * interval_ms
  result$pct <- round(100 * result$samples / total_samples, 1)
  result <- result[order(-result$samples), ]
  rownames(result) <- NULL

  # Apply filters
  result <- result[result$pct >= min_pct & result$time_ms >= min_time_ms, ]

  if (!is.null(n)) {
    result <- head(result, n)
  }

  result
}
