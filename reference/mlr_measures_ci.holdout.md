# Holdout CI

Standard holdout CI. This inference method can only be applied to
decomposable losses.

## Parameters

Only those from
[`MeasureAbstractCi`](https://mlr3inferr.mlr-org.com/reference/mlr_measures_abstract_ci.md).

## Super classes

[`mlr3::Measure`](https://mlr3.mlr-org.com/reference/Measure.html) -\>
[`mlr3inferr::MeasureAbstractCi`](https://mlr3inferr.mlr-org.com/reference/mlr_measures_abstract_ci.md)
-\> `MeasureCiHoldout`

## Methods

### Public methods

- [`MeasureCiHoldout$new()`](#method-MeasureCiHoldout-new)

- [`MeasureCiHoldout$clone()`](#method-MeasureCiHoldout-clone)

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

    MeasureCiHoldout$new(measure)

#### Arguments

- `measure`:

  ([`Measure`](https://mlr3.mlr-org.com/reference/Measure.html) or
  `character(1)`)  
  A measure of ID of a measure.

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    MeasureCiHoldout$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
ci_ho = msr("ci.holdout", "classif.acc")
ci_ho
#> 
#> ── <MeasureCiHoldout> (classif.acc): Holdout Interval ──────────────────────────
#> • Packages: mlr3, mlr3measures, and mlr3inferr
#> • Range: [0, 1]
#> • Minimize: FALSE
#> • Average: custom
#> • Parameters: alpha=0.05, within_range=TRUE
#> • Properties: primary_iters
#> • Predict type: response
#> • Predict sets: test
#> • Aggregator: mean()
rr = resample(tsk("sonar"), lrn("classif.featureless"), rsmp("holdout"))
rr$aggregate(ci_ho)
#>       classif.acc classif.acc.lower classif.acc.upper 
#>         0.5217391         0.4030112         0.6404670 
```
