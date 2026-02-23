#' Self-time summary by function
#'
#' Returns the time spent directly in each function (at the top of the call
#' stack). This shows where CPU cycles are actually being consumed.
#'
#' @param x A profvis object.
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
#' @export
pv_self_time <- function(x) {
  check_profvis(x)

  prof <- extract_prof(x)
  interval_ms <- extract_interval(x)
  total_samples <- extract_total_samples(x)

  # Get the deepest frame for each time point
  max_depths <- tapply(prof$depth, prof$time, max)
  max_depth_df <- data.frame(
    time = as.integer(names(max_depths)),
    max_depth = as.integer(max_depths)
  )
  prof_merged <- merge(prof, max_depth_df, by = "time")
  top_of_stack <- prof_merged[prof_merged$depth == prof_merged$max_depth, ]

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
  result
}

#' Total time summary by function
#'
#' Returns the time spent in each function including all its callees. This
#' shows which functions are on the call stack when time is being spent.
#'
#' @param x A profvis object.
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
#' @export
pv_total_time <- function(x) {
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
  result
}
