# DeviationsLH

A package to keep track of deviations between data moments and model moments. This is meant to be used when calibrating economic models.


## Data moments and deviations

The [`AbstractDevation`](@ref) object is designed to keep track of target moments for the calibration. It also stores the corresponding model moments and can therefore compute and display measures of model fit.

There are several types of `AbstractDeviation`s:

1. [`Deviation`](@ref) is the default type. It holds `Array`s of `AbstractFloats`s of any dimension.
2. [`ScalarDeviation`](@ref) holds scalar moments.
3. [`RegressionDeviation`](@ref) handles the case where the target moments are represented by regression coefficients and their standard errors.
4. [`BoundsDeviation`](@ref)s are zero until the model values get out of bounds. These are useful for preventing numerical optimizers from trying "crazy" parameter values.

[`scalar_dev`](@ref) computes a scalar deviation from model and data values (weighted). 

```@docs
AbstractDeviation
Deviation
ScalarDeviation
RegressionDeviation
BoundsDeviation
scalar_dev
```

## Scaling Deviations

A common approach is to use the sum of squared deviations between model and data, perhaps weighted by inverse standard errors. This does not work well for data moments that are either small (e.g. percentiles) or span a wide range (e.g. percentiles).

Example: `d = 0.1; m = 0.2; dev = 0.01` versus `d = 0.0, m = 1.0; dev = 100`.

One option: map data into range `[1, 2]`. `dHat = f(d) in [1, 2]`. `mHat = f(m)`. 
Deviation `d = abs(dHat - mHat) ^ p`.

Another option: `abs(d - m) ^ p`.

In general: Scaling is defined by `f` and `p`.

- absolute deviation: `f(d) = d` and `p = 1`
- squared deviation: `f(d) = d` and `p = 2`

## [`ChangeTable`](@ref)

This is an object that can keep track of which model parameters affect which deviations.

The user initializes the table with the constructor. Then they solve the model perturbing one parameter at a time. `ChangeTable` produces a formatted table that shows the effect of each parameter on each deviation.


```@docs
ChangeTable
```

# Change Log

2024-July-9 (v1.4)
Replaced Formatting.jl
2024-Feb-1
Added `is_bounds_deviation`.
2023-Aug-24
Option to skip small deviations in deviation display.
2023-Aug-22
Aux data in all deviations.
2023-July-17
Using long description in scalar_deviation_table
2023-Jan-30
Added `ScalingLog`.
2023-Jan-27 (v2.0)
Added `AbstractScaling`. Removed `normP`.

-------------