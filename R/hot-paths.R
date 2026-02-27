#' Hot call paths
#'
#' Returns the most common complete call stacks. This shows which execution
#' paths through the code consume the most time.
#'
#' @param x A profvis object.
#' @param n Maximum number of paths to return. If `NULL`, returns all.
#' @param include_source If `TRUE` and source references are available, include
#'   file:line information in the path labels.
#'
#' @return A data frame with columns:
#'   - `stack`: The call path (functions separated by arrows)
#'   - `samples`: Number of profiling samples with this exact path
#'   - `time_ms`: Time in milliseconds
#'   - `pct`: Percentage of total time
#'
#' @examples
#' p <- pv_example()
#' pv_hot_paths(p)
#' @export
pv_hot_paths <- function(x, n = NULL, include_source = TRUE) {
  check_profvis(x)

  prof <- extract_prof(x)
  interval_ms <- extract_interval(x)
  total_samples <- extract_total_samples(x)
  has_source <- has_source_refs(x)

  # Build call stacks (bottom-up: caller first)
  prof_sorted <- prof[order(prof$time, prof$depth), ]

  # Create label with optional source location
  if (has_source && include_source) {
    prof_sorted$display <- ifelse(
      is.na(prof_sorted$filename),
      prof_sorted$label,
      paste0(
        prof_sorted$label,
        " (",
        prof_sorted$filename,
        ":",
        prof_sorted$linenum,
        ")"
      )
    )
  } else {
    prof_sorted$display <- prof_sorted$label
  }

  stacks <- tapply(
    prof_sorted$display,
    prof_sorted$time,
    function(labels) paste(labels, collapse = " \u2192 ")
  )

  stack_df <- data.frame(
    time = as.integer(names(stacks)),
    stack = as.character(stacks),
    stringsAsFactors = FALSE
  )

  counts <- table(stack_df$stack)
  result <- data.frame(
    stack = names(counts),
    samples = as.integer(counts),
    stringsAsFactors = FALSE
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

#' Print hot paths in readable format
#'
#' @param x A profvis object.
#' @param n Number of paths to show.
#' @param include_source Include source references in output.
#'
#' @return Invisibly returns the hot paths data frame.
#'
#' @examples
#' p <- pv_example()
#' pv_print_hot_paths(p, n = 3)
#'
#' @export
pv_print_hot_paths <- function(x, n = 10, include_source = TRUE) {
  check_profvis(x)

  paths <- pv_hot_paths(x, n = n, include_source = include_source)

  if (nrow(paths) == 0) {
    cat("No profiling data available.\n")
    return(invisible(paths))
  }

  cat_header("HOT CALL PATHS")
  cat("\n")

  for (i in seq_len(nrow(paths))) {
    row <- paths[i, ]
    cat(sprintf(
      "Rank %d: %.0f ms (%.1f%%) - %d samples\n",
      i,
      row$time_ms,
      row$pct,
      row$samples
    ))

    parts <- strsplit(row$stack, " \u2192 ")[[1]]
    cat("    ", paste(parts, collapse = "\n  \u2192 "), "\n\n", sep = "")
  }

  # Add hints - suggest focusing on the leaf function of the hottest path
  hints <- character()
  if (nrow(paths) > 0) {
    hottest_stack <- paths$stack[1]
    parts <- strsplit(hottest_stack, " \u2192 ")[[1]]
    # Extract function name (without source location)
    leaf_part <- parts[length(parts)]
    leaf_func <- sub(" \\(.*\\)$", "", leaf_part)
    hints <- c(
      hints,
      sprintf('Investigate hottest path: pv_focus(p, "%s")', leaf_func)
    )
  }
  cat_hints(hints)

  invisible(paths)
}
