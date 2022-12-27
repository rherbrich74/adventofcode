# --- Day 2: Rock Paper Scissors ---
#
# 2022 written by Ralf Herbrich

# solves the puzzle
function solution(file_name, solution_no)
    # computes score for each game based on mine and opponents move (Part 1)
    function solution1_score(me, opp)
        outcome_score = 
            if (me == opp) 
                3 
            else 
                if ((me == 0 && opp == 2) || (me == 2 && opp == 1) || (me == 1 && opp == 0)) 
                    6 
                else 
                    0 
                end
            end
        shape_score = me + 1
        outcome_score + shape_score
    end

    # computes the  score based on opponent move and outcome for each game (Part 2)
    function solution2_score(opp, outcome)
        me = 
            if (outcome == 0) 
                if (opp == 0) 
                    2 
                elseif (opp == 1)
                    0
                else
                    1
                end 
            elseif (outcome == 2)
                if (opp == 0) 
                    1 
                elseif (opp == 1)
                    2
                else
                    0
                end
            else
                opp
            end
        outcome_score = 3 * outcome
        shape_score = me + 1;
        outcome_score + shape_score
    end

    # read the input file and parse it to a score
    open(file_name, "r") do file
        individual_scores = map(
            function (line)
                opp = line[1] - 'A'
                me = line[3] - 'X'
                if (solution_no == 1) solution1_score(opp, me) else solution2_score(opp, me) end
            end,
            eachline(file))
        println("Score: ", sum(individual_scores))
    end
end

# main entry of the program
if (length(ARGS) != 2)
    println("usage: solution [1|2] <rps-file>");
    exit(-1);
end

solution(ARGS[2], tryparse(Int, ARGS[1]))