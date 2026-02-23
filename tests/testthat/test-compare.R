test_that("pv_compare returns correct structure", {
  p1 <- mock_profvis()
  p2 <- mock_profvis()

  result <- pv_compare(p1, p2)

  expect_type(result, "list")
  expect_named(result, c("summary", "by_function", "improved", "regressed"))
  expect_s3_class(result$summary, "data.frame")
  expect_s3_class(result$by_function, "data.frame")
  expect_s3_class(result$improved, "data.frame")
  expect_s3_class(result$regressed, "data.frame")
})

test_that("pv_compare detects improvement", {
  # Create "before" with more samples
  prof_before <- data.frame(
    time = 1:10,
    depth = rep(1L, 10),
    label = rep("slow", 10),
    filename = rep(NA_character_, 10),
    linenum = rep(NA_integer_, 10),
    filenum = rep(NA_integer_, 10),
    memalloc = seq(100, 1000, by = 100),
    meminc = rep(100, 10),
    stringsAsFactors = FALSE
  )

  # Create "after" with fewer samples
  prof_after <- data.frame(
    time = 1:3,
    depth = rep(1L, 3),
    label = rep("slow", 3),
    filename = rep(NA_character_, 3),
    linenum = rep(NA_integer_, 3),
    filenum = rep(NA_integer_, 3),
    memalloc = c(100, 200, 300),
    meminc = rep(100, 3),
    stringsAsFactors = FALSE
  )

  p1 <- mock_profvis(prof = prof_before, files = list())
  p2 <- mock_profvis(prof = prof_after, files = list())

  result <- pv_compare(p1, p2)

  # After should be faster (less time)
  expect_lt(result$summary$after[1], result$summary$before[1])
})

test_that("pv_compare detects regression", {
  # Create "before" with fewer samples
  prof_before <- data.frame(
    time = 1:3,
    depth = rep(1L, 3),
    label = rep("func", 3),
    filename = rep(NA_character_, 3),
    linenum = rep(NA_integer_, 3),
    filenum = rep(NA_integer_, 3),
    memalloc = c(100, 200, 300),
    meminc = rep(100, 3),
    stringsAsFactors = FALSE
  )

  # Create "after" with more samples (slower)
  prof_after <- data.frame(
    time = 1:10,
    depth = rep(1L, 10),
    label = rep("func", 10),
    filename = rep(NA_character_, 10),
    linenum = rep(NA_integer_, 10),
    filenum = rep(NA_integer_, 10),
    memalloc = seq(100, 1000, by = 100),
    meminc = rep(100, 10),
    stringsAsFactors = FALSE
  )

  p1 <- mock_profvis(prof = prof_before, files = list())
  p2 <- mock_profvis(prof = prof_after, files = list())

  result <- pv_compare(p1, p2)

  # After should be slower (more time)
  expect_gt(result$summary$after[1], result$summary$before[1])
})

test_that("pv_compare respects n parameter", {
  p1 <- mock_profvis()
  p2 <- mock_profvis()

  result <- pv_compare(p1, p2, n = 2)

  expect_lte(nrow(result$by_function), 2)
})

test_that("pv_print_compare snapshot", {
  p1 <- mock_profvis()
  p2 <- mock_profvis()
  expect_snapshot(pv_print_compare(p1, p2))
})

test_that("pv_compare rejects non-profvis input", {
  p <- mock_profvis()

  expect_error(pv_compare(list(), p), "must be a profvis object")
  expect_error(pv_compare(p, "bad"), "must be a profvis object")
})

test_that("pv_compare handles identical profiles", {
  p <- mock_profvis()

  result <- pv_compare(p, p)

  # Same profile should show no change
  expect_equal(result$summary$before[1], result$summary$after[1])
})
