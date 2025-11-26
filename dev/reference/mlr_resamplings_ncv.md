# Nested Cross-Validation

This implements the Nested CV resampling procedure by Bates et al.
(2024).

## Point Estimation

When calling `$aggregate()` on a resample result obtained using this
resampling method, only the outer resampling iterations will be used, as
they have a smaller bias. See section "Point Estimation" of
[`MeasureCiNestedCV`](https://mlr3inferr.mlr-org.com/dev/reference/mlr_measures_ci.ncv.md).

## Parameters

- `folds` :: `integer(1)`  
  The number of folds. This is initialized to `5`.

- `repeats` :: `integer(1)`  
  The number of repetitions. THis is initialized to `10`.

## References

Bates, Stephen, Hastie, Trevor, Tibshirani, Robert (2024).
“Cross-validation: what does it estimate and how well does it do it?”
*Journal of the American Statistical Association*, **119**(546),
1434–1445.

## Super class

[`mlr3::Resampling`](https://mlr3.mlr-org.com/reference/Resampling.html)
-\> `ResamplingNestedCV`

## Active bindings

- `iters`:

  (`integer(1)`)  
  The total number of resampling iterations.

## Methods

### Public methods

- [`ResamplingNestedCV$new()`](#method-ResamplingNestedCV-new)

- [`ResamplingNestedCV$unflatten()`](#method-ResamplingNestedCV-unflatten)

- [`ResamplingNestedCV$clone()`](#method-ResamplingNestedCV-clone)

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

    ResamplingNestedCV$new()

------------------------------------------------------------------------

### Method `unflatten()`

Convert a resampling iteration to a more useful representation. For
outer resampling iterations, `inner` is `NA`.

#### Usage

    ResamplingNestedCV$unflatten(iter)

#### Arguments

- `iter`:

  (`integer(1)`)  
  The iteration.

#### Returns

`list(rep, outer, inner)`

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    ResamplingNestedCV$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
ncv = rsmp("ncv", folds = 3, repeats = 10L)
ncv
#> 
#> ── <ResamplingNestedCV> : Nested CV ────────────────────────────────────────────
#> • Iterations: 90
#> • Instantiated: FALSE
#> • Parameters: folds=3, repeats=10
rr = resample(tsk("mtcars"), lrn("regr.featureless"), ncv)
```
