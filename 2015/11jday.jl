using Test

password = Vector{Char}("cqjxjnds")
alphabet = 'a':'z'
skiplist = ['i', 'o', 'l']

function increment!(str::Vector{Char}, ind=lastindex(str))
    if str[ind] != 'z'
        str[ind] += 1
    else
        str[ind] = 'a'
        return increment!(str, ind-1)
    end
    str
end

@testset let str = Vector{Char}("azx")
    @test increment!(str) == Vector{Char}("azy")
    @test increment!(str) == Vector{Char}("azz")
    @test increment!(str) == Vector{Char}("baa")
end

function includeSeq(str::Vector{Char}, sz=3)
    for i in 3:length(str)
        if str[i-2] + 2 == str[i-1] + 1 == str[i]
            return true
        end
    end
    return false 
end

@testset begin
    str1 = Vector{Char}("abcdef")
    str2 = reverse(str1)
    @test includeSeq(str1)
    @test includeSeq(str2) broken=true
end

function hasUniquePairs(str::String, num=2)
    getindex.(str, findall(r"(\w)\1", str)) |> unique |> length |> >(1)
end

@testset begin
    str1 = "aafdfgcchljaaeoj"
    str2 = "abcd"
    @test hasUniquePairs(str1)
    @test !hasUniquePairs(str2)
end

validate(passwd::String) = validate(Vector{Char}(passwd))

function validate(passwd::Vector{Char})
    isempty(intersect(skiplist, passwd)) && includeSeq(passwd) && hasUniquePairs(String(passwd))
end

@testset begin
    strs = ["hijklmmn", "abbceffg", "abbcegjk", "abcdffaa", "ghjaabcc"]
    answrs = Bool[0,0,0,1,1]
    for (str, answr) in zip(strs, answrs)
        @test validate(str)==answr
    end
end

nextpasswd(passwd::String) = nextpasswd!(Vector{Char}(passwd))

function nextpasswd!(passwd::Vector{Char})
    while !validate(passwd)
        increment!(passwd)
    end
    passwd
end

newpassword = copy(password)

nextpasswd!(newpassword)

increment!(newpassword)

"cqjxxyzz"
"cqkaabcc"