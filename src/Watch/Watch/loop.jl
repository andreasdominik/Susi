# main loop of Susi watch tool:
#

function watchSusi()

    open(MQTT_MESSAGE_PIPE) do fifo
       for oneMQTT in eachline(fifo)

           (topic, payload) = parseMQTT(oneMQTT)

            # println(oneMQTT)
            # println(topic)
            # println(payload)

            if topic != nothing && payload isa Dict
                if topic == TOPIC_LOG_SESSION_STARTED
                    showStartedSession(payload)
                elseif topic == TOPIC_SESSION_ENDED
                    showEndedSession(payload)

                elseif topic == TOPIC_START_SESSION
                    showStartSession(payload)
                elseif topic == TOPIC_HOTWORD
                    showHotwordDetected(payload)
                elseif topic == TOPIC_HOTWORD_ON
                    showHotwordOn(payload)

                elseif topic == TOPIC_ASR_START
                    showAudioRequest(payload)
                elseif topic == TOPIC_ASR_AUDIO
                    showAudioRecorded(payload)

                elseif topic == TOPIC_ASR_TRANSSCRIBE
                    showSTTRequest(payload)
                elseif topic == TOPIC_ASR_TEXT
                    showTransscript(payload)

                elseif topic == TOPIC_NLU_QUERY
                    showNLURequest(payload)
                elseif topic == TOPIC_NLU_PARSED
                    showNLUResult(payload)

                elseif occursin(TOPIC_INTENT, topic)
                    showIntentPublished(payload)

                elseif topic == TOPIC_END
                    showEndSession(payload)
                elseif topic == TOPIC_CONTINUE_SESSION
                    showContSession(payload)

                elseif topic == TOPIC_TTS_SAY
                    showSay(payload)
                elseif topic == TOPIC_TTS_REQUEST
                    showTTSRequest(payload)
                elseif topic == TOPIC_TTS_AUDIO
                    showTTSAudio(payload)
                elseif topic == TOPIC_PLAY
                    showPlay(payload)
                elseif topic == TOPIC_PLAY_FINISHED
                    showPlayFinished(payload)
                elseif topic == TOPIC_NOTIFICATION_ON
                    showNotification(payload, :on)
                elseif topic == TOPIC_NOTIFICATION_OFF
                    showNotification(payload, :off)
                end
            end
            # sleep(10.0)
        end
    end
end
