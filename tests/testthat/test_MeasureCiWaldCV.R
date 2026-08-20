test_that("basic", {
  expect_ci_measure("ci.wald_cv", rsmp("cv"), variance = "all-pairs")
  expect_ci_measure("ci.wald_cv", rsmp("cv"), variance = "within-fold")
  expect_ci_measure("ci.wald_cv", rsmp("loo"), variance = "all-pairs")
  expect_ci_measure("ci.wald_cv", rsmp("loo"), variance = "within-fold")
})

test_that("aggr and CI point estimate agree", {
  withr::local_seed(1)
  # The CI point estimate is the mean over all observations, while the standard aggregation
  # averages the per-fold scores. These only coincide when all folds have the same size, so we
  # choose the number of folds such that it divides the number of observations (208 = 4 * 52).
  task = tsk("sonar")
  rr = resample(task, lrn("classif.featureless"), rsmp("cv", folds = 4))
  ci = rr$aggregate(msr("ci", "classif.acc"))
  aggr = rr$aggregate(msr("classif.acc"))
  expect_equal(ci[[1L]], aggr[[1L]])
})
