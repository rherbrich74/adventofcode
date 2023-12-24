# --- Day 4: Camp Cleanup ---
#
# 2022 written by Ralf Herbrich

# solves the puzzle
function solution(file_name, solution_no)
    # parse a line from the input and returns 0 or 1 depdening on whether there was containment
    function solution1_score(((a1,a2),(b1,b2)))
        if ((a1 ≥ b1 && a2 ≤ b2) || ((b1 ≥ a1 && b2 ≤ a2))) 1 else 0 end
    end

    # parse a line from the input and returns 0 or 1 depdening on whether there was overlap
    function solution2_score(((a1,a2),(b1,b2)))
        if (a2 < b1 || b2 < a1) 0 else 1 end
    end

    # read the input file and parse it to a score
    open(file_name, "r") do file
        numbers = map(
            # read each line and convert to a pair of number pairs
            function (line)
                a1, a2, b1, b2 = match(r"([0-9]+)-([0-9]+),([0-9]+)-([0-9]+)", line)
                ((tryparse(Int, a1),tryparse(Int, a2)),((tryparse(Int, b1),tryparse(Int, b2))))
            end, eachline(file))
            
        if (solution_no == 1)
            println("Score: ", sum(map(solution1_score, numbers)))
        else
            println("Score: ", sum(map(solution2_score, numbers)))
        end 
    end
end

# main entry of the program
if (length(ARGS) != 2)
    println("usage: solution [1|2] <assignment-file>")
    exit(-1)
end

solution(ARGS[2], tryparse(Int, ARGS[1]))