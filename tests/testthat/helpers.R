expect_ci_measure = function(m, rr, symmetric = TRUE) {
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
}

