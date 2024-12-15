# Solves the seventh day of the Advent of Code 2024
#
# 2024 by Ralf Herbrich
# Hasso Plattner Institute, University of Potsdam, Germany

# puzzle input format
struct NumberPuzzle
    result::Int
    numbers::Vector{Int}
end

# reads the input data from a file
function read_input(filename)
    # regex pattern for reading a number followed by a colon and a whitespace separated list of numbers
    pat = r"(\d+): (.*)"
    open(filename) do file
        puzzles = Vector{NumberPuzzle}()
        for line in eachline(file)
            m = match(pat, line)
            push!(puzzles, NumberPuzzle(parse(Int, m.captures[1]), parse.(Int, split(m.captures[2], " "))))
        end
        return puzzles
    end
end

# solves the first part of the puzzle
function solution1(puzzles)
    # checks if a solution exists for a given puzzle
    function is_solvable(index, result, puzzle)
        if (index == 1)
            return result == puzzle.numbers[1]
        end
        val1 = is_solvable(index - 1, result - puzzle.numbers[index], puzzle)
        val2 = (result % puzzle.numbers[index] == 0) && is_solvable(index - 1, result / puzzle.numbers[index], puzzle)
        return val1 || val2
    end

    sum = 0
    for puzzle in puzzles
        if (is_solvable(length(puzzle.numbers), puzzle.result, puzzle))
            sum += puzzle.result
        end
    end

    return sum
end

# solves the second part of the puzzle
function solution2(puzzles)
    # checks if a solution exists for a given puzzle
    function is_solvable(index, result, puzzle)
        if (index == 1)
            return result == puzzle.numbers[1]
        end
        val1 = is_solvable(index - 1, result - puzzle.numbers[index], puzzle)
        val2 = (result % puzzle.numbers[index] == 0) && is_solvable(index - 1, result / puzzle.numbers[index], puzzle)
        base = 10^Int(ceil(log10(puzzle.numbers[index] + 1)))
        val3 = ((result - puzzle.numbers[index]) % base == 0) && is_solvable(index - 1, (result - puzzle.numbers[index]) / base, puzzle)
        return val1 || val2 || val3
    end

    sum = 0
    for puzzle in puzzles
        if (is_solvable(length(puzzle.numbers), puzzle.result, puzzle))
            sum += puzzle.result
        end
    end

    return sum
end

puzzles = read_input("/Users/rherbrich/src/adventofcode/2024/day7/input.txt")

println("Solution 1 = ", solution1(puzzles))
println("Solution 2 = ", solution2(puzzles))

