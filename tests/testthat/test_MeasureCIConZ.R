test_that("basic", {
  withr::local_seed(1)
  mci = msr("ci.con_z", "regr.mae")
  rr = resample(tsk("boston_housing"), lrn("regr.featureless"), rsmp("paired_subsampling", repeats_in = 5, repeats_out = 10))
  expect_ci_measure(mci, rr)
})

test_that("stratification", {
  withr::local_seed(1)
  mci = msr("ci.con_z", "regr.mae")
  task = tsk("boston_housing")
  task$col_roles$stratum = "chas"
  rr = resample(task, lrn("regr.featureless"), rsmp("paired_subsampling", repeats_in = 5, repeats_out = 10))
  expect_ci_measure(mci, rr)
})
