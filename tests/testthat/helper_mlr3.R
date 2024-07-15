# load mlr3 helper files

library("mlr3")

mlr_helpers = list.files(system.file("testthat", package = "mlr3"), pattern = "^helper.*\\.[rR]", full.names = TRUE)
lapply(mlr_helpers, FUN = source)
