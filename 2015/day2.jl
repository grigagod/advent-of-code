# str = readline()

parseline(line) = parse.(Int, split(line,'x'))

calcperimeters(w,l,h) = 2min(w+l, w+h, l+h)

processbox(v::AbstractVector) = processbox(v...)
processbox(w,l,h) = calcperimeters(w,l,h) + w*l*h

sum(processbox ∘ parseline, eachline(stdin)) |> println