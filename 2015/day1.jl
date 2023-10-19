str = readline(stdin)

function main(str)
    acc = 0
    for (i, rune) in enumerate(str)
        acc += rune == '(' ? 1 : -1
        acc == -1 && return i
    end
    return -1
end

main(str) |> println