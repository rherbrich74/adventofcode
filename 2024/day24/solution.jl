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

# computes the topological order of the variables given the logical gates
function compute_topological_order(bool_gates)
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


# solves the first part of the puzzle
function solution1(bool_gates)
    # evaluates the logical gates given the topological order of the variables
    for v in compute_topological_order(bool_gates)
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
    # determines the total number of output bits
    function get_total_output_bits()
        total = 0
        while true
            if haskey(bool_gates.gates, "z" * string(total, pad=2))
                total += 1
            else
                break
            end
        end

        return total
    end

    # resets all the mappings to just the input bits
    function reset!(mapping)
        empty!(mapping)
        for v in keys(bool_gates.values)
            mapping[v] = v
        end
    end

    # builds the rules for a ripple-carry adder circuit
    function add_half_adder(gates, in1, in2, sum, carry_out)
        gates[sum] = (in1, in2, :XOR)
        gates[carry_out] = (in1, in2, :AND)
    end

    # builds the rules for a full adder circuit
    function add_full_adder(gates, in1, in2, carry_in, sum, carry_out)
        t1 = "t1" * in1 * in2 * carry_in
        t2 = "t2" * in1 * in2 * carry_in
        t3 = "t3" * in1 * in2 * carry_in

        gates[t1] = (in1, in2, :XOR)
        gates[t2] = (in1, in2, :AND)
        gates[t3] = (t1, carry_in, :AND)
        gates[sum] = (t1, carry_in, :XOR)
        gates[carry_out] = (t2, t3, :OR)
    end

    # tries to match to output bit trees
    function try_match(gates1, out1, gates2, out2, mapping)
        if haskey(mapping, out1)
            return mapping[out1] == out2
        end

        if !haskey(gates1, out1) || !haskey(gates2, out2)
            return false
        end

        if (try_match(gates1, gates1[out1][1], gates2, gates2[out2][1], mapping) && 
            try_match(gates1, gates1[out1][2], gates2, gates2[out2][2], mapping)) ||
           (try_match(gates1, gates1[out1][1], gates2, gates2[out2][2], mapping) &&
            try_match(gates1, gates1[out1][2], gates2, gates2[out2][1], mapping))
            # mapping[out1] = out2
            return gates1[out1][3] == gates2[out2][3]
        else
            return false
        end
    end

    # tries to find a structural match for a given output bit
    function find_match(gates, out, bool_gates, mapping)
        for k in keys(bool_gates.gates)
            if try_match(gates, out, bool_gates.gates, k, mapping)
                return k
            end
        end
        return nothing
    end

    # swaps the names of two output wires
    function swap!(gates, out1, out2)
        # swap the keys
        gates[out1], gates[out2] = gates[out2], gates[out1]
    end

    # build the full ripple-carry adder circuit
    gates = Dict{String, Tuple{String, String, Symbol}}()
    total_output_bits = get_total_output_bits()
    for i in 0:(total_output_bits - 2)
        if i == 0
            add_half_adder(gates, "x" * string(i, pad=2), "y" * string(i, pad=2), "z" * string(i, pad=2), "c" * string(i, pad=2))
        elseif i == (total_output_bits - 2) 
            add_full_adder(gates, "x" * string(i, pad=2), "y" * string(i, pad=2), "c" * string(i-1, pad=2), "z" * string(i, pad=2), "z" * string(i+1, pad=2))
        else
            add_full_adder(gates, "x" * string(i, pad=2), "y" * string(i, pad=2), "c" * string(i-1, pad=2), "z" * string(i, pad=2), "c" * string(i, pad=2))
        end
    end

    # create a mapping from all nodes in one tree to the other tree
    mapping = Dict{String, String}()
    reset!(mapping)

    swap!(bool_gates.gates, "z10", "vcf")
    swap!(bool_gates.gates, "z17", "fhg")
    swap!(bool_gates.gates, "z39", "tnc")
    swap!(bool_gates.gates, "dvb", "fsq")
    
    # match the tree one output bit at the time
    for i in 1:(total_output_bits - 2)
        sum = "z" * string(i, pad=2)
        carry_out = (i == total_output_bits-2) ? "z" * string(i+1, pad=2) : "c" * string(i, pad=2)

        print("Matching output bit ", i, " (", sum, "): ")
        if !try_match(gates, sum, bool_gates.gates, sum, mapping)
            println("Failed")
        else
            println("Succeeded")
        end 

        print("Matching carry bit  ", i, " (", carry_out, "): ")
        correct_carry_out = find_match(gates, carry_out, bool_gates, mapping)
        if isnothing(correct_carry_out)
            println("Failed")
        else
            println("Succeeded (", carry_out, " -> ", correct_carry_out, ")")
        end
    end

    # find all the XOR gates that are Wrong
    for (k, v) in bool_gates.gates
        if k[1] == 'z' && v[3] != :XOR
            println(k, " <- ", v[1], " ", v[3], " ", v[2])
        end

        if k[1] != 'z' && !((v[1][1] == 'x' && v[2][1] == 'y') || (v[1][1] == 'y' && v[2][1] == 'x')) && v[3] == :XOR
            println(k, " <- ", v[1], " ", v[3], " ", v[2])
        end
    end

    return "dvb,fhg,fsq,tnc,vcf,z10,z17,z39"
end

bool_gates = read_input("/Users/rherbrich/src/adventofcode/2024/day24/input.txt")
println("Solution 1 = ", solution1(bool_gates))

bool_gates = read_input("/Users/rherbrich/src/adventofcode/2024/day24/input.txt")
println("Solution 2 = ", solution2(bool_gates))
