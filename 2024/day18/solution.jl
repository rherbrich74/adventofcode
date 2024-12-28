# Solves the eighteenth day of the Advent of Code 2024
#
# 2024 by Ralf Herbrich
# Hasso Plattner Institute, University of Potsdam, Germany

using DataStructures

# reads the input data from a file
function read_input(filename)
    open(filename) do file
        locations = Vector{Tuple{Int,Int}}()
        for line in eachline(file)
            push!(locations, (parse(Int, split(line, ",")[1]), parse(Int, split(line, ",")[2])))
        end
        return locations
    end
end

# prints the maze
function print_map(map)
    for y in axes(map, 1)
        for x in axes(map, 2)
            print(map[y, x])
        end
        println()
    end
end

# shortest path length
function shortest_path_length(map, start, finish)
    # mark the whole map as not visited
    visited = Matrix{Bool}(undef, size(map, 1), size(map, 2))
    for y in axes(visited, 1)
        for x in axes(visited, 2)
            visited[y, x] = false
        end
    end

    # find the length of the shortest path using breath-first search
    q = Queue{Tuple{Int,Int,Int}}()
    enqueue!(q, (start[1], start[2], 0))
    while !isempty(q)
        x, y, d = dequeue!(q)

        # check if we reached the finish
        if x == finish[1] && y == finish[2]
            return d
        end

        # make sure we are not walking loops
        if visited[y, x]
            continue
        end
        visited[y, x] = true

        # check the four directions: up
        if y > 1 && map[y-1, x] != '#'
            enqueue!(q, (x, y-1, d+1))
        end

        # check the four directions: down
        if y < size(map, 1) && map[y+1, x] != '#'
            enqueue!(q, (x, y+1, d+1))
        end

        # check the four directions: left
        if x > 1 && map[y, x-1] != '#'
            enqueue!(q, (x-1, y, d+1))
        end

        # check the four directions: right
        if x < size(map, 2) && map[y, x+1] != '#'
            enqueue!(q, (x+1, y, d+1))
        end
    end

    return nothing
end

# solves the first part of the puzzle
function solution1(locations, sz, n)
    # setup an empty map
    map = Matrix{Char}(undef, sz+1, sz+1)
    for y in axes(map, 1)
        for x in axes(map, 2)
            map[y, x] = '.'
        end
    end

    # add walls at the locations to the map
    for location in locations[1:n]
        map[location[2]+1, location[1]+1] = '#'
    end

    print_map(map)

    return shortest_path_length(map, (1, 1), (sz+1, sz+1))
end

# solves the second part of the puzzle
function solution2(locations, sz, n)
    # setup an empty map
    map = Matrix{Char}(undef, sz+1, sz+1)
    for y in axes(map, 1)
        for x in axes(map, 2)
            map[y, x] = '.'
        end
    end

    # add walls at the locations to the map
    for location in locations[1:n]
        map[location[2]+1, location[1]+1] = '#'
    end

    for i in n+1:length(locations)
        map[locations[i][2]+1, locations[i][1]+1] = '#'
        if isnothing(shortest_path_length(map, (1, 1), (sz+1, sz+1)))
            return locations[i]
        end
    end
end


locations = read_input("/Users/rherbrich/src/adventofcode/2024/day18/input.txt")

println("Solution 1 = ", solution1(locations, 70, 1024))
println("Solution 2 = ", solution2(locations, 70, 1024))
