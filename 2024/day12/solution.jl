# Solves the twelfth day of the Advent of Code 2024
#
# 2024 by Ralf Herbrich
# Hasso Plattner Institute, University of Potsdam, Germany

# reads the input data from a file
function read_input(filename)
    open(filename) do file
        data = readlines(file)
        map = Matrix{Char}(undef, length(data), length(data[1]))
        for (i, line) in enumerate(data)
            for (j, c) in enumerate(line)
                map[i, j] = c
            end
        end
        return map
    end
end

# solves the first part of the puzzle
function solution1(map)
    # determines the unique area characters in the map
    function get_unique_labels(map)
        labels = Set{Char}()
        for c in map
            push!(labels, c)
        end

        return labels
    end

    # gets the price of land of label `label` on the map
    function get_price(map, label)
        visited = falses(size(map))

        # computes the area and perimeter of the area starting at position (i, j)
        function get_area_and_perimeter(i, j)
            visited[i, j] = true

            # determine the area for the piece of land at (i, j)
            area = 1

            # determine the perimeter for the piece of land at (i, j)
            perimeter = 0
            if i == 1 || map[i-1, j] != label
                perimeter += 1
            end
            if i == size(map, 1) || map[i+1, j] != label
                perimeter += 1
            end
            if j == 1 || map[i, j-1] != label
                perimeter += 1
            end
            if j == size(map, 2) || map[i, j+1] != label
                perimeter += 1
            end
    
            if i > 1 && map[i-1, j] == label && visited[i-1, j] == false
                (other_area, other_perimeter) = get_area_and_perimeter(i-1, j)
                area += other_area
                perimeter += other_perimeter
            end
            if i < size(map, 1) && map[i+1, j] == label && visited[i+1, j] == false
                (other_area, other_perimeter) = get_area_and_perimeter(i+1, j)
                area += other_area
                perimeter += other_perimeter
            end
            if j > 1 && map[i, j-1] == label && visited[i, j-1] == false
                (other_area, other_perimeter) = get_area_and_perimeter(i, j-1)
                area += other_area
                perimeter += other_perimeter
            end
            if j < size(map, 2) && map[i, j+1] == label && visited[i, j+1] == false
                (other_area, other_perimeter) = get_area_and_perimeter(i, j+1)
                area += other_area
                perimeter += other_perimeter
            end

            return (area, perimeter)
        end

        price = 0
        for i in axes(map, 1)
            for j in axes(map, 2)
                if map[i, j] == label && visited[i, j] == false
                    (area, perimeter) = get_area_and_perimeter(i, j)
                    price += area * perimeter
                end
            end
        end

        return price
    end

    sum = 0
    for c in get_unique_labels(map)
        price = get_price(map, c)
        sum += price
    end

    return sum
end

# solves the second part of the puzzle
function solution2(map)
    # determines the unique area characters in the map
    function get_unique_labels(map)
        labels = Set{Char}()
        for c in map
            push!(labels, c)
        end

        return labels
    end

    # gets the price of land of label `label` on the map
    function get_price(map, label)
        visited = falses(size(map))

        # computes the of the area starting at position (i, j)
        function get_land(i, j)
            visited[i, j] = true

            land = Set{Tuple{Int, Int}}()
            push!(land, (i, j))
            if i > 1 && map[i-1, j] == label && visited[i-1, j] == false
                union!(land, get_land(i-1, j))
            end
            if i < size(map, 1) && map[i+1, j] == label && visited[i+1, j] == false
                union!(land, get_land(i+1, j))
            end
            if j > 1 && map[i, j-1] == label && visited[i, j-1] == false
                union!(land, get_land(i, j-1))
            end
            if j < size(map, 2) && map[i, j+1] == label && visited[i, j+1] == false
                union!(land, get_land(i, j+1))
            end

            return land
        end

        # computes the area of a piece of land
        function get_area(land)
            return length(land)
        end

        # computes the perimeter of a piece of land
        function get_perimeter(land)
            # store all the fences
            fence = Set{Tuple{Int, Int, Symbol}}()

            # construct the fence around the perimeter of the land and count every piece 
            perimeter = 0
            for (i, j) in land
                # determine the perimeter for the piece of land at (i, j)
                if i == 1 || map[i-1, j] != label
                    push!(fence, (i, j, :up))
                    perimeter += 1
                end
                if i == size(map, 1) || map[i+1, j] != label
                    push!(fence, (i, j, :down))
                    perimeter += 1
                end
                if j == 1 || map[i, j-1] != label
                    push!(fence, (i, j, :left))
                    perimeter += 1
                end
                if j == size(map, 2) || map[i, j+1] != label
                    push!(fence, (i, j, :right))
                    perimeter += 1
                end
            end

            # remove all the fences that are on the same straight line
            while !isempty(fence)
                (i, j, direction) = first(fence)
                delete!(fence, (i, j, direction))
                if direction == :up
                    k = 1
                    while ((i, j+k, :up) in fence)
                        delete!(fence, (i, j+k, :up))
                        perimeter -= 1
                        k += 1
                    end
                    k = 1
                    while ((i, j-k, :up) in fence)
                        delete!(fence, (i, j-k, :up))
                        perimeter -= 1
                        k += 1
                    end
                end

                if direction == :down
                    k = 1
                    while ((i, j+k, :down) in fence)
                        delete!(fence, (i, j+k, :down))
                        perimeter -= 1
                        k += 1
                    end
                    k = 1
                    while ((i, j-k, :down) in fence)
                        delete!(fence, (i, j-k, :down))
                        perimeter -= 1
                        k += 1
                    end
                end

                if direction == :left
                    k = 1
                    while ((i+k, j, :left) in fence)
                        delete!(fence, (i+k, j, :left))
                        perimeter -= 1
                        k += 1
                    end
                    k = 1
                    while ((i-k, j, :left) in fence)
                        delete!(fence, (i-k, j, :left))
                        perimeter -= 1
                        k += 1
                    end
                end

                if direction == :right
                    k = 1
                    while ((i+k, j, :right) in fence)
                        delete!(fence, (i+k, j, :right))
                        perimeter -= 1
                        k += 1
                    end
                    k = 1
                    while ((i-k, j, :right) in fence)
                        delete!(fence, (i-k, j, :right))
                        perimeter -= 1
                        k += 1
                    end
                end
            end

            return perimeter
        end

        price = 0
        for i in axes(map, 1)
            for j in axes(map, 2)
                if map[i, j] == label && visited[i, j] == false
                    land = get_land(i, j)
                    area = get_area(land)
                    perimeter = get_perimeter(land)
                    price += area * perimeter
                end
            end
        end
        return price
    end

    sum = 0
    for c in get_unique_labels(map)
        price = get_price(map, c)
        sum += price
    end

    return sum
end

map = read_input("/Users/rherbrich/src/adventofcode/2024/day12/input.txt")

println("Solution 1 = ", solution1(map))
println("Solution 2 = ", solution2(map))
