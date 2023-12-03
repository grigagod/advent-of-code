# 12 red cubes, 13 green cubes, and 14 blue cubes
rules = Dict("red"=>12, "green"=>13, "blue"=>14)

test = "Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green"

# cube -> set -> game
isvalidCube(cube) = cube.count <= rules[cube.color]

function parseCube(str) 
    splitted = split(str)
    return (count=parse(Int, splitted[begin]),color=splitted[end])
end

isvalidSet(set) = all(isvalidCube, set)

parseSet(set) = parseCube.(split(set, ","))

parseSets(sets) = parseSet.(split(sets, ";"))

isvalidGame(game) = all(isvalidSet, game)

parseGame(line) = parseSets(split(line, ":")[end])

function calculate(src) 
    splitted = split(src, ":")
    id = parse(Int, split(splitted[begin])[end])
    game = parseGame(splitted[end])
    # return isvalidGame(game) ? id : 0
    # pt2
    reduce(*, [maximum(map(cube -> cube.color == key ? cube.count : 0 , reduce(vcat,game))) for key in keys(rules)])
end

sum(calculate, eachline(stdin)) |> println

#rr = r"Game (\d+): (.*;?)+"

#function parseline(line)
#    data = split(line, ':')
#    idx = 