test_that("simple", {
  mci = msr("ci.cor_t", "regr.mse")
  rr = resample(tsk("boston_housing"), lrn("regr.featureless"), rsmp("subsampling", repeats = 10))
  expect_ci_measure(mci, rr)
})
