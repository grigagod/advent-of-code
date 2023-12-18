const rexp = r"(?<dir>.) (?<len>\d+) \((?<hex>.*)\)"
const char2dir = Dict(split("U D L R") .=> ((-1, 0), (1, 0), (0, -1), (0, 1)))
const digit2char = Dict(split("0 1 2 3") .=> ("R", "D", "L", "U"))

digit2dir(digit) = char2dir[digit2char[digit]]

function parsebasic(line)
    dir, len, _ = match(rexp, line)
    (dir=char2dir[dir], len=parse(Int, len))
end

function parsehex(line)
    _, _, hex = match(rexp, line)
    (dir=digit2dir(hex[end:end]), len=parse(Int, hex[begin+1:end-1], base=16))
end

dir(nt) = nt[:dir]

len(nt) = nt[:len]

vertices(trenches) = accumulate(.+, dir(t).*len(t) for t in trenches; init=(0,0))

shoelacearea(x, y) = abs(sum(x .* circshift(y, -1) .- circshift(x, -1) .* y)) / 2

function volume(trenches)
    vs = vertices(trenches)
    sum(len.(trenches)) / 2 + shoelacearea(first.(vs), last.(vs)) + 1
end

lines = split(read(stdin, String), "\n")

@time volume(parsebasic.(lines)) |> Int |> println
@time volume(parsehex.(lines)) |> Int |> println