# Solves the second day of the Advent of Code 2024
#
# 2024 by Ralf Herbrich
# Hasso Plattner Institute, University of Potsdam, Germany

# reads the input data from a file
function read_input(filename)
    open(filename) do file
        ids = Vector{Vector{Int}}()
        for line in eachline(file)
            push!(ids, parse.(Int, split(line, " ")))
        end
        return ids
    end
end

# solves the first part of the puzzle
function solution1(ids)
    # checks that a list if all decreasing
    function all_decreasing(id_list)
        for i in 2:length(id_list)
            if (id_list[i-1] <= id_list[i]) || (id_list[i-1] > id_list[i] + 3)
                return false
            end
        end
        return true
    end

    # checks that a list if all increasing
    function all_increasing(id_list)
        for i in 2:length(id_list)
            if (id_list[i-1] >= id_list[i]) || (id_list[i] > id_list[i-1] + 3)
                return false
            end
        end
        return true
    end

    sum = 0
    for id_list in ids
        if all_decreasing(id_list) || all_increasing(id_list)
            sum += 1
        end
    end

    return sum
end

# solves the second part of the puzzle
function solution2(ids)
    # checks that a list if all decreasing
    function all_decreasing(id_list)
        for i in 2:length(id_list)
            if (id_list[i-1] <= id_list[i]) || (id_list[i-1] > id_list[i] + 3)
                return false
            end
        end
        return true
    end

    # checks that a list if all increasing
    function all_increasing(id_list)
        for i in 2:length(id_list)
            if (id_list[i-1] >= id_list[i]) || (id_list[i] > id_list[i-1] + 3)
                return false
            end
        end
        return true
    end

    sum = 0
    for id_list in ids
        if all_decreasing(id_list) || all_increasing(id_list)
            sum += 1
        else
            # try to remove a single element and check whether the conditions are still true
            for i in 1:length(id_list)
                if all_decreasing([id_list[1:i-1]; id_list[i+1:end]]) || all_increasing([id_list[1:i-1]; id_list[i+1:end]])
                    sum += 1
                    break
                end
            end
        end
    end

    return sum
end

ids = read_input("/Users/rherbrich/src/adventofcode/2024/day2/input.txt")

println("Solution 1 = ", solution1(ids))
println("Solution 2 = ", solution2(ids))
