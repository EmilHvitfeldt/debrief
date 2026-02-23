test_that("pv_recursive returns correct structure", {
  p <- mock_profvis_recursive()
  result <- pv_recursive(p)

  expect_s3_class(result, "data.frame")
  expect_named(result, c("label", "max_depth", "avg_depth", "recursive_samples",
                         "total_samples", "pct_recursive", "total_ms", "pct_time"))
})

test_that("pv_recursive detects recursive functions", {
  p <- mock_profvis_recursive()
  result <- pv_recursive(p)

  expect_gt(nrow(result), 0)
  expect_true("recurse" %in% result$label)
})

test_that("pv_recursive returns empty for non-recursive profile", {
  # Create a profile with no recursion
  prof <- data.frame(
    time = c(1L, 1L, 2L, 2L, 3L),
    depth = c(1L, 2L, 1L, 2L, 1L),
    label = c("a", "b", "a", "c", "a"),
    filename = rep(NA_character_, 5),
    linenum = rep(NA_integer_, 5),
    filenum = rep(NA_integer_, 5),
    memalloc = c(100, 150, 150, 200, 200),
    meminc = c(0, 50, 0, 50, 0),
    stringsAsFactors = FALSE
  )

  p <- mock_profvis(prof = prof, files = list())
  result <- pv_recursive(p)

  expect_equal(nrow(result), 0)
})

test_that("pv_recursive max_depth is correct", {
  p <- mock_profvis_recursive()
  result <- pv_recursive(p)

  recurse_row <- result[result$label == "recurse", ]
  # In mock_profvis_recursive, max depth of recursion is 5 (time 3)
  expect_equal(recurse_row$max_depth, 5)
})

test_that("pv_print_recursive snapshot for recursive profile", {
  p <- mock_profvis_recursive()
  expect_snapshot(pv_print_recursive(p))
})

test_that("pv_print_recursive handles non-recursive profile", {
  # Create a profile with no recursion
  prof <- data.frame(
    time = c(1L, 1L, 2L, 2L, 3L),
    depth = c(1L, 2L, 1L, 2L, 1L),
    label = c("a", "b", "a", "c", "a"),
    filename = rep(NA_character_, 5),
    linenum = rep(NA_integer_, 5),
    filenum = rep(NA_integer_, 5),
    memalloc = c(100, 150, 150, 200, 200),
    meminc = c(0, 50, 0, 50, 0),
    stringsAsFactors = FALSE
  )

  p <- mock_profvis(prof = prof, files = list())
  expect_snapshot(pv_print_recursive(p))
})

test_that("pv_recursive rejects non-profvis input", {
  expect_error(pv_recursive(list()), "must be a profvis object")
  expect_error(pv_print_recursive("bad"), "must be a profvis object")
})
