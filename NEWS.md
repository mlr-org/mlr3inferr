# 0.2.1

* Compatibility with upcoming `mlr3` release.


# 0.2.0

## Bugfixes

* Calling `$aggregate()` on a resample result using a `ResamplingPairedSubsampling` now gives correct point estimates.

## Features

* Improve README to warn of possible differences between point estimates from inference methods to point estimates from applying the measure directly.
* Improved the documentation of various inference methods w.r.t.
  the point estimation.

## Other

* Deprecated id `"nested_cv"` in favour of `"ncv"` for nested resampling
procedure.

# 0.1.0

* Initial release.
