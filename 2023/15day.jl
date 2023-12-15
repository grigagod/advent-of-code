using DataStructures

const numberofboxes = 256

hhash(str::AbstractString; mod=numberofboxes) = foldl(str; init=0) do sum, c
    17(sum + Int(c)) % mod
end

const rexp = r"^(?<label>.*?)(?<op>[-=])(?<num>\d*)?$" 

function part2(inp)::Int
    Box = OrderedDict{String, Int}
    boxes = Dict{Int, Box}()
    for rule in inp
        m = match(rexp, rule)
        isnothing(m) && continue
        label, op, num_ = (String(something(x, "")) for x in m)
        ind = hhash(label)
        if op == "="
            num = parse(Int, num_)
            boxes[ind] = push!(get(boxes, ind, Box()), label=>num)
        else
            haskey(boxes, ind) && delete!(boxes[ind], label)
        end
    end
    sum(
        (ind+1)*sum(i*len for (i, (_, len)) in enumerate(box); init=0)::Int
        for (ind, box) in boxes
    )
end

file = joinpath(@__DIR__, "15in.txt")

inp = split(read(file, String), ",")

sum(hhash, inp) |> println

part2(inp) |> println