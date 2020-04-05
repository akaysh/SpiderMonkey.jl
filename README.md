# SpiderMonkey.jl

[![Build Status](https://travis-ci.org/akaysh/SpiderMonkey.jl.svg?branch=master)](https://travis-ci.org/akaysh/SpiderMonkey.jl)


Spider Monkey Optimization is a numerical optimization algorithm which is based on the foraging begavior of spider monkeys. It is one of the swarm intelligence approaches which can be broadly classified as an algorithm inspired by intelligent foraging behavior of fission–fusion social structure based animals. The animals which follow fission–fusion social systems (like Spider Monkeys), split themselves from large to smaller groups and vice-versa based on the scarcity or availability of food.  
[Here](https://link.springer.com/article/10.1007/s12293-013-0128-0) is the research paper for SMO algorithm and [here](https://www.sciencedirect.com/science/article/abs/pii/S2210650216000122) is my Aegist Spider Monkey algorithm research paper which proposed a few tweaks in the original algorithm to make it more efficient (will be implemented soon as a part of this package).

## Install
`Pkg.add("SpiderMonkey")`

## Usage

### Import the library
This brings the function `smo` (short for Spider Monkey Optimization) into the scope.

`using SpiderMonkey`

### Define your optimization function and parameters

The function can be defined like the ones in [BlackBoxOptimizationBenchmarking](https://github.com/jonathanBieler/BlackBoxOptimizationBenchmarking.jl) or you can use one of those implemented bechmarking functions.

For the SMO optimization algorithm we need the function `f` to be optimized, the dimension of the search space `D` or the function and population of the spider monkeys `P` for the heuristic search. We also need to define the upper `ub` and lower bounds `lb` of the search space coordinates for the boundaries which are `DX1` arrays.

### SMO
```julia
using BlackBoxOptimizationBenchmarking;
ub = fill(5,(100,));
lb = fill(-5,(100,));
smo(100,30,BlackBoxOptimizationBenchmarking.F1.f,0.5,25,20,8,100,ub,lb);
```

### Best hyperparameters?
There are lots of parameters that can be tweaked. The algorithm is generally fairly robust meaning that slight changes in parameters should not result in drastically different performance.

I suggest reading on Spider Monkey Optimization algorithm here before starting. However if you don't feel like it, the parameters worth playing around with might be: 
- `ɳ`: perturbation rate
- `λ`: local leader limit, max count for which the position of the local leader remains unchanged
- `α`: global leader limit, max count for which the position of the global leader remains unchanged
- `β`: maximum number of groups allowed
- `τ`: maximum number of iterations
