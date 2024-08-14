expect_ci_measure = function(id, resampling, symmetric = TRUE, ...) {
  check = function(m, rr) {
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
    if (symmetric && ci[[2]] != m$range[[1L]] && ci[[3]] != m$range[2L]) {
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
  task = tsk("boston_housing")
  rr = resample(task, lrn("regr.featureless"), resampling)
  check(msr(id, measure = "regr.rmse", within_range = FALSE), rr)
  check(msr(id, measure = "regr.mse", within_range = FALSE), rr)

  task$col_roles$stratum = "chas"
  rr_strat = resample(task, lrn("regr.featureless"), resampling)
  check(msr(id, measure = "regr.rmse", within_range = FALSE), rr_strat)
  check(msr(id, measure = "regr.mse", within_range = FALSE), rr_strat)

  if (!mlr3misc::require_namespaces("rpart", quietly = TRUE)) return(NULL)

  # decomposable vs. non-decomposable
  rr = resample(tsk("sonar"), lrn("classif.rpart", predict_type = "prob"), resampling)
  if (!get_private(msr(id, "regr.mse"))$.requires_obs_loss) {
    m = msr(id, "classif.auc")
    check(m, rr)
  } else {
    expect_error(msr(id, "classif.auc"))
  }
}
