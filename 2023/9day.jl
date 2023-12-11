example = """0 3 6 9 12 15
1 3 6 10 15 21
10 13 16 21 30 45"""

# """0 3 6 9 12 15 18"""
# "3 3 3 3 3 3"
# "0 0 0 0 0"

# "10 13  16  21  30  45"
# "3  3   5   9   15"
# "0  2   4   6"
# "2  2   2"
# "0  0   0"

# "5  10  13  16  21  30  45"
# "5   3   3   5   9   15"
# "-2  0   2   4   6"
# "2   2   2   2"
# "0   0   0"

# -(-(-(-0 + 2) + 0) + 3) + 10
# 10 - (3 - (0 - (2 - 0)))

parsehistory(line::AbstractString) = parsehistory(split(line, "\n"))
parsehistory(lines::Union{AbstractVector{<:AbstractString}, Base.EachLine}) = [parse.(Int, split(line)) for line in lines]

function prevgen(history::AbstractVector{<:Integer}, acc=0, sign=false)
    if all(iszero, history)
        acc
    else
        @views prevgen(history[begin+1:end] .- history[begin:end-1],  acc + (-1)^sign * history[begin], !sign)
    end
end

function nextgen(history::AbstractVector{<:Integer}, acc=0)
    if all(iszero, history)
        acc
    else
        @views nextgen(history[begin+1:end] .- history[begin:end-1], acc + history[end])
    end
end

using Test

@testset begin
    xx = parsehistory("""0 3 6 9 12 15
1 3 6 10 15 21
10 13 16 21 30 45""")
    yy = [18, 28, 68]
    for (x, y) in zip(xx, yy)
        @test nextgen(x) == y
    end
end

@testset begin
    xx = parsehistory("""0 3 6 9 12 15
    1 3 6 10 15 21
    10 13 16 21 30 45""")
    yy = [-3, 0, 5]
    for (x, y) in zip(xx, yy)
        @test prevgen(x) == y
    end
end


sum(nextgen, parsehistory(eachline(joinpath(@__DIR__,"9in.txt")))) 


sum(prevgen, parsehistory(eachline(joinpath(@__DIR__,"9in.txt")))) 