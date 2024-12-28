# Solves the nineteenth day of the Advent of Code 2024
#
# 2024 by Ralf Herbrich
# Hasso Plattner Institute, University of Potsdam, Germany

# structure to store the puzzle input
struct Input
    tokens::Vector{String}
    puzzles::Vector{String}
end

# reads the input data from a file
function read_input(filename)
    open(filename) do file
        data = readlines(file)
        tokens = split(data[1], ", ")

        puzzles = Vector{String}()
        for i in 3:length(data)
            push!(puzzles, data[i])
        end
        return Input(tokens, puzzles)
    end
end

mutable struct MatchingTree
    children::Dict{Char,MatchingTree}
    final::Bool
end

# adds a string to the matching tree
function add!(tree::MatchingTree, s::String)
    if length(s) == 0
        return
    end

    if haskey(tree.children, s[1])
        if length(s) == 1
            tree.children[s[1]].final = true
        else
            add!(tree.children[s[1]], s[2:end])
        end
    else
        tree.children[s[1]] = MatchingTree(Dict{Char,MatchingTree}(), length(s) == 1)
        add!(tree.children[s[1]], s[2:end])
    end
end

# prints the matching tree
function print_tree(tree::MatchingTree, indent::Int)
    for (k, v) in tree.children
        for _ in 1:indent
            print(" ")
        end
        print("└")
        if v.final
            println("[", k, "]")
        else
            println(k)
        end
        print_tree(v, indent + 1)
    end
end

# solves the first part of the puzzle
function solution1(input)
    # build a matching tree to speed up the search
    root = MatchingTree(Dict{Char,MatchingTree}(), false)
    for p in input.tokens
        add!(root, p)
    end

    # tries to match a string against the tokens stored in the matching tree
    function match(tree::MatchingTree, s::String, i::Int)
        if haskey(tree.children, s[i])
            if i == length(s)
                return tree.children[s[i]].final
            else
                if tree.children[s[i]].final
                    return match(root, s, i + 1) || match(tree.children[s[i]], s, i + 1)
                else
                    return match(tree.children[s[i]], s, i + 1)
                end
            end
        else
            return false
        end
    end

    # count the number of invalid puzzles
    sum = 0
    for p in input.puzzles
        if match(root, p, 1)
            sum += 1
        end
    end

    return sum
end

# solves the second part of the puzzle
function solution2(input)
    # build a matching tree to speed up the search
    root = MatchingTree(Dict{Char,MatchingTree}(), false)
    for p in input.tokens
        add!(root, p)
    end

    # counts the in how many ways a string can be made with the tokens
    function count(cache::Dict{Tuple{MatchingTree,Int},Int}, tree::MatchingTree, s::String, i::Int)
        if haskey(cache, (tree, i))
            return cache[(tree, i)]
        end

        if haskey(tree.children, s[i])
            if i == length(s)
                return tree.children[s[i]].final ? 1 : 0
            else
                if tree.children[s[i]].final
                    cache[(tree, i)] = count(cache, root, s, i + 1) + count(cache, tree.children[s[i]], s, i + 1)
                    return cache[(tree, i)]
                else
                    cache[(tree, i)] = count(cache, tree.children[s[i]], s, i + 1)
                    return cache[(tree, i)]
                end
            end
        else
            return 0
        end
    end

    # count the number of invalid puzzles
    sum = 0
    for p in input.puzzles
        cache = Dict{Tuple{MatchingTree,Int},Int}()
        sum += count(cache, root, p, 1)
    end

    return sum
end

input = read_input("/Users/rherbrich/src/adventofcode/2024/day19/input.txt")

println("Solution 1 = ", solution1(input))
println("Solution 2 = ", solution2(input))
