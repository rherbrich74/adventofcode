# Solves the twenty second day of the Advent of Code 2024
#
# 2024 by Ralf Herbrich
# Hasso Plattner Institute, University of Potsdam, Germany

# reads the input data from a file
function read_input(filename)
    open(filename) do file
        return parse.(Int, readlines(file))
    end
end

# evolves a pseudo-random number by one step
function evolve(seed::Int)
    seed = ((seed << 6) ⊻ seed) % 16777216
    seed = (seed >> 5) ⊻ seed
    seed = ((seed << 11) ⊻ seed) % 16777216
    return seed
end

# solves the first part of the puzzle
function solution1(seeds)
    # evolves the pseudo-random number 2000 times
    sum = 0
    for seed in seeds
        initial = seed
        for _ in 1:2000
            seed = evolve(seed)
        end
        sum += seed
        # println(initial, ": ", seed)
    end

    return sum
end

# solves the second part of the puzzle
function solution2(seeds)
    # determines the bidding prizes in the 2000 evolutions
    function get_prizes(seed)
        prizes = Vector{Int}()
        for _ in 1:2000
            before_prize = seed % 10
            push!(prizes, before_prize)
            seed = evolve(seed)
        end
        push!(prizes, seed % 10)

        return prizes
    end

    # builds up a dictionary of all wins for a given prize change history
    function build_prize_change_history(prizes)
        prize_change_history = Dict{Tuple{Int,Int,Int,Int}, Int}()
        prize_changes = prizes[2:end] .- prizes[1:end-1]
        for i in 4:length(prize_changes)
            key = (prize_changes[i - 3], prize_changes[i - 2], prize_changes[i - 1], prize_changes[i])
            if !(haskey(prize_change_history, key))
                prize_change_history[key] = prizes[i + 1]
            end
        end

        return prize_change_history
    end

    # builds up a list of all prize change histories and sum up the total wins
    wins = Dict{Tuple{Int,Int,Int,Int}, Int}()
    for d in map(build_prize_change_history, map(get_prizes, seeds))
        for (key, value) in d
            if haskey(wins, key)
                wins[key] += value
            else
                wins[key] = value
            end
        end
    end

    return maximum(values(wins))
end

seeds = read_input("/Users/rherbrich/src/adventofcode/2024/day22/input.txt")

println("Solution 1 = ", solution1(seeds))
println("Solution 2 = ", solution2(seeds))