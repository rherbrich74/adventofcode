# Solves the twenty third day of the Advent of Code 2024
#
# 2024 by Ralf Herbrich
# Hasso Plattner Institute, University of Potsdam, Germany

# reads the input data from a file
function read_input(filename)
    open(filename) do file
        # regular expression that matches two characters, then a minus sign, then two characters
        connection_pat = r"(.+)-(.+)"
        lan_graph_neighbors = Dict{String, Vector{String}}()
        for line in eachline(file)
            # extracts the two characters from the line
            m = match(connection_pat, line)
            if !isnothing(m)
                from = m.captures[1]
                to = m.captures[2]
                if haskey(lan_graph_neighbors, from)
                    push!(lan_graph_neighbors[from], to)
                else
                    lan_graph_neighbors[from] = [to]
                end
                if haskey(lan_graph_neighbors, to)
                    push!(lan_graph_neighbors[to], from)
                else
                    lan_graph_neighbors[to] = [from]
                end
            end
        end

        return lan_graph_neighbors
    end
end

# solves the first part of the puzzle
function solution1(graph)
    sum = 0
    nodes = collect(keys(graph))
    n = length(nodes)

    for i in 1:n
        for j in i+1:n
            for k in j+1:n
                if nodes[i][1] != 't' && nodes[j][1] != 't' && nodes[k][1] != 't'
                    continue
                end
                if nodes[j] in graph[nodes[i]] && nodes[k] in graph[nodes[j]] && nodes[i] in graph[nodes[k]]
                    sum += 1
                end
            end
        end
    end

    return sum
end

# solves the second part of the puzzle
function solution2(graph)
    mc = Set{String}()

    # finds the maximum clique in the graph
    function max_clique(nodes, clique)
        # stop searching if the current possible max clique is smaller than the maximum clique so far
        if length(nodes) + length(clique) <= length(mc)
            return
        end

        if length(nodes) == 0
            if length(clique) > length(mc)
                println("Found new max clique: ", length(clique))
                mc = clique
            end
            return
        end

        for n in nodes
            max_clique(intersect(nodes, Set(graph[n])), union(clique, Set([n])))
        end
    end    
    
    max_clique(Set(collect(keys(graph))), Set{String}())
    return join(sort(collect(mc)), ",")
end

lan_graph_neighbors = read_input("/Users/rherbrich/src/adventofcode/2024/day23/input.txt")

println("Solution 1 = ", solution1(lan_graph_neighbors))
println("Solution 2 = ", solution2(lan_graph_neighbors))