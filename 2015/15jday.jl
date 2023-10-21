using Flux: relu
using LinearAlgebra

specs = permutedims(eval(Meta.parse(read(joinpath(@__DIR__,"15in.txt"),String))))

specs0 = specs[1:end-1,:]

calories = specs[end,:]

f(amounts) = prod(relu.(speki * amounts))

function bruteforcealltheshitoutofthisfuckinproblem(calories)
    maxval = 0
    for i in 1:97, j in 1:97-i, k in 1:97-i-j
        am = [i,j,k,100-i-j-k]
        calories ⋅ am == 500 || continue
        maxval = max(maxval,f(am))
    end
    maxval
end

bruteforcealltheshitoutofthisfuckinproblem(calories)