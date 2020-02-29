function askDuckling(dimension, text)
    return askRustling(dimension, text)
end




"""
    askDuckling(dimension, text)

Call duckling to read the slot content.
"""
function askDucklingService(dimension, text)

    cmd = `curl -v -XPOST http://$DUCKLING_HOST:$DUCKLING_PORT/parse --data lang=$LANG\&text=$text -o duckling.out`

    slotvalue = ""
    try
# println("CMD: $cmd")
        run(cmd; wait = true)
        json = JSON.parsefile("duckling.out")
        json = key2symbol(json)

        # println("EEEE $json")
        for oneEntry in json
# println(oneEntry)
            body = oneEntry[:body]
            dim = oneEntry[:dim]
            value = oneEntry[:value][:value]
# println("dimension = $dimension, dim = $dim")
# println("VALUE = $value")
            # return time w/o timezone:
            #
            if dimension == "Time" && dim == "time"
                slotvalue = replace(value, r"-\d\d:\d\d$" => "")

            # return numbers as numbers (not string):
            #
            elseif dimension in ["Number", "Ordinal"] && dim in ["number", "ordinal"]
                slotvalue = value

            # return currency as string with unit like "5 EUR":
            #
            elseif dimension == "Currency" && dim == "amount-of-money"
                slotvalue = "$value $(json[:value][:unit])"

            # return duration always as number of secs:
            #
            elseif dimension == "Duration" && dim == "duration"
                slotvalue = json[:value][:normalized][:value]
            end
        end

    catch
        slotvalue = ""
    end

    return slotvalue
end




"""
    askRustling(dimension, text)

Call duckling to read the slot content.
"""
function askRustling(dimension, text)

    IN_FILE = "rustling.in"
    OUT_FILE = "rustling.out"

    try
        rm(OUT_FILE)
    catch
    end
    # create input file for rustling service:
    #
    rawSlot = Dict("sentence" => text)
    open(IN_FILE, "w") do f
        JSON.print(f, rawSlot)
    end

    # wait until result is there:
    #
    time = 0
    while !isfile(OUT_FILE) && (time < 5)
        sleep(0.01)
        time += 0.01
    end

    # read rustling result:
    #
    slotvalue = ""
    try
        rustlingOut = strip(read(OUT_FILE, String))
        rustlingOut = replace(rustlingOut, "\r" => "")
        rustlingOut = replace(rustlingOut, "\n" => "")

        println("from file: $rustlingOut")
        # return time w/o timezone:
        #
        if dimension == "Time"
            regEx = r"^Datetime\(DatetimeOutput { moment: (\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d),"
            #slotvalue = replace(value, r"[+-]\d\d:\d\d$" => "")  # rm timezone
            m = match(regEx, rustlingOut)
            if m != nothing
                slotvalue = m[1]
            end

        # return numbers as numbers (not string):
        #
        elseif dimension in ["Number", "Ordinal"]
            regEx = r"^(?:Integer\(IntegerOutput|Ordinal\(OrdinalOutput|Float\(FloatOutput)\(([0-9,\.]+)\)\)"
            m = match(regEx, rustlingOut)
            println(regEx)
            println(rustlingOut)
            if m != nothing
                slotvalue = m[1]
            end

        # return currency as string with unit like "5 EUR":
        #
        elseif dimension == "Currency"
            regEx = r"^AmountOfMoney\(AmountOfMoneyOutput \{ value: ([0-9,\.]+),.*unit.*\(\"(.+)\"\)"
            m = match(regEx, rustlingOut)
            if m != nothing
                slotvalue = "$(m[1]) $(m[2])"
            else
                regEx = r"^(?:Integer\(IntegerOutput|Ordinal\(OrdinalOutput|Float\(FloatOutput)\(([0-9,\.]+)\)\)"
                m = match(regEx, rustlingOut)
                if m != nothing
                   slotvalue = m[1]
                end
            end


        # return duration always as number of secs:
        #
        elseif dimension == "Duration"
            regEx = r"^Duration\(DurationOutput \{ period: Period\(\{([0-9]): ([0-9,\.]+)\}\)"
            m = match(regEx, rustlingOut)

            # make unit:
            #
            if m != nothing
                unitNum = tryparse(Int, m[1])
                val = tryparse(Int, m[2])

                if unitNum != nothing && val != nothing && 0 ≤ unitNum ≤ 7
                    units = ["year", "unknown","month", "week", "day", "hour", "minute", "second"]
                    unit = units[unitNum+1]
                    slotvalue = "$val $unit"
                else
                    slotvalue = "0"
                end
            end
        else
            m = nothing
        end

    catch
        slotvalue = ""
    end
    return slotvalue
end
