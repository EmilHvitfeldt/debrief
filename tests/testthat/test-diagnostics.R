# Tests for GC pressure detection and suggestions

test_that("pv_gc_pressure returns correct structure", {
  p <- mock_profvis_gc()
  result <- pv_gc_pressure(p)

  expect_s3_class(result, "data.frame")
  expect_named(result, c("severity", "pct", "time_ms", "description"))
})

test_that("pv_gc_pressure detects high GC", {
  p <- mock_profvis_gc()
  result <- pv_gc_pressure(p)

  # mock_profvis_gc has 40% GC time, should be detected
  expect_equal(nrow(result), 1)
  expect_equal(result$severity, "high")
  expect_gt(result$pct, 25)
})

test_that("pv_gc_pressure returns empty for low GC", {
  # Profile with no GC
  p <- mock_profvis()
  result <- pv_gc_pressure(p)

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 0)
})

test_that("pv_gc_pressure returns empty for profile without GC entries", {
  prof <- data.frame(
    time = 1:3,
    depth = rep(1L, 3),
    label = c("good_func", "good_func", "good_func"),
    filename = rep(NA_character_, 3),
    linenum = rep(NA_real_, 3),
    filenum = rep(NA_real_, 3),
    memalloc = c(100, 100, 100),
    meminc = c(0, 0, 0),
    stringsAsFactors = FALSE
  )

  p <- mock_profvis(prof = prof, files = list())
  result <- pv_gc_pressure(p)

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 0)
})

test_that("pv_print_gc_pressure snapshot with high GC", {
  p <- mock_profvis_gc()
  expect_snapshot(pv_print_gc_pressure(p))
})

test_that("pv_print_gc_pressure snapshot with no GC", {
  p <- mock_profvis()
  expect_snapshot(pv_print_gc_pressure(p))
})

test_that("pv_suggestions returns correct structure", {
  p <- mock_profvis()
  result <- pv_suggestions(p)

  expect_s3_class(result, "data.frame")
  expect_named(
    result,
    c("priority", "category", "suggestion", "location", "potential_impact")
  )
})

test_that("pv_suggestions priority is ordered", {
  p <- mock_profvis_gc()
  result <- pv_suggestions(p)

  if (nrow(result) > 1) {
    # Priorities should be in increasing order
    expect_true(all(diff(result$priority) >= 0))
  }
})

test_that("pv_print_suggestions snapshot with GC pressure", {
  p <- mock_profvis_gc()
  expect_snapshot(pv_print_suggestions(p))
})

test_that("pv_print_suggestions handles profile with no suggestions", {
  prof <- data.frame(
    time = 1L,
    depth = 1L,
    label = "x",
    filename = NA_character_,
    linenum = NA_real_,
    filenum = NA_real_,
    memalloc = 100,
    meminc = 0,
    stringsAsFactors = FALSE
  )

  p <- mock_profvis(prof = prof, files = list())
  expect_snapshot(pv_print_suggestions(p))
})

test_that("diagnostics functions reject non-profvis input", {
  expect_error(pv_gc_pressure(list()), "must be a profvis object")
  expect_error(pv_suggestions("bad"), "must be a profvis object")
  expect_error(pv_print_gc_pressure(42), "must be a profvis object")
  expect_error(pv_print_suggestions(NULL), "must be a profvis object")
})
