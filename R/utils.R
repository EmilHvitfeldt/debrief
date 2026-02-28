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

# Print "Next steps" suggestions for AI agents
# suggestions should be a character vector of R expressions
cat_next_steps <- function(suggestions) {
  if (length(suggestions) == 0) {
    return(invisible())
  }
  cat("\n### Next steps\n")
  for (s in suggestions) {
    cat(s, "\n", sep = "")
  }
}

# Check if a function name is a user function (not internal R machinery)
# Internal functions start with: ( like (top-level), < like <GC>, [ like [.data.frame
is_user_function <- function(func_name) {
  !grepl("^[(<\\[]", func_name)
}

# Extract common profile data in one call - reduces boilerplate
extract_profile_data <- function(x) {
  check_profvis(x)

  check_empty_profile(x)
  prof <- extract_prof(x)
  list(
    prof = prof,
    interval_ms = extract_interval(x),
    total_samples = extract_total_samples(x)
  )
}

# Build a result data frame from label counts with time calculations
build_count_result <- function(counts, interval_ms, total_samples) {
  result <- data.frame(
    label = names(counts),
    samples = as.integer(counts)
  )
  result$time_ms <- result$samples * interval_ms
  result$pct <- round(100 * result$samples / total_samples, 1)
  result <- result[order(-result$samples), ]
  rownames(result) <- NULL
  result
}

# Apply standard filters and limit to result data frames
apply_result_filters <- function(
  result,
  n = NULL,
  min_pct = 0,
  min_time_ms = 0
) {
  result <- result[result$pct >= min_pct & result$time_ms >= min_time_ms, ]
  if (!is.null(n)) {
    result <- head(result, n)
  }
  result
}

# Empty data frame factories for consistent return types
empty_label_samples_pct <- function() {
  data.frame(
    label = character(),
    samples = integer(),
    pct = numeric()
  )
}

empty_time_result <- function() {
  data.frame(
    label = character(),
    samples = integer(),
    time_ms = numeric(),
    pct = numeric()
  )
}

empty_location_result <- function() {
  data.frame(
    location = character(),
    label = character(),
    filename = character(),
    linenum = integer(),
    samples = integer(),
    time_ms = numeric(),
    pct = numeric()
  )
}

empty_memory_result <- function() {
  data.frame(
    label = character(),
    mem_mb = numeric()
  )
}

empty_memory_lines_result <- function() {
  data.frame(
    location = character(),
    label = character(),
    filename = character(),
    linenum = integer(),
    mem_mb = numeric()
  )
}
