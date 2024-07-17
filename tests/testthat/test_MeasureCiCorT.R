test_that("simple", {
  expect_ci_measure("ci.cor_t", rsmp("subsampling", repeats = 10L))
})
