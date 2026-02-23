# Tests for export functions

test_that("pv_to_json returns valid JSON string", {
  p <- pv_example()
  json <- pv_to_json(p)

  expect_type(json, "character")
  expect_length(json, 1)
  expect_true(grepl("^\\{", json))
  expect_true(grepl("\\}$", json))
})

test_that("pv_to_json includes metadata", {
  p <- pv_example()
  json <- pv_to_json(p)

  expect_true(grepl("metadata", json))
  expect_true(grepl("total_time_ms", json))
  expect_true(grepl("total_samples", json))
  expect_true(grepl("interval_ms", json))
})

test_that("pv_to_json respects include parameter", {
  p <- pv_example()

  json_all <- pv_to_json(p)
  json_limited <- pv_to_json(p, include = c("self_time"))

  expect_true(grepl("self_time", json_all))
  expect_true(grepl("\"total_time\":", json_all))
  expect_true(grepl("self_time", json_limited))
  # Note: "total_time_ms" appears in metadata, so check for the section key

  expect_false(grepl("\"total_time\":", json_limited))
})

test_that("pv_to_json pretty parameter works", {
  p <- pv_example()

  json_pretty <- pv_to_json(p, pretty = TRUE)
  json_compact <- pv_to_json(p, pretty = FALSE)

  expect_true(grepl("\n", json_pretty))
  expect_false(grepl("\n", json_compact))
})

test_that("pv_to_json writes to file", {
  p <- pv_example()
  tmp <- tempfile(fileext = ".json")
  on.exit(unlink(tmp))

  result <- pv_to_json(p, file = tmp)

  expect_equal(result, tmp)
  expect_true(file.exists(tmp))

  content <- readLines(tmp)
  expect_true(length(content) > 0)
})

test_that("pv_to_list returns list with correct structure", {
  p <- pv_example()
  result <- pv_to_list(p)

  expect_type(result, "list")
  expect_true("metadata" %in% names(result))
  expect_true("self_time" %in% names(result))
  expect_true("total_time" %in% names(result))
})

test_that("pv_to_list metadata contains expected fields", {
  p <- pv_example()
  result <- pv_to_list(p)

  expect_true("total_time_ms" %in% names(result$metadata))
  expect_true("total_samples" %in% names(result$metadata))
  expect_true("interval_ms" %in% names(result$metadata))
  expect_true("has_source_refs" %in% names(result$metadata))
})

test_that("pv_to_list self_time is a data frame", {
  p <- pv_example()
  result <- pv_to_list(p)

  expect_s3_class(result$self_time, "data.frame")
  expect_true("label" %in% names(result$self_time))
  expect_true("time_ms" %in% names(result$self_time))
})

test_that("pv_to_list respects include parameter", {
  p <- pv_example()

  result_all <- pv_to_list(p)
  result_limited <- pv_to_list(p, include = "self_time")

  expect_true("self_time" %in% names(result_all))
  expect_true("total_time" %in% names(result_all))
  expect_true("self_time" %in% names(result_limited))
  expect_false("total_time" %in% names(result_limited))
})

test_that("pv_to_json handles empty results", {
  p <- pv_example("no_source")
  json <- pv_to_json(p)

  expect_type(json, "character")
  expect_true(grepl("hot_lines", json))
})

test_that("JSON serializer handles special characters", {
  # Test internal to_json function
  result <- profvis.txt:::to_json(list(text = "line1\nline2\ttab"))
  expect_true(grepl("\\\\n", result))
  expect_true(grepl("\\\\t", result))
})

test_that("JSON serializer handles NA values",
{
  result <- profvis.txt:::to_json(list(val = NA))
  expect_true(grepl("null", result))
})

test_that("JSON serializer handles empty lists", {
  # Empty unnamed list is an empty array
  result <- profvis.txt:::to_json(list())
  expect_equal(result, "[]")

  # Empty named list is an empty object
  result <- profvis.txt:::to_json(structure(list(), names = character()))
  expect_equal(result, "{}")

  # Named list with empty value
  result <- profvis.txt:::to_json(list(arr = list()))
  expect_true(grepl("\\[\\]", result))
})
