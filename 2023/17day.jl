using DataStructures

function getmatrix(str)
    n = count('\n', str) + 1
    m = findfirst('\n', str) - 1
    permutedims(reshape([Int(c-'0') for c in (replace(str, "\n" => ""))], m, n))
end

const dirs = CartesianIndex.([(1, 0), (-1, 0), (0, 1), (0, -1)])

function fillqueue(pq, key, val)
    if haskey(pq, key)
        if val < pq[key]
            pq[key] = val
        end
    else
        enqueue!(pq, key, val)
    end
end

function minpath(mat, min=1,max=3)
    src, dst = CartesianIndex(1,1), last(eachindex(IndexCartesian(),mat))
    entered = Set{Tuple{CartesianIndex{2}, CartesianIndex{2}, Int64}}()
    pq = PriorityQueue{Tuple{CartesianIndex{2}, CartesianIndex{2}, Int64}, Int64}()
    enqueue!(pq, (src, CartesianIndex(0, 0), 0), 0)
    while !isempty(pq)
        key, val = dequeue_pair!(pq)
        pos, dir, n = key
        if pos == dst && n >= min
            return val
        end

        key in entered && continue
        push!(entered, key)

        if n < max && dir != CartesianIndex(0, 0)
            npos = pos + dir
            if checkbounds(Bool, mat, npos)
                fillqueue(pq, (npos, dir, n+1), val + mat[npos])
            end
        end

        n < min && dir != CartesianIndex(0, 0) && continue

        for ndir in dirs
            npos = pos + ndir
            if ndir != dir && ndir != -dir && checkbounds(Bool, mat, npos)
                fillqueue(pq, (npos, ndir, 1), val + mat[npos])
            end
        end
    end
end

mat = getmatrix(read(stdin, String))

@time minpath(mat) |> println
@time minpath(mat, 4, 10) |> println