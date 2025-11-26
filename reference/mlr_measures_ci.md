# Default CI Method

For certain resampling methods, there are default confidence interval
methods. See `mlr3::mlr_reflections$default_ci_methods` for a selection.
This measure will select the appropriate CI method depending on the
class of the used
[`Resampling`](https://mlr3.mlr-org.com/reference/Resampling.html).

## Parameters

Only those from
[`MeasureAbstractCi`](https://mlr3inferr.mlr-org.com/reference/mlr_measures_abstract_ci.md).

## Super classes

[`mlr3::Measure`](https://mlr3.mlr-org.com/reference/Measure.html) -\>
[`mlr3inferr::MeasureAbstractCi`](https://mlr3inferr.mlr-org.com/reference/mlr_measures_abstract_ci.md)
-\> `Measure`

## Methods

### Public methods

- [`MeasureCi$new()`](#method-Measure-new)

- [`MeasureCi$aggregate()`](#method-Measure-aggregate)

- [`MeasureCi$clone()`](#method-Measure-clone)

Inherited methods

- [`mlr3::Measure$format()`](https://mlr3.mlr-org.com/reference/Measure.html#method-format)
- [`mlr3::Measure$help()`](https://mlr3.mlr-org.com/reference/Measure.html#method-help)
- [`mlr3::Measure$print()`](https://mlr3.mlr-org.com/reference/Measure.html#method-print)
- [`mlr3::Measure$score()`](https://mlr3.mlr-org.com/reference/Measure.html#method-score)

------------------------------------------------------------------------

### Method `new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    MeasureCi$new(measure)

#### Arguments

- `measure`:

  ([`Measure`](https://mlr3.mlr-org.com/reference/Measure.html) or
  `character(1)`)  
  A measure of ID of a measure.

------------------------------------------------------------------------

### Method [`aggregate()`](https://rdrr.io/r/stats/aggregate.html)

Obtain a point estimate, as well as lower and upper CI boundary.

#### Usage

    MeasureCi$aggregate(rr)

#### Arguments

- `rr`:

  ([`ResampleResult`](https://mlr3.mlr-org.com/reference/ResampleResult.html))  
  Resample result.

#### Returns

named `numeric(3)`

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    MeasureCi$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
rr = resample(tsk("sonar"), lrn("classif.featureless"), rsmp("holdout"))
rr$aggregate(msr("ci", "classif.acc"))
#>       classif.acc classif.acc.lower classif.acc.upper 
#>         0.3913043         0.2753062         0.5073025 
# is the same as:
rr$aggregate(msr("ci.holdout", "classif.acc"))
#>       classif.acc classif.acc.lower classif.acc.upper 
#>         0.3913043         0.2753062         0.5073025 
```
