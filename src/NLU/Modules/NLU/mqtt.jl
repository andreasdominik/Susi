# Simple quick-and-dirty wrapper around mosquitto
# to publish and subscribe to messages.
#
# A. Dominik, 2019
#



"""
    readOneMQTT(topics; hostname = nothing, port = nothing
                        user = nothing, password = nothing)

Listen to one or more topics until one message is
retrieved and return topic as string and payload as Dict
or as String if JSON parsing is not possible).

## Arguments
* `topics`: AbstractString or List of AbstractString to define
            topics to subscribe
* `hostname`, `port`, `user`, `password`:   Hostname and port to listen.
            If not specified
            mosquitto_sub will be called without hostname/port
            (using the default configuration of the system).
"""
function readOneMQTT(topics; hostname = nothing, port = nothing,
                             user = nothing, password = nothing)

    cmd = constructMQTTcmd(topics, hostname = hostname, port = port,
                                   user = user, password = password)

    println("cmd: cmd")
    retrieved = runOneMQTT(cmd)
    println("retrieved: $retrieved \n")
    topic, payload = parseMQTT(retrieved)

    return topic, payload
end



#
#
# low-level mosquito-commands:
#
#

"""
    constructMQTTcmd(topics; hostname = nothing, port = nothing
                          timeout = nothing)

Build the shell cmd to retrieve one MQTT massege with mosquito_sub.
Timeout is in sec.
"""
function constructMQTTcmd(topics; hostname = nothing, port = nothing,
                          user = nothing, password = nothing,
                          timeout = nothing)

    # TODO: `$(CONFIG["mqtt_subsribe"] -v -C 1)`
    cmd = `mosquitto_sub -v -C 1 --qos 2`
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
        cmd = `$cmd -t 'hermes/#' -t 'susi/#'`
    end

    if timeout != nothing
        cmd = `$cmd -W $timeout`
    end

    cmd = Cmd(cmd, ignorestatus = true)
    #println("Mosquito command is : $cmd")

    return cmd
end


"""
    runOneMQTT(cmd)

Run the cmd return mosquito_sub output.
"""
function runOneMQTT(cmd)

    return read(cmd, String)
end


"""
    parseMQTT(message)

Parse the output of mosquito_sub -v and return topic as string
and payload as Dict (or String if JSON parsing is not possible)
"""
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





"""
    publishMQTT(topic, payload, hostname = nothing, port = nothing)

Publish a MQTT message.

## Arguments
* `topics`: String with the topic
* `payload`: Dict() with message
* `hostname`:
* `port`:     Hostname and port to use. If not specified
            mosquitto_sub will be called without hostname/port
            (using the default configuration of the system).
"""
function publishMQTT(topic, payload; hostname = nothing, port = nothing,
                            user = nothing, password = nothing)

    # build cmd string:
    #
    # TODO: `$(CONFIG["mqtt_publish"])`
    cmd = `mosquitto_pub --qos 2`
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

    cmd = `$cmd -t $topic`

    json = tryMkJSON(payload)
    if json isa AbstractString && length(json) > 0
        cmd = `$cmd -m $json`
    else
        cmd = `$cmd -m ''`
    end

    cmd = Cmd(cmd, ignorestatus = true)
    run(cmd, wait = false)
end

#
#
# Helper function for JSON:
#
#
"""
    tryParseJSON(text)

parses a JSON and returns a hierarchy of Dicts{Symbol, Any} and Arrays with
the content or a string (text), if text is not a valid JSON, the raw string is
returned.
"""
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





"""
    key2symbol(arr::Array)

Wrapper for key2symbol, if 1st hierarchy is an Array
"""
function key2symbol(arr::Array)

    return [key2symbol(elem) for elem in arr]
end


"""
    key2symbol(dict::Dict)

Return a new Dict() with all keys replaced by Symbols.
d is scanned hierarchically.
"""
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

"""
    tryMkJSON(payload)

Create a JSON representation of the input (nested Dict or Array)
or return an empty string if not possible.
"""
function tryMkJSON(payload)

    json = Dict()
    try
        json = JSON.json(payload)
    catch
        json = ""
    end

    return json
end


"""
    tryParseJSONfile(fname; quiet = false)

Parse a JSON file and return a hierarchy of Dicts with
the content.
* keys are changed to Symbol
* on error, an empty Dict() is returned

## Arguments:
- fname: filename
- quiet: if false Snips utters an error message
"""
function tryParseJSONfile(fname; quiet = false)

    try
        json = JSON.parsefile( fname)
    catch
        msg = TEXTS[:error_json]
        if ! quiet
            publishSay(msg)
        end
        printDebug("tryParseJSONfile: $msg : $fname")
        json = Dict()
    end

    json = key2symbol(json)
    return json
end
