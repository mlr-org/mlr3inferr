test_that("basic", {
  task = tsk("mtcars")$cbind(data.frame(chas = rep(c("a", "b"), times = 16)))
  expect_ci_measure(
    "ci.ncv",
    rsmp("nested_cv", folds = 3L, repeats = 5L),
    task = task
  )
})
