lines = collect(eachline("8in.txt"))

sum(sizeof ∘ Meta.parse, eachline("8in.txt"))