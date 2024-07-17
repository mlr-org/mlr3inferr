test_that("basic", {
  withr::local_seed(1)
  expect_ci_measure("ci.con_z", rsmp("paired_subsampling", repeats_in = 5, repeats_out = 10))
})
