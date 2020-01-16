#
# watch he MQTT traffic of susi.
#
# © Andreas Dominik, THM, 2010
#
#
# MQTT helpers:
#

function parseMQTT(message)

    # extract topic and JSON payload:
    #
    rgx = r"(?<topic>[^[:space:]]+) (?<payload>.*)"s
    m = match(rgx, message)
    if m != nothing
        topic = strip(m[:topic])
        payload = tryParseJSON(strip(m[:payload]))
    else
        topic = nothing
        payload = Dict()
    end

    return topic, payload
end





function tryParseJSON(text)

    jsonDict = Dict()
    try
        jsonDict = JSON.parse(text)
        jsonDict = key2symbol(jsonDict)
    catch
        jsonDict = text
    end

    return jsonDict
end

function key2symbol(arr::Array)

    return [key2symbol(elem) for elem in arr]
end

function key2symbol(dict::Dict)

    mkSymbol(s) = Symbol(replace(s, r"[^a-zA-Z0-9]"=>"_"))

    d = Dict{Symbol}{Any}()
    for (k,v) in dict

        if v isa Dict
            d[mkSymbol(k)] = key2symbol(v)
        elseif v isa Array
            d[mkSymbol(k)] = [(elem isa Dict) ? key2symbol(elem) : elem for elem in v]
        else
            d[mkSymbol(k)] = v
        end
    end
    return d
end
