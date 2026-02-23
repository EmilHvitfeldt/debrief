#' Show source context for a specific location
#'
#' Displays source code around a specific file and line number with profiling
#' information for each line.
#'
#' @param x A profvis object.
#' @param filename The source file to examine.
#' @param linenum The line number to center on. If `NULL`, shows the hottest
#'   line in the file.
#' @param context Number of lines to show before and after.
#'
#' @return Invisibly returns a data frame with line-by-line profiling data.
#'
#' @examples
#' \dontrun{
#' p <- profvis::profvis(some_function())
#' pv_source_context(p, "/R/my-file.R", linenum = 42)
#' }
#' @export
pv_source_context <- function(x, filename, linenum = NULL, context = 10) {
  check_profvis(x)

  prof <- extract_prof(x)
  interval_ms <- extract_interval(x)
  total_samples <- extract_total_samples(x)
  files <- extract_files(x)
  file_contents <- build_file_contents(files)

  # Find matching filename (partial match allowed)
  available_files <- unique(prof$filename[!is.na(prof$filename)])
  matching <- grep(filename, available_files, value = TRUE, fixed = TRUE)

  if (length(matching) == 0) {
    cat("File not found in profiling data.\n")
    cat("Available files:\n")
    for (f in available_files) {
      cat("  ", f, "\n")
    }
    return(invisible(NULL))
  }

  if (length(matching) > 1) {
    cat("Multiple files match. Using:", matching[1], "\n")
  }
  filename <- matching[1]

  # Get profiling data for this file
  file_prof <- prof[!is.na(prof$filename) & prof$filename == filename, ]

  # If no linenum specified, find the hottest line
  if (is.null(linenum)) {
    # Self-time: top of stack
    max_depths <- tapply(prof$depth, prof$time, max)
    max_depth_df <- data.frame(
      time = as.integer(names(max_depths)),
      max_depth = as.integer(max_depths)
    )
    prof_merged <- merge(file_prof, max_depth_df, by = "time")
    top_of_stack <- prof_merged[prof_merged$depth == prof_merged$max_depth, ]

    if (nrow(top_of_stack) > 0) {
      line_counts <- table(top_of_stack$linenum)
      linenum <- as.integer(names(which.max(line_counts)))
    } else {
      linenum <- min(file_prof$linenum, na.rm = TRUE)
    }
    cat(sprintf("Showing context around hottest line: %d\n\n", linenum))
  }

  # Get line-by-line profiling data
  line_data <- aggregate_lines(file_prof, interval_ms, total_samples)

  # Get source lines
  start_line <- max(1L, linenum - context)
  end_line <- linenum + context
  source_lines <- get_source_lines(
    filename,
    start_line,
    end_line,
    file_contents
  )

  if (is.null(source_lines)) {
    cat("Source code not available for this file.\n")
    return(invisible(line_data))
  }

  actual_end <- min(start_line + length(source_lines) - 1, end_line)

  cat_header(sprintf("SOURCE: %s", filename))
  cat("\n")
  cat(sprintf(
    "Lines %d-%d (centered on %d)\n\n",
    start_line,
    actual_end,
    linenum
  ))
  cat("  Time   Mem   Line  Source\n")
  cat(strrep("-", 70), "\n")

  for (i in seq_along(source_lines)) {
    ln <- start_line + i - 1
    line_info <- line_data[line_data$linenum == ln, ]

    if (nrow(line_info) > 0) {
      time_str <- sprintf("%5.0f", line_info$time_ms[1])
      mem_str <- sprintf("%5.1f", line_info$mem_mb[1])
    } else {
      time_str <- "    -"
      mem_str <- "    -"
    }

    marker <- if (ln == linenum) ">>>" else "   "
    cat(sprintf(
      "%s %s %s %4d: %s\n",
      marker,
      time_str,
      mem_str,
      ln,
      source_lines[i]
    ))
  }

  cat(strrep("-", 70), "\n")
  cat("Time in ms, Memory in MB\n")

  invisible(line_data)
}

aggregate_lines <- function(file_prof, interval_ms, total_samples) {
  if (nrow(file_prof) == 0) {
    return(data.frame(
      linenum = integer(),
      samples = integer(),
      time_ms = numeric(),
      pct = numeric(),
      mem_mb = numeric(),
      stringsAsFactors = FALSE
    ))
  }

  # Aggregate samples by line
  line_counts <- table(file_prof$linenum)
  mem_sums <- tapply(
    pmax(0, file_prof$meminc),
    file_prof$linenum,
    sum
  )

  result <- data.frame(
    linenum = as.integer(names(line_counts)),
    samples = as.integer(line_counts),
    stringsAsFactors = FALSE
  )
  result$time_ms <- result$samples * interval_ms
  result$pct <- round(100 * result$samples / total_samples, 1)
  result$mem_mb <- as.numeric(mem_sums[as.character(result$linenum)])
  result$mem_mb[is.na(result$mem_mb)] <- 0

  result[order(-result$samples), ]
}
