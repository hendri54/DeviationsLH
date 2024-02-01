## -----------------  Deviation vector

"""
    DevVector

Deviation vector
"""
mutable struct DevVector
    dv :: Vector{AbstractDeviation}
end



"""
    DevVector()

Constructs an empty deviation vector
"""
function DevVector()
    DevVector(Vector{AbstractDeviation}())
end

Base.isempty(d :: DevVector) = Base.isempty(d.dv);
Base.length(d :: DevVector) = Base.length(d.dv);
Base.getindex(d :: DevVector, j) = d.dv[j];

# Iteration
function Base.iterate(d :: DevVector, j) 
    if isempty(d)
        return nothing
    elseif j > length(d)
        return nothing
    else
        return d.dv[j], j+1
    end
end

Base.iterate(d :: DevVector) = Base.iterate(d, 1);


"""
    append!(d :: DevVector, dev :: Deviation)

Append a deviation.
"""
function Base.append!(d :: DevVector, dev :: AbstractDeviation)
    @assert !dev_exists(d, dev.name)  "Deviation $(dev.name) already exists"
    Base.push!(d.dv, dev)
end


"""
    $(SIGNATURES)
    
Set model values for one deviation in a `DevVector` specified by `name`
"""
function set_model_values(d :: DevVector, name :: Symbol, modelV)
    dev = retrieve(d, name);
    @assert !isempty(dev)
    set_model_values(dev, modelV);
    return nothing
end


"""
	$(SIGNATURES)

Get model values from a `DevVector`.
"""
function get_model_values(devV :: DevVector, mName :: Symbol)
    d = retrieve(devV, mName);
    return get_model_values(d)
end


"""
	$(SIGNATURES)

Get data values from a `DevVector`.
"""
function get_data_values(devV :: DevVector, mName :: Symbol)
    d = retrieve(devV, mName);
    return get_data_values(d)
end



"""
	set_weights!
"""
function set_weights!(d :: DevVector, name :: Symbol, wtV)
    dev = retrieve(d, name);
    @assert !isempty(dev)
    @assert size(wtV) == size(dev.dataV)  "Size mismatch: $(size(wtV)) vs $(size(dev.dataV))"
    set_weights!(dev, wtV);
    return nothing
end


"""
    retrieve

If not found: return empty Deviation
"""
function retrieve(d :: DevVector, dName :: Symbol)
    outDev = empty_deviation();

    n = length(d);
    if n > 0
        dIdx = 0;
        for i1 in 1 : n
            #println("$i1: $(d.dv[i1].name)")
            if d.dv[i1].name == dName
                dIdx = i1;
                break;
            end
            #println("  not found")
        end
        if dIdx > 0
            outDev = d.dv[dIdx];
        end
    end
    return outDev
end


function dev_exists(d :: DevVector, dName :: Symbol)
    return !isempty(retrieve(d, dName))
end

Base.show(io :: IO, d :: DevVector) = show_deviations(io, d);

"""
    $(SIGNATURES)

Show all deviations. Each gets a short display with name and scalar deviation.
Used during calibration.
If `scalar_dev(dev) < minDev` then the deviation is not shown.
"""
function show_deviations(io :: IO,  d :: DevVector; 
        sorted :: Bool = false, minDev = -1.0)
    if length(d) < 1
        println(io, "No deviations");
    else
        lineV = Vector{String}();
        for dev in d.dv
            if first(scalar_dev(dev)) > minDev
                dStr = short_display(dev);
                push!(lineV, dStr);
            end
        end
        if sorted
            lineV = sort(lineV);
        end
        stringWidth = min(20, maximum(length.(lineV)));
        show_string_vector(lineV, 80; io, stringWidth);
    end
end

show_deviations(d :: DevVector; kwargs...) = show_deviations(stdout, d; kwargs...);


"""
    $(SIGNATURES)

Write a table containing scalar deviations. Can be printed nicely using `PrettyTables`.
"""
function scalar_deviation_table(devV :: DevVector)
    headerV = ["Name", "Data", "Model", "Deviation"];
    tbM = Matrix{String}(undef, 0, 4);
    for dev in devV;
        if is_scalar_deviation(dev)
            data = round(only(get_data_values(dev)); digits = 2);
            model = round(only(get_model_values(dev)); digits = 2);
            stdError = get_std_errors(dev);
            if !isnothing(stdError)
                stdError = round(stdError, digits = 2);
                seStr = " ($stdError)";
            else
                seStr = "";
            end
            _, sDevStr = scalar_dev(dev);
            row = [string(long_description(dev))  "$(data)$(seStr)"  string(model)  sDevStr];
            tbM = vcat(tbM, row);
        end
    end
    return tbM, headerV
end

# function show_scalar_deviations(devV :: DevVector,  showModel :: Bool,  outDir :: String)
#     println("Showing scalar deviations model / data");
#     newPath = joinpath(outDir, "scalar_moments.txt");
#     open(newPath, "w") do io
#         # Header
#         write(io, "Moment  Data  Model \n");
#         # Write each moment (if scalar)
#         for dev in devV;
#             if is_scalar_deviation(dev)
#                 write(io, dev.name, @sprintf(" %.2f", get_data_values(dev)[1]));
#                 stdError = get_std_errors(dev);
#                 if !isnothing(stdError)
#                     stdError = round(stdError, digits = 2);
#                 end
#                 write(io,  " (s.e.  $stdError)")
#                 if showModel
#                     write(io, "  model", @sprintf(" %.2f", get_model_values(dev)[1]));
#                     write(io, "  dev: ",  scalar_dev_string(dev));
#                 end
#                 write(io, "\n");
#             end
#         end
#     end
#     return nothing
# end


"""
	$(SIGNATURES)

Return vector of scalar deviations.

Returns empty vector if `DevVector` is empty.
"""
function scalar_devs(d :: DevVector; inclScalarWt :: Bool = true)
    sds = scalar_dev_dict(d; inclScalarWt = inclScalarWt);
    return collect(values(sds));
end


"""
	$(SIGNATURES)

Make a `Dict{Symbol, DevType}` that maps deviation names into scalar deviations.
Useful for saving to disk.
"""
function scalar_dev_dict(d :: DevVector; inclScalarWt :: Bool = true)
    sds = Dict{Symbol, DevType}();
    n = length(d);
    if n > 0
        for i1 in 1 : n
            dev,_ = scalar_dev(d.dv[i1],  inclScalarWt = inclScalarWt);
            sds[name(d.dv[i1])] = dev;
        end
    end
    return sds
end

"""
	$(SIGNATURES)

Overall scalar deviation. Weighted sum of the scalar deviations returned by all `Deviation` objects
"""
function scalar_deviation(d :: DevVector)
    scalarDev = 0.0;
    for dev in d.dv
        sDev, _ = scalar_dev(dev,  inclScalarWt = true);
        @assert sDev >= 0.0
        scalarDev += sDev;
    end
    @argcheck (scalarDev >= 0.0)  "Scalar dev not positive: $scalarDev";
    return scalarDev
end


## ----------  For testing

function make_test_scalar_deviation(devNo :: Integer)
    name, shortStr, longStr, fmtStr = test_dev_info(devNo);
    modelV = devNo * 1.1;
    dataV = devNo * 2.2;
    return ScalarDeviation{Float64}(;
        name = name, modelV = modelV, 
        dataV, shortStr, longStr,
        auxData = make_test_aux_data())
end

function test_dev_info(devNo :: Integer)
    name = Symbol("d$devNo");
    shortStr = "dev$devNo";
    longStr = "Deviation $devNo"
    fmtStr = "%.2f";
    return name, shortStr, longStr, fmtStr
end


# ---------------