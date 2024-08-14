#' @title Abstract Class for Confidence Intervals
#' @name mlr_measures_abstract_ci
#' @description
#' Base class for confidence interval measures.
#' See section *Inheriting* on how to add a new method.
#' @section Parameters:
#' * `alpha` :: `numeric(1)`\cr
#'   The desired alpha level.
#'   This is initialized to $0.05$.
#' * `within_range` :: `logical(1)`\cr
#'   Whether  to restrict the confidence interval within the range of possible values.
#'   This is initialized to `TRUE`.
#' @details
#' The aggregator of the wrapped measure is ignored, as the inheriting CI dictates how the point
#' estimate is constructed. If a measure for which to calculate a CI has `$obs_loss` but also a `$trafo`,
#' (such as RMSE), the delta method is used to obtain confidence intervals.
#' @param measure ([`Measure`][mlr3::Measure])\cr
#'   The measure for which to calculate a confidence interval. Must have `$obs_loss`.
#' @param resamplings (`character()`)\cr
#'   To which resampling classes this measure can be applied.
#' @param requires_obs_loss (`logical(1)`)\cr
#'   Whether the inference method requires a pointwise loss function.
#' @template param_param_set
#' @template param_packages
#' @template param_label
#' @param rr ([`ResampleResult`][mlr3::ResampleResult])\cr
#'   The resample result.
#' @param delta_method (`logical(1)`)\cr
#'   Whether to use the delta method for measures (such RMSE) that have a trafo.
#' @section Inheriting:
#' To define a new CI method, inherit from the abstract base class and implement the private method:
#' `ci: function(tbl: data.table, rr: ResampleResult, param_vals: named `list()`) -> numeric(3)`
#' If `requires_obs_loss` is set to `TRUE`, `tbl` contains the columns `loss`, `row_id` and `iteration`, which are the pointwise loss,
#' Otherwise, `tbl` contains the result of `rr$score()` with the name of the loss column set to `"loss"`.
#' the identifier of the observation and the resampling iteration.
#' It should return a vector containing the `estimate`, `lower` and `upper` boundary in that order.
#'
#' In case the confidence interval is not of the form `(estimate, estimate - z * se, estimate + z * se)`
#' it is also necessary to implement the private method:
#' `.trafo: function(ci: numeric(3), measure: Measure) -> numeric(3)`
#' Which receives a confidence interval for a pointwise loss (e.g. squared-error) and transforms it according
#' to the transformation `measure$trafo` (e.g. sqrt to go from mse to rmse).
#'
#' @export
MeasureAbstractCi = R6Class("MeasureAbstractCi",
  inherit = Measure,
  public = list(
    #' @field resamplings (`character()`)\cr
    #' On which resampling classes this method can operate.
    resamplings = NULL,
    #' @field measure ([`Measure`][mlr3::Measure])\cr
    measure = NULL,
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function(measure = NULL, param_set = ps(), packages = character(), resamplings, label, delta_method = FALSE,
      requires_obs_loss = TRUE) { # nolint
      private$.delta_method = assert_flag(delta_method, na.ok = TRUE)
      private$.requires_obs_loss = assert_flag(requires_obs_loss)
      if (test_string(measure)) measure = msr(measure)
      self$measure = measure

      if (private$.requires_obs_loss) {
        assert(
          check_class(measure, "Measure"),
          check_false(inherits(measure, "MeasureCi")),
          check_function(measure$obs_loss),
          combine = "and",
          .var.name = "Argument measure must be a scalar Measure with a pointwise loss function (has $obs_loss field)"
        )
      } else {
        assert(
          check_class(measure, "Measure"),
          check_false(inherits(measure, "MeasureCi")),
          combine = "and",
          .var.name = "Argument measure must be a scalar Measure."
        )
      }

      param_set = c(param_set,
        ps(
          alpha = p_dbl(lower = 0, upper = 1, init = 0.05, tags = "required"),
          within_range = p_lgl(init = TRUE, tags = "required")
        )
      )

      self$resamplings = assert_character(resamplings, min.len = 1L, all.missing = TRUE)

      super$initialize(
        id = self$measure$id,
        param_set = param_set,
        range = self$measure$range,
        minimize = self$measure$minimize,
        average = "custom",
        properties = "primary_iters",
        predict_type = self$measure$predict_type,
        packages = unique(c(self$measure$packages, "mlr3inferr"), packages),
        label = label
      )
    },
    #' @description
    #' Obtain a point estimate, as well as lower and upper CI boundary.
    #' @return named `numeric(3)`
    aggregate = function(rr) {
      assert_class(rr, "ResampleResult")
      if (!is.null(rr$task$groups)) {
        stopf("Confidence Intervals for grouped observations are currently not supported")
      }
      if ("test" %nin% rr$learner$predict_sets) {
        stopf("Predictions for set 'test' must be available to obtain confidence intervals, but learner has predict sets '%s'", # nolint
          paste0(rr$learner$predict_sets, collapse = ", ")) # nolint
      }
      measure = self$measure
      if (!identical(measure$predict_sets, "test")) {
        stopf("Measure '%s' for which CIs are to be calculated must have predict_set 'test', but has", self$measure$id,
          paste0(self$measure$predict_sets, collapse = ", ")) # nolint
      }

      if (!is_scalar_na(self$resamplings) && !test_multi_class(rr$resampling, self$resamplings)) {
        stopf("CI for Measure '%s' requires one of: %s", self$measure$id, paste0(self$resamplings, sep = ", "))
      }

      param_vals = self$param_set$get_values()
      tbl = if (private$.requires_obs_loss) {
        rr$obs_loss(self$measure)
      } else {
        rr$score(self$measure)
      }
      setnames(tbl, self$measure$id, "loss")

      ci = private$.ci(tbl, rr, param_vals)
      if (!is.null(self$measure$trafo)) {
        ci = private$.trafo(ci)
      }
      if (param_vals$within_range) {
        ci = pmin(pmax(ci, self$range[1L]), self$range[2L])
      }
      set_names(ci, c(self$id, paste0(self$id, ".", c("lower", "upper"))))
    }
  ),
  private = list(
    .requires_obs_loss = NULL,
    .delta_method = FALSE,
    .trafo = function(ci) {
      if (!private$.delta_method) {
        stopf("Measure '%s' has a trafo, but the CI does not handle it", self$measure$id)
      }
      measure = self$measure
      # delta-rule
      multiplier = measure$trafo$deriv(ci[[1]])
      ci[[1]] = measure$trafo$fn(ci[[1]])
      halfwidth = (ci[[3]] - ci[[1]])
      est_t = measure$trafo$fn(ci[[1]])
      ci_t = c(est_t, est_t - halfwidth * multiplier, est_t + halfwidth * multiplier)
      set_names(ci_t, names(ci))
    },
    .score = function(prediction, ...) {
      stopf("CI measures must be passed to $aggregate(), not $score()")
    },
    .ci = function(tbl, rr, param_vals) {
      stopf("Abstract method.")
    }
  )
)
