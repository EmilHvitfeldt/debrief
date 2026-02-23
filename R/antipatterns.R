#' Detect common performance anti-patterns
#'
#' Analyzes the profile to identify known performance anti-patterns in R code,
#' such as data frame operations in loops, growing vectors, and string
#' operations in hot paths.
#'
#' @param x A profvis object.
#'
#' @return A data frame with columns:
#'   - `pattern`: Name of the anti-pattern
#'   - `severity`: "high", "medium", or "low"
#'   - `location`: Where the pattern was detected (function or file:line)
#'   - `description`: Explanation of the issue
#'   - `time_ms`: Time spent in this pattern
#'   - `pct`: Percentage of total time
#'
#' @examples
#' \dontrun{
#' p <- profvis::profvis(some_function())
#' pv_antipatterns(p)
#' }
#' @export
pv_antipatterns <- function(x) {
  check_profvis(x)

  prof <- extract_prof(x)
  interval_ms <- extract_interval(x)
  total_samples <- extract_total_samples(x)
  has_source <- has_source_refs(x)

  patterns <- list()

  # Pattern 1: Data frame subsetting in recursion/loops
  patterns <- c(
    patterns,
    detect_df_subsetting_in_recursion(prof, interval_ms, total_samples)
  )

  # Pattern 2: Repeated string operations
  patterns <- c(patterns, detect_string_ops(prof, interval_ms, total_samples))

  # Pattern 3: Excessive garbage collection
  patterns <- c(patterns, detect_gc_pressure(prof, interval_ms, total_samples))

  # Pattern 4: Deep call stacks
  patterns <- c(patterns, detect_deep_stacks(prof, interval_ms, total_samples))

  # Pattern 5: Data frame operations in hot paths
  patterns <- c(
    patterns,
    detect_df_ops_in_hot_path(prof, interval_ms, total_samples)
  )

  if (length(patterns) == 0) {
    return(data.frame(
      pattern = character(),
      severity = character(),
      location = character(),
      description = character(),
      time_ms = numeric(),
      pct = numeric(),
      stringsAsFactors = FALSE
    ))
  }

  result <- do.call(rbind, patterns)
  result <- result[
    order(
      factor(result$severity, levels = c("high", "medium", "low")),
      -result$time_ms
    ),
  ]
  rownames(result) <- NULL
  result
}

detect_df_subsetting_in_recursion <- function(
  prof,
  interval_ms,
  total_samples
) {
  # Find recursive functions
  times <- unique(prof$time)
  recursive_funcs <- character()

  for (t in times) {
    stack <- prof[prof$time == t, ]
    func_counts <- table(stack$label)
    recursive_funcs <- c(recursive_funcs, names(func_counts[func_counts > 1]))
  }
  recursive_funcs <- unique(recursive_funcs)

  if (length(recursive_funcs) == 0) {
    return(list())
  }

  # Check if [.data.frame or [[.data.frame appear with recursive functions
  df_ops <- c("[.data.frame", "[[.data.frame", "[.data.table", "[[.data.table")

  patterns <- list()
  for (func in recursive_funcs) {
    # Find times where both recursive func and df ops appear
    func_times <- unique(prof$time[prof$label == func])
    for (df_op in df_ops) {
      df_times <- unique(prof$time[prof$label == df_op])
      overlap <- intersect(func_times, df_times)

      if (length(overlap) > 10) {
        # Threshold
        time_ms <- length(overlap) * interval_ms
        pct <- round(100 * length(overlap) / total_samples, 1)

        if (pct > 5) {
          patterns[[length(patterns) + 1]] <- data.frame(
            pattern = "df_subset_in_recursion",
            severity = if (pct > 20) {
              "high"
            } else if (pct > 10) {
              "medium"
            } else {
              "low"
            },
            location = sprintf("%s + %s", func, df_op),
            description = sprintf(
              "Data frame subsetting (%s) inside recursive function (%s). Consider using vector indexing or pre-extracting columns.",
              df_op,
              func
            ),
            time_ms = time_ms,
            pct = pct,
            stringsAsFactors = FALSE
          )
        }
      }
    }
  }

  patterns
}

detect_string_ops <- function(prof, interval_ms, total_samples) {
  string_funcs <- c(
    "paste",
    "paste0",
    "sprintf",
    "substr",
    "substring",
    "gsub",
    "sub",
    "grep",
    "grepl",
    "regexpr",
    "regmatches",
    "strsplit",
    "nchar",
    "toupper",
    "tolower"
  )

  patterns <- list()
  for (func in string_funcs) {
    func_times <- unique(prof$time[prof$label == func])
    if (length(func_times) > 0) {
      time_ms <- length(func_times) * interval_ms
      pct <- round(100 * length(func_times) / total_samples, 1)

      if (pct > 5) {
        patterns[[length(patterns) + 1]] <- data.frame(
          pattern = "string_ops_hot_path",
          severity = if (pct > 15) {
            "high"
          } else if (pct > 8) {
            "medium"
          } else {
            "low"
          },
          location = func,
          description = sprintf(
            "String operation '%s' in hot path (%.1f%% of time). Consider pre-computing or using faster alternatives.",
            func,
            pct
          ),
          time_ms = time_ms,
          pct = pct,
          stringsAsFactors = FALSE
        )
      }
    }
  }

  patterns
}

detect_gc_pressure <- function(prof, interval_ms, total_samples) {
  gc_times <- unique(prof$time[prof$label == "<GC>"])
  if (length(gc_times) == 0) {
    return(list())
  }

  time_ms <- length(gc_times) * interval_ms
  pct <- round(100 * length(gc_times) / total_samples, 1)

  if (pct > 10) {
    list(data.frame(
      pattern = "gc_pressure",
      severity = if (pct > 25) {
        "high"
      } else if (pct > 15) {
        "medium"
      } else {
        "low"
      },
      location = "<GC>",
      description = sprintf(
        "High garbage collection overhead (%.1f%% of time). Indicates excessive memory allocation. Look for growing vectors, repeated data frame operations, or unnecessary copies.",
        pct
      ),
      time_ms = time_ms,
      pct = pct,
      stringsAsFactors = FALSE
    ))
  } else {
    list()
  }
}

detect_deep_stacks <- function(prof, interval_ms, total_samples) {
  max_depth <- max(prof$depth)

  if (max_depth > 50) {
    # Find where deep stacks occur
    deep_times <- unique(prof$time[prof$depth > 30])
    time_ms <- length(deep_times) * interval_ms
    pct <- round(100 * length(deep_times) / total_samples, 1)

    list(data.frame(
      pattern = "deep_call_stack",
      severity = if (max_depth > 100) "medium" else "low",
      location = sprintf("max depth: %d", max_depth),
      description = sprintf(
        "Very deep call stacks (max %d). May indicate deep recursion or excessive function call overhead.",
        max_depth
      ),
      time_ms = time_ms,
      pct = pct,
      stringsAsFactors = FALSE
    ))
  } else {
    list()
  }
}

detect_df_ops_in_hot_path <- function(prof, interval_ms, total_samples) {
  df_funcs <- c(
    "[.data.frame",
    "[[.data.frame",
    "$<-.data.frame",
    "[<-.data.frame",
    "rbind.data.frame",
    "cbind.data.frame",
    "merge.data.frame"
  )

  total_df_time <- 0
  for (func in df_funcs) {
    func_times <- unique(prof$time[prof$label == func])
    total_df_time <- total_df_time + length(func_times)
  }

  time_ms <- total_df_time * interval_ms
  pct <- round(100 * total_df_time / total_samples, 1)

  if (pct > 20) {
    list(data.frame(
      pattern = "df_ops_heavy",
      severity = if (pct > 40) "high" else "medium",
      location = "data.frame operations",
      description = sprintf(
        "Data frame operations consume %.1f%% of time. Consider using data.table, vectors, or matrices for performance-critical code.",
        pct
      ),
      time_ms = time_ms,
      pct = pct,
      stringsAsFactors = FALSE
    ))
  } else {
    list()
  }
}

#' Print anti-patterns analysis
#'
#' @param x A profvis object.
#'
#' @return Invisibly returns the anti-patterns data frame.
#' @export
pv_print_antipatterns <- function(x) {
  check_profvis(x)

  patterns <- pv_antipatterns(x)

  cat_header("PERFORMANCE ANTI-PATTERNS")
  cat("\n")

  if (nrow(patterns) == 0) {
    cat("No significant anti-patterns detected.\n")
    return(invisible(patterns))
  }

  for (i in seq_len(nrow(patterns))) {
    row <- patterns[i, ]
    severity_icon <- switch(
      row$severity,
      high = "[!!!]",
      medium = "[!!]",
      low = "[!]"
    )

    cat(sprintf(
      "%s %s (%.0f ms, %.1f%%)\n",
      severity_icon,
      row$pattern,
      row$time_ms,
      row$pct
    ))
    cat(sprintf("    Location: %s\n", row$location))
    cat(sprintf("    %s\n\n", row$description))
  }

  invisible(patterns)
}
