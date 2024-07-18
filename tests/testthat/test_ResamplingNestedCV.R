test_that("ResamplingNestedCV works", {
  withr::local_seed(2)
  res = rsmp("nested_cv", folds = 10, repeats = 3)
  res
  task = tsk("iris")
  res$instantiate(task)

  expect_equal(res$iters, 300)
  expect_equal(res$unflatten(1), list(rep = 1, outer = 1, inner = NA_integer_))
  expect_equal(res$unflatten(2), list(rep = 1, outer = 2, inner = NA_integer_))
  expect_equal(res$unflatten(11), list(rep = 1, outer = 1, inner = 1))
  expect_equal(res$unflatten(12), list(rep = 1, outer = 1, inner = 2))
  expect_equal(res$unflatten(12), list(rep = 1, outer = 1, inner = 2))
  expect_equal(res$unflatten(101), list(rep = 2, outer = 1, inner = NA_integer_))
  expect_equal(res$unflatten(137), list(rep = 2, outer = 3, inner = 9))
  expect_equal(res$unflatten(300), list(rep = 3, outer = 10, inner = 9))

  train_sets = lapply(seq_len(res$iters), function(x) res$train_set(x))
  test_sets = lapply(seq_len(res$iters), function(x) res$test_set(x))
  assert_true(sum(duplicated(lapply(1:300, function(i) c(train_sets[i], test_sets[i])))) == 0)
  lengths(train_sets)
  assert_true(all(lengths(train_sets) %in% c(135, 120)))
  assert_true(all(lengths(test_sets) == 15))

  x = which(map_lgl(train_sets, function(set) isTRUE(all.equal(set,  train_sets[[20]]))))

  length(unique(train_sets))
  test_sets = lapply(seq_len(res$iters), function(x) res$test_set(x))


  rr = resample(task, lrn("classif.debug"), res)
  expect_class(rr, "ResampleResult")

  # All observations appear in the same number of splits
  # Also each train sample is in rep * (folds - 1)^2 splits, because
  # 1. If it is in the outer test set (1) then it will never bee in one of the train sets.
  # If it is in the outer train set (folds - 1), then it will be in (folds - 1 - 1) inner train sets, because it is
  # once in the inner test set.
  # --> (folds - 1) + (folds - 1) * (folds - 1)
  # in (folds - 1) outer folds in (folds - 2) inner folds and
  ttrain = table(unlist(train_sets))
  expect_true(length(unique(ttrain)) == 1 & unique(ttrain) == 3 * (10 - 1)^2)

  # Each observation is once in the outer test set: 1
  # In each inner loop it is once in the test set: (folds - 1)
  # Total appearances: folds
  ttest = table(unlist(test_sets))
  expect_true(length(unique(ttest)) == 1 & unique(ttest) == 3 * 10)

  all_disjoint = Reduce(`&&`, Map(function(x, y) length(intersect(x, y)) == 0, x = ttest, y = ttrain))
  expect_true(all_disjoint)

  # iter_info is correct

  for (i in seq_len(res$iters)) {
    info = res$unflatten(i)
    if (is.na(info$inner)) {
      expect_true((length(res$test_set(i)) + length(res$train_set(i))) == task$nrow)
    } else {
      expect_true((length(res$test_set(i)) + length(res$train_set(i))) < task$nrow)
    }
  }
})

test_that("stratification works",{
  withr::local_seed(2)
  task = tsk("iris")$filter(c(1:30, 51:80))$droplevels()
  task$col_roles$stratum = "Species"
  r = rsmp("nested_cv", folds = 3, repeats = 1)
  r$instantiate(task)
  walk(seq_len(r$iters), function(i) {
    expect_disjunct(r$train_set(i), r$test_set(i))
    expect_equal(length(unique(table(task$data(r$test_set(i), "Species")$Species))), 1)
    expect_equal(length(unique(table(task$data(r$train_set(i), "Species")$Species))), 1)
  })
})

test_that("primary iters", {
  task = tsk("iris")$filter(c(1:30, 51:80))$droplevels()
  task$col_roles$stratum = "Species"
  r = rsmp("nested_cv", folds = 3, repeats = 1)
  r$instantiate(task)
  expect_equal(r$primary_iters, 1:3)
  r$param_set$set_values(
    folds = 4L, repeats = 1
  )
  r$instantiate(task)
  expect_equal(r$primary_iters, 1:4)
  r$param_set$set_values(
    folds = 4L, repeats = 2
  )
  r$instantiate(task)
  expect_equal(r$primary_iters, c(1:4, 17:20))
})
