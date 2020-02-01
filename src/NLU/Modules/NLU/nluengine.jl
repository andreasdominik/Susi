function listener()

    host = CONFIG["mqtt"]["host"]
    port = CONFIG["mqtt"]["port"]
    user = CONFIG["mqtt"]["user"]
    password = CONFIG["mqtt"]["password"]

    (length(host) < 1) && (host = nothing)
    (length(port) < 1) && (port = nothing)
    (length(user) < 1) && (user = nothing)
    (length(password) < 1) && (password = nothing)

    topics = [TOPIC_NLU_QUERY,
              TOPIC_NLU_INTENT_FILTER,
              TOPIC_NLU_RESET_INTENT_FILTER]

    while true
        (topic, payload) = readOneMQTT(topics,
                                       hostname = host, port = port,
                                       user = user,password =password)

        if topic == TOPIC_NLU_INTENT_FILTER
            setIntentFilter(payload)

        elseif topic == TOPIC_NLU_RESET_INTENT_FILTER
            resetIntentFilter(payload)

        # aboard silently:
        #
        elseif !(haskey(payload, :input) && length(payload[:input]) > 0)
            println("[NLU]: No input text in NLU request!")

        else
            result = Dict{Symbol,Any}(:id => payload[:id],
                          :sessionId => payload[:sessionId],
                          :input => payload[:input])

            if haskey(payload, :intentFilter)
               posFilter = payload[:intentFilter]
            else
               posFilter = []
            end

            if !haskey(payload, :siteId)
               payload[:siteId] = "default"
            end
            negFilter = mkFilter(payload[:siteId])

            matched = findIntent(payload[:input], payload[:siteId],
                                 posFilter, negFilter)

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
function findIntent(command, siteId, posFilter, negFilter)

    # clean command:
    #
    command = strip(command)
    command = replace(command, r"\s{2,}" => " ")

    for oneMatch in MATCHES

        # test if filtered:
        #
        if length(posFilter) > 0
            useit = (oneMatch.intent in posFilter)
        else
            useit = ! (oneMatch.intent in negFilter)
        end

        if useit
            println()
            println("""testing ... >$command< against $(oneMatch.match):
            $(oneMatch.matchExpression)""")

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
            raw = strip(raw)
            if length(raw) > 0
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


"""
make a list of filtered intents for this NLU request from
paylod list and from global intentFilter list
"""
function mkFilter(siteId)

    global intentFilter
    negFilter = []

    for (s, f) in intentFilter
        if s == siteId || s == "#"
            push!(negFilter, f)
        end
    end
    return negFilter
end
