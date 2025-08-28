#' @title Nested CV CI
#' @name mlr_measures_ci.ncv
#' @description
#' Confidence Intervals based on [`ResamplingNestedCV`][ResamplingNestedCV], including bias-correction.
#' This inference method can only be applied to decomposable losses.
#'
#' @section Point Estimation:
#' The point estimate uses a bias correction term as described in Bates et al. (2024).
#' Therefore, the results of directly applying a measure `$aggregate(msr(<key>))` will be different
#' from the point estimate of `$aggregate(msr("ci", <key>))`, where the point estimate is obtained
#' by averaging over the outer CV results.
#'
#' @section Parameters:
#' Those from [`MeasureAbstractCi`], as well as:
#' * `bias` :: `logical(1)`\cr
#'   Whether to do bias correction. This is initialized to `TRUE`.
#'   If `FALSE`, the outer iterations are used for the point estimate
#'   and no bias correction is applied.
#' @template param_measure
#' @export
#' @references
#' `r format_bib("bates2024cross")`
#' @examples
#' ci_ncv = msr("ci.ncv", "classif.acc")
#' ci_ncv
MeasureCiNestedCV = R6Class("MeasureCiNestedCV",
  inherit = MeasureAbstractCi,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function(measure) {
      param_set = ps(
        bias = p_lgl(init = TRUE, tags = "required")
      )
      super$initialize(
        param_set = param_set,
        measure = measure,
        resamplings = "ResamplingNestedCV",
        label = "Nested CV Interval",
        delta_method = TRUE,
        man = "mlr3inferr::mlr_measures_ci.ncv"
      )
    }
  ),
  private = list(
    .ci = function(tbl, rr, param_vals) {
      resampling = rr$resampling
      repeats = resampling$param_set$values$repeats
      folds = resampling$param_set$values$folds
      n_iters = resampling$iters
      n = resampling$task_nrow

      iter_info = map_dtr(seq_len(n_iters), function(i) {
        u = resampling$unflatten(i)
        n = tbl[list(i), get(".N"), on = "iteration"][[1L]]
        list(
          rep   = rep(u$rep, times = n),
          outer = rep(u$outer, times = n),
          inner = rep(u$inner, times = n)
        )
      })
      tbl = cbind(tbl, iter_info)

      tbl_outer = tbl[is.na(get("inner"))]
      tbl_inner = tbl[!is.na(get("inner"))]

      b_list = tbl_outer[, list(b = var(get("loss")) / get(".N")), by = c("rep", "outer")][["b"]]

      tmp1 = tbl_outer[, list(avg_outer = mean(get("loss"))), by = c("rep", "outer")]
      tmp2 = tbl_inner[, list(avg_inner = mean(get("loss"))), by = c("rep", "outer")]
      tmp_join = merge(tmp1, tmp2, by = c("rep", "outer"))

      a_list = tmp_join[, list(a = (get("avg_inner") - get("avg_outer"))^2)][["a"]]

      err_ncv = mean(tbl_inner$loss)
      mse = mean(a_list - b_list)

      err_cv = tbl_outer[, mean(get("loss"))]

      # we recommend re-scaling to obtain an estimate for a sample of size n by instead taking:
      mse = (folds - 1) / folds * mse

      # We do the max(mse, 0) because the mse estimate can sometimes be negative.
      # The ensure_within ensures that it is within the range of assumig that all the estimates from the outer folds
      # are 100% dependent vs. assuming that they are 100% independent

      sigma_in = sd(tbl_inner$loss)
      se_low = sigma_in / sqrt(n)
      se_up = se_low * sqrt(folds)

      se = max(se_low, min(sqrt(max(0, mse)), se_up))

      s = qnorm(1 - param_vals$alpha / 2) * se
      if (param_vals$bias) {
        # left term going from (k - 1) / k * n to k / n
        # right from going from (k - 2) / k * n to (k - 1) / l * n
        # different than in nestedcv implementation but authors did not respond to my email
        bias = if (param_vals$bias) {
          bias = (1 + (folds - 2) / folds) * (err_ncv - err_cv)
        } else {
          NULL
        }

        c(err_ncv - bias, err_ncv - bias - s, err_ncv - bias + s)
      } else {
        # use the outer CVs for point estimation
        # this is slightly different from the bates paper, but we
        # do it here for consistency with calling e.g. $aggregate(msr("classif.acc"))
        c(err_cv, err_cv - s, err_cv + s)
      }
    }
  )
)

#' @include aaa.R
measures[["ci.ncv"]] =  list(MeasureCiNestedCV, .prototype_args = list(measure = "classif.acc"))
