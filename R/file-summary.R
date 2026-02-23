#' File-level time summary
#'
#' Aggregates profiling time by source file. Requires source references
#' (use `devtools::load_all()` for best results).
#'
#' @param x A profvis object.
#'
#' @return A data frame with columns:
#'   - `filename`: Source file path
#'   - `samples`: Number of profiling samples
#'   - `time_ms`: Time in milliseconds
#'   - `pct`: Percentage of total time
#'
#' @examples
#' p <- pv_example()
#' pv_file_summary(p)
#' @export
pv_file_summary <- function(x) {
  check_profvis(x)

  prof <- extract_prof(x)
  interval_ms <- extract_interval(x)
  total_samples <- extract_total_samples(x)

  # Filter to rows with source info
  with_source <- prof[!is.na(prof$filename), ]
  if (nrow(with_source) == 0) {
    return(data.frame(
      filename = character(),
      samples = integer(),
      time_ms = numeric(),
      pct = numeric(),
      stringsAsFactors = FALSE
    ))
  }

  # Count unique time-filename combinations (total time per file)
  unique_pairs <- unique(with_source[, c("time", "filename")])
  counts <- table(unique_pairs$filename)

  result <- data.frame(
    filename = names(counts),
    samples = as.integer(counts),
    stringsAsFactors = FALSE
  )
  result$time_ms <- result$samples * interval_ms
  result$pct <- round(100 * result$samples / total_samples, 1)
  result <- result[order(-result$samples), ]
  rownames(result) <- NULL
  result
}

#' Print file summary
#'
#' @param x A profvis object.
#'
#' @return Invisibly returns the file summary data frame.
#'
#' @examples
#' p <- pv_example()
#' pv_print_file_summary(p)
#'
#' @export
pv_print_file_summary <- function(x) {
  check_profvis(x)

  summary_df <- pv_file_summary(x)

  if (nrow(summary_df) == 0) {
    cat("No source location data available.\n")
    cat("Use devtools::load_all() to enable source references.\n")
    return(invisible(summary_df))
  }

  cat_header("FILE SUMMARY")
  cat("\n")

  for (i in seq_len(nrow(summary_df))) {
    row <- summary_df[i, ]
    cat(sprintf(
      "%6.0f ms (%5.1f%%)  %s\n",
      row$time_ms,
      row$pct,
      row$filename
    ))
  }

  invisible(summary_df)
}
