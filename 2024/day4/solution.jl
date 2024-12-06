# Solves the fourth day of the Advent of Code 2024
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

# solves the first part of the puzzle
function solution1(maze, word)
    # check if the word fits horizontally
    function check_horizontal(maze, i, j, word)
        if j + length(word) - 1 > size(maze, 2)
            return 0
        end

        for k in eachindex(word)
            if maze[i, j + k - 1] != word[k]
                return 0
            end
        end

        return 1
    end

    # check if the word fits vertically
    function check_vertical(maze, i, j, word)
        if i + length(word) - 1 > size(maze, 1)
            return 0
        end

        for k in eachindex(word)
            if maze[i + k - 1, j] != word[k]
                return 0
            end
        end

        return 1
    end

    # check if the word fits diagonally
    function check_diagonal_forward(maze, i, j, word)
        if i + length(word) - 1 > size(maze, 1) || j + length(word) - 1 > size(maze, 2)
            return 0
        end

        for k in eachindex(word)
            if maze[i + k - 1, j + k - 1] != word[k]
                return 0
            end
        end

        return 1
    end

    # check if the word fits diagonally
    function check_diagonal_backward(maze, i, j, word)
        if i - length(word) + 1 < 1 || j + length(word) - 1 > size(maze, 2)
            return 0
        end

        for k in eachindex(word)
            if maze[i - k + 1, j + k - 1] != word[k]
                return 0
            end
        end

        return 1
    end

    sum = 0
    word_reverse = reverse(word)
    for i in 1:size(maze, 1)
        for j in 1:size(maze, 2)
            sum += check_horizontal(maze, i, j, word) +
                   check_vertical(maze, i, j, word) +
                   check_diagonal_forward(maze, i, j, word) +
                   check_diagonal_backward(maze, i, j, word) +
                   check_horizontal(maze, i, j, word_reverse) +
                   check_vertical(maze, i, j, word_reverse) +
                   check_diagonal_forward(maze, i, j, word_reverse) +
                   check_diagonal_backward(maze, i, j, word_reverse)
        end
    end
    return sum
end

# solves the second part of the puzzle
function solution2(maze)
    # check if the word fits horizontally
    function check_XMAS(maze, i, j)
        if i + 2 > size(maze, 1) || j + 2 > size(maze, 2)
            return false
        end

        if maze[i, j] == 'M' && maze[i + 1, j + 1] == 'A' && maze[i + 2, j + 2] == 'S' && 
            maze[i + 2, j] == 'M' && maze[i, j + 2] == 'S'
             return true
        end
 
        if maze[i, j] == 'M' && maze[i + 1, j + 1] == 'A' && maze[i + 2, j + 2] == 'S' && 
            maze[i + 2, j] == 'S' && maze[i, j + 2] == 'M'
             return true
        end
 
        if maze[i, j] == 'S' && maze[i + 1, j + 1] == 'A' && maze[i + 2, j + 2] == 'M' && 
            maze[i + 2, j] == 'M' && maze[i, j + 2] == 'S'
             return true
        end
 
        if maze[i, j] == 'S' && maze[i + 1, j + 1] == 'A' && maze[i + 2, j + 2] == 'M' && 
            maze[i + 2, j] == 'S' && maze[i, j + 2] == 'M'
             return true
        end
 
        return false
    end

    sum = 0
    for i in 1:size(maze, 1)
        for j in 1:size(maze, 2)
            if check_XMAS(maze, i, j)
                sum += 1
            end
        end
    end
    return sum
end

maze = read_input("/Users/rherbrich/src/adventofcode/2024/day4/input.txt")

println("Solution 1 = ", solution1(maze, "XMAS"))
println("Solution 2 = ", solution2(maze))

