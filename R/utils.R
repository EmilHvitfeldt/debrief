# Internal utility functions

check_profvis <- function(x, call = parent.frame()) {
  if (!inherits(x, "profvis")) {
    stop("`x` must be a profvis object.", call. = FALSE)
  }
}

check_empty_profile <- function(x) {
  prof <- extract_prof(x)
  if (nrow(prof) == 0) {
    stop(
      "Profile contains no samples.\n",
      "Your code ran too fast to capture any profiling data.\n",
      "Try wrapping your code in a loop: for (i in 1:10) { ... }\n",
      "Increase the iteration count until samples appear.",
      call. = FALSE
    )
  }
}

extract_prof <- function(x) {
  x$x$message$prof
}

extract_interval <- function(x) {
  x$x$message$interval
}

extract_files <- function(x) {
  x$x$message$files
}

extract_total_samples <- function(x) {
  max(extract_prof(x)$time)
}
# Extract rows where each function is at the top of the call stack (self-time)
# This is used for self-time calculations throughout the package
extract_top_of_stack <- function(prof) {
  max_depths <- tapply(prof$depth, prof$time, max)
  max_depth_df <- data.frame(
    time = as.integer(names(max_depths)),
    max_depth = as.integer(max_depths)
  )
  prof_merged <- merge(prof, max_depth_df, by = "time")
  prof_merged[prof_merged$depth == prof_merged$max_depth, ]
}

has_source_refs <- function(x) {
  prof <- extract_prof(x)
  any(!is.na(prof$filename))
}

build_file_contents <- function(files) {
  if (is.null(files) || length(files) == 0) {
    return(list())
  }
  contents <- list()
  for (f in files) {
    if (!is.null(f$content) && !is.null(f$filename)) {
      lines <- strsplit(f$content, "\n", fixed = TRUE)[[1]]
      contents[[f$filename]] <- lines
    }
  }
  contents
}

get_source_line <- function(filename, linenum, file_contents) {
  if (is.null(file_contents) || length(file_contents) == 0) {
    return(NULL)
  }
  lines <- file_contents[[filename]]
  if (is.null(lines) || linenum > length(lines)) {
    return(NULL)
  }
  trimws(lines[linenum])
}

get_source_lines <- function(filename, start, end, file_contents) {
  if (is.null(file_contents) || length(file_contents) == 0) {
    return(NULL)
  }
  lines <- file_contents[[filename]]
  if (is.null(lines)) {
    return(NULL)
  }
  start <- max(1L, start)
  end <- min(length(lines), end)
  if (start > end) {
    return(NULL)
  }
  lines[start:end]
}

# Formatting helpers
cat_header <- function(text) {
  cat("## ", text, "\n\n", sep = "")
}

cat_section <- function(text) {
  cat("\n### ", text, "\n", sep = "")
}

# Format time with percentage - used throughout package for consistent output
fmt_time <- function(time_ms, pct, time_width = 6, pct_width = 5) {
  sprintf(
    paste0("%", time_width, ".0f ms (%", pct_width, ".1f%%)"),
    time_ms,
    pct
  )
}

# Format memory in MB - used throughout package for consistent output
fmt_memory <- function(mem_mb, width = 8) {
  sprintf(paste0("%", width, ".2f MB"), mem_mb)
}

truncate_string <- function(s, max_len = 60) {
  if (nchar(s) > max_len) {
    paste0(substr(s, 1, max_len - 3), "...")
  } else {
    s
  }
}
