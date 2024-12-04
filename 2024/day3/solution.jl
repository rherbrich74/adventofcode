# Solves the third day of the Advent of Code 2024
#
# 2024 by Ralf Herbrich
# Hasso Plattner Institute, University of Potsdam, Germany

# reads the input data from a file
function read_input(filename)
    open(filename) do file
        return join(readlines(file), "\n")
    end
end

# solves the first part of the puzzle
function solution1(data)
    sum = 0
    pattern = r"mul\((\d{1,3}),(\d{1,3})\)"
    for m in eachmatch(pattern, data)
        sum += parse(Int, m.captures[1]) * parse(Int, m.captures[2])
    end
    return sum
end

# solves the second part of the puzzle
function solution2(ids)
    sum = 0
    pattern = r"(?:do\(\)|don't\(\)|mul\((\d{1,3}),(\d{1,3})\))"
    enabled = true
    for m in eachmatch(pattern, data)
        if isnothing(m.captures[1]) && m.match == "do()"
            enabled = true
        elseif isnothing(m.captures[1]) && m.match == "don't()"
            enabled = false
        else
            if enabled
                sum += parse(Int, m.captures[1]) * parse(Int, m.captures[2])
            end
        end
    end
    return sum
end

data = read_input("/Users/rherbrich/src/adventofcode/2024/day3/input.txt")

println("Solution 1 = ", solution1(data))
println("Solution 2 = ", solution2(data))

