# Solves the first day of the Advent of Code 2024
#
# 2024 by Ralf Herbrich
# Hasso Plattner Institute, University of Potsdam, Germany

struct FileBlock
    file_id::Int
    length::Int
end

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
        output = Vector{String}()
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
        packed = Vector{String}()
        i = 1
        j = length(decompressed)

        while i <= j
            if decompressed[i] != "."
                # copy each file_id from the left
                push!(packed, decompressed[i])
                i += 1
            else
                # otherwise copy the file_id from the right
                push!(packed, decompressed[j])
                j -= 1
                while decompressed[j] == "." && i <= j
                    j -= 1
                end
                i += 1
            end
        end

        return packed
    end

    # computes the checksum
    function checksum(packed)
        sum = 0
        for (i, s) in enumerate(packed)
            inc = (i -1) * parse(Int, s)
            sum += inc
        end
        return sum
    end

    return checksum(pack(decompress(compressed)))
end

# solves the second part of the puzzle
function solution2(compressed)
    # decompresses the compressed string
    function decompress(compressed)
        output = Vector{FileBlock}()
        for file_id in 1:length(compressed)÷2
            push!(output, FileBlock(file_id-1, parse(Int, compressed[2*file_id-1])))
            push!(output, FileBlock(-1, parse(Int, compressed[2*file_id])))
        end
        push!(output, FileBlock(length(compressed)÷2, parse(Int, compressed[end])))
        return output
    end

    # prints the packed file blocks
    function print_packed(packed)
        for p in packed
            if p.file_id == -1
                print(repeat(".", p.length))
            else
                print(repeat(string(p.file_id), p.length))
            end
        end
        println()
    end

    # pack the decompressed file blocks
    function pack(decompressed::Vector{FileBlock})
        packed = deepcopy(decompressed)
        j = length(decompressed)

        while j > 1
            if packed[j].file_id == -1
                # skip the blocks that are dots
                j -= 1
                continue
            else
                for i in 1:j
                    if packed[i].file_id != -1
                        continue
                    else
                        if packed[i].length == packed[j].length
                            packed[i], packed[j] = packed[j], packed[i]
                            break
                        elseif packed[i].length > packed[j].length
                            # insert a new element into the packed array at index i
                            insert!(packed, i, FileBlock(packed[j].file_id, packed[j].length))
                            packed[i+1] = FileBlock(-1, packed[i+1].length - packed[j+1].length)
                            packed[j+1] = FileBlock(-1, packed[j+1].length)
                            j += 1
                            break
                        end
                    end
                end
                j -= 1
            end
        end

        return packed
    end

    # computes the checksum
    function checksum(packed)
        sum = 0
        i = 0
        for s in packed
            if s.file_id == -1
                i += s.length
            else
                for _ in 1:s.length
                    inc = i * s.file_id
                    sum += inc
                    i += 1
                end
            end
        end

        return sum
    end

    return checksum(pack(decompress(compressed)))
end

compressed = read_input("/Users/rherbrich/src/adventofcode/2024/day9/input.txt")

println("Solution 1 = ", solution1(compressed))
println("Solution 2 = ", solution2(compressed))
