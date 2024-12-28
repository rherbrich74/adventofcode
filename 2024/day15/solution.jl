# Solves the fifteenth day of the Advent of Code 2024
#
# 2024 by Ralf Herbrich
# Hasso Plattner Institute, University of Potsdam, Germany

# the input data structure
struct MazeWorker
    maze::Matrix{Char}
    moves::String
end

# reads the input data from a file
function read_input(filename)
    open(filename) do file
        data = readlines(file)
        # a regular expression that matches a line of all '#' characters
        wall_pattern = r"^#+$"

        height = 2
        while isnothing(match(wall_pattern, data[height]))
            height += 1
        end

        # parse the maze
        maze = Matrix{Char}(undef, height, length(data[1]))
        for i in 1:height
            for (j, c) in enumerate(data[i])
                maze[i, j] = c
            end
        end

        # parse the directions
        moves = join(data[height+1:end], "")
        return MazeWorker(maze, moves)
    end
end

# find the starting position
function find_start(maze)
    for y in axes(maze, 1)
        for x in axes(maze, 2)
            if maze[y, x] == '@'
                return x, y
            end
        end
    end
end

# prints a maze opn the screem
function print_maze(maze)
    for y in axes(maze, 1)
        for x in axes(maze, 2)
            print(maze[y, x])
        end
        println()
    end
end

# solves the first part of the puzzle
function solution1(maze_worker)
    # executes the move by one step in direction `direction` 
    function take_step(x, y, move, maze)
        # execute a move up
        if move == '^'
            if maze[y-1, x] == '#'
                return x, y
            elseif maze[y-1, x] == '.'
                maze[y, x], maze[y-1, x] = '.', '@'
                return x, y-1
            elseif maze[y-1, x] == 'O'
                tmp_y = y-1
                while maze[tmp_y, x] == 'O'
                    tmp_y -= 1
                end
                if maze[tmp_y, x] == '.'
                    maze[y, x], maze[y-1, x], maze[tmp_y, x] = '.', '@', 'O'
                    return x, y-1
                else
                    return x, y
                end
            end
        end

        # execute a move right
        if move == '>'
            if maze[y, x+1] == '#'
                return x, y
            elseif maze[y, x+1] == '.'
                maze[y, x], maze[y, x+1] = '.', '@'
                return x+1, y
            elseif maze[y, x+1] == 'O'
                tmp_x = x+1
                while maze[y, tmp_x] == 'O'
                    tmp_x += 1
                end
                if maze[y, tmp_x] == '.'
                    maze[y, x], maze[y, x+1], maze[y, tmp_x] = '.', '@', 'O'
                    return x+1, y
                else
                    return x, y
                end
            end
        end

        # execute a move down
        if move == 'v'
            if maze[y+1, x] == '#'
                return x, y
            elseif maze[y+1, x] == '.'
                maze[y, x], maze[y+1, x] = '.', '@'
                return x, y+1
            elseif maze[y+1, x] == 'O'
                tmp_y = y+1
                while maze[tmp_y, x] == 'O'
                    tmp_y += 1
                end
                if maze[tmp_y, x] == '.'
                    maze[y, x], maze[y+1, x], maze[tmp_y, x] = '.', '@', 'O'
                    return x, y+1
                else
                    return x, y
                end
            end
        end

        # execute a move left
        if move == '<'
            if maze[y, x-1] == '#'
                return x, y
            elseif maze[y, x-1] == '.'
                maze[y, x], maze[y, x-1] = '.', '@'
                return x-1, y
            elseif maze[y, x-1] == 'O'
                tmp_x = x-1
                while maze[y, tmp_x] == 'O'
                    tmp_x -= 1
                end
                if maze[y, tmp_x] == '.'
                    maze[y, x], maze[y, x-1], maze[y, tmp_x] = '.', '@', 'O'
                    return x-1, y
                else
                    return x, y
                end
            end
        end
    end

    # computes the score of a maze
    function compute_score(maze)
        score = 0
        for y in axes(maze, 1)
            for x in axes(maze, 2)
                if maze[y, x] == 'O'
                    score += (100*(y-1) + (x-1))
                end
            end
        end
        return score
    end


    x, y = find_start(maze_worker.maze)    

    # println("Initial state")
    # print_maze(maze_worker.maze)
    # println()

    for move in maze_worker.moves
        x, y = take_step(x, y, move, maze_worker.maze)

        # println("Move: ", move)
        # print_maze(maze_worker.maze)
        # println()

    end

    return compute_score(maze_worker.maze)
end

# solves the second part of the puzzle
function solution2(maze_worker)
    # grows the maze by a factor of two in width
    function grow_maze(maze)
        height, width = size(maze)
        new_maze = Matrix{Char}(undef, height, 2*width)
        for y in 1:height
            for x in 1:width
                if maze[y, x] == '#'
                    new_maze[y, 2*x-1] = '#'
                    new_maze[y, 2*x] = '#'
                end
                if maze[y, x] == '.'
                    new_maze[y, 2*x-1] = '.'
                    new_maze[y, 2*x] = '.'
                end
                if maze[y, x] == '@'
                    new_maze[y, 2*x-1] = '@'
                    new_maze[y, 2*x] = '.'
                end
                if maze[y, x] == 'O'
                    new_maze[y, 2*x-1] = '['
                    new_maze[y, 2*x] = ']'
                end
            end
        end
        return new_maze
    end

    # executes the move by one step in direction `direction` 
    function take_step(x, y, move, maze)
        # checks is the box can be pushed upwards
        function check_free_box_space_upwards(x, y)
            if maze[y-1, x] == '.' && maze[y-1, x+1] == '.' 
                return true
            elseif maze[y-1, x] == '#' || maze[y-1, x+1] == '#'
                return false
            elseif maze[y-1, x] == '[' && maze[y-1, x+1] == ']'
                return check_free_box_space_upwards(x, y-1)
            elseif maze[y-1, x] == ']' && maze[y-1, x+1] == '.'
                return check_free_box_space_upwards(x-1, y-1)
            elseif maze[y-1, x] == '.' && maze[y-1, x+1] == '['
                return check_free_box_space_upwards(x+1, y-1)
            elseif maze[y-1, x] == ']' && maze[y-1, x+1] == '['
                return check_free_box_space_upwards(x-1, y-1) && check_free_box_space_upwards(x+1, y-1) 
            end
            return true
        end

        # checks is the box can be pushed downwards
        function check_free_box_space_downwards(x, y)
            if maze[y+1, x] == '.' && maze[y+1, x+1] == '.' 
                return true
            elseif maze[y+1, x] == '#' || maze[y+1, x+1] == '#'
                return false
            elseif maze[y+1, x] == '[' && maze[y+1, x+1] == ']'
                return check_free_box_space_downwards(x, y+1)
            elseif maze[y+1, x] == ']' && maze[y+1, x+1] == '.'
                return check_free_box_space_downwards(x-1, y+1)
            elseif maze[y+1, x] == '.' && maze[y+1, x+1] == '['
                return check_free_box_space_downwards(x+1, y+1)
            elseif maze[y+1, x] == ']' && maze[y+1, x+1] == '['
                return check_free_box_space_downwards(x-1, y+1) && check_free_box_space_downwards(x+1, y+1) 
            end
            return true
        end

        # checks is the box can be pushed to the right
        function check_free_box_space_right(x, y)
            if maze[y, x+2] == '.' 
                return true
            elseif maze[y, x+2] == '#' 
                return false
            elseif maze[y, x+2] == '[' 
                return check_free_box_space_right(x+2, y)
            end
            return true
        end

        # checks is the box can be pushed to the left
        function check_free_box_space_left(x, y)
            if maze[y, x-1] == '.' 
                return true
            elseif maze[y, x-1] == '#' 
                return false
            elseif maze[y, x-1] == ']' 
                return check_free_box_space_left(x-2, y)
            end
            return true
        end

        # pushes a box at position x, y upwards 
        function push_upwards(x, y)
            if maze[y-1, x] == '[' && maze[y-1, x+1] == ']'
                push_upwards(x, y-1)
            elseif maze[y-1, x] == ']' && maze[y-1, x+1] == '.'
                push_upwards(x-1, y-1)
            elseif maze[y-1, x] == '.' && maze[y-1, x+1] == '['
                push_upwards(x+1, y-1)
            elseif maze[y-1, x] == ']' && maze[y-1, x+1] == '['
                push_upwards(x-1, y-1)
                push_upwards(x+1, y-1) 
            end
            maze[y, x], maze[y, x+1], maze[y-1, x], maze[y-1, x+1] = maze[y-1, x], maze[y-1, x+1], maze[y, x], maze[y, x+1]
        end

        # pushes a box at position x, y downwards
        function push_downwards(x, y)
            if maze[y+1, x] == '[' && maze[y+1, x+1] == ']'
                push_downwards(x, y+1)
            elseif maze[y+1, x] == ']' && maze[y+1, x+1] == '.'
                push_downwards(x-1, y+1)
            elseif maze[y+1, x] == '.' && maze[y+1, x+1] == '['
                push_downwards(x+1, y+1)
            elseif maze[y+1, x] == ']' && maze[y+1, x+1] == '['
                push_downwards(x-1, y+1)
                push_downwards(x+1, y+1) 
            end
            maze[y, x], maze[y, x+1], maze[y+1, x], maze[y+1, x+1] = maze[y+1, x], maze[y+1, x+1], maze[y, x], maze[y, x+1]
        end

        # pushes a box at position x, y to the right
        function push_right(x, y)
            if maze[y, x+2] == '['
                push_right(x+2, y)
            end
            maze[y, x], maze[y, x+1], maze[y, x+2] = maze[y, x+2], maze[y, x], maze[y, x+1]
        end

        # pushes a box at position x, y to the left
        function push_left(x, y)
            if maze[y, x-1] == ']'
                push_left(x-2, y)
            end
            maze[y, x-1], maze[y, x], maze[y, x+1] = maze[y, x], maze[y, x+1], maze[y, x-1]
        end
        
        # execute a move up
        if move == '^'
            if maze[y-1, x] == '#'
                return x, y
            elseif maze[y-1, x] == '.'
                maze[y, x], maze[y-1, x] = maze[y-1, x], maze[y, x]
                return x, y-1
            elseif maze[y-1, x] == '[' && check_free_box_space_upwards(x, y-1)
                push_upwards(x, y-1)
                maze[y, x], maze[y-1, x] = maze[y-1, x], maze[y, x]
                return x, y-1
            elseif maze[y-1, x] == ']' && check_free_box_space_upwards(x-1, y-1)
                push_upwards(x-1, y-1)
                maze[y, x], maze[y-1, x] = maze[y-1, x], maze[y, x]
                return x, y-1
            else
                return x, y
            end
        end

        # execute a move down
        if move == 'v'
            if maze[y+1, x] == '#'
                return x, y
            elseif maze[y+1, x] == '.'
                maze[y, x], maze[y+1, x] = maze[y+1, x], maze[y, x]
                return x, y+1
            elseif maze[y+1, x] == '[' && check_free_box_space_downwards(x, y+1)
                push_downwards(x, y+1)
                maze[y, x], maze[y+1, x] = maze[y+1, x], maze[y, x]
                return x, y+1
            elseif maze[y+1, x] == ']' && check_free_box_space_downwards(x-1, y+1)
                push_downwards(x-1, y+1)
                maze[y, x], maze[y+1, x] = maze[y+1, x], maze[y, x]
                return x, y+1
            else
                return x, y
            end
        end

        # execute a move right
        if move == '>'
            if maze[y, x+1] == '#'
                return x, y
            elseif maze[y, x+1] == '.'
                maze[y, x], maze[y, x+1] = maze[y, x+1], maze[y, x]
                return x+1, y
            elseif maze[y, x+1] == '[' && check_free_box_space_right(x+1, y)
                push_right(x+1, y)
                maze[y, x], maze[y, x+1] = maze[y, x+1], maze[y, x]
                return x+1, y
            else
                return x, y
            end
        end

        # execute a move left
        if move == '<'
            if maze[y, x-1] == '#'
                return x, y
            elseif maze[y, x-1] == '.'
                maze[y, x], maze[y, x-1] = maze[y, x-1], maze[y, x]
                return x-1, y
            elseif maze[y, x-1] == ']' && check_free_box_space_left(x-2, y)
                push_left(x-2, y)                
                maze[y, x], maze[y, x-1] = maze[y, x-1], maze[y, x]
                return x-1, y
            else
                return x, y
            end
        end
    end

    # computes the score of a maze
    function compute_score(maze)
        score = 0
        for y in axes(maze, 1)
            for x in axes(maze, 2)
                if maze[y, x] == '['
                    score += (100*(y-1) + (x-1))
                end
            end
        end
        return score
    end

    new_maze = grow_maze(maze_worker.maze)
    x, y = find_start(new_maze)
    
    # println("Initial state")
    # print_maze(new_maze)
    # println()

    for move in maze_worker.moves
        x, y = take_step(x, y, move, new_maze)

        # println("Move: ", move)
        # print_maze(new_maze)
        # println()

    end

    return compute_score(new_maze)
end

maze_worker = read_input("/Users/rherbrich/src/adventofcode/2024/day15/input.txt")
println("Solution 1 = ", solution1(maze_worker))

maze_worker = read_input("/Users/rherbrich/src/adventofcode/2024/day15/input.txt")
println("Solution 2 = ", solution2(maze_worker))
