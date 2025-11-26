# Cross-Validation CI

Confidence intervals for cross-validation. The method is asymptotically
exact for the so called *Test Error* as defined by Bayle et al. (2020).
For the (expected) risk, the confidence intervals tend to be too
liberal. This inference method can only be applied to decomposable
losses.

## Parameters

Those from
[`MeasureAbstractCi`](https://mlr3inferr.mlr-org.com/reference/mlr_measures_abstract_ci.md),
as well as:

- `variance` :: `"all-pairs"` or `"within-fold"`  
  How to estimate the variance. The results tend to be very similar.

## References

Bayle, Pierre, Bayle, Alexandre, Janson, Lucas, Mackey, Lester (2020).
“Cross-validation confidence intervals for test error.” *Advances in
Neural Information Processing Systems*, **33**, 16339–16350.

## Super classes

[`mlr3::Measure`](https://mlr3.mlr-org.com/reference/Measure.html) -\>
[`mlr3inferr::MeasureAbstractCi`](https://mlr3inferr.mlr-org.com/reference/mlr_measures_abstract_ci.md)
-\> `MeasureCiWaldCV`

## Methods

### Public methods

- [`MeasureCiWaldCV$new()`](#method-MeasureCiWaldCV-new)

- [`MeasureCiWaldCV$clone()`](#method-MeasureCiWaldCV-clone)

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

    MeasureCiWaldCV$new(measure)

#### Arguments

- `measure`:

  ([`Measure`](https://mlr3.mlr-org.com/reference/Measure.html) or
  `character(1)`)  
  A measure of ID of a measure.

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    MeasureCiWaldCV$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
m_waldcv = msr("ci.wald_cv", "classif.ce")
m_waldcv
#> 
#> ── <MeasureCiWaldCV> (classif.ce): Wald CV Interval ────────────────────────────
#> • Packages: mlr3, mlr3measures, and mlr3inferr
#> • Range: [0, 1]
#> • Minimize: TRUE
#> • Average: custom
#> • Parameters: variance=all-pairs, alpha=0.05, within_range=TRUE
#> • Properties: primary_iters
#> • Predict type: response
#> • Predict sets: test
#> • Aggregator: mean()
rr = resample(tsk("sonar"), lrn("classif.featureless"), rsmp("cv"))
rr$aggregate(m_waldcv)
#>       classif.ce classif.ce.lower classif.ce.upper 
#>        0.4663462        0.3985507        0.5341416 
```
