test_that("measure dictionary can still be converted to table", {
  expect_data_table(as.data.table(mlr3::mlr_measures))
  # TODO: Check that all IDs are also properly represented
})
