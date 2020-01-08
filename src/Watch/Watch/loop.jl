# main loop of Susi watch tool:
#

function watchSusi(host, port, user, password)

    while true
        (topic, payload) = readOneMQTT(["hermes/#", "susi/#"],
                            hostname = host, port = port,
                            user = user, password = password)

        println(payload)
        
        if topic == TOPIC_START_SESSION
            showStartSession(payload)
        end
    end
end
