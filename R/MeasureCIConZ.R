#' @title Conservative-Z CI
#' @name mlr_measures_ci_con_z
#' @description
#' The conservative-z confidence intervals based on the [`ResamplingPairedSubsampling`].
#' Because the variance estimate is obtained using only `n / 2` observations, it tends to be conservative.
#' @section Parameters:
#' Only those from [`MeasureAbstractCi`].
#' @template param_measure
#' @export
#' @references
#' `r format_bib("nadeau1999inference")`
#' @examples
#' ci_conz = msr("ci.con_z", "classif.acc")
#' ci_conz
MeasureCiConZ = R6Class("MeasureCiConZ",
  inherit = MeasureAbstractCi,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function(measure) {
      super$initialize(
        measure = measure,
        resamplings = "ResamplingPairedSubsampling",
        label = "Conservative-Z CI",
        delta_method = TRUE
      )
    }
  ),
  private = list(
    .ci = function(tbl, rr, param_vals) {
      repeats_in = rr$resampling$param_set$values$repeats_in
      repeats_out = rr$resampling$param_set$values$repeats_out
      tbl = tbl[, list(loss = mean(get("loss"))), by = "iteration"]

      estimate = tbl[get("iteration") <= repeats_in, mean(get("loss"))]

      # this table we use only to estimate the variance
      tbl_var = tbl[get("iteration") > repeats_in, ]
      tbl_var$replication = rep(seq_len(repeats_out), each = repeats_in * 2)
      tbl_var$partition = rep(rep(1:2, each = repeats_in), times = repeats_out)

      # Now for each replication we average the measure in both partitions and then
      # calculate the squared error between the averaged partitions

      x = tbl_var[, list(loss = mean(get("loss"))), by = c("replication", "partition")]

      x = dcast(x, replication ~ partition, value.var = "loss")

      sigma2 = sum((x[["1"]] - x[["2"]])^2) / (2 * repeats_out)

      z = qnorm(1 - param_vals$alpha / 2) * sqrt(sigma2)

      c(estimate, estimate - z, estimate + z)
    }
  )
)

#' @include aaa.R
measures[["ci.con_z"]] = list(MeasureCiConZ, .prototype_args = list(measure = "classif.acc"))
