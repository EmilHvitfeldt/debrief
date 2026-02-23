#' Text-based flame graph
#'
#' Generates an ASCII representation of a flame graph showing the hierarchical
#' breakdown of time spent in the call tree.
#'
#' @param x A profvis object.
#' @param width Width of the flame graph in characters.
#' @param min_pct Minimum percentage to show (filters small slices).
#' @param max_depth Maximum depth to display.
#'
#' @return Invisibly returns the flame data structure.
#'
#' @examples
#' p <- pv_example()
#' pv_flame(p)
#' @export
pv_flame <- function(x, width = 70, min_pct = 2, max_depth = 15) {
  check_profvis(x)

  prof <- extract_prof(x)
  interval_ms <- extract_interval(x)
  total_samples <- extract_total_samples(x)
  total_time <- total_samples * interval_ms

  cat_header("FLAME GRAPH (text)")
  cat("\n")
  cat(sprintf(
    "Total time: %.0f ms | Width: %d chars | Min: %.0f%%\n\n",
    total_time,
    width,
    min_pct
  ))

  # Build and print flame tree using path-based approach
  tree <- build_flame_tree_v2(prof, total_samples)

  # Print the tree
  print_flame_tree(tree, width, min_pct, total_samples, max_depth)

  cat("\nLegend: [====] = time spent, width proportional to time\n")

  invisible(tree)
}

build_flame_tree_v2 <- function(prof, total_samples) {
  # Build tree by aggregating paths
  times <- unique(prof$time)

  # Get stack for each time point
  stacks <- lapply(times, function(t) {
    stack <- prof[prof$time == t, ]
    stack <- stack[order(stack$depth), ]
    stack$label
  })

  # Find max depth and pre-allocate
  max_depth <- max(sapply(stacks, length))
  tree <- vector("list", max_depth)
  for (i in seq_len(max_depth)) {
    tree[[i]] <- list()
  }

  # Count path prefixes at each level
  for (stack in stacks) {
    for (depth in seq_along(stack)) {
      path <- paste(stack[1:depth], collapse = "|")
      if (is.null(tree[[depth]][[path]])) {
        tree[[depth]][[path]] <- list(
          name = stack[depth],
          samples = 0,
          depth = depth,
          parent_path = if (depth > 1) {
            paste(stack[1:(depth - 1)], collapse = "|")
          } else {
            ""
          }
        )
      }
      tree[[depth]][[path]]$samples <- tree[[depth]][[path]]$samples + 1
    }
  }

  tree
}

print_flame_tree <- function(tree, width, min_pct, total_samples, max_depth) {
  # Print root bar
  bar <- strrep("=", width)
  cat(sprintf("[%s] (root) 100%%\n", bar))

  if (length(tree) == 0) {
    return()
  }

  # Print each level
  for (depth in seq_len(min(length(tree), max_depth))) {
    level <- tree[[depth]]
    if (is.null(level)) {
      next
    }

    # Sort by samples descending
    items <- level[order(-sapply(level, function(x) x$samples))]

    for (item in items) {
      pct <- 100 * item$samples / total_samples
      if (pct < min_pct) {
        next
      }

      bar_width <- max(1, round(width * item$samples / total_samples))
      bar <- strrep("=", bar_width)
      indent <- strrep("  ", item$depth)

      name <- truncate_string(item$name, 40)
      cat(sprintf("%s[%s] %s (%.1f%%)\n", indent, bar, name, pct))
    }
  }
}

#' Condensed flame graph
#'
#' Shows a simplified, condensed view of the flame graph focusing on the
#' hottest paths.
#'
#' @param x A profvis object.
#' @param n Number of hot paths to show.
#' @param width Width of bars.
#'
#' @return Invisibly returns a data frame with path, samples, and pct columns.
#' @export
pv_flame_condense <- function(x, n = 10, width = 50) {
  check_profvis(x)

  prof <- extract_prof(x)
  interval_ms <- extract_interval(x)
  total_samples <- extract_total_samples(x)

  cat_header("CONDENSED FLAME VIEW")
  cat("\n")

  # Get unique paths and their frequencies
  times <- unique(prof$time)

  path_counts <- list()
  for (t in times) {
    stack <- prof[prof$time == t, ]
    stack <- stack[order(stack$depth), ]
    path <- paste(stack$label, collapse = " > ")

    if (is.null(path_counts[[path]])) {
      path_counts[[path]] <- 0
    }
    path_counts[[path]] <- path_counts[[path]] + 1
  }

  # Convert to data frame and sort
  paths_df <- data.frame(
    path = names(path_counts),
    samples = unlist(path_counts),
    stringsAsFactors = FALSE
  )
  paths_df <- paths_df[order(-paths_df$samples), ]
  paths_df$pct <- round(100 * paths_df$samples / total_samples, 1)

  # Show top n paths
  for (i in seq_len(min(n, nrow(paths_df)))) {
    row <- paths_df[i, ]
    bar_width <- max(1, round(width * row$samples / total_samples))
    bar <- strrep("#", bar_width)

    cat(sprintf("\n%s %.1f%% (%d samples)\n", bar, row$pct, row$samples))

    # Show path vertically
    parts <- strsplit(row$path, " > ")[[1]]
    for (j in seq_along(parts)) {
      indent <- strrep("  ", j - 1)
      cat(sprintf("%s-> %s\n", indent, parts[j]))
    }
  }


  invisible(paths_df)
}
