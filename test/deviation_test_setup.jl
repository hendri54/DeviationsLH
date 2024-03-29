## -----------  Make deviations for testing
# Names are :d1 etc

mdl = DeviationsLH;

function make_test_matrix_deviation(devNo :: Integer; 
        offset :: Float64 = 0.0,
        scaling = make_scaling_none())
    sizeV = (5, 4);
    modelV = devNo .+ (1 : sizeV[1]) .+ (1 : sizeV[2])' .+ 0.1 .+ offset;
    idxV = [2:4, 2:3];
    dataV = modelV[idxV...] .+ 0.7;
    wtV = dataV .+ 0.9;
    name, shortStr, longStr, fmtStr = mdl.test_dev_info(devNo);
    d = Deviation{Float64}(; name, modelV, dataV, wtV,
        idxV, scaling,  shortStr, longStr,
        auxData = mdl.make_test_aux_data());
    return d;
end

function make_test_deviation(devNo :: Integer; 
        offset :: Float64 = 0.0,
        scaling = make_scaling_none())
    dataV = devNo .+ collect(range(2.1, 3.4, length = 5));
    modelV = dataV .+ 0.7 .+ offset;
    wtV = dataV .+ 0.9;
    name, shortStr, longStr, fmtStr = mdl.test_dev_info(devNo);
    d = Deviation{Float64}(; name, modelV, dataV, wtV,
        scaling, shortStr, longStr,
        auxData = mdl.make_test_aux_data());
    return d;
end

function make_test_bounds_deviation(devNo :: Integer, insideBounds :: Bool)
    modelM = collect(1 : 5) .+ collect(2 : 4)' .+ 0.5;
    lbM = modelM .- 0.1;
    ubM = modelM .+ 0.1;
    wtM = modelM .+ 1.3;
    if !insideBounds
        modelM[3] = ubM[3] + 0.01;
    end

    name, shortStr, longStr, fmtStr = mdl.test_dev_info(devNo);
    d = BoundsDeviation{Float64}(;
        name,  modelV = modelM,  lbV = lbM,  ubV = ubM,
        wtV = wtM,  shortStr, longStr, fmtStr, 
        auxData = mdl.make_test_aux_data());
    return d;
end

function make_test_penalty_deviation(devNo :: Integer)
    modelM = collect(1 : 5) .+ collect(2 : 4)' .+ 0.5;
    name, shortStr, longStr, fmtStr = mdl.test_dev_info(devNo);
    d = PenaltyDeviation{Float64}(; name = name,  modelV = modelM,  
        scalarDevFct = penalty_dev_fct,
        shortStr, longStr,
        auxData = mdl.make_test_aux_data());
    return d;

end

function penalty_dev_fct(modelM)
    return sum(modelM) .- 3.0
end


# Make regression deviation for testing.
# No of regressors = devNo + 1
function make_test_regression_deviation(devNo :: Integer)
    name, shortStr, longStr, fmtStr = mdl.test_dev_info(devNo);
    nc = devNo + 2;
    coeffNameV = Symbol.("beta" .* string.(1 : nc));
    mCoeffV = collect(range(0.1, 0.9, length = nc));
    mSeV = collect(range(0.3, 0.1, length = nc));
    rModel = RegressionTable(coeffNameV, mCoeffV, mSeV);
    rData = RegressionTable(coeffNameV, mCoeffV .+ 0.1, mSeV .+ 0.2);
    scaling = make_scaling_none();
    return RegressionDeviation{Float64}(; name,
        shortStr, longStr, modelV = rModel, dataV = rData, scaling,
        auxData = mdl.make_test_aux_data())
end



function make_test_deviation_vector(n :: Integer; offset :: Float64 = 0.0)
    dv = DevVector();
    for j = 1 : n
        d = make_test_matrix_deviation(j; offset = offset + 0.2 * j);
        append!(dv, d);
    end
    return dv
end

# ---------------