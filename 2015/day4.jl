using MD5

function main(secret)
    for i in 1:typemax(Int)
        reinterpret(UInt128, md5(secret*string(i)))[1] & 0xffffff == 0 && return i
    end
end

main(readline()) |> println