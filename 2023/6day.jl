example = """Time:      7  15   30
Distance:  9  40  200"""
input_gp = """Time:        56     97     78     75
Distance:   546   1927   1131   1139"""
input_pd = """Time:        40     92     97     90
Distance:   215   1064   1505   1100"""

rexp = r"Time:\s*(?<times>[\d\s]*)\nDistance:\s*(?<distances>[\d\s]*)"
times, distances = map(v -> parse.(Int, v), split.(match(rexp, input_gp).captures))

function waysToBeat(time::Int, distance::Int)
    # hold - время ожидания
    # drive - время езды
    # drive == time - hold
    # hold^2  + (-time) * hold + distance <= 0
    hold1 = nextfloat(time/2 - sqrt(time^2/4 - distance))
    hold2 = prevfloat(time/2 + sqrt(time^2/4 - distance))
    floor(Int, hold2) - ceil(Int, hold1) + 1
end

prod(waysToBeat.(times, distances))

time2, distance2 = parse.(Int, replace.(match(rexp, input_gp).captures, " "=>""))

waysToBeat(time2,distance2)