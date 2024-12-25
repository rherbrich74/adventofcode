# Solves the thirteenth day of the Advent of Code 2024
#
# 2024 by Ralf Herbrich
# Hasso Plattner Institute, University of Potsdam, Germany

# the data of a single puzzle
struct Puzzle
    button_A_Δx::Int
    button_A_Δy::Int
    button_B_Δx::Int
    button_B_Δy::Int
    target_x::Int
    target_y::Int
end

# reads the input data from a file
function read_input(filename)
    open(filename) do file
        data = readlines(file)

        # regular expression to match "Button A: X+94, Y+34"
        butA_pat = r"Button A: X\+(\d+), Y\+(\d+)"
        # regular expression to match "Button B: X+94, Y+34"
        butB_pat = r"Button B: X\+(\d+), Y\+(\d+)"
        # regular expression to match "Prize: X=8400, Y=5400"
        prize_pat = r"Prize: X=(\d+), Y=(\d+)"

        # result list
        puzzles = Vector{Puzzle}()

        # parse each puzzle
        line_no = 1
        while line_no <= length(data)
            if !(isnothing(match(butA_pat, data[line_no])))
                button_A_Δx = parse(Int, match(butA_pat, data[line_no]).captures[1])
                button_A_Δy = parse(Int, match(butA_pat, data[line_no]).captures[2])
                
                line_no += 1
                match(butB_pat, data[line_no])
                button_B_Δx = parse(Int, match(butB_pat, data[line_no]).captures[1])
                button_B_Δy = parse(Int, match(butB_pat, data[line_no]).captures[2])

                line_no += 1
                match(prize_pat, data[line_no])
                target_x = parse(Int, match(prize_pat, data[line_no]).captures[1])
                target_y = parse(Int, match(prize_pat, data[line_no]).captures[2])

                line_no += 2

                push!(puzzles, Puzzle(button_A_Δx, button_A_Δy, button_B_Δx, button_B_Δy, target_x, target_y))
            else
                break
            end
        end

        return puzzles
    end
end

# solves the first part of the puzzle
function solution1(puzzles)
    # solves a single puzzle
    function solve_puzzle(puzzle)
        for button_A_presses in 0:100
            for button_B_presses in 0:100
                x = button_A_presses * puzzle.button_A_Δx + button_B_presses * puzzle.button_B_Δx
                y = button_A_presses * puzzle.button_A_Δy + button_B_presses * puzzle.button_B_Δy

                if x == puzzle.target_x && y == puzzle.target_y
                    return button_A_presses*3 + button_B_presses
                end
            end
        end

        return 0
    end

    # solve all puzzles
    sum = 0
    for puzzle in puzzles
        sum += solve_puzzle(puzzle)
    end

    return sum
end

# solves the second part of the puzzle
function solution2(puzzles)
    # solves a single puzzle cleverly
    function solve_puzzle(puzzle)
        # solve the puzzle by solving the linear equation system
        # button_A_presses * puzzle.button_A_Δx + button_B_presses * puzzle.button_B_Δx = puzzle.target_x
        # button_A_presses * puzzle.button_A_Δy + button_B_presses * puzzle.button_B_Δy = puzzle.target_y

        # using Cramer's rule
        det = puzzle.button_A_Δx * puzzle.button_B_Δy - puzzle.button_A_Δy * puzzle.button_B_Δx
        det_A = puzzle.target_x * puzzle.button_B_Δy - puzzle.target_y * puzzle.button_B_Δx
        det_B = puzzle.button_A_Δx * puzzle.target_y - puzzle.button_A_Δy * puzzle.target_x

        button_A_presses = det_A ÷ det
        button_B_presses = det_B ÷ det

        if button_A_presses == det_A / det && button_B_presses == det_B / det
            return button_A_presses*3 + button_B_presses
        else
            return 0
        end
    end

    # solve all puzzles
    sum = 0
    for puzzle in puzzles
        modified_puzzle = Puzzle(puzzle.button_A_Δx, puzzle.button_A_Δy, 
                                 puzzle.button_B_Δx, puzzle.button_B_Δy, 
                                 10000000000000 + puzzle.target_x, 10000000000000 + puzzle.target_y)
        sum += solve_puzzle(modified_puzzle)
    end

    return sum
end

puzzles = read_input("/Users/rherbrich/src/adventofcode/2024/day13/input.txt")

println("Solution 1 = ", solution1(puzzles))
println("Solution 2 = ", solution2(puzzles))

