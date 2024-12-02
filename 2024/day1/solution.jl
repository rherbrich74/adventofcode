# Solves the first day of the Advent of Code 2024
#
# 2024 by Ralf Herbrich
# Hasso Plattner Institute, University of Potsdam, Germany

# reads the input data from a file
function read_input(filename)
    open(filename) do file
        id1s = Vector{Int}()
        id2s = Vector{Int}()
        for line in eachline(file)
            id1, id2 = parse.(Int, split(line, "   "))
            push!(id1s, id1)
            push!(id2s, id2)
        end
        return id1s, id2s
    end
end

# solves the first part of the puzzle
function solution1(id1s, id2s)
    sum = 0
    sort!(id1s)
    sort!(id2s)
    for i in eachindex(id1s)
        sum += abs(id1s[i] - id2s[i])
    end
    return sum
end

# solves the second part of the puzzle
function solution2(id1, id2)
    sum = 0

    sort!(id1s)
    sort!(id2s)
    i = 1           # counter in the first list
    j = 1           # counter in the second list
    N = length(id1s)
    while i <= N
        # advance the counter on the right until it's at least as large as the left
        while j <= N && id1s[i] > id2s[j]
            j += 1
        end

        # increase the sum by the left ID as long as the IDs are equal with the advancing right ID
        while j <= N && id1s[i] == id2s[j]
            sum += id1s[i]
            j += 1
        end
        i += 1
    end
    return sum
end

id1s, id2s = read_input("/Users/rherbrich/src/adventofcode/2024/day1/input.txt")

println("Solution 1 = ", solution1(id1s, id2s))
println("Solution 2 = ", solution2(id1s, id2s))
