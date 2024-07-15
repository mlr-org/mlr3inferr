test_that("basic", {
  repeats_in = 2
  repeats_out = 3
  ratio = 0.78
  r = rsmp("paired_subsampling", ratio = ratio, repeats_in = repeats_in, repeats_out = repeats_out)
  task = tsk("iris")
  r$instantiate(task)

  expect_class(r, "ResamplingPairedSubsampling")
  expect_equal(r$iters, 14)
  walk(seq_len(repeats_in), function(i) {
    expect_permutation(c(r$train_set(i), r$test_set(i)), task$row_ids)
  })
  walk(3:14, function(i) {
    expect_equal(length(unique(c(r$train_set(i), r$test_set(i)))), 75)
  })
  walk(1:14, function(i) {
    expect_disjunct(r$train_set(i), r$test_set(i))
  })

  expect_equal(length(unique(lengths(map(seq_len(r$iters), function(i) r$test_set(i))))), 1L)

  rr = resample(
    task,
    lrn("classif.featureless"),
    r
  )
  expect_class(rr, "ResampleResult")
})

test_that("n2 is the same everywhere", {
  task1 = tsk("iris")
  res1 = rsmp("paired_subsampling", repeats_in = 10, repeats_out = 15, ratio = 0.9)
  res1$instantiate(task1)
  expect_equal(length(res1$test_set(1)), length(res1$test_set(11)))

  res2 = rsmp("paired_subsampling", repeats_in = 10, repeats_out = 15, ratio = 0.9)
  task2 = tsk("iris")$filter(1:149)
  res2$instantiate(task2)
  expect_equal(length(res2$test_set(1)), length(res2$test_set(11)))
})

test_that("unflatten works", {
  task = tsk("iris")
  res = rsmp("paired_subsampling", repeats_in = 3, repeats_out = 2)
  res$instantiate(task)
  # standard subsampling
  expect_equal(res$unflatten(1), list(outer = NA, partition = NA, inner = 1))
  expect_equal(res$unflatten(2), list(outer = NA, partition = NA, inner = 2))
  expect_equal(res$unflatten(3), list(outer = NA, partition = NA, inner = 3))

  # pair1
  # partition 1
  expect_equal(res$unflatten(4), list(outer = 1, partition = 1, inner = 1))
  expect_equal(res$unflatten(5), list(outer = 1, partition = 1, inner = 2))
  expect_equal(res$unflatten(6), list(outer = 1, partition = 1, inner = 3))
  # partition 2
  expect_equal(res$unflatten(7), list(outer = 1, partition = 2, inner = 1))
  expect_equal(res$unflatten(8), list(outer = 1, partition = 2, inner = 2))
  expect_equal(res$unflatten(9), list(outer = 1, partition = 2, inner = 3))

  # pair2
  expect_equal(res$unflatten(10), list(outer = 2, partition = 1, inner = 1))
  expect_equal(res$unflatten(11), list(outer = 2, partition = 1, inner = 2))
  expect_equal(res$unflatten(12), list(outer = 2, partition = 1, inner = 3))
  # partition 2
  expect_equal(res$unflatten(13), list(outer = 2, partition = 2, inner = 1))
  expect_equal(res$unflatten(14), list(outer = 2, partition = 2, inner = 2))
  expect_equal(res$unflatten(15), list(outer = 2, partition = 2, inner = 3))
})

test_that("ratio is respected", {
  task = tsk("iris")$filter(1:100)
  r = rsmp("paired_subsampling", repeats_out = 1, repeats_in = 1L, ratio = 0.8)
  r$instantiate(task)
  expect_equal(r$iters, 3L)
  expect_equal(length(r$test_set(1)), 20)
  expect_equal(length(r$train_set(1)), 80)

  # partition 1
  expect_equal(length(r$test_set(2)), 20)
  expect_equal(length(r$train_set(2)), 30)

  # partition 2
  expect_equal(length(r$test_set(2)), 20)
  expect_equal(length(r$train_set(2)), 30)
})
