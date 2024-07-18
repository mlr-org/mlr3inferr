#' @title Paired Subsampling
#' @name mlr_resamplings_paired_subsampling
#' @description
#' Paired Subsampling to enable inference on the generalization error.
#' One should **not** directlu call `$aggregate()` with a non-CI measure on a resample result using paired subsampling,
#' as most of the resampling iterations are only intended 
#' @details
#' The first `repeats_in` iterations are a standard [`ResamplingSubsampling`][mlr3::ResamplingSubsampling]
#' and should be used to obtain a point estimate of the generalization error.
#' The remaining iterations should be used to estimate the standard error.
#' Here, the data is divided `repeats_out` times into two equally sized disjunct subsets, to each of which subsampling
#' which, a subsampling with `repeats_in` repetitions is applied.
#' See the `$unflatten(iter)` method to map the iterations to this nested structure.
#' @section Parameters:
#' * `repeats_in` :: `integer(1)`\cr
#'   The inner repetitions.
#' * `repeats_out` :: `integer(1)`\cr
#'   The outer repetitions.
#' * `ratio` :: `numeric(1)`\cr
#'   The proportion of data to use for training.
#' @references
#' `r format_bib("nadeau1999inference")`
#' @export
#' @examples
#' pw_subs = rsmp("paired_subsampling")
#' pw_subs
ResamplingPairedSubsampling = R6Class("ResamplingPairedSubsampling",
  inherit = mlr3::Resampling,
  public = list(
    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      param_set = ps(
        repeats_in = p_int(lower = 1L, tags = "required", init = 15L),
        repeats_out = p_int(lower = 1L, tags = "required", init = 10L),
        ratio   = p_dbl(2 / 3, 1, tags = "required", init = 0.9)
      )
      super$initialize(
        id = "paired_subsampling",
        param_set = param_set,
        label = "Paired Subsampling",
        man = "mlr3::mlr_resamplings_paired_subsampling"
      )
    },
    #' @description
    #' Unflatten the resampling iteration into a more informative representation:
    #' * `inner`: The subsampling iteration
    #' * `outer`: `NA` for the first `repeats_in` iterations. Otherwise it indicates
    #'   the outer iteration of the paired subsamplings.
    #' * `partition`: `NA` for the first `repeats_in` iterations.
    #'   Otherwise it indicates whether the subsampling is applied to the first or second partition
    #'   Of the two disjoint halfs.
    #' @param iter (`integer(1)`)\cr
    #' Resampling iteration.
    #' @return
    #' `list(outer, partition, inner)`
    unflatten = function(iter) {
      assert_int(iter, upper = self$iters)
      pvs = self$param_set$get_values()
      repeats_in = pvs$repeats_in
      repeats_out = pvs$repeats_out
      if (iter <= repeats_in) {
        return(list(outer = NA, partition = NA, inner = iter))
      }
      iter = iter - repeats_in
      outer = ceiling(iter / (repeats_in * 2))
      iter = iter - (2 * repeats_in) * (outer - 1L)
      partition = ceiling(iter / repeats_in)
      inner = iter - (partition - 1) * repeats_in
      list(outer = outer, partition = partition, inner = inner)
    }
  ),
  private = list(
    .combine = function(instances) {
      f = function(instances) {
        Reduce(function(lhs, rhs) {
          n = length(lhs$row_ids)
          list(train =
            Map(function(x, y) c(x, y + n), lhs$train, rhs$train),
          row_ids = c(lhs$row_ids, rhs$row_ids)
          )
        }, instances)
      }

      map(seq_along(instances[[1L]]), function(i) {
        f(map(instances, i))
      })
    },
    .sample_once = function(ids, reps, ratio) {
      n = length(ids)
      nr = round(n * ratio)

      train = replicate(reps, sample.int(n, nr), simplify = FALSE)
      list(train = train, row_ids = ids)
    },
    .sample = function(ids, task, ...) {
      if (!is.null(task$groups)) {
        stopf("Resampling '%s' cannot be applied to grouped tasks", self$id)
      }

      pvs = self$param_set$get_values()

      repeats_in = pvs$repeats_in
      repeats_out = pvs$repeats_out
      ratio = pvs$ratio

      self$primary_iters = repeats_in

      n = length(ids)
      n1 = round(n * ratio)
      n2 = n - n1

      # make sure the n_sub (size of paired subsamplings) is even
      n_sub = (n - n %% 2) / 2

      if (!n_sub) {
        if (!is.null(task$strata)) {
          stopf("Not enough observations in one of the strata")
        } else {
          stopf("Not enough observations in the task")
        }
      }

      instance = vector("list", length = 1 + repeats_out * 2)
      instance[[1]] = private$.sample_once(ids, repeats_in, ratio)

      # we want the same n2 for the subsets, just the new n1' is smaller than the n1 above
      # n1' = round(n_sub * new_ratio)
      # n2 + n1' = n_sub
      # n2 = n_sub - round(n_sub * new_ratio)
      # n_sub - n_2 = round(n_sub * new_ratio)
      # new_ratio = (n_sub - n_2 ) / n_sub + rounding

      new_ratio = (n_sub - n2) / n_sub

      for (i in seq_len(repeats_out)) {
        sub_ids = sample(ids, n_sub * 2)
        instance[[i * 2]] =  private$.sample_once(sub_ids[seq(1, n_sub)], repeats_in, new_ratio)
        instance[[1 + i * 2]] =  private$.sample_once(sub_ids[seq(n_sub + 1, 2 * n_sub)], repeats_in, new_ratio)
      }
      instance
    },
    .get_train = function(i) {
      info = self$unflatten(i)
      if (is.na(info$outer)) {
        return(self$instance[[1L]]$row_ids[self$instance[[1L]]$train[[info$inner]]])
      }
      x = self$instance[[1L + (info$outer - 1L) * 2 + info$partition]]
      x$row_ids[x$train[[info$inner]]]
    },

    .get_test = function(i) {
      info = self$unflatten(i)
      if (is.na(info$outer)) {
        return(self$instance[[1L]]$row_ids[-self$instance[[1L]]$train[[info$inner]]])
      }
      x = self$instance[[1L + (info$outer - 1L) * 2 + info$partition]]
      x$row_ids[-x$train[[info$inner]]]
    }
  ),
  active = list(
    #' @field iters (`integer(1)`)\cr
    #' The total number of resampling iterations.
    iters = function(rhs) {
      pvs = self$param_set$get_values()
      (pvs$repeats_out * 2 + 1) * pvs$repeats_in
    }
  )
)

#' @include aaa.R
resamplings[["paired_subsampling"]] = ResamplingPairedSubsampling
