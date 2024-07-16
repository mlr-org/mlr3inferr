test_that("simple", {
  mci = msr("ci.holdout", "regr.mse")
  rr = resample(tsk("boston_housing"), lrn("regr.featureless"), rsmp("holdout"))
  expect_ci_measure(mci, rr)
})

test_that("stratification", {
  mci = msr("ci.holdout", "regr.mse")
  task = tsk("boston_housing")
  task$col_roles$stratum = "chas"
  rr = resample(task, lrn("regr.featureless"), rsmp("holdout"))
  expect_ci_measure(mci, rr)
})
