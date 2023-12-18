using DataStructures

function getmatrix(str)
    n = count('\n', str) + 1
    m = findfirst('\n', str) - 1
    permutedims(reshape(Vector{Char}(replace(str, "\n" => "")), m, n))
end

struct Beam
    pos::CartesianIndex{2}
    dir::CartesianIndex{2}
end

Base.transpose(ind::CartesianIndex{2}) = CartesianIndex(ind[2],ind[1])

function moveforward(b::Beam, c::AbstractChar)
    pos = b.pos
    dirs = [b.dir]
    if c == '.'
        pos = pos
    elseif c == '\\'
        dirs[1] = transpose(dirs[1])
    elseif c == '/'
        dirs[1] = -transpose(dirs[1])
    elseif c == '-'
        if b.dir == CartesianIndex(1, 0) || b.dir == CartesianIndex(-1, 0)
            dirs = [CartesianIndex(0, 1), CartesianIndex(0, -1)]
        end
    elseif c == '|'
        if b.dir == CartesianIndex(0, 1) || b.dir == CartesianIndex(0, -1)
            dirs = [CartesianIndex(1, 0), CartesianIndex(-1, 0)]
        end
    end
    Beam.(Ref(pos) .+ dirs, dirs)
end

const dirs = Dict(
    CartesianIndex.([(1,0), (0,1), (-1,0), (0,-1)]) .=> 1 .<< (0:3)
)

function bimbimbambam(mat::AbstractMatrix{<:AbstractChar}, init=Beam(CartesianIndex(1,1), CartesianIndex(0,1)))
    q = Queue{Beam}()
    enqueue!(q, init)
    used = zeros(UInt8, size(mat))
    used[init.pos] = dirs[init.dir]
    while !isempty(q)
        b = dequeue!(q)
        for b in moveforward(b, mat[b.pos])
            if checkbounds(Bool, mat, b.pos) && (used[b.pos] & dirs[b.dir]) == 0
                used[b.pos] |= dirs[b.dir]
                enqueue!(q, b)
            end
        end
    end
    count(!iszero, used)
end


mat = getmatrix(read(stdin, String))

@time println("part1: ", bimbimbambam(mat))

xx,yy = axes(mat)
inits = [
    Beam.(CartesianIndex.(xx,first(yy)), Ref(CartesianIndex(0, 1)));
    Beam.(CartesianIndex.(xx, last(yy)), Ref(CartesianIndex(0,-1)));
    Beam.(CartesianIndex.(first(xx),yy), Ref(CartesianIndex(1, 0)));
    Beam.(CartesianIndex.(last(xx), yy), Ref(CartesianIndex(-1,0)))
]
@time println("part2: ", maximum(init -> bimbimbambam(mat, init), inits))