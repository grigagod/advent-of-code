coord = [0, 0]
coord2 = copy(coord)
visited = Set{typeof(coord)}([copy(coord)])

const rules = Dict('^' => [0, 1], '>' => [1, 0], 'v' => [0, -1], '<' => [-1, 0])

for (idx, rune) in enumerate(read(stdin, String))
    crd = isodd(idx) ? coord : coord2
    crd .+= rules[rune]
    push!(visited, copy(crd))
end

println(length(visited))