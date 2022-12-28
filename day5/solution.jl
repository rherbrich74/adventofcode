# --- Day 5: Supply Stacks ---
#
# 2022 written by Ralf Herbrich

# solves the puzzle
function solution(file_name, solution_no)
    # read the input file and parse it to build up the stacks
    open(file_name, "r") do file

        # determine the number of stacks and temporarily store all stacks
        stacks_str = Vector{String}()
        no_stacks = 0
        while (true)
            line = readline(file) 
            m = eachmatch(r"( [0-9] )", line) |> collect
            if (length(m) == 0)
                push!(stacks_str, line)
            else
                no_stacks = length(m)
                break
            end
        end

        # now parse the indiviudal stack strings and build the stacks
        stacks = [Vector{Char}() for _ in 1:no_stacks]
        for line in stacks_str
            m = eachmatch(r"(\[(.)\])+", line) |> collect
            for i in m 
                push!(stacks[(i.offset[1] - 1)÷4+1], i.captures[1][2])
            end
        end
        stacks = map(reverse, stacks)

        # eventually parse and execute all commands from the file on the stacks
        readline(file)
        while (true)
            line = readline(file)
            m = match(r"move ([0-9]+) from ([0-9]+) to ([0-9]+)", line)
            if (!isnothing(m))
                n = tryparse(Int, m[1])
                from = tryparse(Int, m[2])
                to = tryparse(Int, m[3])
                if (solution_no == 1)
                    for i in 1:n
                        push!(stacks[to], stacks[from][end])
                        stacks[from] = stacks[from][1:end-1]
                    end
                else
                    for i in 1:n
                        push!(stacks[to], stacks[from][end-n+i])
                    end
                    stacks[from] = stacks[from][1:end-n]
                end
            else
                break
            end
        end

        # print the final solution word
        print("Solution = ")
        for i = 1:no_stacks
            print(stacks[i][end])
        end
        println()
    end
end

# main entry of the program
if (length(ARGS) != 2)
    println("usage: solution [1|2] <rps-file>")
    exit(-1)
end

solution(ARGS[2], tryparse(Int, ARGS[1]))