# Simple quick-and-dirty wrapper around mosquitto
# to publish and subscribe to messages.
#
# A. Dominik, 2019
#


"""
    subscribeMQTT(topics, callback; hostname = nothing, port = nothing)

Listen to one or more topics.

## Arguments
* `topics`: AbstractString or List of AbtsractString to define
          topics to subscribe
* `callback`: Function to be executed for a incoming message.
* `hostname`:
* `port`:     Hostname and port to listen. If not specified
            mosquitto_sub will be called without hostname/port
            (using the default configuration of the system).

## Details:
The callback function has the signature f(topic, payload), where
topic is a String and payload a Dict{Symbol, Any} with the content
of the payload (assuming, that the payload is in JSON-format) or
a String, if the payload is not a valid JSON.

The callback function is spawned.
"""
function subscribeMQTT(topics, callback; hostname = nothing, port = nothing)

    cmd = constructMQTTcmd(topics, hostname = hostname, port = port)

    # # listen forever:
    # #
    # while true
    #     # printDebug(getAllConfig())
    #     # printDebug(getConfig(:debug))
    #     # printDebug(matchConfig(:debug))
    #
    #     retrieved = runOneMQTT(cmd)
    #     topic, payload = parseMQTT(retrieved)
    #
    #     if topic != nothing && payload != nothing
    #         if matchConfig(:debug, "no_parallel")
    #             callback(topic, payload)
    #         else
    #             @spawn callback(topic, payload)
    #         end
    #     end
    # end

    # MQTT listen and write to channel:
    #
    intents = Channel(32)
    @async while true
        retrieved = runOneMQTT(cmd)
        put!(intents, retrieved)
    end


    # process intents from channel:
    #
    while true
        retrieved = take!(intents)
        (topic, payload) = parseMQTT(retrieved)

        if topic != nothing && payload != nothing
            if matchConfig(:debug, "no_parallel")
                callback(topic, payload)
            else
                @async callback(topic, payload)
            end
        end
    end
end



"""
    readOneMQTT(topics; hostname = nothing, port = nothing)

Listen to one or more topics until one message is
retrieved and return topic as string and payload as Dict
or as String if JSON parsing is not possible).

## Arguments
* `topics`: AbstractString or List of AbstractString to define
          topics to subscribe
* `hostname`:
* `port`:     Hostname and port to listen. If not specified
            mosquitto_sub will be called without hostname/port
            (using the default configuration of the system).
"""
function readOneMQTT(topics; hostname = nothing, port = nothing)

    cmd = constructMQTTcmd(topics, hostname = hostname, port = port)

    retrieved = runOneMQTT(cmd)
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
                          timeout = nothing)

    cmd = `mosquitto_sub -v -C 1`
    if hostname != nothing
        cmd = `$cmd -h $hostname`
    end

    if port != nothing
        cmd = `$cmd -p $port`
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
    #println("Mosquito command is : $cmd")

    return cmd
end


"""
    runOneMQTT(cmd)

Run the cmd return mosquito_sub output.
"""
function runOneMQTT(cmd)

    printLog("MQTT-command: $cmd")
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
        printLog("ERROR: Unable to parse MQTT message!")
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
function publishMQTT(topic, payload, hostname = nothing, port = nothing)

    # build cmd string:
    #
    cmd = `mosquitto_pub`
    if hostname != nothing
        cmd = `$cmd -h $hostname`
    end

    if port != nothing
        cmd = `$cmd -p $port`
    end

    cmd = `$cmd -t $topic`

    json = tryMkJSON(payload)
    if json isa AbstractString && length(json) > 0
        cmd = `$cmd -m $json`
    else
        cmd = `$cmd -m ''`
    end

    cmd = Cmd(cmd, ignorestatus = true)

    printLog(cmd)
    run(cmd, wait = true)  # false maybe possible?
end


"""
    publishMQTTfile(topic, fname, hostname = nothing, port = nothing)

Publish a MQTT message with a file as payload.

## Arguments
* `topics`: String with the topic
* `fname`: full path and name of file to be published
* `hostname`:
* `port`:     Hostname and port to use. If not specified
            mosquitto_sub will be called without hostname/port
            (using the default configuration of the system).
"""
function publishMQTTfile(topic, fname, hostname = nothing, port = nothing)

    # build cmd string:
    #
    cmd = `mosquitto_pub`
    if hostname != nothing
        cmd = `$cmd -h $hostname`
    end

    if port != nothing
        cmd = `$cmd -p $port`
    end

    cmd = `$cmd -t $topic`

    if fname isa AbstractString && length(fname) > 0
        cmd = `$cmd -f $fname`
    else
        cmd = `$cmd -m ''`
    end

    cmd = Cmd(cmd, ignorestatus = true)

    printLog(cmd)
    run(cmd, wait = true)  # false maybe possible?
end
