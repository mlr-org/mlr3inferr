test_that("basic", {
  rr = resample(tsk("iris"), lrn("classif.featureless"), rsmp("holdout"))
  ci1 = rr$aggregate(msr("ci", "classif.acc"))
  ci2 = rr$aggregate(msr("ci.holdout", "classif.acc"))
  expect_equal(ci1, ci2)
  expect_ci_measure("ci", rsmp("holdout"))
})
