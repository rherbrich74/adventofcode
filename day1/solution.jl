# --- Day 1: Calorie Counting ---
#
# 2022 written by Ralf Herbrich

# solves the puzzle
function solution(file_name, solution_no)
    # read the input file and parse it to a list of calories per elf
    elf_calories = open(file_name, "r") do file
        # define the empty array of elf calories
        elf_calories = Vector{Int}()

        # parse each line of the input
        cur_cal_counter = 0;
        for line in eachline(file)
            cals = tryparse(Int, line)
            if (isnothing(cals))
                push!(elf_calories, cur_cal_counter)
                cur_cal_counter = 0
            else
                cur_cal_counter = cur_cal_counter + cals
            end
        end

        # return the maximum calories
        elf_calories
    end

    if (solution_no == 1)
        # Output the maximum of the calories on the screen
        println("Score: ", maximum(elf_calories))
    else 
        sort!(elf_calories, rev=true)
        # Output the sum of the top three elf calories
        println("Score: ", elf_calories[1] + elf_calories[2] + elf_calories[3])
    end
end

# main entry of the program
if (length(ARGS) != 2)
    println("usage: solution [1|2] <input-file>");
    exit(-1);
end

solution(ARGS[2], tryparse(Int, ARGS[1]))
