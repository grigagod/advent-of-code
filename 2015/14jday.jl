mutable struct Reindeer
    speed::Int
    runtime::Int
    resttime::Int
    curdist::Int
    traveltime::Int
    points::Int
    active::Bool

    Reindeer(speed, runtime, resttime) = new(speed, runtime, resttime, 0, 0, 0, true)
end

curdist(rd::Reindeer) = rd.curdist
givepoint!(rd::Reindeer) = rd.points+=1
points(rd::Reindeer) = rd.points

deers = [Reindeer(parse.(Int,eachsplit(line))...) for line in eachline(joinpath(@__DIR__, "14in.txt"))]

function rundeer!(deer::Reindeer)
    if deer.active
        if deer.traveltime == deer.runtime
            deer.traveltime = 1
            deer.active = false
        else
            deer.curdist += deer.speed
            deer.traveltime += 1
        end
    else
        if deer.traveltime == deer.resttime
            deer.active = true
            deer.traveltime = 1
            deer.curdist += deer.speed
        else
            deer.traveltime += 1
        end
    end
end

deers = reshape(deers, length(deers), 1)

for _ in Base.OneTo(2503)
    rundeer!.(deers)
    @views givepoint!.(deers[argmax(curdist.(deers); dims=1)])
end

maximum(points.(deers))

maximum(deer -> rundeer(deer,2503), deers)