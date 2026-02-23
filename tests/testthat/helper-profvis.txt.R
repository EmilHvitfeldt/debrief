# Helper functions for testing profvis.txt

# Create a mock profvis object for testing
# This allows testing without running actual profiling
mock_profvis <- function(
    prof = NULL,
    interval = 10,
    files = NULL
) {
  if (is.null(prof)) {
    # Default simple profile data
    prof <- data.frame(
      time = c(1L, 1L, 2L, 2L, 2L, 3L, 3L, 4L, 4L, 4L, 5L),
      depth = c(1L, 2L, 1L, 2L, 3L, 1L, 2L, 1L, 2L, 3L, 1L),
      label = c(
        "outer", "inner",
        "outer", "inner", "deep",
        "outer", "helper",
        "outer", "inner", "deep",
        "outer"
      ),
      filename = c(
        "R/main.R", "R/main.R",
        "R/main.R", "R/main.R", "R/utils.R",
        "R/main.R", "R/helper.R",
        "R/main.R", "R/main.R", "R/utils.R",
        "R/main.R"
      ),
      linenum = as.double(c(
        10, 15,
        10, 15, 5,
        10, 20,
        10, 15, 5,
        10
      )),
      filenum = as.double(c(1, 1, 1, 1, 2, 1, 3, 1, 1, 2, 1)),
      memalloc = c(100, 150, 150, 200, 250, 250, 300, 300, 350, 400, 400),
      meminc = c(0, 50, 0, 50, 50, 0, 50, 0, 50, 50, 0),
      stringsAsFactors = FALSE
    )
  }

  if (is.null(files)) {
    files <- list(
      list(
        filename = "R/main.R",
        content = paste(
          "# Main file",
          "outer <- function() {",
          "  x <- 1",
          "  y <- 2",

          "  inner()",
          "}",
          "",
          "inner <- function() {",
          "  result <- deep()",
          "  result",
          "}",
          "",
          "",
          "",
          "  z <- heavy_computation()",
          sep = "\n"
        ),
        normpath = "R/main.R"
      ),
      list(
        filename = "R/utils.R",
        content = paste(
          "# Utils",
          "deep <- function() {",
          "  Sys.sleep(0.01)",
          "  42",
          "  x <- rnorm(1000)",
          "}",
          sep = "\n"
        ),
        normpath = "R/utils.R"
      ),
      list(
        filename = "R/helper.R",
        content = paste(
          "# Helper functions",
          "helper <- function() {",
          "  paste('hello', 'world')",
          "}",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "  do_work()",
          sep = "\n"
        ),
        normpath = "R/helper.R"
      )
    )
  }

  structure(
    list(
      x = list(
        message = list(
          prof = prof,
          interval = interval,
          files = files
        )
      )
    ),
    class = "profvis"
  )
}

# Create a mock profvis with no source references
mock_profvis_no_source <- function() {

  prof <- data.frame(
    time = c(1L, 1L, 2L, 2L, 3L),
    depth = c(1L, 2L, 1L, 2L, 1L),
    label = c("foo", "bar", "foo", "baz", "foo"),
    filename = rep(NA_character_, 5),
    linenum = rep(NA_real_, 5),
    filenum = rep(NA_real_, 5),
    memalloc = c(100, 150, 150, 200, 200),
    meminc = c(0, 50, 0, 50, 0),
    stringsAsFactors = FALSE
  )

  mock_profvis(prof = prof, files = list())
}

# Create a mock profvis with recursive function
mock_profvis_recursive <- function() {
  prof <- data.frame(
    time = c(1L, 1L, 1L, 2L, 2L, 2L, 2L, 3L, 3L, 3L, 3L, 3L),
    depth = c(1L, 2L, 3L, 1L, 2L, 3L, 4L, 1L, 2L, 3L, 4L, 5L),
    label = c(
      "recurse", "recurse", "recurse",
      "recurse", "recurse", "recurse", "recurse",
      "recurse", "recurse", "recurse", "recurse", "recurse"
    ),
    filename = rep("R/recursive.R", 12),
    linenum = rep(5, 12),
    filenum = rep(1, 12),
    memalloc = seq(100, 1200, by = 100),
    meminc = rep(100, 12),
    stringsAsFactors = FALSE
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

  mock_profvis(prof = prof, files = files)
}

# Create a mock profvis with GC and memory pressure
mock_profvis_gc <- function() {
  prof <- data.frame(
    time = c(1L, 2L, 3L, 4L, 5L, 6L, 7L, 8L, 9L, 10L),
    depth = c(1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 1L),
    label = c("work", "work", "<GC>", "work", "<GC>", "<GC>", "work", "<GC>", "work", "work"),
    filename = c(rep("R/work.R", 2), NA, "R/work.R", NA, NA, "R/work.R", NA, rep("R/work.R", 2)),
    linenum = as.double(c(5, 5, NA, 5, NA, NA, 5, NA, 5, 5)),
    filenum = as.double(c(1, 1, NA, 1, NA, NA, 1, NA, 1, 1)),
    memalloc = c(100, 200, 200, 300, 300, 300, 400, 400, 500, 600),
    meminc = c(0, 100, 0, 100, 0, 0, 100, 0, 100, 100),
    stringsAsFactors = FALSE
  )

  files <- list(
    list(
      filename = "R/work.R",
      content = "work <- function() {\n  x <- rnorm(1e6)\n  y <- cumsum(x)\n  z <- paste(x)\n  z\n}",
      normpath = "R/work.R"
    )
  )

  mock_profvis(prof = prof, files = files)
}

# Create a mock profvis with string operations
mock_profvis_strings <- function() {
  prof <- data.frame(
    time = c(1L, 1L, 2L, 2L, 3L, 3L, 4L, 4L, 5L),
    depth = c(1L, 2L, 1L, 2L, 1L, 2L, 1L, 2L, 1L),
    label = c(
      "process", "paste",
      "process", "paste0",
      "process", "sprintf",
      "process", "gsub",
      "process"
    ),
    filename = rep("R/strings.R", 9),
    linenum = as.double(c(1, 2, 1, 3, 1, 4, 1, 5, 1)),
    filenum = rep(1, 9),
    memalloc = seq(100, 900, by = 100),
    meminc = rep(100, 9),
    stringsAsFactors = FALSE
  )

  files <- list(
    list(
      filename = "R/strings.R",
      content = paste(
        "process <- function() {",
        "  paste('a', 'b')",
        "  paste0('a', 'b')",
        "  sprintf('%s', 'a')",
        "  gsub('a', 'b', 'aaa')",
        "}",
        sep = "\n"
      ),
      normpath = "R/strings.R"
    )
  )

  mock_profvis(prof = prof, files = files)
}

# Create a mock profvis with data frame operations
mock_profvis_df_ops <- function() {
  prof <- data.frame(
    time = rep(1:10, each = 3),
    depth = rep(1:3, 10),
    label = rep(c("process", "loop_body", "[.data.frame"), 10),
    filename = rep(c("R/df.R", "R/df.R", NA), 10),
    linenum = as.double(rep(c(1, 5, NA), 10)),
    filenum = as.double(rep(c(1, 1, NA), 10)),
    memalloc = seq(100, 3000, by = 100),
    meminc = rep(c(0, 50, 50), 10),
    stringsAsFactors = FALSE
  )

  files <- list(
    list(
      filename = "R/df.R",
      content = paste(
        "process <- function(df) {",
        "  for (i in 1:nrow(df)) {",
        "    loop_body(df, i)",
        "  }",
        "  df[i, ]$col",
        "}",
        sep = "\n"
      ),
      normpath = "R/df.R"
    )
  )

  mock_profvis(prof = prof, files = files)
}
