# Solves the twenty fifth day of the Advent of Code 2024
#
# 2024 by Ralf Herbrich
# Hasso Plattner Institute, University of Potsdam, Germany

# data structure to hold all keys and locks
struct LocksAndKeys
    keys::Vector{Vector{Int}}
    locks::Vector{Vector{Int}}
end

# reads the input data from a file
function read_input(filename)
    open(filename) do file
        data = readlines(file)

        # parse all the keys
        ks = Vector{Vector{Int}}()
        for i = 1:8:length(data)
            if i+6 <= length(data) && data[i+6] == "#####"
                key = zeros(Int, 5)
                for j in 5:-1:1
                    for key_idx in 1:5
                        if data[i+j][key_idx] == '#'
                            key[key_idx] += 1
                        end
                    end
                end
                push!(ks, key)
            end
        end

        # parse all the locks
        ls = Vector{Vector{Int}}()
        for i = 1:8:length(data)
            if data[i] == "#####"
                lock = zeros(Int, 5)
                for j in 1:5
                    for lock_idx in 1:5
                        if data[i+j][lock_idx] == '#'
                            lock[lock_idx] += 1
                        end
                    end
                end
                push!(ls, lock)
            end
        end

        return LocksAndKeys(ks, ls)
    end
end

# solves the first part of the puzzle
function solution1(locks_and_keys)
    function matches(key, lock)
        for i in 1:5
            if key[i] + lock[i] > 5
                return false
            end
        end
        return true
    end

    sum = 0
    for key in locks_and_keys.keys
        for lock in locks_and_keys.locks
            if matches(key, lock)
                sum += 1
            end
        end
    end

    return sum
end

locks_and_keys = read_input("/Users/rherbrich/src/adventofcode/2024/day25/input.txt")

println("Solution 1 = ", solution1(locks_and_keys))
