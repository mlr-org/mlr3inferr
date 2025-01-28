#' @title Corrected-T CI
#' @name mlr_measures_ci.cor_t
#' @description
#' Corrected-T confidence intervals based on [`ResamplingSubsampling`][mlr3::ResamplingSubsampling].
#' A heuristic factor is applied to correct for the dependence between the iterations.
#' The confidence intervals tend to be liberal.
#' This inference method can also be applied to non-decomposable losses.
#' @section Parameters:
#' Only those from [`MeasureAbstractCi`].
#' @template param_measure
#' @export
#' @references
#' `r format_bib("nadeau1999inference")`
#' @examples
#' m_cort = msr("ci.cor_t", "classif.acc")
#' m_cort
#' rr = resample(
#'   tsk("sonar"),
#'   lrn("classif.featureless"),
#'   rsmp("subsampling", repeats = 10)
#' )
#' rr$aggregate(m_cort)
MeasureCiCorrectedT = R6Class("MeasureCiCorrectedT",
  inherit = MeasureAbstractCi,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function(measure) {
      super$initialize(
        measure = measure,
        resamplings = "ResamplingSubsampling",
        label = "Corrected-T Interval",
        requires_obs_loss = FALSE,
        delta_method = TRUE,
        man = "mlr3inferr::mlr_measures_ci.cor_t"
      )
    }
  ),
  private = list(
    .ci = function(tbl, rr, param_vals) {
      J = rr$resampling$param_set$values$repeats
      ratio = rr$resampling$param_set$values$ratio
      n = rr$resampling$task_nrow

      # in the nadeau paper n1 is the train-set size and n2 the test set size

      n1 = round(ratio * n) # in the ResamplingSubsampling the same rounding is used
      n2 = n - n1

      # the different mu in the rows are the mu_j
      mus = tbl$loss
      # the global estimator
      estimate = mean(mus)
      # The naive SD estimate (does not take correlation between folds into account)
      # (9)
      estimate_sd = sd(mus)

      # The corrected SD estimate
      sd_corrected = estimate_sd * sqrt(1 / J + n2 / n1)
      z = qt(1 - param_vals$alpha / 2, df = J - 1)

      halfwidth = sd_corrected * z

      lower = estimate - halfwidth
      upper = estimate + halfwidth

      c(estimate, lower, upper)
    }
  )
)

#' @include aaa.R
measures[["ci.cor_t"]] = list(MeasureCiCorrectedT, .prototype_args = list(measure = "classif.acc"))
