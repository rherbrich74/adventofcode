# --- Day 8: Treetop Tree House ---
#
# 2022 written by Ralf Herbrich

# solves the puzzle
function solution(file_name, solution_no)
    open(file_name, "r") do file
        # read the input file and parse it into a 2D array
        tree_map = map(line -> map(x -> Int(x)-Int('0'),collect(line)), eachline(file))
        no_rows = length(tree_map)
        no_cols = length(tree_map[1])

        # checks, if coordiantes (x,y) is visible from outside
        function is_visible(coors)
            x = coors[1]
            y = coors[2]

            if (all(t -> tree_map[x][t] < tree_map[x][y],(y-1):-1:1))               # check north
                return true
            elseif (all(t -> tree_map[t][y] < tree_map[x][y],(x+1):+1:no_cols))     # check east
                return true
            elseif (all(t -> tree_map[x][t] < tree_map[x][y],(y+1):+1:no_rows))     # check south
                return true
            elseif (all(t -> tree_map[t][y] < tree_map[x][y],(x-1):-1:1))           # check west
                return true
            else
                return false
            end
        end 

        # computes the tree score at position coors = (x,y)
        function tree_score(coors)
            x = coors[1]
            y = coors[2]

            # computes the 
            function count_free_trees(f, ts)
                score = 1
                for t in ts
                    if (f(t))
                        score += 1
                    else
                        break
                    end
                end
                return (score)
            end

            score =  count_free_trees(t -> tree_map[x][t] < tree_map[x][y],(y-1):-1:2)            # north score
            score *= count_free_trees(t -> tree_map[t][y] < tree_map[x][y],(x+1):+1:(no_cols-1))  # east score
            score *= count_free_trees(t -> tree_map[x][t] < tree_map[x][y],(y+1):+1:(no_rows-1))  # south score
            score *= count_free_trees(t -> tree_map[t][y] < tree_map[x][y],(x-1):-1:2)            # west score

            return (score)
        end 

        # generate the list of grid coordinates
        grid = collect(Iterators.product(1:no_cols,1:no_rows))
        if (solution_no == 1)
            println("Score: ", sum(map(coors -> is_visible(coors) ? 1 : 0, grid)))
        else
            println("Score: ", maximum(map(coors -> tree_score(coors), grid)))
        end        
    end
end


# main entry of the program
if (length(ARGS) != 2)
    println("usage: solution [1|2] <tree-file>")
    exit(-1)
end

solution(ARGS[2], tryparse(Int, ARGS[1]))