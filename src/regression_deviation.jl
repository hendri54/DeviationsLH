function empty_regression_deviation(F1 = Float64)
    return RegressionDeviation{F1}(name = :empty)
end

"""
	$(SIGNATURES)

Set regressors to exclude from scalar deviation.
"""
exclude_regressors!(d :: RegressionDeviation{F1}, exclV) where F1 =
    d.excludeV = exclV;

is_excluded(d :: RegressionDeviation{F1}, name :: Symbol) where F1 = 
    name ∈ d.excludeV;

function drop_excluded(d :: RegressionDeviation{F1}, nameV) where F1
    if isempty(d.excludeV)
        outV = copy(nameV);
    else
        outV = filter(n -> !is_excluded(d, n), nameV);
    end
    return outV
end


"""
	$(SIGNATURES)

Returns vector of names, coefficients and std errors. Always sorted by name. Otherwise, the order is unpredictable.
"""
function get_unpacked_data_values(d :: RegressionDeviation{F1};
    dropExcluded :: Bool = false) where F1
    dataRt = get_data_values(d);
    nameV = sort(EconometricsLH.get_names(d.dataV));
    if dropExcluded
        nameV = drop_excluded(d, nameV);
    end
    coeffV, seV = get_coeff_se_multiple(d.dataV, nameV);
    return nameV, coeffV, seV
end


# Return coefficients and std errors in same order as for data
function get_unpacked_model_values(d :: RegressionDeviation{F1};
    dropExcluded :: Bool = false) where F1

    nameV = sort(EconometricsLH.get_names(d.modelV));
    if dropExcluded
        nameV = drop_excluded(d, nameV);
    end
    coeffV, seV = get_coeff_se_multiple(d.modelV, nameV);
    return nameV, coeffV, seV
end


"""
	$(SIGNATURES)

Set model values for a RegressionDeviation.

If model regression is missing regressors, the option of setting these regressors to 0 is provided (e.g. for dummies without occurrences).
"""
function set_model_values(d :: RegressionDeviation, modelV :: RegressionTable);
    # setMissingRegressors :: Bool = false)

    # if setMissingRegressors
    #     set_missing_regressors!(modelV, get_names(d.dataV));
    # end

    if !have_same_regressors([d.dataV, modelV])  
        rModelV = EconometricsLH.get_names(modelV);
        rDataV = EconometricsLH.get_names(d.dataV);
        error("""Regressors do not match: $d
            Model: $rModelV
            Data:  $rDataV""")
    end
    d.modelV = deepcopy(modelV);
    return nothing
end


function get_weights(d :: RegressionDeviation)
    return 1.0
end


# For RegressionDeviation: sum of (model - data) / se
# se2coeffLb governs the scaling of the std errors. s.e./beta >= se2coeffLb
# Excludes regressors if this is set in the `RegressionDeviation`.
function scalar_dev(d :: RegressionDeviation; se2coeffLb :: Float64 = 0.1,
    inclScalarWt :: Bool = true)
    nameV, coeffV, seV = get_unpacked_data_values(d; dropExcluded = true);
    mNameV, mCoeffV, _ = get_unpacked_model_values(d; dropExcluded = true);
    # Names and sort order must match
    @assert isequal(nameV, mNameV)  "Names do not match: \n $nameV \n $mNameV"

    seV = max.(seV, se2coeffLb .* abs.(coeffV));
    scalarDev = scalar_deviation(mCoeffV, coeffV, 1.0 ./ seV; p = norm_p(d));
    if inclScalarWt
        scalarDev *= d.scalarWt;
    end
    scalarStr = sprintf1(d.fmtStr, scalarDev);
    return scalarDev, scalarStr
end


"""
	$(SIGNATURES)

Show a RegressionDeviation
"""
function regression_show_fct(d :: RegressionDeviation; 
    showModel :: Bool = true, fPath :: String = "")

    nameV, coeffV, seV = get_unpacked_data_values(d);
    dataM = hcat(nameV, round.(coeffV, digits = 3), round.(seV, digits = 3));
    headerV = ["Regressor", "Data", "s.e."];

    if showModel
        _, mCoeffV, mSeV = get_unpacked_model_values(d);
        dataM = hcat(dataM,  round.(mCoeffV, digits = 3), round.(mSeV, digits = 3));
        headerV = vcat(headerV, ["Model", "s.e."])
    end

    io = open_show_path(d, fPath = fPath);
    pretty_table(io, dataM,  headerV);
    close_show_path(d, io);
end


Base.show(io :: IO, d :: RegressionDeviation{F1}) where F1 = 
    Base.print(io, "$(name(d)):  ", short_description(d));


# -----------------