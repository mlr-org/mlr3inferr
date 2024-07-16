test_that("basic", {
  task = tsk("mtcars")
  learner = lrn("regr.featureless")

  mci = msr("ci.naive_cv", "regr.mse", variance = "all-pairs")
  rr = resample(task, learner, rsmp("cv"))
  expect_ci_measure(mci, rr)

  mci = msr("ci.naive_cv", "regr.mse", variance = "within-fold")
  rr = resample(task, learner, rsmp("cv"))
  expect_ci_measure(mci, rr)

  mci = msr("ci.naive_cv", "regr.mse")
  rr = resample(task, learner, rsmp("loo"))
  expect_ci_measure(mci, rr)

  mci = msr("ci.naive_cv", "regr.mse", variance = "within-fold")
  rr = resample(task, learner, rsmp("loo"))
  expect_error(rr$aggregate(mci), "LOO")
})

test_that("stratification", {
  mci = msr("ci.naive_cv", "regr.mse")
  task = tsk("boston_housing")
  task$col_roles$stratum = "chas"
  rr = resample(task, lrn("regr.featureless"), rsmp("cv"))
  expect_ci_measure(mci, rr)
})
