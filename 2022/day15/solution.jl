# --- Day 15: Beacon Exclusion Zone ---
#
# 2022 written by Ralf Herbrich

# type for a Sensor/Beacon location
struct SensorBeacon
    sensor_x::Int                   # x coordinate of the sensor
    sensor_y::Int                   # y coordinate of the sensor
    beacon_x::Int                   # x coordinate of the beacon
    beacon_y::Int                   # y coordinate of the beacon 
    distance::Int                   # Manhattan distance between beacon and sensor
end

# solves the puzzle
function solution(file_name, solution_no)
    open(file_name, "r") do file
        # read all the sensor informations
        sensors = Vector{SensorBeacon}()
        for line in eachline(file)
            m = match(r"Sensor at x=([-\d]+), y=([-\d]+): closest beacon is at x=([-\d]+), y=([-\d]+)", line)
            if (!isnothing(m))
                s_x = tryparse(Int, m[1])
                s_y = tryparse(Int, m[2])
                b_x = tryparse(Int, m[3])
                b_y = tryparse(Int, m[4])
                push!(sensors, SensorBeacon(s_x, s_y, b_x, b_y, abs(s_x - b_x) + abs(s_y - b_y)))
            end
        end

        # computes the sensor coverage for a target row
        function compute_senor_coverage(target_row)
            intervals = Vector{Tuple{Int,Int}}()
            for sb in sensors
                d = sb.distance - abs(sb.sensor_y - target_row)
                if (d >= 0)
                    start = (sb.sensor_x - d == sb.beacon_x) ? sb.sensor_x - d + 1 : sb.sensor_x - d
                    finish = (sb.sensor_x + d == sb.beacon_x) ? sb.sensor_x + d - 1 : sb.sensor_x + d
                    push!(intervals, (start, finish))
                end
            end

            min_x = reduce(min, map(pair -> pair[1], intervals))
            max_x = reduce(max, map(pair -> pair[2], intervals))

            score = 0
            for x = min_x:max_x
                if (any(map(pair -> x >= pair[1] && x <= pair[2], intervals)))
                    score += 1
                end
            end
            println("Score: ", score)    
        end

        # identifies the row with a single beacon 
        function find_beacon(N)

            # packs the intervals by merging all intervals which overlap
            function pack_intervals(intervals)
                sorted_intervals = sort(intervals, by=x->x[1])
                new_intervals = Vector{Tuple{Int,Int}}()
                (s,e) = sorted_intervals[1]
                for i = 2:lastindex(sorted_intervals)
                    if (sorted_intervals[i][1] <= e)
                        e = max(e, sorted_intervals[i][2])
                    else
                        push!(new_intervals, (s,e))
                        (s,e) = sorted_intervals[i]
                    end
                end
                push!(new_intervals, (s,e))
                
                return(new_intervals)
            end

            for target_row in 1:N
                # build the list of all intervals 
                intervals = Vector{Tuple{Int,Int}}()
                for sb in sensors
                    d = sb.distance - abs(sb.sensor_y - target_row)
                    if (d >= 0)
                        push!(intervals, (sb.sensor_x - d, sb.sensor_x + d))
                    end
                end

                # pack the intervals and check which one ends up in two with a whole 
                intervals = pack_intervals(intervals)
                if (length(intervals) == 2)
                    score = (intervals[1][2]+1) * 4000000 + target_row
                    println("Score: ", score, " (x=", (intervals[1][2]+1), ",y=", target_row, ")")
                end
            end
        end

        if (solution_no == 1)
            compute_senor_coverage(2000000)
        else
            find_beacon(4000000)
        end
    end
end

# main entry of the program
if (length(ARGS) != 2)
    println("usage: solution [1|2] <sensor-file>")
    exit(-1)
end

solution(ARGS[2], tryparse(Int, ARGS[1]))