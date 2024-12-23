# Solves the tenth day of the Advent of Code 2024
#
# 2024 by Ralf Herbrich
# Hasso Plattner Institute, University of Potsdam, Germany

# reads the input data from a file
function read_input(filename)
    open(filename) do file
        data = readlines(file)
        map = Matrix{Int}(undef, length(data), length(data[1]))
        for (i, line) in enumerate(data)
            for (j, c) in enumerate(line)
                map[i, j] = if isdigit(c) parse(Int, c) else -1 end
            end
        end
        return map
    end
end

# solves the first part of the puzzle
function solution1(map)
    # counts the number of full paths starting from a given position
    function count_full_paths(i, j)
        # initialize an matrix visited with false
        visited = falses(size(map))

        function dfs(i, j)
            # mark the current position as visited
            visited[i, j] = true

            # if we reached the end of the path, return 1
            if map[i, j] == 9
                return 1
            end
            
            # check the path to the right, left, up, and down and sum up the number of paths
            total_paths = 0
            if i < size(map, 1) && !visited[i + 1, j] && map[i + 1, j] == map[i, j] + 1
                total_paths += dfs(i + 1, j)
            end
            if j < size(map, 2) && !visited[i, j + 1] && map[i, j + 1] == map[i, j] + 1
                total_paths += dfs(i, j + 1)
            end
            if i > 1 && !visited[i - 1, j] && map[i - 1, j] == map[i, j] + 1
                total_paths += dfs(i - 1, j)
            end
            if j > 1 && !visited[i, j - 1] && map[i, j - 1] == map[i, j] + 1
                total_paths += dfs(i, j - 1)
            end

            return total_paths
        end

        return dfs(i, j)
    end

    sum = 0
    for i in axes(map, 1)
        for j in axes(map, 2)
            if map[i, j] == 0
                sum += count_full_paths(i, j)
            end
        end
    end

    return sum
end

# solves the second part of the puzzle
function solution2(compressed)
    # counts the number of full paths starting from a given position
    function count_full_paths(i, j)
        # initialize an matrix visited with false
        visited = falses(size(map))

        function dfs(i, j)
            # mark the current position as visited
            visited[i, j] = true

            # if we reached the end of the path, return 1
            if map[i, j] == 9
                visited[i, j] = false
                return 1
            end
            
            # check the path to the right, left, up, and down and sum up the number of paths
            total_paths = 0
            if i < size(map, 1) && !visited[i + 1, j] && map[i + 1, j] == map[i, j] + 1
                total_paths += dfs(i + 1, j)
            end
            if j < size(map, 2) && !visited[i, j + 1] && map[i, j + 1] == map[i, j] + 1
                total_paths += dfs(i, j + 1)
            end
            if i > 1 && !visited[i - 1, j] && map[i - 1, j] == map[i, j] + 1
                total_paths += dfs(i - 1, j)
            end
            if j > 1 && !visited[i, j - 1] && map[i, j - 1] == map[i, j] + 1
                total_paths += dfs(i, j - 1)
            end

            # unset visited
            visited[i, j] = false

            return total_paths
        end

        return dfs(i, j)
    end

    sum = 0
    for i in axes(map, 1)
        for j in axes(map, 2)
            if map[i, j] == 0
                sum += count_full_paths(i, j)
            end
        end
    end

    return sum
end

map = read_input("/Users/rherbrich/src/adventofcode/2024/day10/input.txt")

println("Solution 1 = ", solution1(map))
println("Solution 2 = ", solution2(map))
