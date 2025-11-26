# Nested CV CI

Confidence Intervals based on
[`ResamplingNestedCV`](https://mlr3inferr.mlr-org.com/dev/reference/mlr_resamplings_ncv.md),
including bias-correction. This inference method can only be applied to
decomposable losses.

## Point Estimation

The point estimate uses a bias correction term as described in Bates et
al. (2024). Therefore, the results of directly applying a measure
`$aggregate(msr(<key>))` will be different from the point estimate of
`$aggregate(msr("ci", <key>))`, where the point estimate is obtained by
averaging over the outer CV results.

## Parameters

Those from
[`MeasureAbstractCi`](https://mlr3inferr.mlr-org.com/dev/reference/mlr_measures_abstract_ci.md),
as well as:

- `bias` :: `logical(1)`  
  Whether to do bias correction. This is initialized to `TRUE`. If
  `FALSE`, the outer iterations are used for the point estimate and no
  bias correction is applied.

## References

Bates, Stephen, Hastie, Trevor, Tibshirani, Robert (2024).
“Cross-validation: what does it estimate and how well does it do it?”
*Journal of the American Statistical Association*, **119**(546),
1434–1445.

## Super classes

[`mlr3::Measure`](https://mlr3.mlr-org.com/reference/Measure.html) -\>
[`mlr3inferr::MeasureAbstractCi`](https://mlr3inferr.mlr-org.com/dev/reference/mlr_measures_abstract_ci.md)
-\> `MeasureCiNestedCV`

## Methods

### Public methods

- [`MeasureCiNestedCV$new()`](#method-MeasureCiNestedCV-new)

- [`MeasureCiNestedCV$clone()`](#method-MeasureCiNestedCV-clone)

Inherited methods

- [`mlr3::Measure$format()`](https://mlr3.mlr-org.com/reference/Measure.html#method-format)
- [`mlr3::Measure$help()`](https://mlr3.mlr-org.com/reference/Measure.html#method-help)
- [`mlr3::Measure$print()`](https://mlr3.mlr-org.com/reference/Measure.html#method-print)
- [`mlr3::Measure$score()`](https://mlr3.mlr-org.com/reference/Measure.html#method-score)
- [`mlr3inferr::MeasureAbstractCi$aggregate()`](https://mlr3inferr.mlr-org.com/dev/reference/MeasureAbstractCi.html#method-aggregate)

------------------------------------------------------------------------

### Method `new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    MeasureCiNestedCV$new(measure)

#### Arguments

- `measure`:

  ([`Measure`](https://mlr3.mlr-org.com/reference/Measure.html) or
  `character(1)`)  
  A measure of ID of a measure.

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    MeasureCiNestedCV$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
ci_ncv = msr("ci.ncv", "classif.acc")
ci_ncv
#> 
#> ── <MeasureCiNestedCV> (classif.acc): Nested CV Interval ───────────────────────
#> • Packages: mlr3, mlr3measures, and mlr3inferr
#> • Range: [0, 1]
#> • Minimize: FALSE
#> • Average: custom
#> • Parameters: bias=TRUE, alpha=0.05, within_range=TRUE
#> • Properties: primary_iters
#> • Predict type: response
#> • Predict sets: test
#> • Aggregator: mean()
```
