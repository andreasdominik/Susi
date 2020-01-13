#
# watch he MQTT traffic of susi.
#
# © Andreas Dominik, THM, 2010
#
#
# MQTT helpers:
#
function readOneMQTT(topics; hostname = nothing, port = nothing,
                             user = nothing, password = nothing)

    cmd = constructMQTTcmd(topics, hostname = hostname, port = port,
                                   user = user, password = password)

    # println("MQTT: $cmd")
    retrieved = runOneMQTT(cmd)
    # println("retrieved: $retrieved")
    topic, payload = parseMQTT(retrieved)

    return topic, payload
end



function constructMQTTcmd(topics; hostname = nothing, port = nothing,
                          user = nothing, password = nothing,
                          timeout = nothing)

    cmd = `mosquitto_sub -v -C 1 -R --qos 2 --id $(MQTT_CLIENT_ID) -c`
    if hostname != nothing
        cmd = `$cmd -h $hostname`
    end

    if port != nothing
        cmd = `$cmd -p $port`
    end

    if user != nothing
        cmd = `$cmd -u $user`
    end

    if password != nothing
        cmd = `$cmd -P $password`
    end

    if topics isa AbstractString
        cmd = `$cmd -t $topics`
    elseif topics isa Array
        unique!(topics)
        for topic in topics
            cmd = `$cmd -t $topic`
        end
    else
        cmd = `$cmd -t '#'`
    end

    if timeout != nothing
        cmd = `$cmd -W $timeout`
    end

    cmd = Cmd(cmd, ignorestatus = true)
    # println("Mosquito command is : $cmd")

    return cmd
end


function runOneMQTT(cmd)

    return read(cmd, String)
end


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
