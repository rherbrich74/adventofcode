# --- Day 25: Full of Hot Air ---
#
# 2022 written by Ralf Herbrich

# solves the puzzle
function solution(file_name, solution_no)
    # converts a number from SNAFU to integer
    function snafu_to_int(s)
        snafu_map = Dict('2' => 2, '1' => 1, '0' => 0, '-' => -1, '=' => -2)

        n = 0
        for i = 1:lastindex(s)
            n = 5*n + snafu_map[s[i]]
        end 
        return (n)
    end

    # converts an integer to a SNAFU number
    function int_to_snafu(n)
        int5_map = Dict(2 => '2', 1 => '1', 0 => '0', -1 => '-', -2 => '=')
        
        # first convert the number to a base-5 number
        int5_number = Vector{Int}()
        while(n > 0)
            push!(int5_number, n % 5)
            n = n ÷ 5
        end

        # and now adjust the numbers for the base {2,1,0,-1,-2}
        int_snafu_number = Vector{Int}()
        carry = 0
        for i in (int5_number) 
            if ((i + carry) <= 2)
                push!(int_snafu_number, i + carry)
                carry = 0
            else
                push!(int_snafu_number, (i + carry) - 5)
                carry = 1
            end
        end
        if (carry > 0)
            push!(int_snafu_number, carry)
        end

        # finally, return the number and map to characters in SNAFU
        return (map(k -> int5_map[k], int_snafu_number) |> reverse |> join)
    end

    open(file_name, "r") do file
        # read all the sensor informations
        println("Solution: ", int_to_snafu(sum(map(line -> snafu_to_int(line), eachline(file)))))
    end
end

# main entry of the program
if (length(ARGS) != 2)
    println("usage: solution [1|2] <sensor-file>")
    exit(-1)
end

solution(ARGS[2], tryparse(Int, ARGS[1]))