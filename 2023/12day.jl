using Memoization

function parserow(row::AbstractString)
    rawsprings, rawconds = split(row, " ")
    conds = parse.(Int, split(rawconds, ","))
    (rawsprings, conds)
end

arrangements(tup::Tuple) = arrangements(tup[1],tup[2])

@memoize function arrangements(str, nums)
    isempty(str) && return Int(isempty(nums))
    isempty(nums) && return Int(!occursin('#', str))
    
    res = 0

    @views if str[begin] in ".?"
        res += arrangements(str[begin+1:end], nums) 
    end

    @views if str[begin] in "#?"
        sn, num = length(str), nums[begin]
        if num <= sn && '.' ∉ str[1:num] && (sn == num || str[begin+num] != '#')
            res += arrangements(str[begin+num+1:end], nums[begin+1:end])        
        end
    end

    res
end

# part 2
function grow(springs, conds, factor=5)
    (join(fill(springs, factor), "?"), repeat(conds, factor))
end

count_variants(tup::Tuple{T1,T2}) where {T1,T2} = count_variants(tup...)

regexs = Dict{Int,Regex}(i => Regex("[#?]{$i}([?.]|\$)") for i in 1:50)

@memoize function count_variants(str, seqs)::Int
    if !isempty(seqs)
        len = seqs[begin]
        rexp = regexs[len]::Regex
        #fistoct = something(findfirst('#',str), length(str))
        #stopind = min(fistoct + len, length(str))
        matches = findall(rexp, str; overlap=true)
        res = 0
        @views for idx in matches
            '#' in str[1:idx.start-1] && break
            res += count_variants(str[idx.stop+1:end], seqs[begin+1:end])
        end
        res
    else
        '#' ∉ str ? 1 : 0
    end
end

file = joinpath(@__DIR__,"12in.txt")

lines = parserow.(eachline(file))
lines2 = [grow(line...) for line in lines]

@time println(sum(arrangements.(lines)))
@time println(sum(arrangements.(lines2)))

@time println(sum(count_variants.(lines)))
@time println(sum(count_variants.(lines2)))
