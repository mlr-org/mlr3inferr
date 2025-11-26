# Abstract Class for Confidence Intervals

Base class for confidence interval measures. See section *Inheriting* on
how to add a new method.

## Details

The aggregator of the wrapped measure is ignored, as the inheriting CI
dictates how the point estimate is constructed. If a measure for which
to calculate a CI has `$obs_loss` but also a `$trafo`, (such as RMSE),
the delta method is used to obtain confidence intervals.

## Parameters

- `alpha` :: `numeric(1)`  
  The desired alpha level. This is initialized to \$0.05\$.

- `within_range` :: `logical(1)`  
  Whether to restrict the confidence interval within the range of
  possible values. This is initialized to `TRUE`.

## Inheriting

To define a new CI method, inherit from the abstract base class and
implement the private method:
`ci: function(tbl: data.table, rr: ResampleResult, param_vals: named `list()`) -> numeric(3)`
If `requires_obs_loss` is set to `TRUE`, `tbl` contains the columns
`loss`, `row_id` and `iteration`, which are the pointwise loss,
Otherwise, `tbl` contains the result of `rr$score()` with the name of
the loss column set to `"loss"`. the identifier of the observation and
the resampling iteration. It should return a vector containing the
`estimate`, `lower` and `upper` boundary in that order.

In case the confidence interval is not of the form
`(estimate, estimate - z * se, estimate + z * se)` it is also necessary
to implement the private method:
`.trafo: function(ci: numeric(3), measure: Measure) -> numeric(3)` Which
receives a confidence interval for a pointwise loss (e.g. squared-error)
and transforms it according to the transformation `measure$trafo` (e.g.
sqrt to go from mse to rmse).

## Super class

[`mlr3::Measure`](https://mlr3.mlr-org.com/reference/Measure.html) -\>
`MeasureAbstractCi`

## Public fields

- `resamplings`:

  ([`character()`](https://rdrr.io/r/base/character.html))  
  On which resampling classes this method can operate.

- `measure`:

  ([`Measure`](https://mlr3.mlr-org.com/reference/Measure.html))  

## Methods

### Public methods

- [`MeasureAbstractCi$new()`](#method-MeasureAbstractCi-new)

- [`MeasureAbstractCi$aggregate()`](#method-MeasureAbstractCi-aggregate)

- [`MeasureAbstractCi$clone()`](#method-MeasureAbstractCi-clone)

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

    MeasureAbstractCi$new(
      measure = NULL,
      param_set = ps(),
      packages = character(),
      resamplings,
      label,
      delta_method = FALSE,
      requires_obs_loss = TRUE,
      man = NA
    )

#### Arguments

- `measure`:

  ([`Measure`](https://mlr3.mlr-org.com/reference/Measure.html))  
  The measure for which to calculate a confidence interval. Must have
  `$obs_loss`.

- `param_set`:

  ([`ParamSet`](https://paradox.mlr-org.com/reference/ParamSet.html))  
  Set of hyperparameters.

- `packages`:

  ([`character()`](https://rdrr.io/r/base/character.html))  
  Set of required packages. A warning is signaled by the constructor if
  at least one of the packages is not installed, but loaded (not
  attached) later on-demand via
  [`requireNamespace()`](https://rdrr.io/r/base/ns-load.html).

- `resamplings`:

  ([`character()`](https://rdrr.io/r/base/character.html))  
  To which resampling classes this measure can be applied.

- `label`:

  (`character(1)`)  
  Label for the new instance.

- `delta_method`:

  (`logical(1)`)  
  Whether to use the delta method for measures (such RMSE) that have a
  trafo.

- `requires_obs_loss`:

  (`logical(1)`)  
  Whether the inference method requires a pointwise loss function.

- `man`:

  (`character(1)`)  
  Manual page.

------------------------------------------------------------------------

### Method [`aggregate()`](https://rdrr.io/r/stats/aggregate.html)

Obtain a point estimate, as well as lower and upper CI boundary.

#### Usage

    MeasureAbstractCi$aggregate(rr)

#### Arguments

- `rr`:

  ([`ResampleResult`](https://mlr3.mlr-org.com/reference/ResampleResult.html))  
  The resample result.

#### Returns

named `numeric(3)`

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    MeasureAbstractCi$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
