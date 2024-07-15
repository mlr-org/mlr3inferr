#' @title Nested Cross-Validation
#' @name mlr_resamlings_ncv
#' @description
#' We have R times:
#' * K outer resamplings
#' * K * (K - 1) inner resamplings
#'
#' The first K^2 iters are then:
#' The first K are the outer K iterations.
#' Then, we have K * (K - 1) inner iterations.
#' @section Parameters:
#' * `folds` :: `integer(1)`\cr
#'   The number of folds.
#' * `repeats` :: `integer(1)`\cr
#'   The number of repetitions.
#' @export
#' @references
#' `r format_bib("bates2024cross")`
#' @examples
#' ncv = rsmp("nested_cv", folds = 3, repeats = 10L)
#' ncv
#' rr = resample(tsk("mtcars"), lrn("regr.featureless"), ncv)
ResamplingNestedCV = R6::R6Class("ResamplingNestedCV",
  inherit = mlr3::Resampling,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        folds = p_int(lower = 2L, tags = "required"),
        repeats = p_int(lower = 1L, tags = "required")
      )

      super$initialize(id = "nested_cv", param_set = param_set,
        label = "Nested CV", man = "mlr3::mlr_resamplings_nested_cv"
      )
    },
    #' @description For a given iteration return info about the inner and outer loop.
    #' In case the iteration belongs to the outer loop, the value `inner` is set to `NA_integer_`.
    #' @param iter (`integer(1)`)\cr
    #'   The iteration.
    unflatten = function(iter) {
      assert_int(iter, lower = 1L, upper = self$iters)
      pv = self$param_set$get_values()
      folds = pv$folds
      repeats = pv$repeats

      rep = ceiling(iter / folds^2)
      a = iter - (rep - 1) * folds^2
      if (a <= folds) {
        list(
          rep = rep,
          outer = a,
          inner = NA_integer_
        )
      } else {
        b = a - folds
        outer = ceiling(b / (folds - 1L))
        inner = b - (outer - 1L) * (folds - 1L)
        list(
          rep = rep,
          outer = outer,
          inner = inner
        )
      }
    }
  ),
  active = list(
     #' @field iters (`integer(1)`)\cr
     #' The total number of resampling iterations.
     iters = function(rhs) {
      assert_ro_binding(rhs)
      pv = self$param_set$get_values()
      pv$repeats * pv$folds^2
    }
  ),
  private = list(
    .sample = function(ids, ...) {
      pv = self$param_set$get_values()
      folds = pv$folds
      repeats = pv$repeats
      map_dtr(seq(repeats), function(r) {
        data.table(
          row_id = ids,
          rep = r,
          fold = shuffle(seq_along0(ids) %% as.integer(folds) + 1L),
          key = c("rep", "fold")
        )
      })
    },
    .get_train = function(i) {
      folds = self$param_set$get_values()$folds
      info = self$unflatten(i)

      if (is.na(info$inner)) { # an outer iteration
        # we first subset subset to the specific iteration and then we remove the outer fold to get the
        # test set from the outer CV
        self$instance[list(info$rep), ,  on = "rep"][!list(info$outer), "row_id", on = "fold"][[1L]]
      } else {
        # if we are in the inner CV that removed the `outer` test set from the outer CV, we first remove
        # the outer fold and the pick one of the remaining folds as the inner test set
        fold_inner = seq_len(folds)[-info$outer][info$inner]
        self$instance[list(info$rep), , on = "rep"][ # subset to the repetition
          !list(info$outer), , on = "fold"][ # subset to the train set of the outer CV
          !list(fold_inner), "row_id", on = "fold"][[1L]] # subset to the train set of the inner CV
      }
    },
    .get_test = function(i) {
      folds = self$param_set$get_values()$folds
      info = self$unflatten(i)

      if (is.na(info$inner)) { # an outer iteration
        # first, we subset to the repetition, then we simply pick the 'outer' fold as the test set.
        self$instance[list(info$rep), ,  on = "rep"][list(info$outer), "row_id", on = "fold"][[1L]]
      } else {
        # which of the outer folds is removed for the inner CV
        fold_inner = seq_len(folds)[-info$outer][info$inner]

        self$instance[list(info$rep), , on = "rep"][ # subset to the repetition
          !list(info$outer), , on = "fold"][ # subset to the train set of the outer CV
          list(fold_inner), "row_id", on = "fold"][[1L]] # subset to the test set of the inner CV
      }
    },
    .combine = function(instances) {
      rbindlist(instances, use.names = TRUE)
    }
  )
)

#' @include aaa.R
resamplings[["nested_cv"]] = ResamplingNestedCV
