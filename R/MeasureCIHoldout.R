#' @title Holdout CI
#' @name mlr_measures_ci_holdout
#' @description
#' Standard holdout CI.
#' @section Parameters:
#' Only those from [`MeasureAbstractCi`].
#' @template param_measure
#' @export
#' @examples
#' ci_ho = msr("ci.holdout", "classif.acc")
#' ci_ho
#' rr = resample(tsk("sonar"), lrn("classif.featureless"), rsmp("holdout"))
#' rr$aggregate(ci_ho)
MeasureCiHoldout = R6Class("MeasureCiHoldout",
  inherit = MeasureAbstractCi,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function(measure) {
      super$initialize(
        measure = measure,
        resamplings = "ResamplingHoldout",
        label = "Holdout CI"
      )
    }
  ),
  private = list(
    .ci = function(tbl, rr, param_vals) {
      losses = tbl[, "loss", with = FALSE][[1L]]
      estimate = mean(losses)
      se = sd(losses) / sqrt(nrow(tbl))
      z = qnorm(1 - param_vals$alpha / 2)

      c(estimate, estimate - se * z, estimate + se * z)
    }
  )
)

#' @include aaa.R
measures[["ci.holdout"]] = list(MeasureCiHoldout, .prototype_args = list(measure = "classif.acc"))
