getmatrix(match::RegexMatch) = getmatrix(match[:field])

function getmatrix(str)
    n = count('\n', str) + 1
    m = findfirst('\n', str) - 1
    res = reshape(Vector{Char}(replace(str, "\n" => "")), m, n)
    permutedims(res)
end

function parseinput(str)
    rexp = r"(?<field>[\s\S]+?)(\n\n|$)"
    getmatrix.(eachmatch(rexp, str))
end

function isreflection(mat1, mat2, smudge=0)
    count = 0
    for (i,j) in zip(mat1,mat2)
        if i != j
            count += 1
            count > smudge && return false
        end
    end
    true
end

function ismirrorpos(mat, mirrorpos; dims, smudge=0)
    dims == 2 && return ismirrorpos(PermutedDimsArray(mat,(2,1)), mirrorpos; dims=1)
    limit = size(mat, 1)
    before, after = if limit - mirrorpos > mirrorpos
        1:mirrorpos, 2mirrorpos:-1:mirrorpos+1
    else
        2mirrorpos-limit+1:mirrorpos, limit:-1:mirrorpos+1
    end
    @views !isempty(before) && isreflection(mat[before,:], mat[after,:], smudge)
end

function findreflection(mat, smudge; dims)
    xx = axes(mat, dims)
    something(findfirst(pos -> ismirrorpos(mat, pos; dims=dims, smudge=smudge), xx), 0)
end

function findreflection(mat; smudge=0)
    100findreflection(mat, smudge; dims=1) + findreflection(mat, smudge; dims=2)
end

file = joinpath(@__DIR__, "13p.txt")

matrices = parseinput(read(file, String))

sum(findreflection, matrices) |> display

sum(mat -> findreflection(mat; smudge=1), matrices) |> display