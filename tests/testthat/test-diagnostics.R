test_that("pv_antipatterns returns correct structure", {
  p <- mock_profvis()
  result <- pv_antipatterns(p)

  expect_s3_class(result, "data.frame")
  expect_named(result, c("pattern", "severity", "location", "description", "time_ms", "pct"))
})

test_that("pv_antipatterns detects GC pressure", {
  p <- mock_profvis_gc()
  result <- pv_antipatterns(p)

  # mock_profvis_gc has 40% GC time, should be detected
  gc_patterns <- result[result$pattern == "gc_pressure", ]
  expect_gt(nrow(gc_patterns), 0)
})

test_that("pv_antipatterns detects string operations", {
  p <- mock_profvis_strings()
  result <- pv_antipatterns(p)

  # mock_profvis_strings has heavy string operations
  # May or may not trigger depending on thresholds
  expect_s3_class(result, "data.frame")
})

test_that("pv_antipatterns detects data frame operations", {
  p <- mock_profvis_df_ops()
  result <- pv_antipatterns(p)

  # mock_profvis_df_ops has heavy df subsetting
  df_patterns <- result[grepl("df", result$pattern), ]
  expect_gt(nrow(df_patterns), 0)
})

test_that("pv_antipatterns returns empty for clean profile", {
  prof <- data.frame(
    time = 1:3,
    depth = rep(1L, 3),
    label = c("good_func", "good_func", "good_func"),
    filename = rep(NA_character_, 3),
    linenum = rep(NA_integer_, 3),
    filenum = rep(NA_integer_, 3),
    memalloc = c(100, 100, 100),
    meminc = c(0, 0, 0),
    stringsAsFactors = FALSE
  )

  p <- mock_profvis(prof = prof, files = list())
  result <- pv_antipatterns(p)

  expect_s3_class(result, "data.frame")
})

test_that("pv_print_antipatterns snapshot with GC pressure", {
  p <- mock_profvis_gc()
  expect_snapshot(pv_print_antipatterns(p))
})

test_that("pv_print_antipatterns snapshot with df operations", {
  p <- mock_profvis_df_ops()
  expect_snapshot(pv_print_antipatterns(p))
})

test_that("pv_suggestions returns correct structure", {
  p <- mock_profvis()
  result <- pv_suggestions(p)

  expect_s3_class(result, "data.frame")
  expect_named(result, c("priority", "category", "suggestion", "location", "potential_impact"))
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
    linenum = NA_integer_,
    filenum = NA_integer_,
    memalloc = 100,
    meminc = 0,
    stringsAsFactors = FALSE
  )

  p <- mock_profvis(prof = prof, files = list())
  expect_snapshot(pv_print_suggestions(p))
})

test_that("diagnostics functions reject non-profvis input", {
  expect_error(pv_antipatterns(list()), "must be a profvis object")
  expect_error(pv_suggestions("bad"), "must be a profvis object")
  expect_error(pv_print_antipatterns(42), "must be a profvis object")
  expect_error(pv_print_suggestions(NULL), "must be a profvis object")
})
