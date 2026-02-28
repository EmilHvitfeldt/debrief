#' Export profiling results as JSON
#'
#' Exports profiling analysis results in JSON format for consumption by
#' AI agents, automated tools, or external applications.
#'
#' @param x A profvis object.
#' @param file Optional file path to write JSON to. If `NULL`, returns the
#'   JSON string.
#' @param pretty If `TRUE`, formats JSON with indentation for readability.
#' @param include Character vector specifying which analyses to include.
#'   Options: "summary", "self_time", "total_time", "hot_lines", "memory",
#'   "callers", "gc_pressure", "suggestions", "recursive". Default includes all.
#' @param system_info If `TRUE`, includes R version and platform info in
#'   metadata. Useful for reproducibility.
#'
#' @return If `file` is `NULL`, returns a JSON string. Otherwise writes to file
#'   and returns the file path invisibly.
#'
#' @examples
#' p <- pv_example()
#' json <- pv_to_json(p)
#' cat(json)
#'
#' # Include only specific analyses
#' json <- pv_to_json(p, include = c("self_time", "hot_lines"))
#'
#' # Include system info for reproducibility
#' json <- pv_to_json(p, system_info = TRUE)
#'
#' @export
pv_to_json <- function(
  x,
  file = NULL,
  pretty = TRUE,
  include = c(
    "summary",
    "self_time",
    "total_time",
    "hot_lines",
    "memory",
    "gc_pressure",
    "suggestions",
    "recursive"
  ),
  system_info = FALSE
) {
  check_profvis(x)
  check_empty_profile(x)

  include <- match.arg(
    include,
    c(
      "summary",
      "self_time",
      "total_time",
      "hot_lines",
      "memory",
      "gc_pressure",
      "suggestions",
      "recursive"
    ),
    several.ok = TRUE
  )

  result <- list()

  # Basic metadata
  prof <- extract_prof(x)
  interval_ms <- extract_interval(x)
  total_samples <- extract_total_samples(x)

  result$metadata <- list(
    total_time_ms = total_samples * interval_ms,
    total_samples = total_samples,
    interval_ms = interval_ms,
    has_source_refs = has_source_refs(x),
    exported_at = format(Sys.time(), "%Y-%m-%dT%H:%M:%S%z")
  )

  # Add system info if requested
  if (system_info) {
    r_info <- R.Version()
    result$metadata$system <- list(
      r_version = paste(r_info$major, r_info$minor, sep = "."),
      platform = r_info$platform,
      os = r_info$os,
      arch = r_info$arch
    )
  }

  # Include requested analyses
  if ("summary" %in% include) {
    result$summary <- list(
      total_time_ms = total_samples * interval_ms,
      unique_functions = length(unique(prof$label)),
      max_depth = max(prof$depth)
    )
  }

  if ("self_time" %in% include) {
    result$self_time <- df_to_list(pv_self_time(x))
  }

  if ("total_time" %in% include) {
    result$total_time <- df_to_list(pv_total_time(x))
  }

  if ("hot_lines" %in% include) {
    hot_lines <- pv_hot_lines(x)
    if (nrow(hot_lines) > 0) {
      result$hot_lines <- df_to_list(hot_lines)
    } else {
      result$hot_lines <- list()
    }
  }

  if ("memory" %in% include) {
    result$memory <- list(
      by_function = df_to_list(pv_memory(x)),
      by_line = df_to_list(pv_memory_lines(x))
    )
  }

  if ("gc_pressure" %in% include) {
    patterns <- pv_gc_pressure(x)
    if (nrow(patterns) > 0) {
      result$gc_pressure <- df_to_list(patterns)
    } else {
      result$gc_pressure <- list()
    }
  }

  if ("suggestions" %in% include) {
    suggestions <- pv_suggestions(x)
    if (nrow(suggestions) > 0) {
      result$suggestions <- df_to_list(suggestions)
    } else {
      result$suggestions <- list()
    }
  }

  if ("recursive" %in% include) {
    recursive <- pv_recursive(x)
    if (nrow(recursive) > 0) {
      result$recursive <- df_to_list(recursive)
    } else {
      result$recursive <- list()
    }
  }

  # Convert to JSON
  json <- to_json(result, pretty = pretty)

  if (!is.null(file)) {
    writeLines(json, file)
    invisible(file)
  } else {
    json
  }
}

#' Export profiling results as a list
#'
#' Returns all profiling analysis results as a nested R list, useful for
#' programmatic access to results without JSON serialization.
#'
#' @param x A profvis object.
#' @param include Character vector specifying which analyses to include.
#'   Same options as [pv_to_json()].
#' @param system_info If `TRUE`, includes R version and platform info in
#'   metadata.
#'
#' @return A named list containing the requested analyses.
#'
#' @examples
#' p <- pv_example()
#' results <- pv_to_list(p)
#' names(results)
#' results$self_time
#'
#' @export
pv_to_list <- function(
  x,
  include = c(
    "summary",
    "self_time",
    "total_time",
    "hot_lines",
    "memory",
    "gc_pressure",
    "suggestions",
    "recursive"
  ),
  system_info = FALSE
) {
  check_profvis(x)
  check_empty_profile(x)

  include <- match.arg(
    include,
    c(
      "summary",
      "self_time",
      "total_time",
      "hot_lines",
      "memory",
      "gc_pressure",
      "suggestions",
      "recursive"
    ),
    several.ok = TRUE
  )

  result <- list()

  prof <- extract_prof(x)
  interval_ms <- extract_interval(x)
  total_samples <- extract_total_samples(x)

  result$metadata <- list(
    total_time_ms = total_samples * interval_ms,
    total_samples = total_samples,
    interval_ms = interval_ms,
    has_source_refs = has_source_refs(x),
    exported_at = Sys.time()
  )

  if (system_info) {
    r_info <- R.Version()
    result$metadata$system <- list(
      r_version = paste(r_info$major, r_info$minor, sep = "."),
      platform = r_info$platform,
      os = r_info$os,
      arch = r_info$arch
    )
  }

  if ("summary" %in% include) {
    result$summary <- list(
      total_time_ms = total_samples * interval_ms,
      unique_functions = length(unique(prof$label)),
      max_depth = max(prof$depth)
    )
  }

  if ("self_time" %in% include) {
    result$self_time <- pv_self_time(x)
  }

  if ("total_time" %in% include) {
    result$total_time <- pv_total_time(x)
  }

  if ("hot_lines" %in% include) {
    result$hot_lines <- pv_hot_lines(x)
  }

  if ("memory" %in% include) {
    result$memory <- list(
      by_function = pv_memory(x),
      by_line = pv_memory_lines(x)
    )
  }

  if ("gc_pressure" %in% include) {
    result$gc_pressure <- pv_gc_pressure(x)
  }

  if ("suggestions" %in% include) {
    result$suggestions <- pv_suggestions(x)
  }

  if ("recursive" %in% include) {
    result$recursive <- pv_recursive(x)
  }

  result
}

# Convert data frame to list of rows for JSON serialization
df_to_list <- function(df) {
  if (is.null(df) || nrow(df) == 0) {
    return(list())
  }
  lapply(seq_len(nrow(df)), function(i) as.list(df[i, , drop = FALSE]))
}

# Simple JSON serialization without external dependencies
to_json <- function(x, pretty = TRUE, indent = 0) {
  indent_str <- if (pretty) strrep("  ", indent) else ""
  newline <- if (pretty) "\n" else ""

  if (is.null(x)) {
    return("null")
  }

  if (is.logical(x) && length(x) == 1) {
    return(
      if (is.na(x)) {
        "null"
      } else if (x) {
        "true"
      } else {
        "false"
      }
    )
  }

  if (is.atomic(x) && length(x) == 1) {
    if (is.na(x)) {
      return("null")
    }
    if (is.character(x)) {
      # Escape special characters
      x <- gsub("\\\\", "\\\\\\\\", x)
      x <- gsub("\"", "\\\\\"", x)
      x <- gsub("\n", "\\\\n", x)
      x <- gsub("\r", "\\\\r", x)
      x <- gsub("\t", "\\\\t", x)
      return(sprintf("\"%s\"", x))
    }
    return(as.character(x))
  }

  if (is.atomic(x) && length(x) > 1) {
    # Array of primitives
    elements <- vapply(
      x,
      function(el) to_json(el, pretty = FALSE),
      character(1)
    )
    return(sprintf("[%s]", paste(elements, collapse = ", ")))
  }

  if (is.data.frame(x)) {
    return(to_json(df_to_list(x), pretty = pretty, indent = indent))
  }

  if (is.list(x)) {
    if (length(x) == 0) {
      if (!is.null(names(x))) {
        return("{}")
      }
      return("[]")
    }

    if (is.null(names(x))) {
      # Array
      elements <- vapply(
        x,
        function(el) {
          paste0(
            if (pretty) strrep("  ", indent + 1) else "",
            to_json(el, pretty = pretty, indent = indent + 1)
          )
        },
        character(1)
      )
      return(sprintf(
        "[%s%s%s%s]",
        newline,
        paste(elements, collapse = paste0(",", newline)),
        newline,
        indent_str
      ))
    } else {
      # Object
      keys <- names(x)
      pairs <- vapply(
        seq_along(x),
        function(i) {
          key <- keys[i]
          val <- to_json(x[[i]], pretty = pretty, indent = indent + 1)
          sprintf(
            "%s\"%s\": %s",
            if (pretty) strrep("  ", indent + 1) else "",
            key,
            val
          )
        },
        character(1)
      )
      return(sprintf(
        "{%s%s%s%s}",
        newline,
        paste(pairs, collapse = paste0(",", newline)),
        newline,
        indent_str
      ))
    }
  }

  # Fallback
  "null"
}
