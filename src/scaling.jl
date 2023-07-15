## ----------  Generic

"""
	$(SIGNATURES)

Compute the scalar deviation between model and data values. 
"""
function scalar_deviation(d :: AbstractDeviation, modelV)
    scalarDev = scalar_deviation(d.scaling, modelV, get_data_values(d), d.wtV);
    return scalarDev
end

function scalar_deviation(s :: AbstractScaling{F1}, 
        modelV :: AbstractArray{F1}, dataV :: AbstractArray{F1}, 
        wtV) where F1 <: AbstractFloat

    if wtV isa Number
        scalarWeight = true;
        totalWt = one(F1);
        wt = one(F1) / length(modelV);
    else
        scalarWeight = false;
        totalWt = sum(wtV);
        wt = zero(F1);
    end
    @argcheck totalWt > 1e-8  "Total weight too small: $totalWt";
    @argcheck !any(isnan.(modelV))  "Model: $modelV";

    scalarDev = zero(F1);
    for j in eachindex(modelV)
        scalarWeight  ||  (wt = wtV[j] / totalWt);
        scalarDev += wt * scale(s, dataV[j], modelV[j]);
    end

    @argcheck (scalarDev >= 0.0)  "Scalar dev not positive: $scalarDev";
    return scalarDev
end

function scalar_deviation(s :: AbstractScaling{F1}, model :: F1, data :: F1, 
        wt :: F1) where F1 <: AbstractFloat
    dev = scale(s, model, data)
    return dev
end


## ----------  No scaling

make_scaling_none() = ScalingNone(1.0);

scale(s :: ScalingNone, m, d) = abs.(d .- m) .^ s.p;

## -----------  Linear

make_scaling_linear(f0, f1, p) = ScalingLinear(f0, f1, p);
scale(s :: ScalingLinear, m, d) = ((s.f0 .+ s.slope .* abs.(d .- m)) .^ s.p)  .- s.f0;

## ------------  Relative

make_scaling_relative(scl, p) = ScalingRelative(scl, p);
scale(s :: ScalingRelative, m, d) = abs.((d .- m) ./ s.scale) .^ s.p;

## ----------  Log

make_scaling_log(f0) = ScalingLog(f0);
function scale(s :: ScalingLog, m, d)
    @assert all_at_least(m, -s.f0 + 1e-8)  "Model values too low: $m";
    @assert all_at_least(d, -s.f0 + 1e-8)  "Data values too low: $d";
    abs.(log.(s.f0 .+ m) .- log.(s.f0 .+ d));
end

# --------------