test_that("simple", {
  expect_ci_measure("ci.cor_t", rsmp("subsampling", repeats = 10L))
})

test_that("aggr and CI point estimate agree", {
  task = tsk("iris")
  rr = resample(task, lrn("classif.featureless"), rsmp("subsampling", repeats = 10L))
  ci = rr$aggregate(msr("ci", "classif.acc"))
  aggr = rr$aggregate(msr("classif.acc"))
  expect_equal(ci[[1L]], aggr[[1L]])
})