test_that("pv_self_time returns correct structure", {
  p <- mock_profvis()
  result <- pv_self_time(p)

  expect_s3_class(result, "data.frame")
  expect_named(result, c("label", "samples", "time_ms", "pct"))
  expect_type(result$label, "character")
  expect_type(result$samples, "integer")
  expect_type(result$time_ms, "double")
  expect_type(result$pct, "double")
})

test_that("pv_self_time calculates self-time correctly", {
  p <- mock_profvis()
  result <- pv_self_time(p)

 # Self-time should only count when function is at top of stack
  # In mock data: inner is at top at time 1, deep at times 2,4, helper at time 3, outer at time 5
  expect_true("deep" %in% result$label)
  expect_true("inner" %in% result$label)
  expect_true("helper" %in% result$label)
  expect_true("outer" %in% result$label)

  # deep appears at top of stack at times 2 and 4 = 2 samples
  deep_row <- result[result$label == "deep", ]
  expect_equal(deep_row$samples, 2L)
})

test_that("pv_self_time percentages sum to 100", {
  p <- mock_profvis()
  result <- pv_self_time(p)

  # Percentages should sum to approximately 100
  expect_equal(sum(result$pct), 100, tolerance = 0.1)
})

test_that("pv_total_time returns correct structure", {
  p <- mock_profvis()
  result <- pv_total_time(p)

  expect_s3_class(result, "data.frame")
  expect_named(result, c("label", "samples", "time_ms", "pct"))
})

test_that("pv_total_time calculates total time correctly", {
  p <- mock_profvis()
  result <- pv_total_time(p)

  # outer appears in all 5 time samples
  outer_row <- result[result$label == "outer", ]
  expect_equal(outer_row$samples, 5L)
  expect_equal(outer_row$pct, 100)
})

test_that("pv_total_time >= pv_self_time for all functions", {
  p <- mock_profvis()
  self <- pv_self_time(p)
  total <- pv_total_time(p)

  merged <- merge(self, total, by = "label", suffixes = c("_self", "_total"))
  expect_true(all(merged$samples_total >= merged$samples_self))
})

test_that("time functions reject non-profvis input", {
  expect_error(pv_self_time(list()), "must be a profvis object")
  expect_error(pv_total_time(data.frame()), "must be a profvis object")
})

test_that("time functions work with no source references", {
  p <- mock_profvis_no_source()

  result_self <- pv_self_time(p)
  result_total <- pv_total_time(p)

  expect_s3_class(result_self, "data.frame")
  expect_s3_class(result_total, "data.frame")
  expect_gt(nrow(result_self), 0)
  expect_gt(nrow(result_total), 0)
})
