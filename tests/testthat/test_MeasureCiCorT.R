test_that("simple", {
  mci = msr("ci.cor_t", "regr.mse")
  rr = resample(tsk("boston_housing"), lrn("regr.featureless"), rsmp("subsampling", repeats = 10))
  expect_ci_measure(mci, rr)
})

test_that("simple", {
  mci = msr("ci.cor_t", "regr.mse")
  task = tsk("boston_housing")
  task$col_roles$stratum = "chas"
  rr = resample(task, lrn("regr.featureless"), rsmp("subsampling", repeats = 10))
  expect_ci_measure(mci, rr)
})
