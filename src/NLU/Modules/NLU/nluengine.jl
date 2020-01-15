function listener()

    host = CONFIG["mqtt"]["host"]
    port = CONFIG["mqtt"]["port"]
    user = CONFIG["mqtt"]["user"]
    password = CONFIG["mqtt"]["password"]

    (length(host) < 1) && (host = nothing)
    (length(port) < 1) && (port = nothing)
    (length(user) < 1) && (user = nothing)
    (length(password) < 1) && (password = nothing)

    topics = TOPIC_NLU_QUERY
    while true
        (topic, payload) = readOneMQTT(topics,
                                       hostname = host, port = port,
                                       user = user,password =password)

        # aboard silently:
        #
        if !(haskey(payload, :input) && length(payload[:input]) > 0)
            println("[NLU]: No input text in NLU request!")
            return
        else
            result = Dict{Symbol,Any}(:id => payload[:id],
                          :sessionId => payload[:sessionId],
                          :input => payload[:input])

            if !haskey(payload, :intentFilter)
                payload[:intentFilter] = []
            end

            matched = findIntent(payload[:input], payload[:intentFilter])

            if matched[:matched]
                # make nlu result payload:
                #
                result[:intent] = matched[:intent]
                result[:slots] = matched[:slots]

                # publish nlu result:
                #
                publishMQTT(TOPIC_NLU_PARSED, result,
                                       hostname = host, port = port,
                                       user = user,password =password)
                printDict(result)
            else
                # publish intent not recognised:
                #
                publishMQTT(TOPIC_NLU_NOT, result,
                                       hostname = host, port = port,
                                       user = user,password =password)
                printDict(result)
            end
        end
    end
end


"""
The core NLU.
Payload has the format:
```
Dict Input (text to analyse)
     intentFilter (list of intents or empty list)
     id (request id)
     sessionId
```
"""
function findIntent(command, filter)

    # clean command:
    #
    command = strip(command)
    command = replace(command, r"\s{2,}" => " ")

    for oneMatch in MATCHES

        println("testing ... $(oneMatch.match) => $(oneMatch.matchExpression)")
        if length(filter) == 0 || oneMatch.intent in filter

            matched = matchOne(command, oneMatch)
            if matched[:matched]
                return matched
            end
        end
    end

    return Dict(:matched=>false)
end


function matchOne(command, oneMatch)

    m = match(oneMatch.matchExpression, command)
    if m != nothing
        slotNames = values(Base.PCRE.capture_names(m.regex.regex))

        # slots is a list of slot with Dicts as elements:
        #  "rawValue": "zwei"
        #  "value":
        #       "kind": "Number", "InstantTime", "Duration", "Ordinal",
        #                         "Custom" == everything else
        #       "value": 2
        #   "range":
        #       "start": 15,
        #       "end": 19
        #   "entity": "snips/number",
        #   "slotName": "Quantity"
        #
        slots = []
        for slotName in slotNames
            slot = oneMatch.slots[slotName]
            raw = m[Symbol(slotName)]
            value = slot.postfun(raw)
            if slot.type in ["InstantTime", "Currency", "Number", "Ordinal", "Duration"]
                kind = slot.type
                entity = slot.type
            else
                kind = "Custom"
                entity = slot.type
            end
            # add dummy ranges:
            #
            range = Dict(:start => 1, :end => 2)
            # slotName = slotName already there

            slot = Dict(:rawValue => raw,
                        :value => Dict(:kind => kind,
                                       :value => value),
                        :range => range,
                        :entity => entity,
                        :slotName => slotName )
            push!(slots, slot)
        end

        matched = Dict(:matched => true,
                     :intent => Dict(:intentName => oneMatch.intent,
                                     :confidenceScore => 1,
                                     :match => oneMatch.match),
                     :skill => oneMatch.skill,
                     :match => oneMatch.match,
                     :slots => slots)
        return matched
    end

    matched = Dict(:matched => false)
    return matched
end
