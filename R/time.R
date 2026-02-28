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
  pd <- extract_profile_data(x)
  top_of_stack <- extract_top_of_stack(pd$prof)
  counts <- table(top_of_stack$label)
  result <- build_count_result(counts, pd$interval_ms, pd$total_samples)
  apply_result_filters(result, n, min_pct, min_time_ms)
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
  pd <- extract_profile_data(x)
  unique_pairs <- unique(pd$prof[, c("time", "label")])
  counts <- table(unique_pairs$label)
  result <- build_count_result(counts, pd$interval_ms, pd$total_samples)
  apply_result_filters(result, n, min_pct, min_time_ms)
}
