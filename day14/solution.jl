# --- Day 14: Regolith Reservoir ---
#
# 2022 written by Ralf Herbrich

# define the wall element types
@enum WallElement Free Wall Sand

# solves the puzzle
function solution(file_name, solution_no)
    open(file_name, "r") do file
        # defines the empty maze
        sand_map = fill(Free, 1000, 1000)

        # read the walls and add them to the map
        function read_sand_map()
            max_y = 0

            # create all the walls in the sand map from the file
            for line in eachline(file)
                coors = map(x->(tryparse(Int,x[1]),tryparse(Int,x[2])+1), [split(pair,",") for pair in split(line, " -> ")])
                last_pos = nothing
                for pos in coors
                    max_y = max(pos[2],max_y)
                    if (!isnothing(last_pos))
                        if (last_pos[1] == pos[1])
                            for y in last_pos[2]:((last_pos[2] < pos[2]) ? +1 : -1):pos[2]
                                sand_map[pos[1],y] = Wall
                            end
                        else
                            for x in last_pos[1]:((last_pos[1] < pos[1]) ? +1 : -1):pos[1]
                                sand_map[x,pos[2]] = Wall
                            end
                        end
                    end
                    last_pos = pos
                end
            end 

            return (max_y)
        end

        # simulates pouring a grain of sand
        function pour_grain_of_sand()
            grain = (500, 1)
        
            # enter an endless loop; if we exit this loop, the sand has not moved anymore
            while (true)
                # check if we are about to move off the grid */
                if (grain[2] == 1000 || sand_map[grain[1],grain[2]] == Sand)
                    return (false)      # in this case, the pour is infinite
                end
        
                # now check if we can still move the grain 
                if (sand_map[grain[1],grain[2] + 1] == Free)
                    grain = (grain[1], grain[2]+1)
                elseif (sand_map[grain[1] - 1,grain[2] + 1] == Free)
                    grain = (grain[1]-1, grain[2]+1)
                elseif (sand_map[grain[1] + 1,grain[2] + 1] == Free)
                    grain = (grain[1]+1, grain[2]+1)
                else
                    sand_map[grain[1],grain[2]] = Sand
                    return (true);      # in this case, the grain has stopped moving 
                end
            end
            println("Internal error: We should never get here!")
            return (true)
        end
        
        # start by reading the sand-map
        max_y = read_sand_map()
        
        if (solution_no == 2)
            # add one more line at the bottom of the map 
            for x = 1:1000
                sand_map[x,max_y+2] = Wall
            end
        end

        # now count the number of grains we can pour on the map
        score = 0
        while (pour_grain_of_sand())
            score += 1
        end
        println("Score: ", score)
    end
end

# main entry of the program
if (length(ARGS) != 2)
    println("usage: solution [1|2] <map-file>")
    exit(-1)
end

solution(ARGS[2], tryparse(Int, ARGS[1]))