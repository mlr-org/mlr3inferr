test_that("simple", {
  mci = msr("ci.holdout", "regr.mse")
  rr = resample(tsk("boston_housing"), lrn("regr.featureless"), rsmp("holdout"))
  expect_ci_measure(mci, rr)
})
