using Distances

function readinput(file, size=(140,140))
    img = falses(size)
    for (i,line) in enumerate(eachline(file))
        img[i, findall('#', line)] .= true
    end
    img
end

function galaxies(img, mul)
    rows = findall(iszero, vec(sum(img; dims=2)))
    cols = findall(iszero, vec(sum(img; dims=1)))
    glxs = Tuple.(findall(!iszero, img))
    shift = [(mul-1).*(sum(x .> rows), sum(y .> cols)) for (x, y) in glxs]
    (.+).(glxs,shift)
end

img = readinput("2023/11in.txt")

sum(pairwise(Cityblock(), galaxies(img, 2))) ÷ 2 |> println
sum(pairwise(Cityblock(), galaxies(img, 1000000))) ÷ 2 |> println