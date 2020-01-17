# implementation of intent filter
#
#
# intentFilter is a Dict (siteId, intent) => true/false
#
# if an intent is not listed, it is used (default == true), otherweise
# the value of the Dict tells if used or not.
#

"""
payload is the payload of the MQTT with topic hermes/dialogueManager/configure
with symbols as keys.
"""
function setIntentFilter(payload)

    if haskey(payload, :siteId)
        siteId = payload[:siteId]
    else
        siteId = "#"
    end

    if haskey(payload, :intents) && payload[:intents] isa AbstractArray
        for oneIntent in payload[:intents]
            if haskey(oneIntent, :intentId) && haskey(oneIntent, :enable)
                global intentFilter[(siteId, oneIntent[:intentId])] = oneIntent[:enable]
            end
        end
    end
end


"""
payload is the payload of the MQTT with topic hermes/dialogueManager/configureReset
with symbols as keys.
"""
function resetIntentFilter(payload)

    if haskey(payload, :siteId)
        resetFiltersSite(payload[:siteId])
    else
        resetFiltersAll()
    end
end


function resetFiltersSite(siteId)

    global intentFilter
    for ((filterSiteId, intent), enable) in intentFilter
        if siteId == filterSiteId
            delete!(intentFilter, (filterSiteId, intent))
        end
    end
end

function resetFiltersAll()

    global intentFilter = Dict{Tuple{AbstractString,AbstractString}, Bool}() 
end
