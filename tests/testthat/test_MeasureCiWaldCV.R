test_that("basic", {
  expect_ci_measure("ci.wald_cv", rsmp("cv"), variance = "all-pairs")
  expect_ci_measure("ci.wald_cv", rsmp("cv"), variance = "within-fold")
  expect_ci_measure("ci.wald_cv", rsmp("loo"), variance = "all-pairs")
  expect_ci_measure("ci.wald_cv", rsmp("loo"), variance = "within-fold")
})

test_that("aggr and CI point estimate agree", {
  task = tsk("sonar")
  rr = resample(task, lrn("classif.featureless"), rsmp("cv", folds = 3))
  ci = rr$aggregate(msr("ci", "classif.acc"))
  aggr = rr$aggregate(msr("classif.acc"))
  # there is some difference due to how we do the aggregation.
  expect_equal(ci[[1L]], aggr[[1L]], tolerance = 0.001)
})
