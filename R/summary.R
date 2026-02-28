#' Text-based summary of profvis output
#'
#' Produces a comprehensive text summary of profiling data suitable for
#' terminal output or AI agent consumption.
#'
#' @param x A profvis object from [profvis::profvis()].
#' @param n_functions Number of top functions to show (default 10).
#' @param n_lines Number of hot source lines to show (default 10).
#' @param n_paths Number of hot paths to show (default 5).
#' @param n_memory Number of memory hotspots to show (default 5).
#'
#' @return Invisibly returns a list containing all computed summaries.
#'
#' @examples
#' p <- pv_example()
#' pv_summary(p)
#' @export
pv_summary <- function(
  x,
  n_functions = 10,
  n_lines = 10,
  n_paths = 5,
  n_memory = 5
) {
  check_profvis(x)
  check_empty_profile(x)

  interval_ms <- extract_interval(x)
  total_samples <- extract_total_samples(x)
  total_time_ms <- total_samples * interval_ms
  has_source <- has_source_refs(x)
  files <- extract_files(x)
  file_contents <- build_file_contents(files)

  # Compute all summaries
  self_time <- pv_self_time(x)
  total_time <- pv_total_time(x)
  hot_lines <- if (has_source) pv_hot_lines(x) else NULL
  hot_paths <- pv_hot_paths(x)
  memory_funcs <- pv_memory(x)
  memory_lines <- if (has_source) pv_memory_lines(x) else NULL

  # Print output
  cat_header("PROFILING SUMMARY")
  cat("\n")

  cat(sprintf(
    "Total time: %.0f ms (%d samples @ %.0f ms interval)\n",
    total_time_ms,
    total_samples,
    interval_ms
  ))
  if (has_source) {
    cat("Source references: available\n")
  } else {
    cat("Source references: not available (use devtools::load_all())\n")
  }
  cat("\n")

  cat_section("TOP FUNCTIONS BY SELF-TIME")
  print_time_df(head(self_time, n_functions))

  cat_section("TOP FUNCTIONS BY TOTAL TIME")
  print_time_df(head(total_time, n_functions))

  if (has_source && !is.null(hot_lines) && nrow(hot_lines) > 0) {
    cat_section("HOT LINES (by self-time)")
    print_lines_df(head(hot_lines, n_lines), file_contents)
  }

  cat_section("HOT CALL PATHS")
  print_paths_df(head(hot_paths, n_paths))

  cat_section("MEMORY ALLOCATION (by function)")
  print_memory_df(head(memory_funcs, n_memory))

  if (has_source && !is.null(memory_lines) && nrow(memory_lines) > 0) {
    cat_section("MEMORY ALLOCATION (by line)")
    print_memory_lines_df(head(memory_lines, n_memory), file_contents)
  }

  cat(strrep("-", 70), "\n")

  invisible(list(
    total_time_ms = total_time_ms,
    total_samples = total_samples,
    interval_ms = interval_ms,
    has_source = has_source,
    self_time = self_time,
    total_time = total_time,
    hot_lines = hot_lines,
    hot_paths = hot_paths,
    memory_funcs = memory_funcs,
    memory_lines = memory_lines
  ))
}

# Print helpers for summary
print_time_df <- function(df) {
  if (is.null(df) || nrow(df) == 0) {
    cat("No data.\n")
    return(invisible())
  }
  for (i in seq_len(nrow(df))) {
    cat(sprintf(
      "%6.0f ms (%5.1f%%)  %s\n",
      df$time_ms[i],
      df$pct[i],
      df$label[i]
    ))
  }
}

print_lines_df <- function(df, file_contents) {
  if (is.null(df) || nrow(df) == 0) {
    cat("No source location data available.\n")
    return(invisible())
  }
  for (i in seq_len(nrow(df))) {
    cat(sprintf(
      "%6.0f ms (%5.1f%%)  %s\n",
      df$time_ms[i],
      df$pct[i],
      df$location[i]
    ))
    src_line <- get_source_line(df$filename[i], df$linenum[i], file_contents)
    if (!is.null(src_line) && nchar(src_line) > 0) {
      cat(sprintf("                   %s\n", truncate_string(src_line)))
    }
  }
}

print_paths_df <- function(df) {
  if (is.null(df) || nrow(df) == 0) {
    cat("No data.\n")
    return(invisible())
  }
  for (i in seq_len(nrow(df))) {
    cat(sprintf(
      "\n%.0f ms (%.1f%%) - %d samples:\n",
      df$time_ms[i],
      df$pct[i],
      df$samples[i]
    ))
    parts <- strsplit(df$stack[i], " -> ")[[1]]
    cat("    ", paste(parts, collapse = "\n  -> "), "\n", sep = "")
  }
}

print_memory_df <- function(df) {
  if (is.null(df) || nrow(df) == 0) {
    cat("No significant memory allocations detected.\n")
    return(invisible())
  }
  for (i in seq_len(nrow(df))) {
    cat(fmt_memory(df$mem_mb[i]), " ", df$label[i], "\n", sep = "")
  }
}

print_memory_lines_df <- function(df, file_contents) {
  if (is.null(df) || nrow(df) == 0) {
    cat("No source location data available.\n")
    return(invisible())
  }
  for (i in seq_len(nrow(df))) {
    cat(fmt_memory(df$mem_mb[i]), " ", df$location[i], "\n", sep = "")
    src_line <- get_source_line(df$filename[i], df$linenum[i], file_contents)
    if (!is.null(src_line) && nchar(src_line) > 0) {
      cat(sprintf("            %s\n", truncate_string(src_line, 58)))
    }
  }
}
