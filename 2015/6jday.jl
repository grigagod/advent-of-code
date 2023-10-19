lights = zeros(Int,1000,1000)

function parse_command!(lights, line)
    ind = findfirst(isdigit, line) - 1
    coords = replace(line[ind:end], " through " => ",")
    x1,y1,x2,y2 = parse.(Int,split(coords, ",")) .+ 1
    @views if line[begin:ind] == "turn on "
        lights[x1:x2,y1:y2] .+= 1
    elseif line[begin:ind] == "turn off "
        map!(lights[x1:x2,y1:y2], lights[x1:x2,y1:y2]) do val
            val == 0 ? val : val-1
        end 
    else
        lights[x1:x2,y1:y2] .+= 2
    end
    lights
end

for line in eachline()
    parse_command!(lights,line)
end

sum(lights) |> println