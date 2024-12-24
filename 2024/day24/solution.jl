# Solves the twenty fourth day of the Advent of Code 2024
#
# 2024 by Ralf Herbrich
# Hasso Plattner Institute, University of Potsdam, Germany

struct BooleanGates
    gates::Dict{String, Tuple{String, String, Symbol}}
    values::Dict{String, Bool}
end

# reads the input data from a file
function read_input(filename)
    open(filename) do file
        # regular expression to match a three letter variable name, a colon and a boolean value
        value_pat = r"([a-z0-9]{3}): (0|1)"
        # regular expression to match a three letter variable name, either of "AND, "OR" and "XOR", a three letter variable name, a "->" and a three letter variable name
        gate_pat = r"([a-z0-9]{3}) (AND|OR|XOR) ([a-z0-9]{3}) -> ([a-z0-9]{3})" 

        values = Dict{String, Bool}()
        while true
            m = match(value_pat, readline(file))
            if isnothing(m)
                break
            else
                values[m[1]] = m[2] == "1"
            end
        end

        gates = Dict{String, Tuple{String, String, Symbol}}()
        while true
            m = match(gate_pat, readline(file))
            if isnothing(m)
                break
            else
                gates[m[4]] = (m[1], m[3], Symbol(m[2]))
            end
        end

        return BooleanGates(gates, values)
    end
end

# solves the first part of the puzzle
function solution1(bool_gates)
    # computes the topological order of the variables given the logical gates
    function compute_topological_order()
        # build the dependency graph of variables due to logical gates
        depend_graph_neighbors = Dict{String, Vector{String}}()
        for (k, v) in bool_gates.gates
            if !haskey(depend_graph_neighbors, v[1])
                depend_graph_neighbors[v[1]] = Vector{String}()
            end
            if !haskey(depend_graph_neighbors, v[2])
                depend_graph_neighbors[v[2]] = Vector{String}()
            end
            push!(depend_graph_neighbors[v[1]], k)
            push!(depend_graph_neighbors[v[2]], k)
        end

        # compute the topological order of the depend_graph_neighbors graph
        topological_order = Vector{String}()

        visited = Dict{String, Bool}()
        function dfs(v)
            if haskey(visited, v)
                return
            end
            visited[v] = true
            if haskey(depend_graph_neighbors, v)
                for n in depend_graph_neighbors[v]
                    dfs(n)
                end
            end
            push!(topological_order, v)
        end

        for v in keys(depend_graph_neighbors)
            dfs(v)
        end

        return reverse(topological_order)
    end

    # evaluates the logical gates given the topological order of the variables
    for v in compute_topological_order()
        if haskey(bool_gates.gates, v)
            (in1, in2, fun) = bool_gates.gates[v]
            if fun == :AND
                bool_gates.values[v] = bool_gates.values[in1] & bool_gates.values[in2]
            elseif fun == :OR
                bool_gates.values[v] = bool_gates.values[in1] | bool_gates.values[in2]
            elseif fun == :XOR
                bool_gates.values[v] = bool_gates.values[in1] ⊻ bool_gates.values[in2]
            end
        end
    end

    # now extract the value in terms of bit patterns
    val = 0
    i = 0
    while true
        # create a zero-padded string of length 2 from i 
        s = "z" * string(i, pad=2)
        if haskey(bool_gates.values, s)
            val = if bool_gates.values[s] val + (1 << i) else val end
        else
            break
        end
        i += 1
    end

    return val
end

# solves the second part of the puzzle
function solution2(bool_gates)
end

bool_gates = read_input("/Users/rherbrich/src/adventofcode/2024/day24/input.txt")

# println(bool_gates)

println("Solution 1 = ", solution1(bool_gates))
println("Solution 2 = ", solution2(bool_gates))
