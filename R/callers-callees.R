#' Get callers of a function
#'
#' Returns the functions that call a specified function, based on profiling
#' data. Shows who invokes the target function.
#'
#' @param x A profvis object.
#' @param func The function name to analyze.
#'
#' @return A data frame with columns:
#'   - `label`: Caller function name
#'   - `samples`: Number of times this caller appeared
#'   - `pct`: Percentage of calls from this caller
#'
#' @examples
#' p <- pv_example()
#' pv_callers(p, "inner")
#' @export
pv_callers <- function(x, func) {
  check_profvis(x)
  check_empty_profile(x)

  prof <- extract_prof(x)

  # Find times when target function appears
  target_times <- unique(prof$time[prof$label == func])

  if (length(target_times) == 0) {
    message(sprintf("Function '%s' not found in profiling data.", func))
    return(data.frame(
      label = character(),
      samples = integer(),
      pct = numeric(),
      stringsAsFactors = FALSE
    ))
  }

  # For each time, find the frame just before (below) the target
  callers <- lapply(target_times, function(t) {
    stack <- prof[prof$time == t, ]
    stack <- stack[order(stack$depth), ]

    target_idx <- which(stack$label == func)
    if (length(target_idx) == 0) {
      return(NULL)
    }

    # Take the first (deepest) occurrence and look at caller
    target_depth <- stack$depth[target_idx[1]]
    caller_row <- stack[stack$depth == target_depth - 1, ]

    if (nrow(caller_row) > 0) {
      caller_row$label[1]
    } else {
      "(top-level)"
    }
  })

  callers <- unlist(callers)
  if (length(callers) == 0) {
    return(data.frame(
      label = character(),
      samples = integer(),
      pct = numeric(),
      stringsAsFactors = FALSE
    ))
  }

  counts <- table(callers)
  result <- data.frame(
    label = names(counts),
    samples = as.integer(counts),
    stringsAsFactors = FALSE
  )
  result$pct <- round(100 * result$samples / sum(result$samples), 1)
  result <- result[order(-result$samples), ]
  rownames(result) <- NULL
  result
}

#' Get callees of a function
#'
#' Returns the functions that a specified function calls, based on profiling
#' data. Shows what the target function invokes.
#'
#' @param x A profvis object.
#' @param func The function name to analyze.
#'
#' @return A data frame with columns:
#'   - `label`: Callee function name
#'   - `samples`: Number of times this callee appeared
#'   - `pct`: Percentage of calls to this callee
#'
#' @examples
#' p <- pv_example()
#' pv_callees(p, "outer")
#' @export
pv_callees <- function(x, func) {
  check_profvis(x)
  check_empty_profile(x)

  prof <- extract_prof(x)

  # Find times when target function appears
  target_times <- unique(prof$time[prof$label == func])

  if (length(target_times) == 0) {
    message(sprintf("Function '%s' not found in profiling data.", func))
    return(data.frame(
      label = character(),
      samples = integer(),
      pct = numeric(),
      stringsAsFactors = FALSE
    ))
  }

  # For each time, find the frame just after (above) the target
  callees <- lapply(target_times, function(t) {
    stack <- prof[prof$time == t, ]
    stack <- stack[order(stack$depth), ]

    target_idx <- which(stack$label == func)
    if (length(target_idx) == 0) {
      return(NULL)
    }

    # Take the last (shallowest/deepest call) occurrence and look at callee
    target_depth <- stack$depth[target_idx[length(target_idx)]]
    callee_row <- stack[stack$depth == target_depth + 1, ]

    if (nrow(callee_row) > 0) {
      callee_row$label[1]
    } else {
      NULL # Function is at top of stack (self-time)
    }
  })

  callees <- unlist(callees)
  if (length(callees) == 0) {
    return(data.frame(
      label = character(),
      samples = integer(),
      pct = numeric(),
      stringsAsFactors = FALSE
    ))
  }

  counts <- table(callees)
  result <- data.frame(
    label = names(counts),
    samples = as.integer(counts),
    stringsAsFactors = FALSE
  )
  result$pct <- round(100 * result$samples / length(target_times), 1)
  result <- result[order(-result$samples), ]
  rownames(result) <- NULL
  result
}

#' Print caller/callee analysis for a function
#'
#' Shows both callers (who calls this function) and callees (what this function
#' calls) in a single view.
#'
#' @param x A profvis object.
#' @param func The function name to analyze.
#' @param n Maximum number of callers/callees to show.
#'
#' @return Invisibly returns a list with `callers` and `callees` data frames.
#'
#' @examples
#' p <- pv_example()
#' pv_print_callers_callees(p, "inner")
#' @export
pv_print_callers_callees <- function(x, func, n = 10) {
  check_profvis(x)
  check_empty_profile(x)

  callers <- pv_callers(x, func)
  callees <- pv_callees(x, func)

  prof <- extract_prof(x)
  interval_ms <- extract_interval(x)
  total_samples <- extract_total_samples(x)

  # Get time stats for this function
  func_times <- unique(prof$time[prof$label == func])
  func_total_time <- length(func_times) * interval_ms
  func_pct <- round(100 * length(func_times) / total_samples, 1)

  cat_header(sprintf("FUNCTION ANALYSIS: %s", func))
  cat("\n")
  cat(sprintf(
    "Total time: %.0f ms (%.1f%% of profile)\n",
    func_total_time,
    func_pct
  ))
  cat(sprintf("Appearances: %d samples\n\n", length(func_times)))

  cat("### Called by\n")
  if (nrow(callers) == 0) {
    cat("  Callers: none\n")
  } else {
    for (i in seq_len(min(n, nrow(callers)))) {
      cat(sprintf(
        "  %5d samples (%5.1f%%)  %s\n",
        callers$samples[i],
        callers$pct[i],
        callers$label[i]
      ))
    }
  }

  cat("\n### Calls to\n")
  if (nrow(callees) == 0) {
    cat("  Callees: none\n")
  } else {
    for (i in seq_len(min(n, nrow(callees)))) {
      cat(sprintf(
        "  %5d samples (%5.1f%%)  %s\n",
        callees$samples[i],
        callees$pct[i],
        callees$label[i]
      ))
    }
  }
  cat("\n")

  invisible(list(callers = callers, callees = callees))
}
