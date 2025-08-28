test_that("basic", {
  withr::local_seed(1)
  expect_ci_measure("ci.con_z", rsmp("paired_subsampling", repeats_in = 5, repeats_out = 10))
})

test_that("aggr and CI point estimate agree", {
  task = tsk("iris")
  rr = resample(task, lrn("classif.featureless"), rsmp("paired_subsampling", repeats_in = 5, repeats_out = 10))
  ci = rr$aggregate(msr("ci", "classif.acc"))
  aggr = rr$aggregate(msr("classif.acc"))
  expect_equal(ci[[1L]], aggr[[1L]])
})
