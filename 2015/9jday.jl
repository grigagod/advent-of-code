using DataStructures
using OffsetArrays
using Profile
using PProf

# Collect a profile
Profile.Allocs.clear()
Profile.Allocs.@profile peakflops()

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

wise_enqueue!(queue,cost,node,mask=2^node) = queue[(node,mask)] = cost[node,mask]

function Base.sizehint!(pq::PriorityQueue,n)
    sizehint!(pq.xs, n)
    sizehint!(pq.index, n)
end

for (_path, filler, order, comparator, aggregator) in (
    (:min_path, Inf, Base.Order.Forward, >, minimum),
    (:max_path, -Inf, Base.Order.Reverse, <, maximum)
)
    @eval begin
        $_path(weights::Matrix) = $_path(OffsetMatrix(weights, OffsetArrays.Origin(0)))

        @inbounds function $_path(weights::OffsetMatrix)
            n = size(weights, 1)
            cost = OffsetMatrix(fill($filler, n, 2^n), OffsetArrays.Origin(0))
            p_queue = PriorityQueue{Tuple{Int,Int},Float64}($order)
            sizehint!(p_queue, sizeof(cost))
            for node in 0:n-1
                cost[node, 2^node] = 0
                wise_enqueue!(p_queue, cost, node)
            end
            visited = falses(n)
            while !isempty(p_queue)
                current, mask = dequeue!(p_queue)
                visited.chunks[1] = mask
                for child in (0:n-1)[.!visited]
                    add = weights[child, current]
                    if $comparator(cost[child, mask | 2^child], cost[current, mask] + add)
                        cost[child, mask | 2^child] = cost[current, mask] + add
                        wise_enqueue!(p_queue, cost, child, mask | 2^child)
                    end
                end 
            end
            @views $aggregator(cost[:,end])
        end
    end
end

main = min_path ∘ readgraph

GC.enable(false)
GC.gc()

main("9in.txt")

PProf.Allocs.pprof()
