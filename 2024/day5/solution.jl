# Solves the fifth day of the Advent of Code 2024
#
# 2024 by Ralf Herbrich
# Hasso Plattner Institute, University of Potsdam, Germany

struct PageRules
    order::Matrix{Bool}
end

# reads the input data from a file
function read_input(filename)
    m = Matrix{Bool}(undef, 100, 100)
    for i = 1:100
        for j = 1:100
            m[i,j] = false
        end
    end
    rules = PageRules(m)
    production = Vector{Vector{Int}}()

    open(filename) do file
        pat = r"(\d{1,3})\|(\d{1,3})"
        for line in eachline(file)
            m = match(pat, line)
            if !isnothing(m)
                predecessor = parse(Int, m.captures[1])
                successor = parse(Int, m.captures[2])

                rules.order[predecessor, successor] = true
                # # add a predecessor rule
                # if !haskey(rules.predecessors, successor)
                #     rules.predecessors[successor] = Vector{Int}()
                # end
                # push!(rules.predecessors[successor], predecessor)

                # # add a successor rule
                # if !haskey(rules.successors, predecessor)
                #     rules.successors[predecessor] = Vector{Int}()
                # end
                # push!(rules.successors[predecessor], successor)
            elseif (length(line) > 0)
                # println(split(line, ","))
                push!(production, map(x -> parse(Int, x), split(line, ",")))
            end
        end
        return rules, production
    end
end

# solves the first part of the puzzle
function solution1(rules, production)
    # checks that the page list obeys the production rules
    function check_validity(pages)
        for i in eachindex(pages)
            # check that all pages before are in the predecessor list
            for j = 1:(i-1)
                if !rules.order[pages[j], pages[i]]
                    return false
                end
            end

            # check that all pages after are in the successor list
            for j = (i+1):length(pages)
                if !rules.order[pages[i], pages[j]]
                    return false
                end
            end
        end
    end

    for pages in production
        if (check_validity(pages))
            println("VALID: ", pages)
        else
            println("NOT VALID: ", pages)
        end
    end
end

# solves the second part of the puzzle
function solution2(rules, production)
end

rules, production = read_input("/Users/rherbrich/src/adventofcode/2024/day5/test.txt")

println(rules)

println("Solution 1 = ", solution1(rules, production))
println("Solution 2 = ", solution2(rules, production))

