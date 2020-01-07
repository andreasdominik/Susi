"""
    askDuckling(dimension, text)

Call duckling web-service to read the slot content.
"""
function askDuckling(dimension, text)

    cmd = `curl -v -XPOST http://$DUCKLING_HOST:$DUCKLING_PORT/parse --data \'lang=$LANG\&text=$text\' -o duckling.out`

    slotvalue = ""
    try
        run(cmd; wait = true)
        json = JSON.parsefile("duckling.out")
        json = key2symbol(json)

        for value in json
            body = value[:body]
            dim = value[:dim]
            value = value[:value][:value]

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
