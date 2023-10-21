using Combinatorics
using Base.Iterators: take

knights0 = String["Alice"; [split(line)[end] for line in take(eachline("13in.txt"), 7)]]

const knights = Dict(knights0 .=> eachindex(knights0))

getknight(str) = knights[str]

n = length(knights0)

weights = fill(0,n,n)

for line in eachline("13in.txt")
    i, weight, j = eachsplit(line) .|> (getknight, x->parse(Int,x), getknight)
    weights[i,j] = weight
end

happiness(perm, weights) = sum(weights[i,j]+weights[j,i] for (i,j) in zip(perm, circshift(perm,1)))
maximum(happiness(perm,weights) for perm in permutations(1:n))

#================Part Two=================#

knights0 = String["ME"; "Alice"; [split(line)[end] for line in take(eachline("13in.txt"), 7)]]

knights = Dict(knights0 .=> eachindex(knights0))

getknight(str) = knights[str]

n = length(knights0)

weights = fill(0,n,n)

for line in eachline("13in.txt")
    i, weight, j = eachsplit(line) .|> (getknight, x->parse(Int,x), getknight)
    weights[i,j] = weight
end

happiness(perm, weights) = sum(weights[i,j]+weights[j,i] for (i,j) in zip(perm, circshift(perm,1)))
maximum(happiness(perm,weights) for perm in permutations(1:n))
    