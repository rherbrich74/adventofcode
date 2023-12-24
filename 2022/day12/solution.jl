# --- Day 12: Hill Climbing Algorithm ---
#
# 2022 written by Ralf Herbrich

# read the map
function read_map(lines)
    # convert the map to a two-dimensaional array
    hill = map(line -> collect(line), lines)
    start = (0,0)
    finish = (0,0)

    # find start and end point
    grid = collect(Iterators.product(1:length(hill),1:length(hill[1])))
    for pos in grid
        if (hill[pos[1]][pos[2]] == 'S')
            start = pos
            hill[pos[1]][pos[2]] = 'a'
        elseif (hill[pos[1]][pos[2]] == 'E')
            finish = pos
            hill[pos[1]][pos[2]] = 'z'
        end
    end

    return (hill = hill, grid = grid, start = start, finish = finish)
end

# compute the shortest distances using Dijkstra’s algorithm
function dijkstra(conf, start, f)
    grid = conf.grid
    N = length(grid)

    # initialize costs
    cost = Matrix{Int}(undef, N, N)
    for from = 1:N
        for to = 1:N
            cost[from,to] = 
                if (from == to)
                    0
                else
                    if (((abs(grid[from][1]-grid[to][1]) <= 1 && grid[from][2] == grid[to][2]) ||
                         (abs(grid[from][2]-grid[to][2]) <= 1 && grid[from][1] == grid[to][1])) && 
                         f(conf.hill[grid[to][1]][grid[to][2]], conf.hill[grid[from][1]][grid[from][2]]))
                        1
                    else
                        N
                    end
                end
        end
    end

    # initialize the distances
    distance = [cost[start,i] for i in 1:N]
    available = Set(1:N)
    delete!(available, start)

    # run the algorithm
    while(length(available) > 0)
        # determine the shortest-not-yet-visited to start
        (min_distance,next_node) = first(sort([(distance[idx],idx) for idx in available], by=first))

        # remove it from the set of available nodes
        delete!(available, next_node)

        # updates the distances
        for idx in available
            if (min_distance + cost[next_node, idx] < distance[idx])
                distance[idx] = min_distance + cost[next_node, idx]
            end 
        end 
    end

    return (distance)
end

# solves the puzzle
function solution(file_name, solution_no)

    open(file_name, "r") do file
        # read the map file
        conf = read_map(eachline(file))

        # determine the start and stop index in the grid
        start = findfirst([conf.grid[i]==conf.start for i in 1:length(conf.grid)])
        finish = findfirst([conf.grid[i]==conf.finish for i in 1:length(conf.grid)])

        if (solution_no == 1)
            # compute the shortest distances using Dijkstra’s algorithm from the start
            distances_from_start = dijkstra(conf, start, (a,b) -> Int(a) - Int(b) <= 1)
            println("Score : ", distances_from_start[finish])
        else
            # compute the shortest distances using Dijkstra’s algorithm from the finish
            distances_from_finish = dijkstra(conf, finish, (a,b) -> Int(b) - Int(a) <= 1)
            # and then search all the starting points who have an 'a'
            possible_start_distances = Vector{Int}()
            for i = 1:length(conf.grid)
                if (conf.hill[conf.grid[i][1]][conf.grid[i][2]] == 'a')
                    push!(possible_start_distances, distances_from_finish[i])
                end
            end
            println("Score : ", minimum(possible_start_distances))
        end
    end
end

# main entry of the program
if (length(ARGS) != 2)
    println("usage: solution [1|2] <map-file>")
    exit(-1)
end

solution(ARGS[2], tryparse(Int, ARGS[1]))