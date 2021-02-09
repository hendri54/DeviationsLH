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

## [`ChangeTable`](@ref)

This is an object that can keep track of which model parameters affect which deviations.

The user initializes the table with the constructor. Then they solve the model perturbing one parameter at a time. `ChangeTable` produces a formatted table that shows the effect of each parameter on each deviation.


```@docs
ChangeTable
```

-------------