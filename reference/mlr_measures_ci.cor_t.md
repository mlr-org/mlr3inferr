# Corrected-T CI

Corrected-T confidence intervals based on
[`ResamplingSubsampling`](https://mlr3.mlr-org.com/reference/mlr_resamplings_subsampling.html).
A heuristic factor is applied to correct for the dependence between the
iterations. The confidence intervals tend to be liberal. This inference
method can also be applied to non-decomposable losses.

## Parameters

Only those from
[`MeasureAbstractCi`](https://mlr3inferr.mlr-org.com/reference/mlr_measures_abstract_ci.md).

## References

Nadeau, Claude, Bengio, Yoshua (1999). “Inference for the generalization
error.” *Advances in neural information processing systems*, **12**.

## Super classes

[`mlr3::Measure`](https://mlr3.mlr-org.com/reference/Measure.html) -\>
[`mlr3inferr::MeasureAbstractCi`](https://mlr3inferr.mlr-org.com/reference/mlr_measures_abstract_ci.md)
-\> `MeasureCiCorrectedT`

## Methods

### Public methods

- [`MeasureCiCorrectedT$new()`](#method-MeasureCiCorrectedT-new)

- [`MeasureCiCorrectedT$clone()`](#method-MeasureCiCorrectedT-clone)

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

    MeasureCiCorrectedT$new(measure)

#### Arguments

- `measure`:

  ([`Measure`](https://mlr3.mlr-org.com/reference/Measure.html) or
  `character(1)`)  
  A measure of ID of a measure.

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    MeasureCiCorrectedT$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
m_cort = msr("ci.cor_t", "classif.acc")
m_cort
#> 
#> ── <MeasureCiCorrectedT> (classif.acc): Corrected-T Interval ───────────────────
#> • Packages: mlr3, mlr3measures, and mlr3inferr
#> • Range: [0, 1]
#> • Minimize: FALSE
#> • Average: custom
#> • Parameters: alpha=0.05, within_range=TRUE
#> • Properties: primary_iters
#> • Predict type: response
#> • Predict sets: test
#> • Aggregator: mean()
rr = resample(
  tsk("sonar"),
  lrn("classif.featureless"),
  rsmp("subsampling", repeats = 10)
)
rr$aggregate(m_cort)
#>       classif.acc classif.acc.lower classif.acc.upper 
#>         0.4898551         0.3408775         0.6388327 
```
