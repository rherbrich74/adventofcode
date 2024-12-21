# Solves the twenty-first day of the Advent of Code 2024
#
# 2024 by Ralf Herbrich
# Hasso Plattner Institute, University of Potsdam, Germany

using DataStructures

const ShortestPadPath = Dict{Tuple{Char, Char}, Vector{String}}

# reads the input data from a file
function read_input(filename)
    open(filename) do file
        return readlines(file)
    end
end

# solves the first part of the puzzle
function solution1(numbers)
    # precompute the shortest path between two elements on a digtial pad
    function precompute_shortest_path()
        digital_pad_neighbors = Dict(
            '0' => [('2', '^'), ('A', '>')],
            '1' => [('4', '^'), ('2', '>')],
            '2' => [('1', '<'), ('3', '>'),('5', '^'), ('0', 'v')],
            '3' => [('6', '^'), ('2', '<'),('A', 'v')],
            '4' => [('7', '^'), ('1', 'v'), ('5', '>')],
            '5' => [('2', 'v'), ('6', '>'), ('4', '<'), ('8', '^')],
            '6' => [('3', 'v'), ('5', '<'), ('9', '^')],
            '7' => [('4', 'v'), ('8', '>')],
            '8' => [('5', 'v'), ('9', '>'), ('7', '<')],
            '9' => [('6', 'v'), ('8', '<')],
            'A' => [('0', '<'), ('3', '^')]
        )

        arrow_pad_neighbors = Dict(
            '^' => [('A', '>'), ('v', 'v')],
            'v' => [('<', '<'), ('^', '^'), ('>', '>')],
            '<' => [('v', '>')],
            '>' => [('A', '^'), ('v', '<')],
            'A' => [('>', 'v'), ('^', '<')]
        )

        function dfs(from, to, paths, visited, path, neighbors)
            if from == to
                path = path * "A"
                if (length(paths) == 0)
                    push!(paths, path)
                else
                    if length(paths[1]) > length(path)
                        filter!(e->false, paths)
                        push!(paths, path)
                    elseif length(paths[1]) == length(path)
                        push!(paths, path)
                    end
                end
                return
            end

            new_visited = copy(visited)
            push!(new_visited, from)
            for (neighbor, direction) in neighbors[from]
                if neighbor in visited
                    continue
                end
                dfs(neighbor, to, paths, new_visited, path * direction, neighbors)
            end
        end

        shortest_path = Dict{Tuple{Char, Char}, Vector{String}}()
        for from in keys(digital_pad_neighbors)
            for to in keys(digital_pad_neighbors)
                paths = Vector{String}()
                dfs(from, to, paths, Set{Char}(), "", digital_pad_neighbors)
                shortest_path[(from, to)] = paths
            end
        end

        for from in keys(arrow_pad_neighbors)
            for to in keys(arrow_pad_neighbors)
                paths = Vector{String}()
                dfs(from, to, paths, Set{Char}(), "", arrow_pad_neighbors)
                shortest_path[(from, to)] = paths
            end
        end

        return shortest_path
    end

    # compute the list of shortest path conversions
    function enumerate_instructions(s, from, paths, path, shortest_path_on_pads)
        if length(s) == 0
            push!(paths, path)
            return
        end

        for p in shortest_path_on_pads[(from, s[1])]
            enumerate_instructions(s[2:end], s[1], paths, path * p, shortest_path_on_pads)
        end
    end

    # solves the shorted code-puzzle for a given number
    function solve(number, shortest_path_on_pads)
        paths = Vector{String}()
        final_instructions = Vector{String}()

        enumerate_instructions(number, 'A', paths, "", shortest_path_on_pads)
        for path in paths
            instructions = Vector{String}()
            enumerate_instructions(path, 'A', instructions, "", shortest_path_on_pads)
            for instruction in instructions
                enumerate_instructions(instruction, 'A', final_instructions, "", shortest_path_on_pads)
            end
        end

        return minimum(map(length, final_instructions))
    end

    shortest_path_on_pads = precompute_shortest_path()
    sum = 0
    for number in numbers
        no = parse(Int, filter(e->e in ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'], number))
        sum += no * solve(number, shortest_path_on_pads)
    end
    
    return sum
end

# solves the second part of the puzzle
function solution2(numbers)
end

numbers = read_input("/Users/rherbrich/src/adventofcode/2024/day21/input.txt")

println("Solution 1 = ", solution1(numbers))
println("Solution 2 = ", solution2(numbers))
