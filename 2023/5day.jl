using Test
using ProgressBars

# dst src len

struct MapRange
    src::UnitRange{Int}
    dst::UnitRange{Int}
end
MapRange(dstStart, srcStart, len) = MapRange(srcStart:srcStart+len-1, dstStart:dstStart+len-1)

struct ConditionsMap
    name::String
    v::Vector{MapRange}
end

# X  -> Y
# Y' -> Z

# union(X, setdiff(Y', Y)) = X' -> Z'

# 1:5 -> 5:10
# 6:10 -> 1:5
# 15 -> 15

# 3:7 -> 13:17
# 8:12 -> 28:32

# 1:5 -> 5:10 -> 15 , [8,10]
function merge(c1::ConditionsMap, c2::ConditionsMap)::ConditionsMap

end

const rexpseeds = r"seeds:\s*(?<seeds>[0-9\s]+)\n\s*(?<rest>[\s\S]*)"
const rexpmap = r"(?<name>.*) map:\n(?<mappings>[\s\d]*?)(?=\n\n|$)"

function parseinput(raw::AbstractString)
    m1 = match(rexpseeds, raw)
    seeds = parse.(Int, split(m1[:seeds]))
    rest = m1[:rest]
    mappings = [
        ConditionsMap(
            m[:name],
            [ MapRange(parse.(Int, split(mapping))...) for mapping in split(m[:mappings],'\n') ]
        )
        for m in eachmatch(rexpmap, rest)
    ]
    seeds, mappings
end

function lookup(src::Int, range::MapRange)
    if src in range.src
        src - range.src[1] + range.dst[1]
    end # else nothing
end

function lookup(src::Int, ranges::ConditionsMap)::Int
    for range in ranges.v
        res = lookup(src, range)
        if !isnothing(res)
            return res
        end
    end
    src
end

function reverse_lookup(src::Int, range::MapRange)
    if src in range.dst
        src - range.dst[1] + range.src[1]
    end # else nothing
end

function reverse_lookup(src::Int, ranges::ConditionsMap)::Int
    for range in ranges.v
        res = reverse_lookup(src, range)
        if !isnothing(res)
            return res
        end
    end
    src
end

@testset begin
    cond = ConditionsMap("seed-to-soil", MapRange[MapRange(98:99, 50:51), MapRange(50:97, 52:99)])
    @test lookup(1, cond) == 1
    @test lookup(5, cond) == 5
    @test lookup(50, cond) == 52
    @test lookup(90, cond) == 92
    @test lookup(98, cond) == 50
    @test lookup(99, cond) == 51
    @test lookup(100, cond) == 100
end

@testset begin
    input = """seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4"""
   seeds, mappings = parseinput(input)
   @test minimum(seed -> foldl(lookup, mappings; init=seed), seeds) == 35
   seeds2 = map(seeds[1:2:end],seeds[2:2:end]) do x,y
    x:x+y-1
   end
   @test minimum(seeds -> minimum(seed -> foldl(lookup, mappings; init=seed), seeds), seeds2) == 46
end

seeds, mappings = parseinput(read("5in.txt", String))
map(seed -> foldl(lookup, mappings; init=seed), seeds) |> display
minimum(seed -> foldl(lookup, mappings; init=seed), seeds) |> println

seeds2 = map(seeds[1:2:end],seeds[2:2:end]) do x,y
    x:x+y-1
end

# minimum(seeds -> minimum(seed -> foldl(lookup, mappings; init=seed), seeds), seeds2) |> println
using ProgressBars
mins = zeros(Int, 10)
Threads.@threads for (i, seeds) in ProgressBar(collect(enumerate(seeds2)), printing_delay=1)
    mins[i] = minimum(seed -> foldl(lookup, mappings; init=seed), ProgressBar(seeds, printing_delay=1))
end

for i in 1:10^6
    seed = foldl(reverse_lookup, reverse(mappings); init=i)
    if any(col -> in(seed, col), seeds2)
        println(i)
        break
    end
end
# mins = zeros(10)
# Threads.@threads for (i, seeds) in ProgressBar(collect(enumerate(seeds2)))
#     minn = typemax(Int)
#     Threads.@threads for seed in ProgressBar(seeds)
#         res = foldl(lookup, mappings; init=seed)
#         if ()
# end
minimum(mins) |> println