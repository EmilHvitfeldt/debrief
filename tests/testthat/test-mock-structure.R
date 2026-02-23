# Tests to verify mock profvis objects match real profvis structure

test_that("mock profvis has correct class", {
  p <- pv_example()
  expect_s3_class(p, "profvis")
})

test_that("mock profvis has correct top-level structure", {
  p <- pv_example()

  expect_true("x" %in% names(p))
  expect_true("message" %in% names(p$x))
  expect_true("prof" %in% names(p$x$message))
  expect_true("interval" %in% names(p$x$message))
  expect_true("files" %in% names(p$x$message))
})

test_that("mock profvis prof has correct columns", {
  p <- pv_example()
  prof <- p$x$message$prof

  expected_cols <- c("time", "depth", "label", "filename", "linenum",
                     "filenum", "memalloc", "meminc")

  expect_s3_class(prof, "data.frame")
  expect_true(all(expected_cols %in% names(prof)))
})

test_that("mock profvis prof has correct column types", {
  p <- pv_example()
  prof <- p$x$message$prof

  expect_type(prof$time, "integer")
  expect_type(prof$depth, "integer")
  expect_type(prof$label, "character")
  expect_type(prof$filename, "character")
  expect_type(prof$linenum, "double")
  expect_type(prof$filenum, "double")
  expect_type(prof$memalloc, "double")
  expect_type(prof$meminc, "double")
})

test_that("mock profvis interval is numeric", {
  p <- pv_example()

  expect_type(p$x$message$interval, "double")
  expect_length(p$x$message$interval, 1)
})

test_that("mock profvis files is a list", {
  p <- pv_example()

  expect_type(p$x$message$files, "list")
})

test_that("mock profvis files have correct structure", {
  p <- pv_example()
  files <- p$x$message$files

  skip_if(length(files) == 0)

  for (f in files) {
    expect_true("filename" %in% names(f))
    expect_true("content" %in% names(f))
    expect_type(f$filename, "character")
    expect_type(f$content, "character")
  }
})

test_that("all pv_example types produce valid structure", {
  types <- c("default", "no_source", "recursive", "gc")

  for (type in types) {
    p <- pv_example(type)

    expect_s3_class(p, "profvis")
    expect_s3_class(p$x$message$prof, "data.frame")
    expect_type(p$x$message$interval, "double")
    expect_type(p$x$message$files, "list")
  }
})

# Validate all test helper mock objects
test_that("mock_profvis produces valid structure", {
  p <- mock_profvis()

  expect_s3_class(p, "profvis")
  expect_s3_class(p$x$message$prof, "data.frame")
  expect_type(p$x$message$interval, "double")
  expect_type(p$x$message$files, "list")

  prof <- p$x$message$prof
  expect_true(all(c("time", "depth", "label", "filename", "linenum", "memalloc", "meminc") %in% names(prof)))
})

test_that("mock_profvis_no_source produces valid structure", {
  p <- mock_profvis_no_source()

  expect_s3_class(p, "profvis")
  expect_s3_class(p$x$message$prof, "data.frame")
  expect_type(p$x$message$interval, "double")
  expect_type(p$x$message$files, "list")

  prof <- p$x$message$prof
  expect_true(all(c("time", "depth", "label", "filename", "linenum", "memalloc", "meminc") %in% names(prof)))

  # Verify no source refs
  expect_true(all(is.na(prof$filename)))
})

test_that("mock_profvis_recursive produces valid structure", {
  p <- mock_profvis_recursive()

  expect_s3_class(p, "profvis")
  expect_s3_class(p$x$message$prof, "data.frame")
  expect_type(p$x$message$interval, "double")
  expect_type(p$x$message$files, "list")

  prof <- p$x$message$prof
  expect_true(all(c("time", "depth", "label", "filename", "linenum", "memalloc", "meminc") %in% names(prof)))

  # Verify it has recursive structure (same function at multiple depths)
  expect_true("recurse" %in% prof$label)
})

test_that("mock_profvis_gc produces valid structure", {
  p <- mock_profvis_gc()

  expect_s3_class(p, "profvis")
  expect_s3_class(p$x$message$prof, "data.frame")
  expect_type(p$x$message$interval, "double")
  expect_type(p$x$message$files, "list")

  prof <- p$x$message$prof
  expect_true(all(c("time", "depth", "label", "filename", "linenum", "memalloc", "meminc") %in% names(prof)))

  # Verify it has GC entries
  expect_true("<GC>" %in% prof$label)
})

test_that("mock_profvis_strings produces valid structure", {
  p <- mock_profvis_strings()

  expect_s3_class(p, "profvis")
  expect_s3_class(p$x$message$prof, "data.frame")
  expect_type(p$x$message$interval, "double")
  expect_type(p$x$message$files, "list")

  prof <- p$x$message$prof
  expect_true(all(c("time", "depth", "label", "filename", "linenum", "memalloc", "meminc") %in% names(prof)))

  # Verify it has string operations
  string_funcs <- c("paste", "paste0", "sprintf", "gsub")
  expect_true(any(string_funcs %in% prof$label))
})

test_that("mock_profvis_df_ops produces valid structure", {
  p <- mock_profvis_df_ops()

  expect_s3_class(p, "profvis")
  expect_s3_class(p$x$message$prof, "data.frame")
  expect_type(p$x$message$interval, "double")
  expect_type(p$x$message$files, "list")

  prof <- p$x$message$prof
  expect_true(all(c("time", "depth", "label", "filename", "linenum", "memalloc", "meminc") %in% names(prof)))

  # Verify it has data frame operations
  expect_true("[.data.frame" %in% prof$label)
})

# Test against real profvis if available
test_that("mock has same essential structure as real profvis", {
  skip_if_not_installed("profvis")
  skip_on_cran()
  skip_on_covr()

  # Create a real profvis object using pause() to ensure samples are collected
  real_p <- profvis::profvis({
    profvis::pause(0.1)
  }, simplify = FALSE)

  mock_p <- pv_example()

  # Both should have "profvis" as a class (real may have additional classes)
  expect_true("profvis" %in% class(real_p))
  expect_true("profvis" %in% class(mock_p))

  # Both should have x$message structure
  expect_true("x" %in% names(real_p))
  expect_true("x" %in% names(mock_p))
  expect_true("message" %in% names(real_p$x))
  expect_true("message" %in% names(mock_p$x))

  # Compare message structure - mock should have required fields
  real_msg_names <- names(real_p$x$message)
  mock_msg_names <- names(mock_p$x$message)
  required_names <- c("prof", "interval", "files")
  expect_true(all(required_names %in% real_msg_names))
  expect_true(all(required_names %in% mock_msg_names))

  # Compare prof data frame
  real_prof <- real_p$x$message$prof
  mock_prof <- mock_p$x$message$prof

  expect_s3_class(real_prof, "data.frame")
  expect_s3_class(mock_prof, "data.frame")

  # Core columns our package uses should be in both
  core_cols <- c("time", "depth", "label")
  expect_true(all(core_cols %in% names(real_prof)))
  expect_true(all(core_cols %in% names(mock_prof)))

  # Column types should match
  expect_identical(typeof(real_prof$time), typeof(mock_prof$time))
  expect_identical(typeof(real_prof$depth), typeof(mock_prof$depth))
  expect_identical(typeof(real_prof$label), typeof(mock_prof$label))
})

# Helper function to validate a mock against real profvis structure
validate_mock_against_real <- function(mock_p, real_prof, mock_name) {
  mock_prof <- mock_p$x$message$prof

 # Class check
  expect_true("profvis" %in% class(mock_p), label = paste(mock_name, "has profvis class"))

  # Structure check
  expect_true("x" %in% names(mock_p), label = paste(mock_name, "has x"))
 expect_true("message" %in% names(mock_p$x), label = paste(mock_name, "has message"))
  expect_true("prof" %in% names(mock_p$x$message), label = paste(mock_name, "has prof"))
  expect_true("interval" %in% names(mock_p$x$message), label = paste(mock_name, "has interval"))
  expect_true("files" %in% names(mock_p$x$message), label = paste(mock_name, "has files"))

  # Prof is data frame
  expect_s3_class(mock_prof, "data.frame")

  # These are the columns our package actually uses
  used_cols <- c("time", "depth", "label", "filename", "linenum", "memalloc", "meminc")

  # All used columns should be present
  for (col in used_cols) {
    expect_true(col %in% names(mock_prof), label = paste(mock_name, "has column", col))
  }

  # Column types should match real profvis
  for (col in used_cols) {
    expect_identical(
      typeof(real_prof[[col]]),
      typeof(mock_prof[[col]]),
      label = paste(mock_name, "type match for", col)
    )
  }
}

test_that("all pv_example types match real profvis structure", {
  skip_if_not_installed("profvis")
  skip_on_cran()
  skip_on_covr()

  # Create a real profvis object
  real_p <- profvis::profvis({
    profvis::pause(0.1)
  }, simplify = FALSE)
  real_prof <- real_p$x$message$prof

  # Test all pv_example types
  types <- c("default", "no_source", "recursive", "gc")
  for (type in types) {
    mock_p <- pv_example(type)
    validate_mock_against_real(mock_p, real_prof, paste("pv_example(", type, ")"))
  }
})

test_that("all test helper mocks match real profvis structure", {
  skip_if_not_installed("profvis")
  skip_on_cran()
  skip_on_covr()

  # Create a real profvis object
  real_p <- profvis::profvis({
    profvis::pause(0.1)
  }, simplify = FALSE)
  real_prof <- real_p$x$message$prof

  # Test all helper mock functions
  validate_mock_against_real(mock_profvis(), real_prof, "mock_profvis()")
  validate_mock_against_real(mock_profvis_no_source(), real_prof, "mock_profvis_no_source()")
  validate_mock_against_real(mock_profvis_recursive(), real_prof, "mock_profvis_recursive()")
  validate_mock_against_real(mock_profvis_gc(), real_prof, "mock_profvis_gc()")
  validate_mock_against_real(mock_profvis_strings(), real_prof, "mock_profvis_strings()")
  validate_mock_against_real(mock_profvis_df_ops(), real_prof, "mock_profvis_df_ops()")
})
