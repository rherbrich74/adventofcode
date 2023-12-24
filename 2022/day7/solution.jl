# --- Day 7: No Space Left On Device ---
#
# 2022 written by Ralf Herbrich

# Type of a file
struct File
    name::String        # name of the file
    size::Int64          # size of the file
end

# Recursive type for directories
struct Directory
    name::String                    # nanme of the directory
    files::Vector{File}             # list of files 
    dirs::Vector{Directory}         # lsit of sub-directories
end

# computes the total size of a directory where the function f is applied to
function total_size(d::Directory)
    total_file_size = sum(map(f -> f.size, d.files); init=0)
    total_dirs_size = sum(map(d -> total_size(d), d.dirs); init=0)
    return total_file_size + total_dirs_size
end

# returns the list of all directories and their total size
function get_dirs_with_total_size(d::Directory)::Vector{Int64}
    xs = map(d -> get_dirs_with_total_size(d), d.dirs)
    ys = reduce(vcat, xs; init=[])
    push!(ys,total_size(d))
    return ys
end

# solves the puzzle
function solution(file_name, solution_no)
    # reads a directory from a first line and file pointer (to read more lines)
    function read_dir(line, file)
        # reads directory name
        m = match(r"\$ cd ([^\n]*)", line)
        if(isnothing(m))
            println("Next line should have been '\$ cd <dir-name>' but was '", line, "'")
            exit(-1)
        end

        # allocate new directory with empty number of files and sub-directories
        d = Directory(m[1],[],[])

        # now read the "ls" command
        line = readline(file)
        if (line != "\$ ls")
            println("Expecting '\$ ls', received '", line, "'")
        end

        # now read all the files
        line = readline(file)
        while(length(line) >0 && line[1] != '$')
            m = match(r"(\d+) (.*)", line)
            if (!isnothing(m))
                push!(d.files, File(m[2],tryparse(Int64,m[1])))
            end
            line = readline(file)
        end

        # and now recursively read all the directories
        while(length(line) >0 && line != "\$ cd ..")
            m = match(r"\$ cd ([^\n]*)", line)
            if (!isnothing(m))
                push!(d.dirs, read_dir(line, file))
            end
            line = readline(file)
        end

        return d
    end

    # read the input file and parse it into the directory structure
    open(file_name, "r") do file
        line = readline(file)
        root = read_dir(line, file)
        
        if (solution_no == 1)
            println("Score = ", filter(x -> x < 100000, get_dirs_with_total_size(root)) |> sum)
        else
            sizes = sort(get_dirs_with_total_size(root))
            space_necessary = 30000000 - (70000000 - total_size(root))
            for sz in sizes
                if (sz > space_necessary)
                    println("Score = ", sz)
                    break
                end
            end
        end
    end
end


# main entry of the program
if (length(ARGS) != 2)
    println("usage: solution [1|2] <dir-file>")
    exit(-1)
end

solution(ARGS[2], tryparse(Int, ARGS[1]))