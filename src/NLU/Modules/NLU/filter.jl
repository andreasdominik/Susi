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

                global intentFilter
                # add to list if disable
                # delete from list if enable:
                #
                if !oneIntent[:enable]
                    push!(intentFilter, (siteId, oneIntent[:intentId]))
                else
                    if siteId == "#"
                        filter!(elem->!(elem[2]==oneIntent[:intentId]), intentFilter)
                    else
                        filter!(elem->!(elem[1]==siteId && elem[2]==oneIntent[:intentId]), intentFilter)
                    end
                end
            end
        end
    end
end

function setIntentAllFilter(payload)
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
    filter!(elem->!(elem[1]==siteId), intentFilter)
end

function resetFiltersAll()

    global intentFilter = Tuple{AbstractString,AbstractString}[]
end
