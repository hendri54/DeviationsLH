using Test, DeviationsLH
# Requires deviation_test_setup

dlh = DeviationsLH;

function dev_vector_test()
    @testset "DevVector" begin
        d = DevVector()
        @test length(d) == 0
        dev1 = make_test_deviation(1);
        dlh.append!(d, dev1);
        @test length(d) == 1


        # Scalar deviation
        dev2 = dlh.make_test_scalar_deviation(2);
        dlh.append!(d, dev2);
        @test length(d) == 2
        show_deviations(d; sorted = false);
        show_deviations(d; sorted = true);
        show(d);

        # Retrieve
        dev22 = dlh.retrieve(d, :d2);
        @test !isempty(dev22)
        @test dev22.dataV ≈ dev2.dataV
        @test dev_exists(d, :d2)
        @test !dev_exists(d, :notThere)

        @test isempty(retrieve(d, :notThere))
        dev = retrieve(d, :d1);
        @test dev.name == :d1

        # Set model values
        modelV = dev22.dataV .+ 1.3;
        set_model_values(d, :d2, modelV);
        dev22 = dlh.retrieve(d, :d2);
        @test dev22.modelV ≈ modelV
        @test isapprox(get_model_values(d, :d2), modelV)
        @test isapprox(get_data_values(d, :d2), get_data_values(dev22))

        # Set weights
        dev3 = make_test_deviation(3);
        dlh.append!(d, dev3);
        wtV = dev3.dataV .+ 2.3;
        dlh.set_weights!(d, :d3, wtV);
        dev3 = dlh.retrieve(d, :d3);
        @test dev3.wtV ≈ wtV
    end
end


function iterate_test()
    @testset "Iteration" begin
        d = make_test_deviation_vector(5);
        j = 0;
        for dev in d
            @test isa(dev, AbstractDeviation)
            j += 1;
        end
        @test j == length(d)
    end
end


function scalar_dev_devvector_test()
    @testset "Scalar deviation" begin
        n = 5;
        d = make_test_deviation_vector(n);
        devV = scalar_devs(d);
        @test length(devV) == n;
        # Not sorted, so test is weak
        dev1 = d[1];
        scalarDev1, _ = scalar_dev(dev1);
        @test any(x -> isapprox(x, scalarDev1), devV)

        scalarDev = scalar_deviation(d);
        @test isa(scalarDev, Float64)
        @test scalarDev >= 0.0

        @test isapprox(sum(devV), scalarDev, rtol = 1e-4)
    end
end

function devvec_dict_test()
    @testset "Deviation Dict" begin
        n = 5;
        d = make_test_deviation_vector(5);
        sds = scalar_dev_dict(d);
        @test isa(sds, Dict{Symbol, dlh.DevType})
        @test length(sds) == 5

        dev1 = d[1];
        scalarDev1, _ = scalar_dev(dev1);
        @test sds[dlh.name(dev1)] ≈ scalarDev1

        devV = scalar_devs(d);
        @test sort(devV) ≈ sort(collect(values(sds)))

        scalarDev = scalar_deviation(d);
        @test isapprox(sum(devV), scalarDev, rtol = 1e-4)
    end
end

function scalar_dev_table_test()
    @testset "Scalar deviation table" begin
        devV = DevVector();
        for j = 1 : 4
            d = dlh.make_test_scalar_deviation(j);
            append!(devV, d);
        end

        for dropZeroWeights in (true, false)
            for showScalarDevs in (true, false)
                tbM, headerV = scalar_deviation_table(devV; 
                    dropZeroWeights, showScalarDevs);
                @test size(tbM, 2) == length(headerV);
            end
        end
    end
end

@testset "DevVector" begin
    dev_vector_test();
    iterate_test();
    scalar_dev_devvector_test();
    devvec_dict_test();
    scalar_dev_table_test();
end

# ----------------