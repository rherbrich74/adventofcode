# --- Day 9: Rope Bridge ---
#
# 2022 written by Ralf Herbrich

# solves the puzzle
function solution(file_name, solution_no)
    open(file_name, "r") do file

        function process_rope_move(n)
            # initialize all the positions of rope to zero
            rope = Vector{Tuple{Int,Int}}(undef, 10)
            tail_positions = Set([rope[n]])

            # now go through all the motion commands and execute the head and tail motion
            while (true)
                m = match(r"([RLUD]) ([0-9]+)", readline(file))
                if isnothing(m)
                    break
                else
                    no_steps = tryparse(Int, m[2])
                    for _ in 1:no_steps
                        # move the head one step
                        if (m[1] == "R")
                            rope[1] = (rope[1][1],rope[1][2]+1)
                        elseif (m[1] == "L")
                            rope[1] = (rope[1][1],rope[1][2]-1)
                        elseif (m[1] == "U")
                            rope[1] = (rope[1][1]+1,rope[1][2])
                        elseif (m[1] == "D")
                            rope[1] = (rope[1][1]-1,rope[1][2])
                        end

                        for i = 2:n
                            # check if the rope pieces are touching, ...
                            if (abs(rope[i][1] - rope[i-1][1]) <= 1 && abs(rope[i][2] - rope[i-1][2]) <= 1)
                                # ... then there is no need to move the new rope piece
                                continue
                            else
                                # ... otherwise, move the rope pieces closer together
                                if (rope[i][1] == rope[i-1][1])
                                    # ... either along the y-dimension (if the x-dimension is the same)
                                    rope_y = rope[i][2] + ((rope[i-1][2] > rope[i][2]) ? +1 : -1)
                                    rope[i] = (rope[i][1], rope_y)
                                elseif (rope[i][2] == rope[i-1][2])
                                    # ... or the x-dimension (if the y-dimension is the same)
                                    rope_x = rope[i][1] + ((rope[i-1][1] > rope[i][1]) ? +1 : -1)
                                    rope[i] = (rope_x, rope[i][2])
                                else
                                    # ... or a diagonal move has to be made
                                    rope_x = rope[i][1] + ((rope[i-1][1] > rope[i][1]) ? +1 : -1)
                                    rope_y = rope[i][2] + ((rope[i-1][2] > rope[i][2]) ? +1 : -1)
                                    rope[i] = (rope_x, rope_y)
                                end
                            end
                        end

                        # add the new tail position to the set
                        push!(tail_positions, rope[n])
                    end
                end
            end

            return (length(tail_positions))
        end
        if (solution_no == 1)
            println("Score = ", process_rope_move(2))
        else
            println("Score = ", process_rope_move(10))
        end
    end
end

# main entry of the program
if (length(ARGS) != 2)
    println("usage: solution [1|2] <rope-file>")
    exit(-1)
end

solution(ARGS[2], tryparse(Int, ARGS[1]))