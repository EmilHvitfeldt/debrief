#' Memory allocation by function
#'
#' Returns memory allocation aggregated by function name.
#'
#' @param x A profvis object.
#' @param n Maximum number of functions to return. If `NULL`, returns all.
#'
#' @return A data frame with columns:
#'   - `label`: Function name
#'   - `mem_mb`: Memory allocated in megabytes
#'
#' @examples
#' \dontrun{
#' p <- profvis::profvis(x <- rep(1, 1e7))
#' pv_memory(p)
#' }
#' @export
pv_memory <- function(x, n = NULL) {
  check_profvis(x)

  prof <- extract_prof(x)

  # Sum positive memory increments by function
  prof_pos <- prof[prof$meminc > 0, ]
  if (nrow(prof_pos) == 0) {
    return(data.frame(
      label = character(),
      mem_mb = numeric(),
      stringsAsFactors = FALSE
    ))
  }

  mem_sums <- tapply(prof_pos$meminc, prof_pos$label, sum)
  result <- data.frame(
    label = names(mem_sums),
    mem_mb = as.numeric(mem_sums),
    stringsAsFactors = FALSE
  )
  result <- result[order(-result$mem_mb), ]
  rownames(result) <- NULL

  if (!is.null(n)) {
    result <- head(result, n)
  }

  result
}

#' Memory allocation by source line
#'
#' Returns memory allocation aggregated by source location. Requires source
#' references (use `devtools::load_all()` for best results).
#'
#' @param x A profvis object.
#' @param n Maximum number of lines to return. If `NULL`, returns all.
#'
#' @return A data frame with columns:
#'   - `location`: File path and line number
#'   - `label`: Function name at this location
#'   - `filename`: Source file path
#'   - `linenum`: Line number
#'   - `mem_mb`: Memory allocated in megabytes
#'
#' @examples
#' \dontrun{
#' p <- profvis::profvis(x <- rep(1, 1e7))
#' pv_memory_lines(p)
#' }
#' @export
pv_memory_lines <- function(x, n = NULL) {
  check_profvis(x)

  prof <- extract_prof(x)

  # Sum positive memory increments by source location
  prof_pos <- prof[prof$meminc > 0 & !is.na(prof$filename), ]
  if (nrow(prof_pos) == 0) {
    return(data.frame(
      location = character(),
      label = character(),
      filename = character(),
      linenum = integer(),
      mem_mb = numeric(),
      stringsAsFactors = FALSE
    ))
  }

  prof_pos$location <- paste0(prof_pos$filename, ":", prof_pos$linenum)

  mem_sums <- tapply(prof_pos$meminc, prof_pos$location, sum)
  result <- data.frame(
    location = names(mem_sums),
    mem_mb = as.numeric(mem_sums),
    stringsAsFactors = FALSE
  )

  # Get label, filename, linenum for each location
  first_occurrence <- prof_pos[!duplicated(prof_pos$location), ]
  result <- merge(
    result,
    first_occurrence[, c("location", "label", "filename", "linenum")],
    by = "location"
  )

  result <- result[order(-result$mem_mb), ]
  rownames(result) <- NULL

  if (!is.null(n)) {
    result <- head(result, n)
  }

  result
}

#' Print memory allocation summary
#'
#' @param x A profvis object.
#' @param n Number of top allocators to show.
#' @param by Either "function" or "line".
#'
#' @return Invisibly returns the memory data frame.
#' @export
pv_print_memory <- function(x, n = 10, by = c("function", "line")) {
  check_profvis(x)
  by <- match.arg(by)

  if (by == "function") {
    mem_df <- pv_memory(x, n = n)

    if (nrow(mem_df) == 0) {
      cat("No significant memory allocations detected.\n")
      return(invisible(mem_df))
    }

    cat_header("MEMORY ALLOCATION BY FUNCTION")
    cat("\n")

    for (i in seq_len(nrow(mem_df))) {
      cat(sprintf("%8.2f MB  %s\n", mem_df$mem_mb[i], mem_df$label[i]))
    }
  } else {
    mem_df <- pv_memory_lines(x, n = n)

    if (nrow(mem_df) == 0) {
      cat("No source location data available.\n")
      cat("Use devtools::load_all() to enable source references.\n")
      return(invisible(mem_df))
    }

    files <- extract_files(x)
    file_contents <- build_file_contents(files)

    cat_header("MEMORY ALLOCATION BY LINE")
    cat("\n")

    for (i in seq_len(nrow(mem_df))) {
      row <- mem_df[i, ]
      cat(sprintf("%8.2f MB  %s\n", row$mem_mb, row$location))
      src_line <- get_source_line(row$filename, row$linenum, file_contents)
      if (!is.null(src_line) && nchar(src_line) > 0) {
        cat(sprintf("            %s\n", truncate_string(src_line, 58)))
      }
    }
  }

  invisible(mem_df)
}
