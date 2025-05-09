test_that("basic", {
  expect_ci_measure("ci.wald_cv", rsmp("cv"), variance = "all-pairs")
  expect_ci_measure("ci.wald_cv", rsmp("cv"), variance = "within-fold")
  expect_ci_measure("ci.wald_cv", rsmp("loo"), variance = "all-pairs")
  expect_ci_measure("ci.wald_cv", rsmp("loo"), variance = "within-fold")
})
