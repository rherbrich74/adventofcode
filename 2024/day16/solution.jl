# Solves the sixteenth day of the Advent of Code 2024
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

# solves the first part of the puzzle
function solution1(maze)
    # finds a letter in the maze
    function find_letter(letter)
        for y in axes(maze, 1)
            for x in axes(maze, 2)
                if maze[y, x] == letter
                    return (x, y)
                end
            end
        end
        return nothing
    end

    # get next location
    function get_next_location(x, y, direction)
        if direction == :north
            return (x, y - 1)
        elseif direction == :south
            return (x, y + 1)
        elseif direction == :west
            return (x - 1, y)
        elseif direction == :east 
            return (x + 1, y)
        end
    end

    # get the maze element at position (x, y) + direction
    function get_maze(x, y, direction)
        new_x, new_y = get_next_location(x, y, direction)
        return maze[new_y, new_x]
    end

    # initialize the clockwise and counter-clockwise directions
    clockwise_directions = Dict(:north => :east, :east => :south, :south => :west, :west => :north)
    counter_clockwise_directions = Dict(:north => :west, :west => :south, :south => :east, :east => :north)

    # find the start and end point
    (start_x, start_y) = find_letter('S')
    (end_x, end_y) = find_letter('E')

    # initialize a priority queue of unfinished nodes
    queue = PriorityQueue{Tuple{Int, Int, Symbol},Int}()

    # initialize the distance matrix for all locations and directions in the maze
    distance = Dict{Tuple{Int, Int, Symbol}, Int}()

    # initialize the distance map and the priority queue
    for y in 2:size(maze, 2)-1
        for x in 2:size(maze, 1)-1
            for direction in [:north, :east, :south, :west]
                if x == start_x && y == start_y && direction == :east
                    distance[(x, y, direction)] = 0
                    queue[(x, y, direction)] = 0
                else
                    distance[(x, y, direction)] = 1000000000
                    queue[(x, y, direction)] = 1000000000
                end
            end
        end
    end

    # run Dijkstra's algorithm
    while length(queue) > 0
        (x, y, direction) = dequeue!(queue)

        # check if moving forward is possible
        if get_maze(x, y, direction) != '#' 
            new_x, new_y = get_next_location(x, y, direction)
            alt = distance[(x, y, direction)] + 1
            if (alt < distance[(new_x, new_y, direction)])
                distance[(new_x, new_y, direction)] = alt
                queue[(new_x, new_y, direction)] = alt
            end
        end

        # check if turning clockwise or counter-clockwise is better in this state
        alt = distance[(x, y, direction)] + 1000
        if (alt < distance[(x, y, clockwise_directions[direction])])
            distance[(x, y, clockwise_directions[direction])] = alt
            queue[(x, y, clockwise_directions[direction])] = alt
        end

        if (alt < distance[(x, y, counter_clockwise_directions[direction])])
            distance[(x, y, counter_clockwise_directions[direction])] = alt
            queue[(x, y, counter_clockwise_directions[direction])] = alt
        end
    end

    solution = minimum([distance[(end_x, end_y, :north)], distance[(end_x, end_y, :east)], distance[(end_x, end_y, :south)], distance[(end_x, end_y, :west)]])
    return solution
end

# solves the second part of the puzzle
function solution2(maze)
    # finds a letter in the maze
    function find_letter(letter)
        for y in axes(maze, 1)
            for x in axes(maze, 2)
                if maze[y, x] == letter
                    return (x, y)
                end
            end
        end
        return nothing
    end

    # get next location
    function get_next_location(x, y, direction)
        if direction == :north
            return (x, y - 1)
        elseif direction == :south
            return (x, y + 1)
        elseif direction == :west
            return (x - 1, y)
        elseif direction == :east 
            return (x + 1, y)
        end
    end

    # get the maze element at position (x, y) + direction
    function get_maze(x, y, direction)
        new_x, new_y = get_next_location(x, y, direction)
        return maze[new_y, new_x]
    end

    # initialize the clockwise and counter-clockwise directions
    clockwise_directions = Dict(:north => :east, :east => :south, :south => :west, :west => :north)
    counter_clockwise_directions = Dict(:north => :west, :west => :south, :south => :east, :east => :north)

    # find the start and end point
    (start_x, start_y) = find_letter('S')
    (end_x, end_y) = find_letter('E')

    # initialize a priority queue of unfinished nodes
    queue = PriorityQueue{Tuple{Int, Int, Symbol},Int}()

    # initialize the distance matrix for all locations and directions in the maze
    distance = Dict{Tuple{Int, Int, Symbol}, Int}()

    # list of all predecessors on the shortest paths to the start
    predecessor = Dict{Tuple{Int, Int, Symbol}, Vector{Tuple{Int, Int, Symbol}}}()

    # initialize the distance map and the priority queue
    for y in 2:size(maze, 2)-1
        for x in 2:size(maze, 1)-1
            for direction in [:north, :east, :south, :west]
                if x == start_x && y == start_y && direction == :east
                    distance[(x, y, direction)] = 0
                    queue[(x, y, direction)] = 0
                else
                    distance[(x, y, direction)] = 1000000000
                    queue[(x, y, direction)] = 1000000000
                end
            end
        end
    end

    # run Dijkstra's algorithm
    while length(queue) > 0
        (x, y, direction) = dequeue!(queue)

        # check if moving forward is possible
        if get_maze(x, y, direction) != '#' 
            new_x, new_y = get_next_location(x, y, direction)
            alt = distance[(x, y, direction)] + 1
            if (alt < distance[(new_x, new_y, direction)])
                distance[(new_x, new_y, direction)] = alt
                queue[(new_x, new_y, direction)] = alt
                predecessor[(new_x, new_y, direction)] = [(x, y, direction)]
            elseif alt == distance[(new_x, new_y, direction)]
                push!(predecessor[(new_x, new_y, direction)], (x, y, direction))
            end
        end

        # check if turning clockwise or counter-clockwise is better in this state
        alt = distance[(x, y, direction)] + 1000
        if (alt < distance[(x, y, clockwise_directions[direction])])
            distance[(x, y, clockwise_directions[direction])] = alt
            queue[(x, y, clockwise_directions[direction])] = alt
            predecessor[(x, y, clockwise_directions[direction])] = [(x, y, direction)]
        elseif alt == distance[(x, y, clockwise_directions[direction])]
            push!(predecessor[(x, y, clockwise_directions[direction])], (x, y, direction))
        end

        if (alt < distance[(x, y, counter_clockwise_directions[direction])])
            distance[(x, y, counter_clockwise_directions[direction])] = alt
            queue[(x, y, counter_clockwise_directions[direction])] = alt
            predecessor[(x, y, counter_clockwise_directions[direction])] = [(x, y, direction)]
        elseif alt == distance[(x, y, counter_clockwise_directions[direction])]
            push!(predecessor[(x, y, counter_clockwise_directions[direction])], (x, y, direction))
        end
    end

    solution = minimum([distance[(end_x, end_y, :north)], distance[(end_x, end_y, :east)], distance[(end_x, end_y, :south)], distance[(end_x, end_y, :west)]])
    if solution == distance[(end_x, end_y, :north)]
        end_direction = :north
    elseif solution == distance[(end_x, end_y, :east)]
        end_direction = :east
    elseif solution == distance[(end_x, end_y, :south)]
        end_direction = :south
    else
        end_direction = :west
    end
    
    shortest_path_nodes = Set{Tuple{Int, Int}}()

    # traverses all nodes on all shortest paths
    function dfs(x, y, direction)
        push!(shortest_path_nodes, (x, y))

        if x == start_x && y == start_y && direction == :east
            return
        end

        for pred in predecessor[(x, y, direction)]
            dfs(pred...)
        end
    end

    dfs(end_x, end_y, end_direction)

    return length(shortest_path_nodes)
end

maze = read_input("/Users/rherbrich/src/adventofcode/2024/day16/input.txt")

println("Solution 1 = ", solution1(maze))
println("Solution 2 = ", solution2(maze))