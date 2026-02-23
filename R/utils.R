# Internal utility functions

check_profvis <- function(x, call = parent.frame()) {
  if (!inherits(x, "profvis")) {
    stop("`x` must be a profvis object.", call. = FALSE)
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
cat_header <- function(text, width = 70) {
  cat(strrep("=", width), "\n")
  padding <- (width - nchar(text)) %/% 2
  cat(strrep(" ", padding), text, "\n", sep = "")
  cat(strrep("=", width), "\n")
}

cat_section <- function(text, width = 70) {
  dashes <- max(0, width - nchar(text) - 5)
  cat("\n--- ", text, " ", strrep("-", dashes), "\n", sep = "")
}

fmt_time <- function(time_ms, pct) {
  sprintf("%6.0f ms (%5.1f%%)", time_ms, pct)
}

fmt_memory <- function(mem_mb) {
  sprintf("%8.2f MB", mem_mb)
}

truncate_string <- function(s, max_len = 60) {
  if (nchar(s) > max_len) {
    paste0(substr(s, 1, max_len - 3), "...")
  } else {
    s
  }
}
