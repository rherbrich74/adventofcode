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
    function decompress(compressed)
        output = ""
        for file_id in 1:length(compressed)/2
            # repeat string(file_id) compressed[2*i-1] many times
            output *= repeat(string(file_id - 1), compressed[2*file_id-1])
            # repeat '.' compressed[2*i] many times
            output *= repeat(".", compressed[2*file_id])
        end
        return output
    end

    println("Decompressed = ", decompress(compressed))
end

# solves the second part of the puzzle
function solution2(compressed)
end

compressed = read_input("/Users/rherbrich/src/adventofcode/2024/day9/test.txt")

println("Compressed = ", compressed)

println("Solution 1 = ", solution1(compressed))
println("Solution 2 = ", solution2(compressed))
