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
            elseif (length(line) > 0)
                push!(production, map(x -> parse(Int, x), split(line, ",")))
            end
        end
        return rules, production
    end
end

# checks that the page list obeys the production rules
function check_validity(pages, rules)
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

    return true
end

# fixes the page order so that the production rules are obeyed
function fix_validity(pages, rules)
    for i in eachindex(pages)
        # check that all pages before are in the predecessor list; if not, swap them
        for j = 1:(i-1)
            if !rules.order[pages[j], pages[i]]
                pages[j], pages[i] = pages[i], pages[j]
            end
        end

        # check that all pages after are in the successor list; if not, swap them
        for j = (i+1):length(pages)
            if !rules.order[pages[i], pages[j]]
                pages[j], pages[i] = pages[i], pages[j]
            end
        end
    end

    return pages
end

# solves the first part of the puzzle
function solution1(rules, production)
    sum = 0
    for pages in production
        if (check_validity(pages, rules))
            sum += pages[length(pages) ÷ 2 + 1]
        end
    end

    return sum
end

# solves the second part of the puzzle
function solution2(rules, production)
    sum = 0
    for pages in production
        if (!check_validity(pages, rules))
            fixed_pages = fix_validity(pages, rules)
            sum += pages[length(fixed_pages) ÷ 2 + 1]
        end
    end

    return sum
end

rules, production = read_input("/Users/rherbrich/src/adventofcode/2024/day5/input.txt")

println("Solution 1 = ", solution1(rules, production))
println("Solution 2 = ", solution2(rules, production))

