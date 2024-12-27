# Solves the seventeenth day of the Advent of Code 2024
#
# 2024 by Ralf Herbrich
# Hasso Plattner Institute, University of Potsdam, Germany

# the state of the 3-bit computer
mutable struct MachineState
    regA::Int
    regB::Int
    regC::Int
    pc::Int
    program::Vector{Int}
end

# reads the input data from a file
function read_input(filename)
    open(filename) do file
        data = readlines(file)
        # regular expression that parses "Register A: 729"
        reg_pat = r"Register ([ABC]): (\d+)"
        # regular expression that parses "Program: 0,1,5,4,3,0"
        prog_pat = r"Program: (.+)"

        regA = parse(Int, match(reg_pat, data[1]).captures[2])
        regB = parse(Int, match(reg_pat, data[2]).captures[2])
        regC = parse(Int, match(reg_pat, data[3]).captures[2])
        program = parse.(Int, split(match(prog_pat, data[5]).captures[1], ","))
        return MachineState(regA, regB, regC, 0, program)
    end
end

# executes the next instruction
function execute(machine, output)
    function combo_operand(operand)
        if operand <= 3
            return operand
        elseif operand == 4
            return machine.regA
        elseif operand == 5
            return machine.regB
        elseif operand == 6
            return machine.regC
        else
            error("Invalid combo operand")
        end
    end

    opcode = machine.program[machine.pc + 1]
    operand = machine.program[machine.pc + 2]    
    if opcode == 0
        machine.regA = machine.regA >> combo_operand(operand)
    elseif opcode == 1
        machine.regB = machine.regB ⊻ operand
    elseif opcode == 2
        machine.regB = combo_operand(operand) & 0x7
    elseif opcode == 3
        if machine.regA != 0
            machine.pc = operand - 2
        end
    elseif opcode == 4
        machine.regB = machine.regB ⊻ machine.regC
    elseif opcode == 5
        push!(output, combo_operand(operand) & 0x7)
    elseif opcode == 6
        machine.regB = machine.regA >> combo_operand(operand)
    elseif opcode == 7
        machine.regC = machine.regA >> combo_operand(operand)
    end

    machine.pc += 2
    if machine.pc == length(machine.program)
        return false
    else 
        return true
    end
end

# executes the next instruction
function print_program(machine)
    function print_combo_operand(operand)
        if operand <= 3
            print(operand)
        elseif operand == 4
            print("[A]")
        elseif operand == 5
            print("[B]")
        elseif operand == 6
            print("[C]")
        else
            error("Invalid combo operand")
        end
    end

    pc = machine.pc
    while true
        opcode = machine.program[machine.pc + 1]
        operand = machine.program[machine.pc + 2]    
        if opcode == 0
            print("SHR A, ")
            print_combo_operand(operand)
        elseif opcode == 1
            print("XOR B, ")
            print(operand)
        elseif opcode == 2
            print("MOV B, ")
            print_combo_operand(operand)
            print(" & 0x7")
        elseif opcode == 3
            print("JNZ ")
            print(operand)
        elseif opcode == 4
            print("XOR B, C")
        elseif opcode == 5
            print("OUT ")
            print_combo_operand(operand)
            print(" & 0x7")
        elseif opcode == 6
            print("SHR B, ")
            print_combo_operand(operand)
        elseif opcode == 7
            print("SHR C, ")
            print_combo_operand(operand)
        end
        println()

        machine.pc += 2
        if machine.pc == length(machine.program)
            machine.pc = pc
            break
        end
    end
end

# solves the first part of the puzzle
function solution1(machine)
    output = Vector{Int}()
    while execute(machine, output)
    end

    return join(string.(output), ",")
end

# solves the second part of the puzzle
function solution2(machine)
    # evaluates the program with the given registers
    function eval(a, b, c) 
        machine.regA = a
        machine.regB = b
        machine.regC = c
        machine.pc = 0
        output = Vector{Int}()
        while execute(machine, output)
        end
        return output
    end

    solution = nothing

    # recursively finds the values from right to left
    function find_values(a, idx)
        function matches_from_end(output, idx)
            if length(output) < idx || length(machine.program) < idx
                return false
            end

            for i in 1:idx
                if output[i] != machine.program[end - idx + i]
                    return false
                end
            end
            return true
        end

        output = eval(a, 0, 0)
        if output == machine.program
            if isnothing(solution)
                solution = a
            else
                solution = min(solution, a)
            end
            return
        end

        if idx == 0 || matches_from_end(output, idx)
            for n in 0:7
                find_values(a * 8 + n, idx + 1)
            end
            return 
        end
    end

    # print_program(machine)

    find_values(0, 0)
    return solution
end

machine = read_input("/Users/rherbrich/src/adventofcode/2024/day17/input.txt")
println("Solution 1 = ", solution1(machine))

machine = read_input("/Users/rherbrich/src/adventofcode/2024/day17/input.txt")
println("Solution 2 = ", solution2(machine))