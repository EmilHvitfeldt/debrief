test_that("pv_source_context snapshot", {
  p <- mock_profvis()
  expect_snapshot(pv_source_context(p, "R/main.R"))
})

test_that("pv_source_context finds file by partial match", {
  p <- mock_profvis()

  # Should match partial filename
  expect_no_error(capture.output(pv_source_context(p, "main.R")))
})

test_that("pv_source_context handles non-existent file", {
  p <- mock_profvis()
  expect_snapshot(pv_source_context(p, "nonexistent.R"))
})

test_that("pv_source_context auto-selects hottest line when linenum is NULL", {
  p <- mock_profvis()
  expect_snapshot(pv_source_context(p, "R/main.R", linenum = NULL))
})

test_that("pv_source_context respects linenum parameter", {
  p <- mock_profvis()
  expect_snapshot(pv_source_context(p, "R/main.R", linenum = 5))
})

test_that("pv_source_context respects context parameter", {
  p <- mock_profvis()

  # Different context values should work
  expect_no_error(capture.output(pv_source_context(p, "R/main.R", context = 3)))
  expect_no_error(capture.output(pv_source_context(p, "R/main.R", context = 15)))
})

test_that("pv_source_context returns line data invisibly", {
  p <- mock_profvis()

  result <- expect_invisible(pv_source_context(p, "R/main.R"))
  expect_s3_class(result, "data.frame")
})

test_that("pv_file_summary returns correct structure", {
  p <- mock_profvis()
  result <- pv_file_summary(p)

  expect_s3_class(result, "data.frame")
  expect_named(result, c("filename", "samples", "time_ms", "pct"))
})

test_that("pv_file_summary returns empty when no source refs", {
  p <- mock_profvis_no_source()
  result <- pv_file_summary(p)

  expect_equal(nrow(result), 0)
})

test_that("pv_file_summary includes all source files", {
  p <- mock_profvis()
  result <- pv_file_summary(p)

  expect_true("R/main.R" %in% result$filename)
})

test_that("pv_print_file_summary snapshot", {
  p <- mock_profvis()
  expect_snapshot(pv_print_file_summary(p))
})

test_that("pv_print_file_summary handles no source refs", {
  p <- mock_profvis_no_source()
  expect_snapshot(pv_print_file_summary(p))
})

test_that("source context functions reject non-profvis input", {
  expect_error(pv_source_context(list(), "file.R"), "must be a profvis object")
  expect_error(pv_file_summary("bad"), "must be a profvis object")
  expect_error(pv_print_file_summary(42), "must be a profvis object")
})
