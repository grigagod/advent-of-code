using Test

const rexp = r"Card\s*(?<id>\d+):\s*(?<wanted>[0-9\s]+)\s*\|\s*(?<actual>[0-9\s]+)"

struct Card
    id::Int
    wanted::Vector{Int}
    actual::Vector{Int}
end

function parseline(line::AbstractString)::Card
    m = match(rexp, line)
    Card(parse(Int, m[:id]), parse.(Int, split(m[:wanted])), parse.(Int, split(m[:actual])))
end

networth(card::Card) = (1 << (length(intersect(card.wanted, card.actual)) - 1))
networth(line::AbstractString) = networth(parseline(line))

sum(networth, eachline(stdin)) |> display

function part2(n, iter=eachline(stdin))
    function scratchcards!(cards, line)
        card = parseline(line)
        nmatches = length(intersect(card.wanted, card.actual))
        rng = card.id+1:min(card.id+nmatches, n)
        cards[rng] .+= cards[card.id]
        cards
    end
    foldl(scratchcards!, iter; init=fill(1,n)) |> sum
end

@testset begin
    input =  split("""Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
    Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
    Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
    Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
    Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
    Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11""",'\n')
    @test networth.(input) == [8,2,2,1,0,0]
end
 
@testset begin
    input =  split("""Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
    Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
    Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
    Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
    Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
    Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11""",'\n')
    @test part2(6, input) == 30
end

part2(187) |> println