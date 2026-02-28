#' Hot source lines by self-time
#'
#' Returns the source lines where the most CPU time is spent. Requires source
#' references (use `devtools::load_all()` for best results).
#'
#' @param x A profvis object.
#' @param n Maximum number of lines to return. If `NULL`, returns all that pass
#'   the filters.
#' @param min_pct Minimum percentage of total time to include (default 0).
#' @param min_time_ms Minimum time in milliseconds to include (default 0).
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
#'
#' # Only lines with >= 10% of time
#' pv_hot_lines(p, min_pct = 10)
#' @export
pv_hot_lines <- function(x, n = NULL, min_pct = 0, min_time_ms = 0) {
  check_profvis(x)
  check_empty_profile(x)

  prof <- extract_prof(x)
  interval_ms <- extract_interval(x)
  total_samples <- extract_total_samples(x)

  # Get the deepest frame for each time point (self-time)
  top_of_stack <- extract_top_of_stack(prof)

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

  # Apply filters
  result <- result[result$pct >= min_pct & result$time_ms >= min_time_ms, ]

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
  check_empty_profile(x)

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
        marker <- if (ln == row$linenum) ">    " else "     "
        cat(sprintf("%s%4d: %s\n", marker, ln, lines[j]))
      }
    } else {
      cat("  (source not available)\n")
    }
    cat("\n")
  }

  # Next steps suggestions
  if (nrow(hot_lines) > 0) {
    suggestions <- character()
    top_func <- hot_lines$label[1]
    top_file <- hot_lines$filename[1]
    if (!grepl("^[(<\\[]", top_func)) {
      suggestions <- c(suggestions, sprintf("pv_focus(p, \"%s\")", top_func))
    }
    suggestions <- c(
      suggestions,
      sprintf("pv_source_context(p, \"%s\")", top_file)
    )
    cat_next_steps(suggestions)
  }

  invisible(hot_lines)
}

#' Get the single hottest line
#'
#' Returns the hottest source line with full context. Useful for quickly
#' identifying the #1 optimization target.
#'
#' @param x A profvis object.
#' @param context Number of source lines to include before and after.
#'
#' @return A list with:
#'   - `location`: File path and line number (e.g., "R/foo.R:42")
#'   - `label`: Function name
#'   - `filename`: Source file path
#'   - `linenum`: Line number
#'   - `time_ms`: Time in milliseconds
#'   - `pct`: Percentage of total time
#'   - `code`: The source line
#'   - `context`: Vector of surrounding source lines
#'   - `callers`: Data frame of functions that call this location
#'
#'   Returns `NULL` if no source references are available.
#'
#' @examples
#' p <- pv_example()
#' pv_worst_line(p)
#' @export
pv_worst_line <- function(x, context = 5) {
  check_profvis(x)
  check_empty_profile(x)

  hot_lines <- pv_hot_lines(x, n = 1)

  if (nrow(hot_lines) == 0) {
    return(NULL)
  }

  row <- hot_lines[1, ]
  files <- extract_files(x)
  file_contents <- build_file_contents(files)

  # Get source line
  code <- get_source_line(row$filename, row$linenum, file_contents)
  if (is.null(code)) {
    code <- NA_character_
  }

  # Get context lines
  start <- max(1L, row$linenum - context)
  end <- row$linenum + context
  context_lines <- get_source_lines(row$filename, start, end, file_contents)
  if (is.null(context_lines)) {
    context_lines <- character()
  }

  # Get callers for this function
  callers <- pv_callers(x, row$label)

  list(
    location = row$location,
    label = row$label,
    filename = row$filename,
    linenum = row$linenum,
    time_ms = row$time_ms,
    pct = row$pct,
    code = code,
    context = context_lines,
    callers = callers
  )
}
