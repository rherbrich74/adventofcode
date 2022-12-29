# --- Day 11: Monkey in the Middle ---
#
# 2022 written by Ralf Herbrich

# Type definition of a monkey program 
struct MonkeyProgram
    index::Int                      # the index of the monkey 
    starting_items::Vector{Int128}  # the starting items 
    monkey_op                       # operation in each cycle
    divisible_test::Int             # the number that the worry level needs to be divisible by 
    target_monkey_true::Int;        # monkey that receives the items when the test is true
    target_monkey_false::Int        # monkey that receives the items when the test is false
end

# Type definition of a monkey program 
mutable struct MonkeyState
    prog::MonkeyProgram             # monkey program to process the items
    no_items_processed::Int         # number of items no_items_processed
    const items::Vector{Int128}     # items in the list for the monkey
end

# read a monkey program
function read_monkey_program(file)
    # parse all of the lines
    m_idx = match(r"Monkey ([0-9])+:", readline(file))
    if(isnothing(m_idx))
        return (nothing)
    end
    start_idx_line = readline(file)
    m_start_items = match(r"  Starting items: (\d+)(, (\d)+)*", start_idx_line)
    if(isnothing(m_start_items))
        return (nothing)
    end
    m_monkey_op = match(r"  Operation: new = old ([*+]) (.+)", readline(file))
    if(isnothing(m_monkey_op))
        return (nothing)
    end
    m_divisible = match(r"  Test: divisible by (\d+)", readline(file))
    if(isnothing(m_divisible))
        return (nothing)
    end
    m_true_rule = match(r"    If true: throw to monkey (\d+)", readline(file))
    if(isnothing(m_true_rule))
        return (nothing)
    end
    m_false_rule = match(r"    If false: throw to monkey (\d+)", readline(file))
    if(isnothing(m_false_rule))
        return (nothing)
    end
    readline(file)

    start_idx = map(x->tryparse(Int,x), split(start_idx_line[m_start_items.offsets[1]:end], ","))
    f = 
        if (m_monkey_op[1] == "*") 
            if (m_monkey_op[2] == "old") 
                x -> x*x
            else 
                y = tryparse(Int, m_monkey_op[2])
                x -> x*y
            end
        else
            y = tryparse(Int, m_monkey_op[2])
            x -> x+y
        end
    prog = MonkeyProgram(tryparse(Int, m_idx[1]) + 1, start_idx, f, tryparse(Int, m_divisible[1]), 
                            tryparse(Int, m_true_rule[1]) + 1,tryparse(Int, m_false_rule[1]) + 1)

    return (prog)
end

# solves the puzzle
function solution(file_name, solution_no)

    open(file_name, "r") do file
        # read all the monkey programs
        progs = Vector{MonkeyProgram}()
        while (true)
            prog = read_monkey_program(file)
            if (isnothing(prog))
                break
            else
                push!(progs, prog)
            end
        end

        # executes a monkey program 
        function run_small_monkey_program(prog::MonkeyProgram, monkey_states::Vector{MonkeyState}) 
            for item in monkey_states[prog.index].items
                monkey_states[prog.index].no_items_processed += 1
                processed_item = prog.monkey_op(item) ÷ 3
                if (processed_item % prog.divisible_test > 0)
                    push!(monkey_states[prog.target_monkey_false].items, processed_item)
                else
                    push!(monkey_states[prog.target_monkey_true].items, processed_item)
                end
            end
            empty!(monkey_states[prog.index].items)
        end

        # executes a monkey program with big integer
        super_modulo = Int128(reduce(*, map(prog -> prog.divisible_test, progs)))
        function run_big_monkey_program(prog::MonkeyProgram, monkey_states::Vector{MonkeyState}) 
            for item in monkey_states[prog.index].items
                monkey_states[prog.index].no_items_processed += 1
                processed_item = prog.monkey_op(item) % super_modulo
                if (processed_item % prog.divisible_test > 0)
                    push!(monkey_states[prog.target_monkey_false].items, processed_item)
                else
                    push!(monkey_states[prog.target_monkey_true].items, processed_item)
                end
            end
            empty!(monkey_states[prog.index].items)
        end

        # initializes the monkey starting_items
        monkey_states = map(prog -> MonkeyState(prog, 0, prog.starting_items), progs)

        if (solution_no == 1)
            # run the programs over 20 rounds
            for round = 1:20
                for prog in progs
                    run_small_monkey_program(prog, monkey_states)
                end
            end

            # sort the processed items and compute score
            cnt = sort(map(state -> state.no_items_processed, monkey_states))
            println("Score (", cnt[end], ", ", cnt[end-1], "): ", cnt[end]*cnt[end-1])
        else
            # run the programs over 10000 rounds
            for round = 1:10000
                for prog in progs
                    run_big_monkey_program(prog, monkey_states)
                end
            end

            # sort the processed items and compute score
            cnt = sort(map(state -> state.no_items_processed, monkey_states))
            println("Score (", cnt[end], ", ", cnt[end-1], "): ", cnt[end]*cnt[end-1])
        end
    end
end

# main entry of the program
if (length(ARGS) != 2)
    println("usage: solution [1|2] <monkey-file>")
    exit(-1)
end

solution(ARGS[2], tryparse(Int, ARGS[1]))