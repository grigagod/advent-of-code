using Test

const testinp = """
O....#....
O.OO#....#
.....##...
OO.#O....O
.O.....O#.
O.#..O.#.#
..O..#O..O
.......O..
#....###..
#OO..#...."""

function getmatrix(str)
    n = count('\n', str) + 1
    m = findfirst('\n', str) - 1
    res = reshape(Vector{Char}(replace(str, "\n" => "")), m, n)
    permutedims(res)
end

function roll!(v::AbstractVector; dir=:bwd)
    if dir == :fwd
        roll!(@view v[reverse(eachindex(v))])
        return v
    end
    vacant = -1
    for i in eachindex(v)
        if vacant == -1
            if v[i] == '.'
                vacant = i
            end
        else
            if v[i] == 'O'
                v[vacant], v[i] = 'O', '.'
                vacant += 1
            elseif v[i] == '#'
                vacant = -1
            end
        end
    end
    v
end

@testset "Roll vector" begin
    inp = Vector{Char}("..O..O.OO.##O.O#.O..")
    ansb= Vector{Char}("OOOO......##OO.#O...")
    ansf= Vector{Char}("......OOOO##.OO#...O")
    @test roll!(inp) == ansb
    @test roll!(inp; dir=:fwd) == ansf
end

roll(mat::AbstractMatrix; dir) = roll!(copy(mat); dir=dir)

function roll!(mat::AbstractMatrix; dir)
    if dir == :north
        roll!.(eachcol(mat); dir=:bwd)
    elseif dir == :south
        roll!.(eachcol(mat); dir=:fwd)
    elseif dir == :west
        roll!.(eachrow(mat); dir=:bwd)
    elseif dir == :east
        roll!.(eachrow(mat); dir=:fwd)
    end
    mat
end

@testset "Roll matrix" begin
    inp = getmatrix(testinp)
    ans = getmatrix("""OOOO.#.O..
    OO..#....#
    OO..O##..O
    O..#.OO...
    ........#.
    ..#....#.#
    ..O..#.O.O
    ..O.......
    #....###..
    #....#....""")

    @test roll!(inp; dir=:north) == ans
end

using LinearAlgebra

function count_load(mat)
    weights = reverse(axes(mat, 2))
    dot(weights, mat .== 'O', ones(Int, length(weights)))
end

@testset "Count load" begin
    inp = roll!(getmatrix(testinp); dir=:north)
    ans = 136
    @test count_load(inp) == 136
end

file = joinpath(@__DIR__, "14p.txt")

mat = getmatrix(read(file, String))
count_load(roll(mat; dir=:north))

rollcycle(mat) = rollcycle!(copy(mat))

function rollcycle!(mat)
    for dir in (:north,:west,:south,:east)
        roll!(mat; dir=dir)
    end
    mat
end

@testset "Roll cycle matrix" begin
    inp = getmatrix(testinp)
    ans1 = getmatrix(""".....#....
    ....#...O#
    ...OO##...
    .OO#......
    .....OOO#.
    .O#...O#.#
    ....O#....
    ......OOOO
    #...O###..
    #..OO#....""")
    ans2 = getmatrix(""".....#....
    ....#...O#
    .....##...
    ..O#......
    .....OOO#.
    .O#...O#.#
    ....O#...O
    .......OOO
    #..OO###..
    #.OOO#...O""")
    
    ans3 = getmatrix(""".....#....
    ....#...O#
    .....##...
    ..O#......
    .....OOO#.
    .O#...O#.#
    ....O#...O
    .......OOO
    #...O###.O
    #.OOO#...O""")
    @test rollcycle!(inp) == ans1
    @test rollcycle!(ans1) == ans2
    @test rollcycle!(ans2) == ans3
end

part2(mat, ncycles=1_000_000_000) = part2!(copy(mat), ncycles)

function part2!(mat, ncycles=1_000_000_000)
    set = typeof(mat)[]
    start = -1
    for i in 1:ncycles
        newmat = rollcycle(mat)
        start = findfirst(==(newmat), set)
        !isnothing(start) && break
        push!(set, newmat)
        mat = newmat
    end
    len = length(set) - start + 1
    mat = set[start + (ncycles - start + 1) % len - 1]
    count_load(mat)
end


part2(mat)