using Test
using SpiderMonkey: smo
using BlackBoxOptimizationBenchmarking


@testset "Optimize Sphere function" begin
    D = 100 # Dimensions
    P = 30 # Population
    fn = BlackBoxOptimizationBenchmarking.F1.f # Function to optimize (in example format)
    ɳ = 0.5 # Perturbation rate
    λ = 25 # Local leader Limit
    α = 20 # Global Leader Limit
    β = 8 # Max Group Count
    τ = 1000 # Iterations
    ub = fill(100,(D,)) # Upper bound for value
    lb = fill(-100,(D,)) # Lower bound for values
    verbose = false
    GL,GL_fitness = smo(D,P,fn,ɳ,λ,α,β,τ,ub,lb,verbose)
    @test GL_fitness ≈ BlackBoxOptimizationBenchmarking.F1.f_opt atol=0.01
    @test size(GL) == D
end


@testset "Bounds Error" begin
    D = 100 # Dimensions
    P = 30 # Population
    fn = BlackBoxOptimizationBenchmarking.F1.f # Function to optimize (in example format)
    ɳ = 0.5 # Perturbation rate
    λ = 25 # Local leader Limit
    α = 20 # Global Leader Limit
    β = 8 # Max Group Count
    τ = 1000 # Iterations
    ub = fill(100,(90,)) # Upper bound for value
    lb = fill(-100,(90,)) # Lower bound for values
    verbose = false
    @test_throws BoundsError smo(D,P,fn,ɳ,λ,α,β,τ,ub,lb,verbose)
end
