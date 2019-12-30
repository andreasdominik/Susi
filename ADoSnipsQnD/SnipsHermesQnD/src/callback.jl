#
# main callback function:
#
# Normally, it is NOT necessary to change anything in this file,
# unless you know what you are doing!
#

function mainCallback(topic, payload)

    # println("""*********************************************
    #         $payload
    #         ************************************************""")

    if !(payload isa Dict) ||
       !(haskey(payload, :siteId)) ||
       !(haskey(payload, :sessionId))


        printLog("Corrupted payload detected for topic $topic")
        # printLog("payload: $(JSON.print(payload))")
        printLog("intent or trigger aborted!")
        return
    end

    # find the intents or triggers that match the current
    # message:
    matchedTopics = filter(Main.INTENT_ACTIONS) do i
                        i[3] == topic
                    end

    for t in matchedTopics

        topic = t[3]
        fun = t[5]   # action function
        skill = t[4]   # module

        if occursin(r"hermes/intent/", topic)
            printLog("Hermes intent $topic recognised; execute $fun in $skill.")
        else occursin(r"qnd/trigger/", topic)
            printLog("System trigger $topic recognised; execute $fun in $skill.")
        end
        skill.callbackRun(fun, topic, payload)
    end

    #println("*********** mainCallback() ended! ****************")
end
