test_that("basic", {
  withr::local_seed(1)
  mci = msr("ci.ncv", "classif.acc")
  rr = resample(tsk("iris"), lrn("classif.featureless"), rsmp("nested_cv", repeats = 20, folds = 5))
  expect_ci_measure(mci, rr)
})
