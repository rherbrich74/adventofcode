# Solves the second day of the Advent of Code 2024
#
# 2024 by Ralf Herbrich
# Hasso Plattner Institute, University of Potsdam, Germany

# reads the input data from a file
function read_input(filename)
    open(filename) do file
        ids = Vector{String}()
        for line in eachline(file)
            for id in split(line, " ")
                push!(ids, id)
            end
        end
        return ids
    end
end

# solves the first and second part of the puzzle
function solution(ids, depth)
    cache = Dict{Tuple{String, Int}, Int}()

    # computes the length of the resulting after repeated application of the rules
    function dp(depth, id)
        if depth == 0
            return 1
        end

        # check if we cached the result 
        if haskey(cache, (id, depth))
            return cache[(id, depth)]
        end

        # apply the rules
        if id == "0"
            cache[(id, depth)] = dp(depth - 1, "1")
        elseif length(id) % 2 == 0
            n = length(id) ÷ 2
            id_left = string(parse(Int, id[1:n]))
            id_right = string(parse(Int, id[n+1:end]))
            cache[(id, depth)] = dp(depth - 1, id_left) + dp(depth - 1, id_right)
        else
            cache[(id, depth)] = dp(depth - 1, string(parse(Int, id) * 2024))
        end

        return cache[(id, depth)]
    end

    sum = 0
    for id in ids
       sum += dp(depth, id) 
    end

    return sum
end


ids = read_input("/Users/rherbrich/src/adventofcode/2024/day11/input.txt")

println("Solution 1 = ", solution(ids, 25))
println("Solution 2 = ", solution(ids, 75))