ridx = r"Game (\d+):"
rround = r"((?: \d+ \w+,?)+);?"
rdraw = r"(?<num>\d+) (?<color>\w+)"

test = "Game 11: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green"

limits = Dict("red"=>12,"green"=>13,"blue"=>14)

function checkgame(line)
    idx = parse(Int, match(ridx, line)[1])
    for round in eachmatch(rround, line)
        for draw in eachmatch(rdraw, round[1])
            limits[draw["color"]] < parse(Int, draw["num"]) && return 0
        end
    end
    return idx
end

function prodgame(line)
    r = g = b = 1
    for round in eachmatch(rround, line)
        for draw in eachmatch(rdraw, round[1])
            if draw["color"] == "red"
                r = max(r, parse(Int, draw["num"]))
            elseif draw["color"] == "green"
                g = max(g, parse(Int, draw["num"]))
            else
                b = max(b, parse(Int, draw["num"]))
            end
        end
    end
    return r*g*b
end

sum(prodgame, eachline(stdin)) |> println