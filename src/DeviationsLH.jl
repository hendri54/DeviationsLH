module DeviationsLH

using ArgCheck, DocStringExtensions, Formatting, PrettyTables
using CommonLH, EconometricsLH, ModelObjectsLH

# Types
export AbstractDeviation, ScalarDeviation, Deviation, RegressionDeviation, BoundsDeviation, PenaltyDeviation;
export AbstractScaling, ScalingNone, ScalingRelative, ScalingLinear, ScalingLog;
export make_scaling_none, make_scaling_linear, make_scaling_relative, make_scaling_log;
# Type methods
export get_data_values, get_unpacked_data_values, get_model_values, get_unpacked_model_values, get_weights, get_std_errors, get_aux_data;
export set_model_values, set_weights!;
export validate_deviation;
# Scalar deviations
export scalar_dev, scalar_devs, scalar_dev_dict, is_scalar_deviation;
# Display
export short_display, show_deviation, long_description, short_description;
export scalar_deviation_table;
# Regression deviation
export exclude_regressors!, is_excluded;
# Deviation vectors
export DevVector, dev_exists, retrieve, scalar_deviation, scalar_devs, show_deviations;

# ChangeTable
export ChangeTable, set_param_values!, show_table;


include("helpers.jl");
include("scaling_types.jl");
include("deviation_types.jl");

include("scaling.jl");
include("deviation.jl");
include("regression_deviation.jl");
include("scalar_deviation.jl");
include("matrix_deviation.jl");
include("bounds_deviation.jl");
include("penalty_deviation.jl");
include("devvector.jl");
include("change_table.jl");

end # module
