test_that("basic", {
  rr = resample(tsk("iris"), lrn("classif.featureless"), rsmp("holdout"))
  ci1 = rr$aggregate(msr("ci", "classif.acc"))
  ci2 = rr$aggregate(msr("ci.holdout", "classif.acc"))
  expect_equal(ci1, ci2)
  mci = msr("ci", "classif.acc")
  expect_ci_measure(mci, rr)
})

test_that("obs_loss with trafo", {
  withr::local_seed(1)
  rr = resample(tsk("boston_housing"), lrn("regr.featureless"), rsmp("cv"))
  ci = rr$aggregate(msr("ci.naive_cv", "regr.rmse"))
  expect_ci_measure(msr("ci.naive_cv", "regr.rmse"), rr, symmetric = FALSE)
  expect_ci_measure(msr("ci", "regr.rmse"), rr, symmetric = FALSE)
})
