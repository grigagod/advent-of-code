src = read("3in.txt",String)
n = count("\n", src) + 1
m = findfirst('\n', src) - 1
mat = Matrix{Char}(undef, m, n)
for (i, line) in enumerate(split(src, '\n'))
    mat[:, i] .= Vector{Char}(line)
end

issymbol(c) = !isdigit(c) && c != '.'

symbols = findall(issymbol, mat)

function neighs(xx::AbstractVector{<:Integer}, y::Integer)
    CartesianIndices((xx[begin]-1:xx[end]+1, y-1:y+1))
end

function partnumber(indices, mat)
    xx, y = indices .% (n+1), indices[1] ÷ (n+1) + 1
    !isempty(intersect(symbols, neighs(xx, y))) ? parse(Int, src[indices]) : 0
end

# pt 1
sum(map(indices -> partnumber(indices, mat), findall(r"\d+",src))) |> println

mutable struct Gear{POS}
    pos::POS
    v::Vector{Int}

    Gear{T}(pos::T) where T = new(pos, Int[])
end

Gear(pos::T) where T = Gear{T}(pos)


gears = [Gear(pos) for pos in findall(c -> c == '*', mat)]

for indices in findall(r"\d+",src)
    xx, y = indices .% (n+1), indices[1] ÷ (n+1) + 1
    neighbours = neighs(xx, y)
    for gear in gears
        gear.pos in neighbours && append!(gear.v, parse(Int, src[indices]))
    end
end

# pt2
sum(prod(gear.v) for gear in gears if length(gear.v) > 1) |> println