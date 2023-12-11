example = """RL

AAA = (BBB, CCC)
BBB = (DDD, EEE)
CCC = (ZZZ, GGG)
DDD = (DDD, DDD)
EEE = (EEE, EEE)
GGG = (GGG, GGG)
ZZZ = (ZZZ, ZZZ)"""


const rexp = r"(?<path>[RL]*)\n\n(?<rest>[\s\S]*)"
const rexprule = r"(?<key>\S+) = \((?<left>.*?), (?<right>.*?)\)"

function parseinput(str)
    m1 = match(rexp, str)

    path = m1["path"]
    rest = m1["rest"]

    graph = Dict{String,NTuple{2,String}}()
    for match in eachmatch(rexprule, rest)
        key, left, right = String.(match)
        graph[key] = (left,right)
    end
    path, graph
end

function countsteps(path, graph, curr="AAA"; stop=(==("ZZZ")))
    for (i, c) in enumerate(Base.Iterators.cycle(path))
        stop(curr) && return i-1
        curr = graph[curr][c == 'R' ? 2 : 1]
        i > 10^8 && return -1
    end
end

using Test

@testset "Example" begin
    example = """RL

    AAA = (BBB, CCC)
    BBB = (DDD, EEE)
    CCC = (ZZZ, GGG)
    DDD = (DDD, DDD)
    EEE = (EEE, EEE)
    GGG = (GGG, GGG)
    ZZZ = (ZZZ, ZZZ)"""
    path, graph = parseinput(example)
    @test countsteps(path, graph) == 2
end

path, graph = parseinput(read(joinpath(@__DIR__,"8in.txt"), String))

countsteps(path, graph)

function part2(path, graph)
    nodes = filter(str -> str[end] == 'A', keys(graph))
    lcm(countsteps.(Ref(path), Ref(graph), nodes; stop=(str -> str[end] == 'Z'))...)
end

part2(path, graph)