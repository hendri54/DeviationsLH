using EconometricsLH, DeviationsLH

dlh = DeviationsLH;

function deviation_test()
    @testset "Deviation" begin
        d1 = dlh.empty_deviation(Float64);
        @test isempty(d1);

        dV = [make_deviation(1), make_matrix_deviation(1)];

        for d in dV
            mSizeV = size(get_model_values(d));
            println("Model size:  $mSizeV");
            @test !isempty(d)

            sDev, devStr = scalar_dev(d);
            @test isa(sDev, Float64);
            @test isa(devStr, AbstractString)
            
            dStr = dlh.short_display(d);
            @test dStr[1:4] == "dev1"
            println("--- Showing deviation")
            show_deviation(d);
            show_deviation(d, showModel = false);
            Base.println(d);

            wtV = get_data_values(d) .+ 0.1;
            dlh.set_weights!(d, wtV);
            @test get_weights(d) ≈ wtV

            modelV = get_model_values(d; matchData = true);
            @test size(modelV) == size(get_data_values(d))

            modelV = get_model_values(d) .+ 0.2;
            dlh.set_model_values(d, modelV);
            @test get_model_values(d) ≈ modelV;

            # Set model values and check that values were copied
            modelV = get_model_values(d);
            model2V = modelV .+ 1.0;
            set_model_values(d, model2V);
            model2V = nothing;
            @test all(get_model_values(d) .> modelV)
        end
    end 
end


function bounds_test()
    @testset "Bounds Deviation" begin
        for insideBounds = [true, false]
            d = make_bounds_deviation(1, insideBounds);
            @test !isempty(d)

            scalarDev, devStr = scalar_dev(d);
            @test isa(scalarDev, Float64);
            @test isa(devStr, AbstractString)
            if insideBounds
                @test scalarDev == 0.0
            else
                @test scalarDev > 0.0
            end
            
            dStr = dlh.short_display(d);
            @test dStr[1:4] == "dev1"
            println("--- Showing deviation")
            show_deviation(d);
            show_deviation(d, showModel = false);
            Base.println(d);

            # Set model values and check that values were copied
            modelV = get_model_values(d);
            model2V = modelV .+ 1.0;
            set_model_values(d, model2V);
            model2V = nothing;
            @test all(get_model_values(d) .> modelV)
        end
    end 
end


function penalty_test()
    @testset "Penalty Deviation" begin
        d = make_penalty_deviation(1);
        @test !isempty(d)

        scalarDev, devStr = scalar_dev(d);
        @test isa(scalarDev, Float64);
        @test isa(devStr, AbstractString)
        @test scalarDev > 0.0
        
        dStr = dlh.short_display(d);
        @test dStr[1:4] == "dev1"
        println("--- Showing deviation")
        show_deviation(d);
        show_deviation(d, showModel = false);
        Base.println(d);

        # Set model values and check that values were copied
        modelV = get_model_values(d);
        model2V = modelV .+ 1.0;
        set_model_values(d, model2V);
        model2V = nothing;
        @test all(get_model_values(d) .> modelV)
    end 
end


function scalar_dev_test()
    @testset "ScalarDeviation" begin
        d1 = dlh.empty_scalar_deviation();
        @test isempty(d1);

        d = make_scalar_deviation(1);
        @test !isempty(d);
        sDev, devStr = scalar_dev(d);
        @test isa(sDev, Float64);
        @test isa(devStr, AbstractString)
        dStr = dlh.short_display(d);
        @test dStr[1:4] == "dev1"

        modelV = d.dataV .+ 0.2;
        dlh.set_model_values(d, modelV);
        @test d.modelV ≈ modelV;

        println("--- Showing scalar deviation")
        show_deviation(d);
        show_deviation(d, showModel = false);
        Base.println(d);
    end
end


function regression_dev_test()
    d1 = dlh.empty_regression_deviation();
    @test isempty(d1);

    d = make_regression_deviation(4);
    dNameV, dCoeffV, dSeV = get_unpacked_data_values(d);
    @test length(dCoeffV) == length(dSeV) > 1
    @test all(dSeV .> 0.0)

    show_deviation(d);
    show_deviation(d, showModel = false);
    Base.println(d);

    mNameV, mCoeffV, mSeV = get_unpacked_model_values(d);
    @test length(mCoeffV) == length(mSeV) == length(dCoeffV)

    nameV = EconometricsLH.get_names(d.dataV);
    mRegr = RegressionTable(nameV, mCoeffV .+ 1.0, mSeV .+ 1.0)
    set_model_values(d, mRegr);
    mRegr = nothing;
    mName2V, mCoeff2V, mSe2V = get_unpacked_model_values(d);
    @test mCoeff2V ≈ mCoeffV .+ 1.0

    exclude_regressors!(d, [:beta2, :beta4]);
    @test is_excluded(d, :beta2)
    @test !is_excluded(d, :beta1)
    name2V, mCoeff2V, mSe2V = get_unpacked_model_values(d; dropExcluded = true);
    @test length(name2V) == length(mSe2V) == length(nameV) - 2
    name3V, _ = get_unpacked_data_values(d; dropExcluded = true);
    @test isequal(name2V, name3V)

    scalarDev, scalarStr = scalar_dev(d);
    @test scalarDev > 0.0
    @test isa(scalarStr, String)

    mRegr = RegressionTable(nameV, dCoeffV, dSeV .+ 0.1);
    set_model_values(d, mRegr);
    mRegr = nothing;
    scalarDev, _ = scalar_dev(d);
    @test scalarDev ≈ 0.0
end


@testset "Deviations" begin
    bounds_test()
    penalty_test()
    deviation_test()
    scalar_dev_test()
    regression_dev_test()
end

# -------------