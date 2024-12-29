# Solves the twentieth day of the Advent of Code 2024
#
# 2024 by Ralf Herbrich
# Hasso Plattner Institute, University of Potsdam, Germany

using DataStructures

# reads the input data from a file
function read_input(filename)
    open(filename) do file
        data = readlines(file)
        maze = Matrix{Char}(undef, length(data), length(data[1]))
        for (i, line) in enumerate(data)
            for (j, c) in enumerate(line)
                maze[i, j] = c
            end
        end
        return maze
    end
end

# finds a letter in the maze
function find_letter(maze, letter)
    for y in axes(maze, 1)
        for x in axes(maze, 2)
            if maze[y, x] == letter
                return (x, y)
            end
        end
    end
    return nothing
end

# builds a map of distances from the start position and the path to the finish
function build_distances_from_start(maze)
    # create a map of distances from start and a path of all race positions
    distances_from_start = -1 * ones(Int, size(maze)...)
    path = Vector{Tuple{Int, Int}}()

    start_x, start_y = find_letter(maze, 'S')
    end_x, end_y = find_letter(maze, 'E')

    x, y = start_x, start_y
    distance = 0
    while x != end_x || y != end_y
        distances_from_start[y, x] = distance
        push!(path, (x, y))
        
        if maze[y, x + 1] != '#' && distances_from_start[y, x + 1] == -1
            x += 1
        elseif maze[y + 1, x] != '#' && distances_from_start[y + 1, x] == -1
            y += 1
        elseif maze[y, x - 1] != '#' && distances_from_start[y, x - 1] == -1
            x -= 1
        elseif maze[y - 1, x] != '#' && distances_from_start[y - 1, x] == -1
            y -= 1
        else
            break
        end

        distance += 1
    end
    distances_from_start[y, x] = distance

    return distances_from_start, path
end

# solves the first part of the puzzle
function solution1(maze)
    distances_from_start, path = build_distances_from_start(maze)

    ## check every single position on the race track if we can breach a wall
    counts = zeros(Int, length(path))
    for (x, y) in path
        if x < size(maze, 2) - 1 && maze[y, x+2] != '#'
            savings = distances_from_start[y, x+2] - distances_from_start[y, x] - 2
            if savings > 0
                counts[savings] += 1
            end
        end

        if x > 2 && maze[y, x-2] != '#'
            savings = distances_from_start[y, x-2] - distances_from_start[y, x] - 2
            if savings > 0
                counts[savings] += 1
            end
        end

        if y < size(maze, 1) - 1 && maze[y+2, x] != '#'
            savings = distances_from_start[y+2, x] - distances_from_start[y, x] - 2
            if savings > 0
                counts[savings] += 1
            end
        end

        if y > 2 && maze[y-2, x] != '#'
            savings = distances_from_start[y-2, x] - distances_from_start[y, x] - 2
            if savings > 0
                counts[savings] += 1
            end
        end
    end

    # for i in 1:length(counts)
    #     if counts[i] > 0
    #         println("There are ", counts[i], " cheats that save ", i, " picoseconds")
    #     end
    # end

    return sum(counts[100:end])
end

# solves the second part of the puzzle
function solution2(maze)
    distances_from_start, path = build_distances_from_start(maze)

    ## check every single position on the race track if we can breach a wall
    counts = zeros(Int, length(path))
    for (x, y) in path
        # check all locations that have a constant Manhattan distance of 20
        for Δx in -20:20
            for Δy in -20:20
                if abs(Δx) + abs(Δy) <= 20
                    distance = abs(Δx) + abs(Δy)
                    if x + Δx >= 1 && x + Δx <= size(maze, 2) && y + Δy >= 1 && y + Δy <= size(maze, 1)
                        if maze[y + Δy, x + Δx] != '#'
                            savings = distances_from_start[y + Δy, x + Δx] - distances_from_start[y, x] - distance
                            if savings > 0
                                counts[savings] += 1
                            end
                        end
                    end
                end
            end
        end
    end

    # for i in 1:length(counts)
    #     if counts[i] > 0
    #         println("There are ", counts[i], " cheats that save ", i, " picoseconds")
    #     end
    # end

    return sum(counts[100:end])
end

maze = read_input("/Users/rherbrich/src/adventofcode/2024/day20/input.txt")

println("Solution 1 = ", solution1(maze))
println("Solution 2 = ", solution2(maze))