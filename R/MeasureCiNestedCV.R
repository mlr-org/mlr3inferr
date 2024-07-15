#' @title Nested CV CI
#' @name mlr_measures_ci_ncv
#' @description
#' Confidence Intervals based on [`ResamplingNestedCV`][ResamplingNestedCV], including bias-correction.
#' @section Parameters:
#' * `alpha` :: `numeric(1)`\cr
#'   The desired alpha level.
#' @template param_measure
#' @export
#' @references
#' `r format_bib("bates2024cross")`
#' @examples
#' # cheap parameterization to run quickly:
#' ci_ncv = msr("ci.ncv", "classif.acc")
#' ci_ncv
MeasureCiNestedCV = R6Class("MeasureCiNestedCV",
  inherit = MeasureAbstractCi,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function(measure) {
      super$initialize(
        measure = measure,
        resamplings = "ResamplingNestedCV",
        label = "Nested CV CI"
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

      # left term going from (k - 1) / k * n to k / n
      # right from going from (k - 2) / k * n to (k - 1) / l * n
      # different than in ntestedcv implementation but authors did not respond to my email
      bias = (1 + (folds - 2) / folds) * (err_ncv - err_cv)


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
      c(err_ncv - bias, err_ncv - bias - s, err_ncv - bias + s)
    }
  )
)

measures[["ci.ncv"]] =  list(MeasureCiNestedCV, .prototype_args = list(measure = "classif.acc"))
