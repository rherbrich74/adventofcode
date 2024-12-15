# Solves the sixth day of the Advent of Code 2024
#
# 2024 by Ralf Herbrich
# Hasso Plattner Institute, University of Potsdam, Germany

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

# find the starting position
function find_start(maze)
    for y in 1:size(maze, 1)
        for x in 1:size(maze, 2)
            if maze[y, x] == '^'
                return x, y
            end
        end
    end
end

# next_step returns the next step in the maze given the direction
function next_step(x, y, direction, maze)
    # start going up
    if direction == :up
        if y == 1
            return x, y-1, :up
        else
            if maze[y-1, x] == '#'
                return next_step(x, y, :right, maze)
            else
                return x, y-1, direction
            end
        end
    end

    # start going right
    if direction == :right
        if x == size(maze, 2)
            return x+1, y, :right
        else
            if maze[y, x+1] == '#'
                return next_step(x, y, :down, maze)
            else
                return x+1, y, direction
            end
        end
    end

    # start going down
    if direction == :down
        if y == size(maze, 1)
            return x, y+1, :down
        else
            if maze[y+1, x] == '#'
                return next_step(x, y, :left, maze)
            else
                return x, y+1, direction
            end
        end
    end

    # start going left
    if direction == :left
        if x == 1
            return x-1, y, :left
        else
            if maze[y, x-1] == '#'
                return next_step(x, y, :up, maze)
            else
                return x-1, y, direction
            end
        end
    end
end

# checks if the position is outside the maze
function outside_maze(x, y, maze)
    if (x < 1) || (x > size(maze, 2)) || (y < 1) || (y > size(maze, 1))
        return true
    else
        return false
    end
end

# checks if putting a wall at the current position leads to a loop
function leads_to_loop(x, y, direction, maze)
    tmp_maze = deepcopy(maze)

    # place a unique direction into the maze
    function place_position(x, y, direction)
        if direction == :up
            tmp_maze[y, x] = '^'
        elseif direction == :right
            tmp_maze[y, x] = '>'
        elseif direction == :down
            tmp_maze[y, x] = 'v'
        elseif direction == :left
            tmp_maze[y, x] = '<'
        end
    end
    
    place_position(x, y, direction)
    new_x, new_y, _ = next_step(x, y, direction, tmp_maze)
    tmp_maze[new_y, new_x] = '#'

    while true
        x, y, direction = next_step(x, y, direction, tmp_maze)
        if outside_maze(x, y, tmp_maze) 
            return false
        else
            if (tmp_maze[y,x] == '^') && direction == :up
                return true
            elseif (tmp_maze[y,x] == '>') && direction == :right
                return true
            elseif (tmp_maze[y,x] == 'v') && direction == :down
                return true
            elseif (tmp_maze[y,x] == '<') && direction == :left
                return true
            end

            place_position(x, y, direction)
        end
    end

    return false
end

# solves the first part of the puzzle
function solution1(maze)
    x, y = find_start(maze)
    direction = :up

    steps = 1
    while true
        maze[y, x] = 'X'
        x, y, direction = next_step(x, y, direction, maze)
        if outside_maze(x, y, maze) 
            break
        else
            if (maze[y,x] != 'X')
                steps += 1
            end
        end
    end

    return steps
end

# solves the second part of the puzzle
function solution2(maze)
    x, y = find_start(maze)
    direction = :up
    loops = 0

    while true
        maze[y, x] = 'X'
        new_x, new_y, new_direction = next_step(x, y, direction, maze)
        if outside_maze(new_x, new_y, maze) 
            break
        else
            if (maze[new_y,new_x] != 'X')
                if (leads_to_loop(x, y, direction, maze))
                    loops += 1
                end
            end
            x, y, direction = new_x, new_y, new_direction
        end
    end

    return loops
end

maze = read_input("/Users/rherbrich/src/adventofcode/2024/day6/input.txt")
println("Solution 1 = ", solution1(maze))

maze = read_input("/Users/rherbrich/src/adventofcode/2024/day6/input.txt")
println("Solution 2 = ", solution2(maze))