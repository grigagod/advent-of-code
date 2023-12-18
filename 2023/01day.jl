patterns = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine", split("123456789","")...]

const dict = Dict(v=>(i-1)%9 + 1 for (i, v) in enumerate(patterns))

decode(str) = dict[str]

rr = Regex("("*join(patterns, "|")*")")

function parseline(line)
    x,y = decode.(@views getindex.(Ref(line), findall(rr, line; overlap=true)[[begin,end]]))
    10x+y
end

sum(parseline, eachline()) |> println


# sum(parse(Int, line[[findfirst(rr, line),findlast(rr, line)]]), eachline())

# findFirst(line) = decode[match(firstRe, line).match]
# findLast(line) = decode[match(lastRe, line).captures[begin]]

# sum(line -> findFirst(line)*10 + findLast(line), eachline(stdin)) |> println