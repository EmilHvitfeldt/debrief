empty_prof <- structure(
  list(
    x = list(
      message = list(
        prof = data.frame(
          time = integer(),
          depth = integer(),
          label = character(),
          filename = character(),
          linenum = numeric(),
          filenum = numeric(),
          memalloc = numeric(),
          meminc = numeric(),
          stringsAsFactors = FALSE
        ),
        interval = 10,
        files = list()
      )
    )
  ),
  class = "profvis"
)

test_that("empty profile errors with helpful message", {
  expect_snapshot(pv_self_time(empty_prof), error = TRUE)
  expect_snapshot(pv_total_time(empty_prof), error = TRUE)
  expect_snapshot(pv_summary(empty_prof), error = TRUE)
  expect_snapshot(pv_hot_lines(empty_prof), error = TRUE)
  expect_snapshot(pv_hot_paths(empty_prof), error = TRUE)
  expect_snapshot(pv_flame(empty_prof), error = TRUE)
  expect_snapshot(pv_memory(empty_prof), error = TRUE)
  expect_snapshot(pv_callers(empty_prof, "foo"), error = TRUE)
  expect_snapshot(pv_callees(empty_prof, "foo"), error = TRUE)
  expect_snapshot(pv_focus(empty_prof, "foo"), error = TRUE)
  expect_snapshot(pv_suggestions(empty_prof), error = TRUE)
  expect_snapshot(pv_gc_pressure(empty_prof), error = TRUE)
  expect_snapshot(pv_recursive(empty_prof), error = TRUE)
  expect_snapshot(pv_call_stats(empty_prof), error = TRUE)
  expect_snapshot(pv_call_depth(empty_prof), error = TRUE)
  expect_snapshot(pv_file_summary(empty_prof), error = TRUE)
  expect_snapshot(pv_source_context(empty_prof, "foo.R"), error = TRUE)
  expect_snapshot(pv_to_json(empty_prof), error = TRUE)
  expect_snapshot(pv_to_list(empty_prof), error = TRUE)
})

test_that("compare functions error on empty profile", {
  valid_prof <- pv_example()

  expect_snapshot(pv_compare(empty_prof, valid_prof), error = TRUE)
  expect_snapshot(pv_compare(valid_prof, empty_prof), error = TRUE)
  expect_snapshot(pv_compare_many(a = empty_prof, b = valid_prof), error = TRUE)
})
