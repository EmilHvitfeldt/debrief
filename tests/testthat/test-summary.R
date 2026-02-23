test_that("pv_summary snapshot", {
  p <- mock_profvis()
  expect_snapshot(pv_summary(p))
})

test_that("pv_summary handles no source refs", {
  p <- mock_profvis_no_source()
  expect_snapshot(pv_summary(p))
})

test_that("pv_summary respects n parameters", {
  p <- mock_profvis()

  # Should not error with different n values
  expect_no_error(capture.output(pv_summary(p, n_functions = 2, n_lines = 2, n_paths = 2, n_memory = 2)))
})

test_that("pv_summary returns invisibly", {
  p <- mock_profvis()

  result <- expect_invisible(pv_summary(p))
  expect_type(result, "list")
  expect_true("total_time_ms" %in% names(result))
  expect_true("self_time" %in% names(result))
  expect_true("total_time" %in% names(result))
  expect_true("hot_paths" %in% names(result))
})

test_that("pv_summary rejects non-profvis input", {
  expect_error(pv_summary(list()), "must be a profvis object")
  expect_error(pv_summary("not profvis"), "must be a profvis object")
})
