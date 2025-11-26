# Conservative-Z CI

The conservative-z confidence intervals based on the
[`ResamplingPairedSubsampling`](https://mlr3inferr.mlr-org.com/reference/mlr_resamplings_paired_subsampling.md).
Because the variance estimate is obtained using only `n / 2`
observations, it tends to be conservative. This inference method can
also be applied to non-decomposable losses.

## Point Estimation

For the point estimation, only the first `repeats_out` resampling
iterations will be used, as the other resampling iterations are only
used to estimate the variance. This is respected when calling
`$aggregate()` using a standard (non-CI) measure.

## Parameters

Only those from
[`MeasureAbstractCi`](https://mlr3inferr.mlr-org.com/reference/mlr_measures_abstract_ci.md).

## References

Nadeau, Claude, Bengio, Yoshua (1999). “Inference for the generalization
error.” *Advances in neural information processing systems*, **12**.

## Super classes

[`mlr3::Measure`](https://mlr3.mlr-org.com/reference/Measure.html) -\>
[`mlr3inferr::MeasureAbstractCi`](https://mlr3inferr.mlr-org.com/reference/mlr_measures_abstract_ci.md)
-\> `MeasureCiConZ`

## Methods

### Public methods

- [`MeasureCiConZ$new()`](#method-MeasureCiConZ-new)

- [`MeasureCiConZ$clone()`](#method-MeasureCiConZ-clone)

Inherited methods

- [`mlr3::Measure$format()`](https://mlr3.mlr-org.com/reference/Measure.html#method-format)
- [`mlr3::Measure$help()`](https://mlr3.mlr-org.com/reference/Measure.html#method-help)
- [`mlr3::Measure$print()`](https://mlr3.mlr-org.com/reference/Measure.html#method-print)
- [`mlr3::Measure$score()`](https://mlr3.mlr-org.com/reference/Measure.html#method-score)
- [`mlr3inferr::MeasureAbstractCi$aggregate()`](https://mlr3inferr.mlr-org.com/reference/MeasureAbstractCi.html#method-aggregate)

------------------------------------------------------------------------

### Method `new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    MeasureCiConZ$new(measure)

#### Arguments

- `measure`:

  ([`Measure`](https://mlr3.mlr-org.com/reference/Measure.html) or
  `character(1)`)  
  A measure of ID of a measure.

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    MeasureCiConZ$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
ci_conz = msr("ci.con_z", "classif.acc")
ci_conz
#> 
#> ── <MeasureCiConZ> (classif.acc): Conservative-Z Interval ──────────────────────
#> • Packages: mlr3, mlr3measures, and mlr3inferr
#> • Range: [0, 1]
#> • Minimize: FALSE
#> • Average: custom
#> • Parameters: alpha=0.05, within_range=TRUE
#> • Properties: primary_iters
#> • Predict type: response
#> • Predict sets: test
#> • Aggregator: mean()
```
