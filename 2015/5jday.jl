#=
function hasconseq(str)
    ["ab", "cd", "pq", "xy"] .|> occursin(str) |> any
end

hasdups(str::AbstractString) = hasdups(Vector{Char}(str))

function hasdups(str)
    @views any(==(0), str[begin+1:end] .- str[begin:end-1])
end

isvowel(c) = c in "aeiou"

function hasnvowels(str, n)
    cnt = 0
    for i in str
        if isvowel(i)
            cnt += 1
            cnt == n && return true
        end
    end
    return false
end

function isnice(str::AbstractString)
    Ref(str) .|> [!hasconseq, hasdups, Base.Fix2(hasnvowels, 3)] |> all
end

Now, a nice string is one with all of the following properties:


It contains at least one letter which repeats with exactly one letter between them, like xyx, abcdefeghi (efe), or even aaa.
=#


isnice(str) = [r"(\w)\w\1", r"(\w{2}).*\1"] .|> occursin(str) |> all

count(isnice, eachline("5in.txt"))

# pipeline(`cat input`, `grep "(..).*\1"`,`grep "(.).\1"`,`wc -l`)