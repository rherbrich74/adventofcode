# Solves the fourteenth day of the Advent of Code 2024
#
# 2024 by Ralf Herbrich
# Hasso Plattner Institute, University of Potsdam, Germany

# store all the data of a robot
mutable struct Robot
    position_x::Int
    position_y::Int
    Δ_x::Int
    Δ_y::Int
end

# reads the input data from a file
function read_input(filename)
    open(filename) do file
        # regular expression to parse a line such as "p=0,4 v=3,-3"
        robo_pat = r"p=(-?\d+),(-?\d+) v=(-?\d+),(-?\d+)"

        robots = Vector{Robot}()
        for line in eachline(file)
            if !isnothing(match(robo_pat, line))
                m = match(robo_pat, line)
                push!(robots, Robot(parse(Int, m[1]), parse(Int, m[2]), parse(Int, m[3]), parse(Int, m[4])))
            else
                println("Skipping: ", line)
            end
        end
        return robots
    end
end


# create a grid with the given width and height and robot counts
function create_map(robots, width, height)
    map = zeros(Int, width, height)
    for robot in robots
        map[robot.position_x + 1, robot.position_y + 1] += 1
    end
    return map
end

# prints a grid with the current robot positions
function print_map(map)
    for y in axes(map, 2)
        for x in axes(map, 1)
            print(map[x, y] > 0 ? string(map[x, y]) : ".")
        end
        println()
    end
end

# moves each robot by one step
function move_robots(robots, width, height)
    for robot in robots
        robot.position_x += robot.Δ_x
        robot.position_y += robot.Δ_y

        robot.position_x = (robot.position_x < 0) ? robot.position_x + width : ((robot.position_x >= width) ? robot.position_x - width : robot.position_x)
        robot.position_y = (robot.position_y < 0) ? robot.position_y + height : ((robot.position_y >= height) ? robot.position_y - height : robot.position_y)
    end
end

# solves the first part of the puzzle
function solution1(robots, width, height)
    # compute the score
    function score(map)
        q1 = sum(map[1:width÷2, 1:height÷2])
        q2 = sum(map[width÷2+2:width, 1:height÷2])
        q3 = sum(map[1:width÷2, height÷2+2:height])
        q4 = sum(map[width÷2+2:width, height÷2+2:height])
        return q1 * q2 * q3 * q4
    end

    for _ in 1:100
        move_robots(robots, width, height)
    end

    return score(create_map(robots, width, height))
end

# solves the second part of the puzzle
function solution2(robots, width, height)
    function is_tree(map)
        return all(map .<= 1)
    end

    i = 0
    while true
        move_robots(robots, width, height)
        i += 1
        map = create_map(robots, width, height)
        
        if is_tree(map)
            print_map(map)
            break
        end

        if i > width * height
            println("No solution found")
            break
        end
    end

    return i
end

robots = read_input("/Users/rherbrich/src/adventofcode/2024/day14/input.txt")
println("Solution 1 = ", solution1(robots, 101, 103))

robots = read_input("/Users/rherbrich/src/adventofcode/2024/day14/input.txt")
println("Solution 2 = ", solution2(robots, 101, 103))

