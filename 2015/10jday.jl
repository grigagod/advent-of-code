v = reverse(digits(1113122113))

function look_and_say(dgs)
    res = Int[]
    cur = dgs[1]
    amount = 1
    for i in 2:length(dgs)
        if cur == dgs[i]
            amount += 1
        else
            push!(res,amount,cur)
            amount = 1
            cur = dgs[i]
        end
    end
    push!(res,amount,cur)
    res
end

∘(fill(look_and_say,50)...)(v) |> length
360154
5103798