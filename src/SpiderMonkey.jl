module SpiderMonkey

export smo

using Statistics, Distributions, Random

"""
smo(D::Int,P::Int,f::Function,ɳ = 0.5,λ = 25,α = 20,β = 8,τ = 100,ub = fill(100,(D,)),lb = fill(-100,(D,)),verbose = false)

Returns a tuple of x_opt (Array of values at which function is optimum) and f_opt (optimum function value)

Spider Monkey Optimization (SMO) is a global optimization algorithm inspired by Fission-Fusion social (FFS) structure of spider monkeys during their foraging behavior. SMO exquisitely depicts two fundamental concepts of swarm intelligence: self-organization and division of labor.


# Arguments
- `D`: Dimension of the function being optimized, must be an integer.
- `P`: Population, Number of Spider Monkeys for the heuristic search, must be an integer.
- `f`: function to be optimized, example reference - BlackBoxOptimizationBenchmarking functions.
- `ɳ`: perturbation rate
- `λ`: local leader limit, max count for which the position of the local leader remains unchanged
- `α`: global leader limit, max count for which the position of the global leader remains unchanged
- `β`: maximum number of groups allowed
- `τ`: maximum number of iterations
- `ub`: upper bound values for spider monkey position coordinates, vector of length D.
- `lb`: lower bound values for spider monkey position coordinates, vector of length D.
- `verbose`: print to console the iteration number, Global leader fitness (f_opt) and number of groups for each iteration.
# Examples
## Optimize a function
Find out the optimum value of a function (numeric optimization) and the value as a vector of dimention D at which the function has optimum value.
```julia-repl
julia> using BlackBoxOptimizationBenchmarking;
julia> ub = fill(5,(100,));
julia> lb = fill(-5,(100,));
julia> smo(100,30,BlackBoxOptimizationBenchmarking.F1.f,0.5,25,20,8,100,ub,lb);
```
"""

mutable struct SMGroup{First,Population,LocalLeader,LLCount,LLIndex}
    first::First
    last::Population
    local_leader::LocalLeader
    local_leader_count::LLCount
    local_leader_index::LLIndex
    SMGroup(First,Population,LocalLeader,LLCount,LLIndex) = new{typeof(First),typeof(Population),typeof(LocalLeader),typeof(LLCount),typeof(LLIndex)}(First,Population,LocalLeader,LLCount,LLIndex)
end


function smo(
        D::Int, # Dimensions
        P::Int, # Population
        f::Function, # Function to optimize (in example format)
        ɳ = 0.5, # Perturbation rate
        λ = 25, # Local leader Limit
        α = 20, # Global Leader Limit
        β = 8, # Max Group Count
        τ = 100, # Iterations
        ub = fill(100,(D,)), # Upper bound for value
        lb = fill(-100,(D,)), # Lower bound for values
        verbose = false
        )

        groups = []
        GLC = 0
        # initialization of monkey population
        SM = rand(P,D)
        for i in 1:P
            for j in 1:D
                SM[i,j] = lb[j] + rand(Uniform(),1)[1]*(ub[j] - lb[j])
            end
        end

        fitness = map(f,eachrow(SM))
        LLIndex = argmin(fitness)
        # Local and Global leaders same with one group
        LL = GL = SM[LLIndex,:]
        group = SMGroup(1,P,LL,0,LLIndex)
        # Global Leader fitness
        GL_fitness = minimum(fitness)
        push!(groups,group)


        while τ > 0
            if verbose
                println("Iteration: $(τ), Global Leader Fitness: $(GL_fitness), Groups: $(length(groups))")
            end
            SM_temp = copy(SM)
            prev_fitness = map(f,eachrow(SM_temp))
            SM = local_leader_phase(groups,D,ɳ,SM,lb,ub)
            new_fitness = map(f,eachrow(SM))
            for i in 1:P
                if new_fitness[i] > prev_fitness[i]
                    SM[i,:] = SM_temp[i,:]
                    fitness[i] = prev_fitness[i]
                else
                    fitness[i] = new_fitness[i]
                end
            end
            prev_fitness = copy(fitness)
            SM_temp = copy(SM)
            SM = global_leader_phase(groups,D,GL,fitness,SM,lb,ub)
            new_fitness = map(f,eachrow(SM))
            for i in 1:P
                if new_fitness[i] > prev_fitness[i]
                    SM[i,:] = copy(SM_temp[i,:])
                    fitness[i] = prev_fitness[i]
                else
                    fitness[i] = new_fitness[i]
                end
            end
            for group in groups
                temp_LL = copy(group.local_leader)
                group.local_leader = SM[argmin(fitness),:]
                if all(temp_LL .== group.local_leader)
                    group.local_leader_count += 1
                end
            end
            temp_GL = copy(GL)
            glb_check_SM = SM
            GL = SM[argmin(fitness),:]
            GL_fitness = minimum(fitness)
            if all(temp_GL .== GL)
                GLC += 1
            end
            SM, groups = local_leader_decision(groups,D,ɳ,λ,SM,lb,ub,GL)
            groups = global_leader_decision(groups,D,GLC,fitness,SM,lb,ub,β,α,P)
            τ -= 1
        end
        return GL,GL_fitness
    end

function local_leader_decision(groups,dimensions,ɳ,λ,SM,lb,ub,GL)
    for group in groups
        if group.local_leader_count > λ
            group.local_leader_count = 0

            GS = group.last - group.first + 1
	        for i in 1:GS
	            for j in 1:dimensions
	                if rand(Uniform(),1)[1] >= ɳ
	                    SM[i,j] += lb[j] + rand(Uniform(),1)[1]*(ub[j] - lb[j])
	                else
	                    SM[i,j] += rand(Uniform(),1)[1]*(GL[j]-SM[i,j])+rand(Uniform(),1)[1]*(SM[i,j]-group.local_leader[j])
                    end
	                if SM[i,j] > ub[j]
	                    SM[i,j] = ub[j]
	                elseif SM[i,j] < lb[j]
	                    SM[i,j] = lb[j]
                    end
                end
            end
        end
    end
    return SM,groups
end

function global_leader_decision(groups,dimensions,GLC,fitness,SM,lb,ub,β,α,P)
    if GLC > α
        GLC = 0
        if length(groups) < β
            g1 = rand(groups)
            if g1.last > g1.first
                temp_last = g1.last
                g1.last = g1.first + cld((g1.last - g1.first),2) - 1
                g1.local_leader_count = 0
                g2 = SMGroup(g1.last + 1,temp_last,SM[argmin(fitness[g1.last:temp_last]),:],0,argmin(fitness[g1.last:temp_last]))
                g1.local_leader = SM[argmin(fitness[g1.first:g1.last]),:]
                push!(groups,g2)
            end
        else
            deleteat!(groups,[i for i in 1:length(groups)])
            g = SMGroup(1,P,SM[argmin(fitness),:],0,argmin(fitness))
            push!(groups,g)
        end
    end
    return groups
end

function global_leader_phase(groups,dimensions,GL,fitness,SM,lb,ub)
    for group in groups
        count = 1
        GS = group.last - group.first + 1
        while count < GS
            for i in 1:GS
                if rand(Uniform(),1)[1] < prob(fitness,group,i)
                    count += 1
                    j = rand(1:dimensions)
                    r = rand(group.first:group.last)
                    if r == i
                        r = i == 1 ? r+1 : r-1
                    end
                    SM[i,j] += rand(Uniform(),1)[1]*(GL[j]-SM[i,j]) + rand(Uniform(-1,1),1)[1]*(SM[r,j]-SM[i,j])
                    if SM[i,j] > ub[j]
                        SM[i,j] = ub[j]
                    elseif SM[i,j] < lb[j]
                    	SM[i,j] = lb[j]
                    end
                end
            end
        end
    end
    return SM
end


function local_leader_phase(groups,dimensions,ɳ,SM,lb,ub)

    for group in groups
        for i in group.first:group.last
            for j in 1:dimensions
                if rand(Uniform(),1)[1] >= ɳ
                    r = rand(group.first:group.last)
                    if r == i
                        r = i == 1 ? r+1 : r-1
                    end
                    SM[i,j] += rand(Uniform(),1)[1]*(group.local_leader[j] - SM[i,j]) + rand(Uniform(-1,1),1)[1]*(SM[r,j] - SM[i,j])
                    if SM[i,j] > ub[j]
                        SM[i,j] = ub[j]
                    elseif SM[i,j] < lb[j]
                        SM[i,j] = lb[j]
                    end
                end
            end
        end
    end
    return SM
end

function prob(fitness,group,i)
    return 0.9*(fitness[group.local_leader_index]/fitness[i]) + 0.1
end

end # module
