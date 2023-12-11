using DataStructures
using Images

grid1 = """
-L|F7
7S-7|
L|7||
-L-J|
L|-JF"""

gird2= """
7-F7-
.FJ|7
SJLL7
|F--J
LJ.LJ"""

function parseinput(raw)
    m = findfirst('\n', raw) - 1
    n = count('\n', raw) + 1
    res = Vector{Char}(raw)
    deleteat!(res, findall(==('\n'), res))
    permutedims(reshape(res,n,m))
end


north = CartesianIndex(-1,0)
east  = CartesianIndex(0, 1)
south = CartesianIndex(1, 0)
west  = CartesianIndex(0,-1)

# @enum Direction north east south west 

pipes = Dict(
    '|' => (north, south), 
    '-' => (east, west), 
    'L' => (north, east), 
    'J' => (north, west), 
    '7' => (south, west),
    'F' => (south, east),
)

ispipe(candidate::Char) = candidate != '.'


function enqueueneighs!(q, mat, visited, curr, dirs=pipes[mat[curr]])
    for dir in dirs
        next = curr + dir
        checkbounds(Bool, mat, next) && iszero(visited[next]) && ispipe(mat[next]) || continue
        # @show next, allowed, dir, -dir in allowed
        if -dir in pipes[mat[next]]
            visited[next] = visited[curr]+1
            enqueue!(q, next)
        end
    end
end

function solve!(mat, c) # pasha c = '7', grisha c = 'L'
    start = findfirst(==('S'), mat)
    mat[start] = c
    visited = zeros(Int, size(mat))
    visited[start] = 1
    T = typeof(start)
    q = Queue{T}()
    enqueueneighs!(q, mat, visited, start, (north, south, east, west))
    while !isempty(q)
        enqueueneighs!(q, mat, visited, dequeue!(q))
    end
    mat, visited
end

assfire(mat, visited) = assfire!(copy(mat), copy(visited))

function assfire!(mat, visited)
    mat[visited .== 0] .= '.'
    rows, cols = size(mat)
    newmat = fill('.', 2rows+1,2cols+1)
    newmat[2:2:2rows, 2:2:2cols] .= mat
    for i in 3:2:2rows-1, j in 2:2:2cols
        d1 = get(pipes, newmat[i-1,j], ())
        d2 = get(pipes, newmat[i+1,j], ())
        if south in d1 && north in d2
            newmat[i,j] = '|'
        end
    end
    for j in 3:2:2cols-1, i in 2:2rows
        d1 = get(pipes, newmat[i, j-1], ())
        d2 = get(pipes, newmat[i, j+1], ())
        if east in d1 && west in d2
            newmat[i,j] = '-'
        end
    end
    newmat[1,1] = 'O'
    q = Queue{CartesianIndex{2}}()
    enqueue!(q, CartesianIndex(1,1))
    while !isempty(q)
        curr = dequeue!(q)
        nexts = Ref(curr) .+ (south,west,north,east)
        for next in nexts
            if checkbounds(Bool, newmat, next) && newmat[next] == '.' 
                newmat[next] = 'O'
                enqueue!(q,next)
            end
        end
    end
    newmat
    # @views count(==('.'), newmat[2:2:end,2:2:end])
end

file = joinpath(@__DIR__,"10in.txt")
mat = parseinput(read(file, String))
_, visited = solve!(mat, 'L')
newmat = assfire(mat, visited)
@views count(==('.'), newmat[2:2:end,2:2:end])


function findstart(rows::AbstractVector{<:AbstracString})
    for 
    end
end
split(grid1,"\n")

a,b = "abc"

#=
..........
.S------7.
.|F----7|.
.||OOOO||.
.||OOOO||.
.|L-7F-J|.
.|II||II|.
.L--JL--J.
..........
=#
