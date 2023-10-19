teststr = """123 -> x
456 -> y
x AND y -> d
x OR y -> e
x LSHIFT 2 -> f
y RSHIFT 2 -> g
NOT x -> h
NOT y -> i"""

testans = """d: 72
e: 507
f: 492
g: 114
h: 65412
i: 65079
x: 123
y: 456"""

struct expr
    type::Int
    v::UInt16
    e::String
end

code2 = map(eachline("7in.txt")) do line
    lhs,rhs = String.(reverse(split(line, " -> ")))
    nrhs = tryparse(UInt16, rhs)
    (isnothing(nrhs) ? (lhs => rhs) : (lhs => nrhs))
end |> Dict{String,Union{String,UInt16}}

# code = map(split(teststr,"\n")) do line
#     =>(reverse(split(line, " -> "))...)
# end |> Dict

function Base.tryparse(code::Dict, str)::UInt16
    res = tryparse(UInt16, str)
    if isnothing(res)
        getwire(code, str)
    else
        res
    end
end


function getwire(code, name)::UInt16
    dep = code[name]
    typeof(dep) <: Integer && return dep
    args = split(dep)
    nargs = length(args)
    if nargs == 1
        code[name] = getwire(code, dep)
    elseif nargs == 2
        code[name] = ~tryparse(code, args[2])
    else # nargs == 3
        lhs = tryparse(code, args[1])
        rhs = tryparse(code, args[3])
        code[name] = if args[2] == "AND"
            lhs & rhs
        elseif args[2] == "OR"
            lhs | rhs
        elseif args[2] == "RSHIFT"
            lhs >> rhs
        else # LSHIFT
            lhs << rhs
        end
    end
end

getwire(code, "a") |> Int |> println