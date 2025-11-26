# Paired Subsampling

Paired Subsampling to enable inference on the generalization error.

## Details

The first `repeats_in` iterations are a standard
[`ResamplingSubsampling`](https://mlr3.mlr-org.com/reference/mlr_resamplings_subsampling.html)
and should be used to obtain a point estimate of the generalization
error. The remaining iterations should be used to estimate the standard
error. Here, the data is divided `repeats_out` times into two equally
sized disjunct subsets, to each of which subsampling which, a
subsampling with `repeats_in` repetitions is applied. See the
`$unflatten(iter)` method to map the iterations to this nested
structure.

## Point Estimation

When calling `$aggregate()` on a resample result obtained using this
resampling method, only the first `repeats_out` iterations will be used.
See section "Point Estimation" of
[`MeasureCiConZ`](https://mlr3inferr.mlr-org.com/reference/mlr_measures_ci.con_z.md).

## Parameters

- `repeats_in` :: `integer(1)`  
  The inner repetitions.

- `repeats_out` :: `integer(1)`  
  The outer repetitions.

- `ratio` :: `numeric(1)`  
  The proportion of data to use for training.

## References

Nadeau, Claude, Bengio, Yoshua (1999). “Inference for the generalization
error.” *Advances in neural information processing systems*, **12**.

## Super class

[`mlr3::Resampling`](https://mlr3.mlr-org.com/reference/Resampling.html)
-\> `ResamplingPairedSubsampling`

## Active bindings

- `iters`:

  (`integer(1)`)  
  The total number of resampling iterations.

## Methods

### Public methods

- [`ResamplingPairedSubsampling$new()`](#method-ResamplingPairedSubsampling-new)

- [`ResamplingPairedSubsampling$unflatten()`](#method-ResamplingPairedSubsampling-unflatten)

- [`ResamplingPairedSubsampling$clone()`](#method-ResamplingPairedSubsampling-clone)

Inherited methods

- [`mlr3::Resampling$format()`](https://mlr3.mlr-org.com/reference/Resampling.html#method-format)
- [`mlr3::Resampling$help()`](https://mlr3.mlr-org.com/reference/Resampling.html#method-help)
- [`mlr3::Resampling$instantiate()`](https://mlr3.mlr-org.com/reference/Resampling.html#method-instantiate)
- [`mlr3::Resampling$print()`](https://mlr3.mlr-org.com/reference/Resampling.html#method-print)
- [`mlr3::Resampling$test_set()`](https://mlr3.mlr-org.com/reference/Resampling.html#method-test_set)
- [`mlr3::Resampling$train_set()`](https://mlr3.mlr-org.com/reference/Resampling.html#method-train_set)

------------------------------------------------------------------------

### Method `new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    ResamplingPairedSubsampling$new()

------------------------------------------------------------------------

### Method `unflatten()`

Unflatten the resampling iteration into a more informative
representation:

- `inner`: The subsampling iteration

- `outer`: `NA` for the first `repeats_in` iterations. Otherwise it
  indicates the outer iteration of the paired subsamplings.

- `partition`: `NA` for the first `repeats_in` iterations. Otherwise it
  indicates whether the subsampling is applied to the first or second
  partition Of the two disjoint halfs.

#### Usage

    ResamplingPairedSubsampling$unflatten(iter)

#### Arguments

- `iter`:

  (`integer(1)`)  
  Resampling iteration.

#### Returns

`list(outer, partition, inner)`

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    ResamplingPairedSubsampling$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
pw_subs = rsmp("paired_subsampling")
pw_subs
#> 
#> ── <ResamplingPairedSubsampling> : Paired Subsampling ──────────────────────────
#> • Iterations: 315
#> • Instantiated: FALSE
#> • Parameters: repeats_in=15, repeats_out=10, ratio=0.9
```
