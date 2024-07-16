expect_ci_measure = function(m, rr, symmetric = TRUE) {
  m = m$clone(deep = TRUE)
  get("expect_measure", envir = .GlobalEnv)(m)
  testthat::expect_s3_class(m, "MeasureAbstractCi")
  testthat::expect_error(rr$score(m), "$aggregate", fixed = TRUE)
  ci = rr$aggregate(m)
  checkmate::expect_numeric(ci[[m$id]])
  checkmate::expect_numeric(ci[[paste0(m$id, ".lower")]])
  checkmate::expect_numeric(ci[[paste0(m$id, ".upper")]])
  testthat::expect_true(ci[[m$id]] > ci[[paste0(m$id, ".lower")]])
  testthat::expect_true(ci[[m$id]] < ci[[paste0(m$id, ".upper")]])
  if (symmetric) {
    d1 = ci[[m$id]] - ci[[paste0(m$id, ".lower")]]
    d2 = ci[[paste0(m$id, ".upper")]] - ci[[m$id]]
    testthat::expect_equal(d1, d2)
  }

  m$param_set$values$alpha = 0.05
  ci1 = rr$aggregate(m)
  m$param_set$values$alpha = 0.5
  ci2 = rr$aggregate(m)

  expect_equal(ci1[1L], ci2[1L])
  expect_true(ci2[2L] >= ci1[2L])
  expect_true(ci2[3L] <= ci1[3L])
}

