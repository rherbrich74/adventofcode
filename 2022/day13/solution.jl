# --- Day 13: Distress Signal ---
#
# 2022 written by Ralf Herbrich

# solves the puzzle
function solution(file_name, solution_no)
    # compares two expressions of lists 
    function compare_list(ex1,ex2)
        if (typeof(ex1) == Int64 && typeof(ex2) == Int64)
            # if both the expressions are integers, just compare them
            return (ex2 - ex1)
        elseif (typeof(ex1) == Expr && typeof(ex2) == Expr)
            # if both expressions are lists, compare them element-by-element
            n1 = length(ex1.args)
            n2 = length(ex2.args)
            for i = 1:min(n1, n2)
                ret_value = compare_list(ex1.args[i],ex2.args[i])
                if (ret_value != 0)
                    return (ret_value)
                end
            end
            return (n2 - n1)
        else
            # if exactly one value is an integer, convert the integer to a list which contains that integer as its only value, then retry the comparison
            if (typeof(ex1) == Int64)
                ex_new = Expr(:vect, ex1)
                return(compare_list(ex_new, ex2))
            elseif (typeof(ex2) == Int64)
                ex_new = Expr(:vect, ex2)
                return(compare_list(ex1, ex_new))
            else
                println("We should never get here")
            end
        end
    end

    open(file_name, "r") do file
        if (solution_no == 1)
            pair_idx = 1
            score = 0
            for line_block in collect(Iterators.partition(eachline(file), 3))
                score += (compare_list(Meta.parse(line_block[1]),Meta.parse(line_block[2])) > 0) ? pair_idx : 0
                pair_idx = pair_idx+1
            end
            println("Score: ", score)
        else
            two_list_ex = Meta.parse("[[2]]")
            six_list_ex = Meta.parse("[[6]]")
            two_list_idx = 0
            six_list_idx = 0

            for line in eachline(file)
                ex = Meta.parse(line)
                if (!isnothing(ex))
                    two_list_idx += (compare_list(ex, two_list_ex) > 0) ? 1 : 0;
                    six_list_idx += (compare_list(ex, six_list_ex) > 0) ? 1 : 0;
                end
            end
            println("Score: ", (two_list_idx + 1) * (six_list_idx + 2))
        end
    end
end

# main entry of the program
if (length(ARGS) != 2)
    println("usage: solution [1|2] <list-file>")
    exit(-1)
end

solution(ARGS[2], tryparse(Int, ARGS[1]))