#' @import paradox
#' @import checkmate
#' @import data.table
#' @import mlr3misc
#' @importFrom R6 R6Class is.R6
#' @importFrom stats qnorm qt sd var
#' @import mlr3
"_PACKAGE"

register_mlr3 = function(...) {
  assign("lg", lgr::get_logger("mlr3"), envir = parent.env(environment()))
  # static checker
  future::plan
  withr::with_seed

  if (Sys.getenv("IN_PKGDOWN") == "true") {
    lg$set_threshold("warn")
  }
  iwalk(as.list(resamplings), function(x, nm) mlr3::mlr_resamplings$add(nm, x))
  iwalk(as.list(measures), function(x, nm) mlr3::mlr_measures$add(nm, x[[1L]], .prototype_args = x$.prototype_args))

  mlr_reflections = mlr3::mlr_reflections
  mlr_reflections$default_ci_methods = list(
    ResamplingHoldout = "ci.holdout",
    ResamplingCV = "ci.naive_cv",
    ResamplingSubsampling = "ci.cor_t",
    ResamplingPairedSubsampling = "ci.con_z",
    ResamplingNestedCV = "ci.nvc"
  )
}


.onLoad = function(libname, pkgname) {
  register_namespace_callback(pkgname, "mlr3", register_mlr3)
}

leanify_package()
