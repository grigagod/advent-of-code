struct Player
    hand::NTuple{5, Int}
    bid::Int
end

bid(p::Player) = p.bid

const dict = Dict(first.(split("A, K, Q, J, T, 9, 8, 7, 6, 5, 4, 3, 2",", ")) .=> reverse(1:13))

function parseplayers(str::String)
    map(split(str,'\n')) do line
        s_hand, s_bid = split(line)
        hand = Tuple(dict[c] for c in s_hand)
        bid = parse(Int, s_bid)
        Player(hand,bid)
    end
end

function readplayers(file::AbstractString)
    contents = read(file, String)
    parseplayers(contents)
end

using Test

function handtype(t::NTuple{5, Int})
    counts = count.(.==(unique(t)),Ref(t))
    if 5 in counts # Five
        7
    elseif 4 in counts # Four
        6
    elseif 3 in counts && 2 in counts # Fullhouse
        5
    elseif 3 in counts # Triplet
        4
    elseif count(==(2), counts) == 2 # Two pairs
        3
    elseif 2 in counts # Pair
        2
    else 
        1
    end
end


@testset "Hand type" begin
    xx = parseplayers("""32T3K 765
    T55J5 684
    KK677 28
    KTJJT 220
    QQQJA 483
    AAAAA 1
    AAAA2 1
    AAAQQ 1
    23456 1""")
    yy = [2,4,3,3,4,7,6,5,1]
    for (x,y) in zip(xx,yy)
        @test handtype(x.hand) == y
    end
end # passed

function Base.isless(p1::Player, p2::Player)
    h1, h2 = p1.hand, p2.hand
    type1, type2 = handtype(h1), handtype(h2)
    type1 < type2 || type1 == type2 && h1 < h2
end

@testset "Comparator" begin
    p1,p2,p3,p4 = parseplayers("""33332 1
    2AAAA 1
    77888 1
    77788 1""")
    @test p2<p1
    @test p4<p3
end

using LinearAlgebra

function part1(players::AbstractVector{Player})
    bid.(sort(players)) ⋅ eachindex(players)
end

@testset "Part 1" begin
    players = parseplayers("""32T3K 765
    T55J5 684
    KK677 28
    KTJJT 220
    QQQJA 483""")
    @test part1(players) == 6440
end

players = readplayers(joinpath(@__DIR__, "7p.txt"))

function part1!(players::AbstractVector{Player})
    bid.(sort!(players)) ⋅ eachindex(players)
end

using Printf

@printf "Part 1: %s" part1!(players)

function mapplayers(players)
    map(players) do player
        Player(replace(player.hand, dict['J'] => 0), player.bid)
    end
end
players2 = mapplayers(players)

function handtype2(t::NTuple{5, Int})
    cards = Dict(c => count(==(c),t) for c in unique(t))
    njokers = haskey(cards, 0) ? pop!(cards, 0) : 0
    counts = isempty(cards) ? [0] : collect(values(cards))
    sort!(counts)
    counts[end] += njokers
    if 5 == counts[end] # Five
        7
    elseif 4 == counts[end] # Four
        6
    elseif 3 == counts[end]
        if length(counts) > 1 && 2 == counts[end-1] # Fullhouse
            5
        else
            4
        end
    elseif length(counts) > 1 && counts[end] == 2 && counts[end-1] == 2 # Two pairs
        3
    elseif 2 == counts[end] # Pair
        2
    else 
        1
    end
end

function Base.isless(p1::Player, p2::Player)
    h1, h2 = p1.hand, p2.hand
    type1, type2 = handtype2(h1), handtype2(h2)
    type1 < type2 || type1 == type2 && h1 < h2
end

@testset "Joker-chujoker" begin
    players = parseplayers("""32T3K 765
    T55J5 684
    KK677 28
    KTJJT 220
    QQQJA 483""") |> mapplayers
    @test part1(players) == 5905
end

part1(players2) |> println

# foldl(::typeof(+), v::AbstractVector{Int}) = sum(v)
# read(s::AbstractString, ::Type{String})
# read("", String)
