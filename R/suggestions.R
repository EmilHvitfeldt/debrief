#' Generate optimization suggestions
#'
#' Analyzes the profile and generates specific, actionable optimization
#' suggestions based on detected patterns and hotspots.
#'
#' @param x A profvis object.
#'
#' @return A data frame with columns:
#'   - `priority`: 1 (highest) to 5 (lowest)
#'   - `category`: Type of optimization (e.g., "data structure", "algorithm")
#'   - `suggestion`: The optimization suggestion
#'   - `location`: Where to apply the optimization
#'   - `potential_impact`: Estimated time that could be saved
#'
#' @examples
#' p <- pv_example("gc")
#' pv_suggestions(p)
#' @export
pv_suggestions <- function(x) {
  check_profvis(x)

  prof <- extract_prof(x)
  interval_ms <- extract_interval(x)
  total_samples <- extract_total_samples(x)
  total_time <- total_samples * interval_ms
  has_source <- has_source_refs(x)

  suggestions <- list()

  # Check for data frame subsetting in recursion
  suggestions <- c(
    suggestions,
    suggest_df_vectorization(prof, interval_ms, total_samples, total_time)
  )

  # Check for recursive functions
  suggestions <- c(
    suggestions,
    suggest_recursion_optimization(prof, interval_ms, total_samples, total_time)
  )

  # Check for GC pressure
  suggestions <- c(
    suggestions,
    suggest_gc_reduction(prof, interval_ms, total_samples, total_time)
  )

  # Check for string operations
  suggestions <- c(
    suggestions,
    suggest_string_optimization(prof, interval_ms, total_samples, total_time)
  )

  # Check for hot lines (if source available)
  if (has_source) {
    suggestions <- c(
      suggestions,
      suggest_hotline_optimization(x, interval_ms, total_samples, total_time)
    )
  }

  # Generic suggestions based on top functions
  suggestions <- c(
    suggestions,
    suggest_top_function_optimization(
      prof,
      interval_ms,
      total_samples,
      total_time
    )
  )

  if (length(suggestions) == 0) {
    return(data.frame(
      priority = integer(),
      category = character(),
      suggestion = character(),
      location = character(),
      potential_impact = character(),
      stringsAsFactors = FALSE
    ))
  }

  result <- do.call(rbind, suggestions)
  result <- result[order(result$priority), ]
  rownames(result) <- NULL

  # Remove duplicates
  result <- result[!duplicated(result$suggestion), ]

  result
}

suggest_df_vectorization <- function(
  prof,
  interval_ms,
  total_samples,
  total_time
) {
  df_subset_times <- unique(prof$time[
    prof$label %in% c("[.data.frame", "[[.data.frame")
  ])
  df_time <- length(df_subset_times) * interval_ms
  df_pct <- 100 * df_time / total_time

  if (df_pct > 15) {
    list(data.frame(
      priority = 1L,
      category = "data structure",
      suggestion = "Replace data frame row subsetting with vector indexing. Instead of `df[i, ]$col`, use `df$col[i]` or pre-extract columns as vectors before loops/recursion.",
      location = "[.data.frame / [[.data.frame",
      potential_impact = sprintf(
        "Up to %.0f ms (%.0f%%)",
        df_time * 0.8,
        df_pct * 0.8
      ),
      stringsAsFactors = FALSE
    ))
  } else {
    list()
  }
}

suggest_recursion_optimization <- function(
  prof,
  interval_ms,
  total_samples,
  total_time
) {
  # Find recursive functions
  times <- unique(prof$time)
  recursive_stats <- list()

  for (t in times) {
    stack <- prof[prof$time == t, ]
    func_counts <- table(stack$label)
    for (func in names(func_counts[func_counts > 1])) {
      if (is.null(recursive_stats[[func]])) {
        recursive_stats[[func]] <- 0
      }
      recursive_stats[[func]] <- recursive_stats[[func]] + 1
    }
  }

  suggestions <- list()
  for (func in names(recursive_stats)) {
    func_time <- recursive_stats[[func]] * interval_ms
    func_pct <- 100 * func_time / total_time

    if (func_pct > 20 && !grepl("^[.<\\[]", func)) {
      # Skip internal functions
      suggestions[[length(suggestions) + 1]] <- data.frame(
        priority = 2L,
        category = "algorithm",
        suggestion = sprintf(
          "Consider converting recursive function '%s' to iterative. Use a stack/queue data structure instead of call stack. This reduces function call overhead and enables better optimization.",
          func
        ),
        location = func,
        potential_impact = sprintf(
          "Potentially %.0f ms (%.0f%%)",
          func_time * 0.3,
          func_pct * 0.3
        ),
        stringsAsFactors = FALSE
      )
    }
  }

  suggestions
}

suggest_gc_reduction <- function(prof, interval_ms, total_samples, total_time) {
  gc_times <- unique(prof$time[prof$label == "<GC>"])
  gc_time <- length(gc_times) * interval_ms
  gc_pct <- 100 * gc_time / total_time

  if (gc_pct > 10) {
    list(data.frame(
      priority = 2L,
      category = "memory",
      suggestion = "High GC overhead detected. Pre-allocate vectors/lists to final size instead of growing them. Avoid creating unnecessary intermediate objects. Consider reusing objects where possible.",
      location = "memory allocation hotspots",
      potential_impact = sprintf(
        "Up to %.0f ms (%.0f%%)",
        gc_time * 0.5,
        gc_pct * 0.5
      ),
      stringsAsFactors = FALSE
    ))
  } else {
    list()
  }
}

suggest_string_optimization <- function(
  prof,
  interval_ms,
  total_samples,
  total_time
) {
  string_funcs <- c(
    "paste",
    "paste0",
    "sprintf",
    "gsub",
    "sub",
    "grep",
    "grepl",
    "strsplit",
    "substring",
    "substr"
  )

  total_string_time <- 0
  hot_string_func <- NULL
  max_time <- 0

  for (func in string_funcs) {
    func_times <- unique(prof$time[prof$label == func])
    func_time <- length(func_times) * interval_ms
    total_string_time <- total_string_time + func_time
    if (func_time > max_time) {
      max_time <- func_time
      hot_string_func <- func
    }
  }

  string_pct <- 100 * total_string_time / total_time

  if (string_pct > 5 && !is.null(hot_string_func)) {
    list(data.frame(
      priority = 3L,
      category = "string operations",
      suggestion = sprintf(
        "String operations are significant (%.1f%%). Consider: (1) pre-computing strings outside loops, (2) using fixed=TRUE in grep/gsub when not using regex, (3) using stringi package for heavy string processing.",
        string_pct
      ),
      location = hot_string_func,
      potential_impact = sprintf(
        "Up to %.0f ms (%.0f%%)",
        total_string_time * 0.5,
        string_pct * 0.5
      ),
      stringsAsFactors = FALSE
    ))
  } else {
    list()
  }
}

suggest_hotline_optimization <- function(
  x,
  interval_ms,
  total_samples,
  total_time
) {
  hot_lines <- pv_hot_lines(x, n = 3)

  if (nrow(hot_lines) == 0) {
    return(list())
  }

  suggestions <- list()
  for (i in seq_len(nrow(hot_lines))) {
    row <- hot_lines[i, ]
    if (row$pct > 5) {
      suggestions[[length(suggestions) + 1]] <- data.frame(
        priority = 1L,
        category = "hot line",
        suggestion = sprintf(
          "Line '%s' at %s consumes %.1f%% of time. Focus optimization efforts here first.",
          truncate_string(row$label, 30),
          row$location,
          row$pct
        ),
        location = row$location,
        potential_impact = sprintf("%.0f ms (%.1f%%)", row$time_ms, row$pct),
        stringsAsFactors = FALSE
      )
    }
  }

  suggestions
}

suggest_top_function_optimization <- function(
  prof,
  interval_ms,
  total_samples,
  total_time
) {
  # Get self-time
  max_depths <- tapply(prof$depth, prof$time, max)
  max_depth_df <- data.frame(
    time = as.integer(names(max_depths)),
    max_depth = as.integer(max_depths)
  )
  prof_merged <- merge(prof, max_depth_df, by = "time")
  top_of_stack <- prof_merged[prof_merged$depth == prof_merged$max_depth, ]

  counts <- table(top_of_stack$label)
  top_func <- names(sort(counts, decreasing = TRUE))[1]
  top_time <- as.integer(counts[top_func]) * interval_ms
  top_pct <- 100 * top_time / total_time

  # Only suggest if it's not an internal R function
  if (top_pct > 10 && !grepl("^[.<\\[]|^<", top_func)) {
    list(data.frame(
      priority = 2L,
      category = "hot function",
      suggestion = sprintf(
        "Function '%s' has highest self-time (%.1f%%). Profile this function in isolation to find micro-optimization opportunities.",
        top_func,
        top_pct
      ),
      location = top_func,
      potential_impact = sprintf("%.0f ms (%.1f%%)", top_time, top_pct),
      stringsAsFactors = FALSE
    ))
  } else {
    list()
  }
}

#' Print optimization suggestions
#'
#' @param x A profvis object.
#'
#' @return Invisibly returns the suggestions data frame.
#'
#' @examples
#' p <- pv_example("gc")
#' pv_print_suggestions(p)
#'
#' @export
pv_print_suggestions <- function(x) {
  check_profvis(x)

  suggestions <- pv_suggestions(x)

  cat_header("OPTIMIZATION SUGGESTIONS")
  cat("\n")

  if (nrow(suggestions) == 0) {
    cat(
      "No specific optimization suggestions. The code may already be well-optimized,\n"
    )
    cat("or the profile is too short to identify patterns.\n")
    return(invisible(suggestions))
  }

  cat("Suggestions are ordered by priority (1 = highest impact).\n\n")

  current_priority <- 0
  for (i in seq_len(nrow(suggestions))) {
    row <- suggestions[i, ]

    if (row$priority != current_priority) {
      current_priority <- row$priority
      cat(sprintf("=== Priority %d ===\n\n", current_priority))
    }

    cat(sprintf("[%s] %s\n", row$category, row$location))
    cat(sprintf("    %s\n", row$suggestion))
    cat(sprintf("    Potential impact: %s\n\n", row$potential_impact))
  }

  invisible(suggestions)
}
