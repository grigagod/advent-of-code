json = open("12in.txt","r") do io
    JSON.Parser.parse(io)
end

scrap(arr::Vector) = sum(scrap,arr)
function scrap(dict::Dict)
    "red" in values(dict) && return 0
    sum(scrap, values(dict))
end
scrap(any) = 0
scrap(num::Int) = num

scrap(json)

96852

sum(x->parse(Int,x.match), eachmatch(r"-?\d+", read("12in.txt", String)))