using Test, DeviationsLH

dlh = DeviationsLH;

function change_table_test()
    @testset "Change table basics" begin
        n = 3;
        dv = make_test_deviation_vector(n);

        paramNameV = [:aa, :bbb, :cc, :d];
        nParam = length(paramNameV);

        ct = dlh.ChangeTable(dv, paramNameV);
        @test dlh.param_names(ct) == paramNameV
        @test dlh.n_params(ct) == nParam
        @test dlh.n_devs(ct) == length(dv)

        for j = 1 : nParam
            # Offset ensures that the first deviation is the same as the base
            dv2 = make_test_deviation_vector(n; offset = 0.5 * (j-1));
            dlh.set_param_values!(ct, j, dv2; scalarDev = nothing);
        end

        dlh.show_table(ct)
        for transposed = [false, true]
            dlh.show_largest_change_table(ct, 3; transposed = transposed)
        end

        pNameV = dlh.find_unchanged_devs(ct; rtol = 0.02);
        println("Unchanged deviations: $pNameV")
        @test isa(pNameV, typeof(paramNameV))
        @test length(pNameV) >= 1
	end
end

@testset "Change Table" begin
    change_table_test()
end

# --------------