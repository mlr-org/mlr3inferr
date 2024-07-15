#' @title Default CI Method
#' @name mlr_measures_ci
#' @description
#' For certain resampling methods, there are default confidence interval methods.
#' See `mlr3::mlr_reflections$default_ci_methods` for a selection.
#' This measure will select the appropriate CI method depending on the class of the
#' used [`Resampling`][mlr3::Resampling].
#' @template param_measure
#' @section Parameters:
#' * `alpha` :: `numeric(1)`\cr
#'   The desired alpha level.
#' @export
#' @examples
#' rr = resample(tsk("sonar"), rsmp("classif.featureless"), rsmp("holdout"))
#' rr$aggregate(msr("ci", "classif.acc"))
#' # is the same as:
#' rr$aggregate(msr("ci.holdout", "classif.acc")
MeasureCi = R6Class("Measure",
  inherit = MeasureAbstractCi,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function(measure) {
      super$initialize(
        measure = measure,
        resamplings = NA,
        label = "Default CI"
      )
    }
  ),
  private = list(
    .ci = function(tbl, rr, param_vals) {
      if (class(rr$resampling)[[1L]] %nin% names(mlr3::mlr_reflections$default_ci_methods)) {
        stopf("There is no default CI method for '%s'", class(rr$resampling)[[1L]])
      }
      measure = msr(
        .key = mlr3::mlr_reflections$default_ci_methods[[class(rr$resampling)[[1L]]]],
        measure = self$measure$clone(deep = TRUE)
      )

      get_private(measure)$.ci(tbl, rr, param_vals)
    }
  )
)

measures[["ci"]] = list(MeasureCi, .prototype_args = list(measure = "classif.acc"))
