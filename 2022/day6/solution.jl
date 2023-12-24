# --- Day 6: Tuning Trouble ---
#
# 2022 written by Ralf Herbrich

# solves the puzzle
function solution(file_name, solution_no)
    # read the input file and parse it for the message
    open(file_name, "r") do file
        line = readline(file)

        # finds the index of the first consecutive occurance of n same symbols
        function find_first_consecutive(n)
            for i = 1:length(line)-n
                s = Set(line[i:(i+n-1)])
                if (length(s) == n)
                    println("Solution: ", i+n-1)
                    break
                end
            end
        end

        if solution_no == 1
            find_first_consecutive(4)
        else
            find_first_consecutive(14)
        end
    end
end


# main entry of the program
if (length(ARGS) != 2)
    println("usage: solution [1|2] <msg-file>")
    exit(-1)
end

solution(ARGS[2], tryparse(Int, ARGS[1]))