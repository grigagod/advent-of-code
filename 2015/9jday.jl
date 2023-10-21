using DataStructures
using Profile
using PProf

"""
    readgraph(file)
reads input and returns matrix that represents graph
"""
function readgraph(file)
    edges = [split(line)[[1,3,5]] for line in eachline(file)]
    nlines = length(edges)
    verteces = SubString{String}[]
    sizehint!(verteces, 2nlines)
    for edge in edges
        append!(verteces, @view edge[[1,2]])
    end
    unique!(verteces)
    n = length(verteces)
    weights = fill(Inf,n,n)
    places = Dict(verteces .=> 1:n)

    for edge in edges
        from,to,dist= places[edge[1]], places[edge[2]], parse(Float64,edge[3])
        weights[from,to] = weights[to, from] = dist
    end
    weights
end

weights = readgraph("2015/9in.txt")

struct Node
    current::Int
    visited::Int
end

for (_path, filler, comparator, aggregator) in (
    (:max_path,-Inf, >, maximum),
    (:min_path, Inf, <, minimum)
)
    @eval begin
        function $_path(weights)
            n = size(weights, 1)
            ht = Dict{Node,Float64}()
            v = Vector{Node}()
            alloc_szie = 2^(n+2)
            sizehint!(v, alloc_szie)
            sizehint!(ht, alloc_szie)
            for node in 0:n-1
                newnode = Node(node, 2^node)
                ht[newnode] = 0
                push!(v, newnode)
            end
            cnt = 0
            for node in v
                cnt += 1
                for child in 0:n-1
                    2^child & node.visited != 0 && continue
                    newcost = ht[node] + weights[child+1, node.current+1]
                    newnode = Node(child, node.visited | 2^child)
                    oldcost = get(ht, newnode, $filler)
                    if $comparator(newcost, oldcost)
                        ht[newnode] = newcost
                        oldcost == $filler && push!(v, newnode)
                    end
                end
            end
            cost = $filler
            for node in @view(v[end-7:end])
                newcost = ht[node]
                if $comparator(newcost, cost)
                    cost = newcost
                end
            end
            cost
        end
    end
end

min_path(weights)
max_path(weights)

begin
    Profile.Allocs.clear()
    Profile.Allocs.@profile sample_rate=1 min_path(weights)
    PProf.Allocs.pprof()
end