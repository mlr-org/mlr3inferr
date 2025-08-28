test_that("basic", {
  task = tsk("mtcars")$cbind(data.frame(chas = rep(c("a", "b"), times = 16)))
  expect_ci_measure(
    "ci.ncv",
    rsmp("ncv", folds = 3L, repeats = 5L),
    task = task
  )
})

test_that("aggr and CI point estimate agree", {
  withr::local_seed(1)
  task = tsk("iris")
  rr = resample(task, lrn("classif.featureless"), rsmp("ncv", folds = 3L, repeats = 5L))
  ci = rr$aggregate(msr("ci", "classif.acc"))
  aggr = rr$aggregate(msr("classif.acc"))
  # there is some difference due to how we do the aggregation.
  expect_equal(ci[[1L]], aggr[[1L]], tolerance = 0.03)
})
