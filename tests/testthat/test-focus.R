test_that("pv_focus snapshot for existing function", {
  p <- mock_profvis()
  expect_snapshot(pv_focus(p, "inner"))
})

test_that("pv_focus handles non-existent function", {
  p <- mock_profvis()
  expect_snapshot(pv_focus(p, "nonexistent"))
})

test_that("pv_focus returns invisibly", {
  p <- mock_profvis()

  result <- expect_invisible(pv_focus(p, "inner"))
  expect_type(result, "list")
  expect_named(
    result,
    c(
      "func",
      "total_time_ms",
      "total_pct",
      "self_time_ms",
      "self_pct",
      "appearances",
      "callers",
      "callees"
    )
  )
})

test_that("pv_focus returns NULL for non-existent function", {
  p <- mock_profvis()

  result <- expect_invisible(pv_focus(p, "nonexistent"))
  expect_null(result)
})

test_that("pv_focus handles no source refs", {
  p <- mock_profvis_no_source()
  expect_snapshot(pv_focus(p, "foo"))
})

test_that("pv_focus context parameter works", {
  p <- mock_profvis()

  # Should not error with different context values
  expect_no_error(capture.output(pv_focus(p, "inner", context = 2)))
  expect_no_error(capture.output(pv_focus(p, "inner", context = 10)))
})

test_that("pv_focus rejects non-profvis input", {
  expect_error(pv_focus(list(), "func"), "must be a profvis object")
})
