module DeviationsLH

using ArgCheck, DocStringExtensions, Formatting, PrettyTables
using EconometricsLH, ModelObjectsLH

export AbstractDeviation, ScalarDeviation, Deviation, RegressionDeviation, BoundsDeviation, PenaltyDeviation
export get_data_values, get_unpacked_data_values, get_model_values, get_unpacked_model_values, get_weights, get_std_errors
export set_model_values, set_weights!
export scalar_dev, scalar_devs, scalar_dev_dict, short_display, show_deviation, validate_deviation, long_description, short_description
# Regression deviation
export exclude_regressors!, is_excluded
# Deviation vectors
export DevVector, dev_exists, retrieve, scalar_deviation, scalar_devs, show_deviations

# ChangeTable
export ChangeTable, set_param_values!, show_table


include("helpers.jl");
include("deviation_types.jl");
include("deviation.jl");
include("regression_deviation.jl");
include("scalar_deviation.jl");
include("matrix_deviation.jl");
include("bounds_deviation.jl");
include("penalty_deviation.jl");
include("devvector.jl");
include("change_table.jl");

end # module
