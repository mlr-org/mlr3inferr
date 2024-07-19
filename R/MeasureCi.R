#' @title Default CI Method
#' @name mlr_measures_ci
#' @description
#' For certain resampling methods, there are default confidence interval methods.
#' See `mlr3::mlr_reflections$default_ci_methods` for a selection.
#' This measure will select the appropriate CI method depending on the class of the
#' used [`Resampling`][mlr3::Resampling].
#' @template param_measure
#' @section Parameters:
#' Only those from [`MeasureAbstractCi`].
#' @export
#' @examples
#' rr = resample(tsk("sonar"), lrn("classif.featureless"), rsmp("holdout"))
#' rr$aggregate(msr("ci", "classif.acc"))
#' # is the same as:
#' rr$aggregate(msr("ci.holdout", "classif.acc"))
MeasureCi = R6Class("Measure",
  inherit = MeasureAbstractCi,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function(measure) {
      super$initialize(
        measure = measure,
        resamplings = NA,
        label = "Default CI",
        delta_method = NA
      )
    },
    #' @description
    #' Obtain a point estimate, as well as lower and upper CI boundary.
    #' @param rr ([`ResampleResult`][mlr3::ResampleResult])\cr
    #'  Resample result.
    #' @return named `numeric(3)`
    aggregate = function(rr) {
      if (class(rr$resampling)[[1L]] %nin% names(mlr3::mlr_reflections$default_ci_methods)) {
        stopf("There is no default CI method for '%s'", class(rr$resampling)[[1L]])
      }
      measure = msr(
        .key = mlr3::mlr_reflections$default_ci_methods[[class(rr$resampling)[[1L]]]],
        measure = self$measure$clone(deep = TRUE)
      )
      measure$aggregate(rr)
    }
  )
)

#' @include aaa.R
measures[["ci"]] = list(MeasureCi, .prototype_args = list(measure = "classif.acc"))
