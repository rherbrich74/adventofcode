# Solves the first day of the Advent of Code 2024
#
# 2024 by Ralf Herbrich
# Hasso Plattner Institute, University of Potsdam, Germany

# reads the input data from a file
function read_input(filename)
    open(filename) do file
        return join(readlines(file),"")
    end
end

# solves the first part of the puzzle
function solution1(compressed)
    # decompresses the compressed string
    function decompress(compressed)
        output = Array{String}(undef, 0)
        for file_id in 1:length(compressed)÷2
            # repeat string(file_id) compressed[2*i-1] many times
            for _ = 1:parse(Int, compressed[2*file_id-1])
                push!(output, string(file_id - 1))
            end
            # repeat '.' compressed[2*i] many times
            for _ = 1:parse(Int, compressed[2*file_id])
                push!(output, ".")
            end
        end
        # repeat string(file_id) compressed[2*i-1] many times
        for _ = 1:parse(Int, compressed[end])
            push!(output, string(length(compressed)÷2))
        end
        return output
    end

    # pack the decompressed string
    function pack(decompressed)
        packed = collect(decompressed)
        i = 1
        j = length(packed)

        while i < j
            if packed[i] == '.'
                packed[i], packed[j] = packed[j], packed[i]

                while packed[j] == '.' && i < j
                    j -= 1
                end
            end
            i += 1
        end
        println("i = ", i, " j = ", j)

        return String(packed[1:i])
    end

    # computes the checksum
    function checksum(packed)
    end

    decompressed = decompress(compressed)
    println("Decompressed = ", length(decompress(compressed)))
    # println("Packed = ", pack(decompress(compressed)))
end

# solves the second part of the puzzle
function solution2(compressed)
end

compressed = read_input("/Users/rherbrich/src/adventofcode/2024/day9/test.txt")

# println("Compressed = ", compressed)

println("Solution 1 = ", solution1(compressed))
println("Solution 2 = ", solution2(compressed))
