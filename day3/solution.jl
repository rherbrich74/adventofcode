# --- Day 3: Rucksack Reorganization ---
#
# 2022 written by Ralf Herbrich

# solves the puzzle
function solution(file_name, solution_no)
    # scoring functions for the Part I
    function solution1_score(line)
        # find the duplicate letter in the two halves of the string
        l = Int(length(line) / 2)
        duplicate = Int(first(intersect(Set(line[1:l]), Set(line[(l+1):(2*l)]))))

        # now compute the score
        if (Int('A') <= duplicate <= Int('Z')) 
            duplicate - Int('A') + 27 
        else 
            duplicate - Int('a') + 1
        end
    end    

    # scoring functions for the Part II
    function solution2_score(lines)
        # find the duplicate letter in the three lines
        duplicate = Int(first(intersect(intersect(Set(lines[1]), Set(lines[2])), Set(lines[3]))))

        # now compute the score
        if (Int('A') <= duplicate <= Int('Z')) 
            duplicate - Int('A') + 27 
        else 
            duplicate - Int('a') + 1
        end
    end    

    # read the input file and parse it to a score
    open(file_name, "r") do file
        if (solution_no == 1)
            println("Score: ", sum(map(solution1_score, eachline(file))))
        else
            println("Score: ", sum(map(solution2_score, collect(Iterators.partition(eachline(file), 3)))))
        end 
    end
end

# main entry of the program
if (length(ARGS) != 2)
    println("usage: solution [1|2] <rps-file>")
    exit(-1)
end

solution(ARGS[2], tryparse(Int, ARGS[1]))