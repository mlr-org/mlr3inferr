test_that("score throws error", {
  rr = resample(tsk("iris"), lrn("classif.featureless"), rsmp("holdout"))
  ci = msr("ci.holdout", "classif.acc")
  expect_error(rr$score(ci), "$aggregate", fixed = TRUE)
})

test_that("resampling method is verified", {
  rr = resample(tsk("iris"), lrn("classif.featureless"), rsmp("insample"))
  ci = msr("ci.holdout", "classif.acc")
  expect_error(rr$aggregate(ci), "ResamplingHoldout")
})

test_that("construction measure checks", {
  rr = resample(tsk("iris"), lrn("classif.featureless"), rsmp("insample"))
  expect_error(msr("ci.holdout", msr("ci.holdout", "classif.acc")), "scalar")
  expect_error(msr("ci.holdout", "acc"), "not found")
  expect_error(msr("ci.holdout", 1), "scalar")
})

test_that("aggregation works", {
  mci = msr("ci.holdout", "classif.acc")
  bmr = benchmark(benchmark_grid(tsks(c("sonar", "iris")), lrn("classif.featureless"), rsmp("holdout")))
  cis = bmr$aggregate(mci)
  expect_numeric(cis$classif.acc)
  expect_numeric(cis$classif.acc.lower)
  expect_true(all(cis$classif.acc.upper >= cis$classif.acc.lower))
  expect_true(all(cis$classif.acc >= cis$classif.acc.lower))
  expect_true(all(cis$classif.acc <= cis$classif.acc.upper))
  expect_numeric(cis$classif.acc.upper)
})

test_that("wrapped measure must evaluate test", {
  rr = resample(tsk("iris"), lrn("classif.featureless", predict_sets = "train"), rsmp("holdout"))
  expect_error(rr$aggregate(msr("ci.holdout", "classif.acc")))
})

test_that("also works when CI measure and passed measure have different IDs", {
  mci = msr("ci.holdout", "classif.acc")
  mci$measure$id = "acc"
  rr = resample(tsk("sonar"), lrn("classif.featureless"), rsmp("holdout"))
  ci = rr$aggregate(mci)
  expect_numeric(ci[["classif.acc"]])
  expect_numeric(ci[["classif.acc.lower"]])
  expect_numeric(ci[["classif.acc.upper"]])
  mci$measure$id = "classif.acc"
  mci$id = "acc"
  ci = rr$aggregate(mci)
  expect_numeric(ci[["acc"]])
  expect_numeric(ci[["acc.lower"]])
  expect_numeric(ci[["acc.upper"]])
})

test_that("grouping is not allowed", {
  task = tsk("boston_housing")
  task$col_roles$group = "chas"

  rr =  resample(task, lrn("regr.featureless"), rsmp("holdout"))
  expect_error(rr$aggregate(msr("ci.holdout", "regr.mse")), "grouped")
})
