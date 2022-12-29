# --- Day 10: Cathode-Ray Tube ---
#
# 2022 written by Ralf Herbrich

# solves the puzzle
function solution(file_name, solution_no)
    open(file_name, "r") do file
        # processor state
        no_cycles = 1
        x = 1
        # score of the execution
        score = 0

        function tick()
            # Part I of the computation 
            if (no_cycles == 20 || no_cycles == 60 || no_cycles == 100 || no_cycles == 140 || no_cycles == 180 || no_cycles == 220)
                score += no_cycles * x
            end

            # Part II of the computation (printing)
            column = (no_cycles - 1) % 40
            print((column == x - 1 || column == x || column == x + 1) ? '#' : '.')
            if (no_cycles % 40 == 0)
                println();
            end
        
            no_cycles+=1
        end

        # processes the file using a specified tick function§
        function process(tick)
            score = 0

            # interpret line-by-line
            for line in eachline(file)
                if (line == "noop")
                    tick()
                elseif (length(line) > 4 && line[1:4] == "addx")
                    tick()
                    tick()
                    x += tryparse(Int,line[5:end])
                end
            end

            return (score)
        end

        println("Score = ", process(tick))
    end
end

# main entry of the program
if (length(ARGS) != 2)
    println("usage: solution [1|2] <code-file>")
    exit(-1)
end

solution(ARGS[2], tryparse(Int, ARGS[1]))