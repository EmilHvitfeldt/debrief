#' Example profvis data
#'
#' Creates an example profvis object for use in examples and testing.
#' This avoids the need to run actual profiling code in examples.
#'
#' @param type Type of example data to create:
#'   - `"default"`: A real profile captured from example code with source refs
#'   - `"no_source"`: A synthetic profile without source references
#'   - `"recursive"`: A synthetic profile with recursive function calls
#'   - `"gc"`: A synthetic profile with garbage collection pressure
#'
#' @return A profvis object that can be used with all debrief functions.
#'
#' @examples
#' # Get default example data
#' p <- pv_example()
#' pv_self_time(p)
#'
#' # Get example with recursive calls
#' p_recursive <- pv_example("recursive")
#' pv_recursive(p_recursive)
#'
#' @export
pv_example <- function(type = c("default", "no_source", "recursive", "gc")) {
  type <- match.arg(type)

  switch(
    type,
    default = example_default(),
    no_source = example_no_source(),
    recursive = example_recursive(),
    gc = example_gc()
  )
}

example_default <- function() {
  readRDS(system.file("extdata/example_profile.rds", package = "debrief"))
}

example_no_source <- function() {
  prof <- data.frame(
    time = c(1L, 1L, 2L, 2L, 3L),
    depth = c(1L, 2L, 1L, 2L, 1L),
    label = c("foo", "bar", "foo", "baz", "foo"),
    filename = rep(NA_character_, 5),
    linenum = rep(NA_real_, 5),
    filenum = rep(NA_real_, 5),
    memalloc = c(100, 150, 150, 200, 200),
    meminc = c(0, 50, 0, 50, 0)
  )

  structure(
    list(
      x = list(
        message = list(
          prof = prof,
          interval = 10,
          files = list()
        )
      )
    ),
    class = "profvis"
  )
}

example_recursive <- function() {
  prof <- data.frame(
    time = c(1L, 1L, 1L, 2L, 2L, 2L, 2L, 3L, 3L, 3L, 3L, 3L),
    depth = c(1L, 2L, 3L, 1L, 2L, 3L, 4L, 1L, 2L, 3L, 4L, 5L),
    label = rep("recurse", 12),
    filename = rep("R/recursive.R", 12),
    linenum = rep(5, 12),
    filenum = rep(1, 12),
    memalloc = seq(100, 1200, by = 100),
    meminc = rep(100, 12)
  )

  files <- list(
    list(
      filename = "R/recursive.R",
      content = paste(
        "recurse <- function(n) {",
        "  if (n <= 0) return(1)",
        "  recurse(n - 1)",
        "}",
        "  recurse(n - 1)",
        sep = "\n"
      ),
      normpath = "R/recursive.R"
    )
  )

  structure(
    list(
      x = list(
        message = list(
          prof = prof,
          interval = 10,
          files = files
        )
      )
    ),
    class = "profvis"
  )
}

example_gc <- function() {
  prof <- data.frame(
    time = c(1L, 2L, 3L, 4L, 5L, 6L, 7L, 8L, 9L, 10L),
    depth = rep(1L, 10),
    label = c(
      "work",
      "work",
      "<GC>",
      "work",
      "<GC>",
      "<GC>",
      "work",
      "<GC>",
      "work",
      "work"
    ),
    filename = c(
      rep("R/work.R", 2),
      NA,
      "R/work.R",
      NA,
      NA,
      "R/work.R",
      NA,
      rep("R/work.R", 2)
    ),
    linenum = as.double(c(5, 5, NA, 5, NA, NA, 5, NA, 5, 5)),
    filenum = as.double(c(1, 1, NA, 1, NA, NA, 1, NA, 1, 1)),
    memalloc = c(100, 200, 200, 300, 300, 300, 400, 400, 500, 600),
    meminc = c(0, 100, 0, 100, 0, 0, 100, 0, 100, 100)
  )

  files <- list(
    list(
      filename = "R/work.R",
      content = "work <- function() {\n  x <- rnorm(1e6)\n  y <- cumsum(x)\n  z <- paste(x)\n  z\n}",
      normpath = "R/work.R"
    )
  )

  structure(
    list(
      x = list(
        message = list(
          prof = prof,
          interval = 10,
          files = files
        )
      )
    ),
    class = "profvis"
  )
}
