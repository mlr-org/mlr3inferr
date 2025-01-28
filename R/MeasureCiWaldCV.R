#' @title Cross-Validation CI
#' @name mlr_measures_ci.wald_cv
#' @description
#' Confidence intervals for cross-validation.
#' The method is asymptotically exact for the so called *Test Error* as defined by Bayle et al. (2020).
#' For the (expected) risk, the confidence intervals tend to be too liberal.
#' This inference method can only be applied to decomposable losses.
#' @section Parameters:
#' Those from [`MeasureAbstractCi`], as well as:
#' * `variance` :: `"all-pairs"` or `"within-fold"`\cr
#'   How to estimate the variance. The results tend to be very similar.
#' @template param_measure
#' @references
#' `r format_bib("bayle2020cross")`
#' @export
#' @examples
#' m_waldcv = msr("ci.wald_cv", "classif.ce")
#' m_waldcv
#' rr = resample(tsk("sonar"), lrn("classif.featureless"), rsmp("cv"))
#' rr$aggregate(m_waldcv)
MeasureCiWaldCV = R6Class("MeasureCiWaldCV",
  inherit = MeasureAbstractCi,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function(measure) {
      param_set = ps(
        variance = p_fct(c("all-pairs", "within-fold"), init = "all-pairs", tags = "required")
      )
      super$initialize(
        param_set = param_set,
        measure = measure,
        resamplings = c("ResamplingCV", "ResamplingLOO"),
        label = "Wald CV Interval",
        delta_method = TRUE,
        man = "mlr3inferr::mlr_measures_ci.wald_cv"
      )
    }
  ),
  private = list(
    .ci = function(tbl, rr, param_vals) {
      if (inherits(rr$resampling, "ResamplingLOO")) {
        assert_true(param_vals$variance == "all-pairs", .var.name = "within-fold variance estimator not admissable for LOO")
      }

      n = rr$resampling$task_nrow

      estimate = mean(tbl$loss)

      var_est = if (param_vals$variance == "all-pairs") {
        # divide by n and not by (n - 1)
        mean((tbl$loss - estimate)^2)
      } else {
        tbl[, list(var_fold = var(get("loss"))), by = "iteration"][, mean(get("var_fold"))]
      }

      se = sqrt(var_est / n)
      z = qnorm(1 - param_vals$alpha / 2) * se
      c(estimate, estimate - z, estimate + z)
    }
  )
)

#' @include aaa.R
measures[["ci.wald_cv"]] = list(MeasureCiWaldCV, .prototype_args = list(measure = "classif.acc"))
