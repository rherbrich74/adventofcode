# Solves the eight day of the Advent of Code 2024
#
# 2024 by Ralf Herbrich
# Hasso Plattner Institute, University of Potsdam, Germany

# reads the input data from a file
function read_input(filename)
    open(filename) do file
        data = readlines(file)
        unique_chars = Dict{Char,Vector{Tuple{Int,Int}}}()
        map = Matrix{Char}(undef, length(data), length(data[1]))
        for (i, line) in enumerate(data)
            for (j, c) in enumerate(line)
                if (c != '.')
                    if c in keys(unique_chars)
                        push!(unique_chars[c], (i, j))
                    else
                        unique_chars[c] = [(i, j)]
                    end
                end
                map[i, j] = c
            end
        end
        return map, unique_chars
    end
end

# prints the maze
function print_map(map)
    for i in 1:size(map, 1)
        for j in 1:size(map, 2)
            print(map[i, j])
        end
        println()
    end
end

# solves the first part of the puzzle
function solution1(map, unique_chars)
    # returns true is a coordinate is on the map
    function on_map(x, y)
        return x >= 1 && x <= size(map, 2) && y >= 1 && y <= size(map, 1)
    end

    locations = Set{Tuple{Int,Int}}()

    for (_, pos) in unique_chars
        for (y1, x1) in pos
            for (y2, x2) in pos
                if (y1 != y2 || x1 != x2)
                    Δx = x2 - x1
                    Δy = y2 - y1 
                    if (on_map(x2 + Δx, y2 + Δy))
                        push!(locations, (x2 + Δx, y2 + Δy))
                    end
                end
            end
        end
    end

    return length(locations)
end

# solves the second part of the puzzle
function solution2(map, unique_chars)
    # returns true is a coordinate is on the map
    function on_map(x, y)
        return x >= 1 && x <= size(map, 2) && y >= 1 && y <= size(map, 1)
    end

    locations = Set{Tuple{Int,Int}}()

    for (_, pos) in unique_chars
        for (y1, x1) in pos
            for (y2, x2) in pos
                if (y1 != y2 || x1 != x2)
                    Δx = x2 - x1
                    Δy = y2 - y1 

                    k = 0
                    while (on_map(x2 + k * Δx, y2 + k * Δy))
                        push!(locations, (x2 + k * Δx, y2 + k * Δy))
                        k += 1
                    end
                end
            end
        end
    end

    return length(locations)
end


map, unique_chars = read_input("/Users/rherbrich/src/adventofcode/2024/day8/input.txt")

println("Solution 1 = ", solution1(map, unique_chars))
println("Solution 2 = ", solution2(map, unique_chars))
