using DeviationsLH
using Test

include("deviation_test_setup.jl");

@testset "All" begin
    include("deviation_test.jl");
    include("dev_vector_test.jl");
    include("change_table_test.jl");
end


# -------------