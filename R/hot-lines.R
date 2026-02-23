#' Hot source lines by self-time
#'
#' Returns the source lines where the most CPU time is spent. Requires source
#' references (use `devtools::load_all()` for best results).
#'
#' @param x A profvis object.
#' @param n Maximum number of lines to return. If `NULL`, returns all.
#'
#' @return A data frame with columns:
#'   - `location`: File path and line number (e.g., "R/foo.R:42")
#'   - `label`: Function name at this location
#'   - `filename`: Source file path
#'   - `linenum`: Line number
#'   - `samples`: Number of profiling samples
#'   - `time_ms`: Time in milliseconds
#'   - `pct`: Percentage of total time
#'
#' @examples
#' p <- pv_example()
#' pv_hot_lines(p)
#' @export
pv_hot_lines <- function(x, n = NULL) {
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

  # Filter to rows with source info
  with_source <- top_of_stack[!is.na(top_of_stack$filename), ]
  if (nrow(with_source) == 0) {
    return(data.frame(
      location = character(),
      label = character(),
      filename = character(),
      linenum = integer(),
      samples = integer(),
      time_ms = numeric(),
      pct = numeric(),
      stringsAsFactors = FALSE
    ))
  }

  # Create location key
  with_source$location <- paste0(with_source$filename, ":", with_source$linenum)

  # Aggregate by location
  counts <- table(with_source$location)
  result <- data.frame(
    location = names(counts),
    samples = as.integer(counts),
    stringsAsFactors = FALSE
  )

  # Get label, filename, linenum for each location
  first_occurrence <- with_source[!duplicated(with_source$location), ]
  result <- merge(
    result,
    first_occurrence[, c("location", "label", "filename", "linenum")],
    by = "location"
  )

  result$time_ms <- result$samples * interval_ms
  result$pct <- round(100 * result$samples / total_samples, 1)
  result <- result[order(-result$samples), ]
  rownames(result) <- NULL

  if (!is.null(n)) {
    result <- head(result, n)
  }

  result
}

#' Print hot lines with source context
#'
#' Prints the hot source lines along with surrounding code context.
#'
#' @param x A profvis object.
#' @param n Number of hot lines to show.
#' @param context Number of lines to show before and after each hotspot.
#'
#' @return Invisibly returns the hot lines data frame.
#'
#' @examples
#' p <- pv_example()
#' pv_print_hot_lines(p, n = 5, context = 3)
#' @export
pv_print_hot_lines <- function(x, n = 5, context = 3) {
  check_profvis(x)

  hot_lines <- pv_hot_lines(x, n = n)

  if (nrow(hot_lines) == 0) {
    cat("No source location data available.\n")
    cat("Use devtools::load_all() to enable source references.\n")
    return(invisible(hot_lines))
  }

  files <- extract_files(x)
  file_contents <- build_file_contents(files)

  cat_header("HOT SOURCE LINES")
  cat("\n")

  for (i in seq_len(nrow(hot_lines))) {
    row <- hot_lines[i, ]
    cat(sprintf(
      "Rank %d: %s (%.0f ms, %.1f%%)\n",
      i,
      row$location,
      row$time_ms,
      row$pct
    ))
    cat(sprintf("Function: %s\n\n", row$label))

    # Show source context
    start <- row$linenum - context
    end <- row$linenum + context
    lines <- get_source_lines(row$filename, start, end, file_contents)

    if (!is.null(lines)) {
      actual_start <- max(1L, start)
      for (j in seq_along(lines)) {
        ln <- actual_start + j - 1
        marker <- if (ln == row$linenum) " >>> " else "     "
        cat(sprintf("%s%4d: %s\n", marker, ln, lines[j]))
      }
    } else {
      cat("  (source not available)\n")
    }
    cat("\n")
  }

  invisible(hot_lines)
}
