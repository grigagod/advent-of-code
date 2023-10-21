using DataStructures
using Profile
using PProf

function readgraph(file)
    vertices = Dict{SubString{String},Int}()
    edges = Dict{Tuple{Int,Int},Float64}()
    raw = read(file, String)
    nlines = count('\n', raw)
    lines = eachsplit(raw, '\n')
    sizehint!(vertices, nlines)
    sizehint!(edges, nlines)
    for line in lines
        from, _, to, _, weight = eachsplit(line)
        haskey(vertices, from) || setindex!(vertices, length(vertices)+1, from)
        haskey(vertices, to) || setindex!(vertices, length(vertices)+1, to)
        edges[(vertices[from], vertices[to])] = parse(Float64, weight)
    end
    n = length(vertices)
    weights = zeros(n,n)
    for (edge, weight) in edges
        i, j = edge
        weights[i, j] = weights[j, i] = weight
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
            v = Node[]
            alloc_szie = n*2^(n-1)
            sizehint!(v, alloc_szie)
            sizehint!(ht, alloc_szie)
            for node in 0:n-1
                newnode = Node(node, 2^node)
                ht[newnode] = 0
                push!(v, newnode)
            end
            for node in v
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
            $aggregator(ht[node] for node in @view(v[end-n+1:end]))
        end
    end
end

min_path(weights)
max_path(weights)

begin
    GC.gc()
    Profile.Allocs.clear()
    Profile.Allocs.@profile sample_rate=1 max_path(weights)
    PProf.Allocs.pprof()
end