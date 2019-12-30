# Hermes wrapper
#
#
# A. Dominik, 2019
#



"""
    subscribe2Intents(intents, callback; moreTopics = nothing)

Subscribe to one or a list of intents and listen forever and run the callback
if a matching intent is recieved.

## Arguments:
* `intents`: Abstract String or List of Abstract Strings to define
           intents to subscribe. The intents will be expanded
           to topics (i.e. "hermes/intent/SwitchOnLight")
* `callback`: Function to be executed for a incoming message
* `moreTopics`: keyword arg to provide additional topics to subscribe
            (complete names of of topics).

## Details:
The callback function has the signature f(topic, intentMessage), where
topic is a String and intentMessage a Dict{Symbol, Any} with the content
of the payload (assuming, that the payload is in JSON-format) or
a String, if the payload is not valid JSON.
The callback function is spawned and the function is listening
to the MQTT server while the callback is executed.
"""
function subscribe2Intents(intents, callback; moreTopics = nothing)

    topics = "hermes/intent/" .* intents
    topics = addStringsToArray!(topics, moreTopics)
    subscribe2Topics(topics, callback)
end


"""
    subscribe2Topics(topics, callback)

Subscribe to one or a list of topics and listen forever and run the callback
if a matching intent is recieved.

## Arguments:
* `topics`: Abstract String or List of Abstract Strings to define
           topics to subscribe.
* `callback`: Function to be executed for a incoming message

See `subscribe2Intents()` for details.
"""
function subscribe2Topics(topics, callback)

    subscribeMQTT(topics, callback; hostname = nothing, port = nothing)
end


"""
    listenIntentsOneTime(intents; moreTopics = nothing)

Subscribe to one or a list of Intents, but listen only until one
matching intent is recognised.

## Arguments
* `intents`: AbstractString or List of AbstractString to define
           intents to subscribe or nothing
* `moreTopics`: keyword arg to provide additional topics to subscribe to.

## Value:
Return values are topic (as String) and payload (as Dict or as
String if JSON parsing is not possible).
If the topic is an intent, only the intent id is returned
(i.e.: devname:intentname without the leading hermes/intent/)
"""
function listenIntentsOneTime(intents; moreTopics = nothing)

    if intents == nothing
        topics = String[]
    else
        topics = "hermes/intent/" .* intents
    end
    topics = addStringsToArray!(topics, moreTopics)

    topic, payload = readOneMQTT(topics; hostname = nothing, port = nothing)
    #println(topic, " ", "$(typeof(topic))")
    intent = topic
    if intent isa AbstractString
        intent = replace(topic, "hermes/intent/"=>"")
    end

    return intent, payload
end



"""
    askYesOrNoOrUnknown(question)

Ask the question and listen to the intent "ADoSnipsYesNoDE"
and return :yes if "Yes" is answered or :no if "No" or
:unknown otherwise.

## Arguments:
* `question`: String with the question to be uttered by Snips
"""
function askYesOrNoOrUnknown(question)

    intentListen = "andreasdominik:ADoSnipsYesNoDE"
    topicsListen = ["hermes/nlu/intentNotRecognized", "hermes/error/nlu",
                    "hermes/dialogueManager/intentNotRecognized"]
    slotName = "yes_or_no"

    listen = true
    intent = ""
    payload = Dict()

    configureIntent(intentListen, true)

    question = langText(question)
    publishContinueSession(question, sessionId = CURRENT_SESSION_ID,
              intentFilter = intentListen,
              customData = nothing, sendIntentNotRecognized = true)
    # publishStartSessionAction(question, siteId = CURRENT_SITE_ID,
    #           intentFilter = intentListen,
    #           sendIntentNotRecognized = true)
    topic, payload = listenIntentsOneTime(intentListen,
                            moreTopics = topicsListen)

    configureIntent(intentListen, false)

    if isInSlot(payload, slotName, "YES")
        return :yes
    elseif isInSlot(payload, slotName, "NO")
        return :no
    else
        return :unknown
    end
end


"""
    askYesOrNo(question)

Ask the question and listen to the intent "ADoSnipsYesNoDE"
and return :true if "Yes" or "No" otherwise.

## Arguments:
* `question`: String with the question to uttered
"""
function askYesOrNo(question)

    answer = askYesOrNoOrUnknown(question)
    return answer == :yes
end



"""
    publishEndSession(text; sessionId = CURRENT_SESSION_ID)

MQTT publish end session.

## Arguments:
* `sessionId`: ID of the session to be terminated as String.
             If omitted, sessionId of the current will be inserted.
* `text`: text to be said via TTS
"""
function publishEndSession(text = nothing, sessionId = CURRENT_SESSION_ID)

    text = langText(text)
    payload = Dict(:sessionId => sessionId)
    if text != nothing
        payload[:text] = text
    end
    publishMQTT("hermes/dialogueManager/endSession", payload)
end




"""
    publishContinueSession(text; sessionId = CURRENT_SESSION_ID,
         intentFilter = nothing,
         customData = nothing, sendIntentNotRecognized = false)

MQTT publish continue session.

## Arguments:
* `sessionId`: ID of the current session as String
* `text`: text to be said via TTS
* `intentFilter`: Optional Array of String - a list of intents names to
                restrict the NLU resolution on the answer of this query.
* `customData`: Optional String - an update to the session's custom data.
* `sendIntentNotRecognized`: Optional Boolean -  Indicates whether the
                dialogue manager should handle non recognized intents
                by itself or sent them as an Intent Not Recognized for
                the client to handle.
"""
function publishContinueSession(text; sessionId = CURRENT_SESSION_ID,
         intentFilter = nothing,
         customData = nothing, sendIntentNotRecognized = false)

    text = langText(text)
    payload = Dict{Symbol, Any}(:sessionId => sessionId, :text => text)

    if intentFilter != nothing
        if intentFilter isa AbstractString
            intentFilter = [intentFilter]
        end
        payload[:intentFilter] = intentFilter
    end
    if customData != nothing
        payload[:customData] = customData
    end
    if sendIntentNotRecognized != nothing
        payload[:sendIntentNotRecognized] = sendIntentNotRecognized
    end

    publishMQTT("hermes/dialogueManager/continueSession", payload)
end


"""
    publishStartSessionAction(text; siteId = CURRENT_SITE_ID,
         intentFilter = nothing, sendIntentNotRecognized = false,
         customData = nothing)

MQTT publish start session with init action

## Arguments:
* `siteId`: ID of the site in which the session is started
* `text`: text to be said via TTS
* `intentFilter`: Optional Array of String - a list of intent names to
                restrict the NLU resolution of the answer of this query.
* `sendIntentNotRecognized`: Optional Boolean -  Indicates whether the
                dialogue manager should handle non recognized intents
                by itself or sent them as an Intent Not Recognized for
                the client to handle.
* `customData`: data to be sent to the service.
"""
function publishStartSessionAction(text; siteId = CURRENT_SITE_ID,
                intentFilter = nothing, sendIntentNotRecognized = false,
                customData = nothing)

    text = langText(text)

    if intentFilter != nothing
        if intentFilter isa AbstractString
            intentFilter = [intentFilter]
        end
    end

    init = Dict(:type => "action",
                :text => text,
                :canBeEnqueued => true,
                :sendIntentNotRecognized => sendIntentNotRecognized)
    if intentFilter != nothing
        init[:intentFilter] = intentFilter
    end

    publishStartSession(siteId, init, customData = customData, wait = true)
end


"""
    publishStartSessionNotification(text; siteId = CURRENT_SITE_ID,
                                    customData = nothing)

MQTT publish start session with init notification

## Arguments:
* `siteId`: siteID
* `text`: text to be said via TTS
* `customData`: data to be sent to the service.
"""
function publishStartSessionNotification(text; siteId = CURRENT_SITE_ID,
                customData = nothing)

    text = langText(text)
    init = Dict(:type => "notification",
                :text => text)

    publishStartSession(siteId, init, customData = customData, wait = true)
end



"""
    publishStartSession(siteId, init; customData = nothing,
                        wait = true)

Worker function for publish start session; called for
start session topics of type action or notification.
"""
function publishStartSession(siteId, init; customData = nothing,
                             wait = true)

    payload = Dict{Symbol, Any}(
                :siteId => siteId,
                :init => init)

    if customData != nothing
        payload[:customData] = customData
    end

    publishMQTT("hermes/dialogueManager/startSession", payload)
end





"""
    publishSay(text; sessionId = CURRENT_SESSION_ID, siteId = nothing,
                    lang = LANG, id = nothing, wait = true)

Let the TTS say something.

The variant with a Symbol as first argument looks up the phrase in the
dictionary of phrases for the selected language by calling
`getText()`.

## Arguments:
* `text`: text to be said via TTS
* `lang`: optional language code to use when saying the text.
        If not specified, default language will be used
* `sessionId`: optional ID of the session if there is one
* `id`: optional request identifier. If provided, it will be passed back
      in the response on hermes/tts/sayFinished.
* `wait`: wait until the massege is spoken (i.i. wait for the
        MQTT-topic)
"""
function publishSay(text; sessionId = CURRENT_SESSION_ID,
                    siteId = CURRENT_SITE_ID, lang = LANG,
                    id = nothing, wait = true)

    text = langText(text)
    payload = Dict(:text => text, :siteId => siteId)

    if lang != nothing
        payload[:lang] = lang
    end

    payload[:sessionId] = sessionId

    # make unique ID:
    #
    if id == nothing
        id = ""
        for i in 1:25
            id = id * StatsBase.sample(collect("abcdefghijklmnopqrst0123456789"))
        end
    end
    payload[:id] = id

    publishMQTT("hermes/tts/say", payload)

    # wait until finished:
    #
    if wait == true
        while wait
            topic, payload = readOneMQTT("hermes/tts/sayFinished")
            if payload[:id] == id
                wait = false
            end
        end
    end
end


# function publishSay(text::Symbol; sessionId = CURRENT_SESSION_ID,
#                     siteId = CURRENT_SITE_ID, lang = LANG,
#                     id = nothing, wait = true)
#
#     strText = langText(text)
#     publishSay(strText, sessionId, siteId,lang, id, wait)
# end
#
#
#
# """
#     langText(key; lang = LANG)
#
# Return the text specified by the key in the specified language
# (or the default language if not given).
# """
# function langText(key; lang = LANG)
#
#     if haskey(LANGUAGE_TEXTS, lang) && haskey(LANGUAGE_TEXTS[lang], key)
#         text = LANGUAGE_TEXTS[lang][key]
#     else
#         text = TEXTS_EN[:error_text]
#     end
#
#     return text
# end



#
# function setLangText(texts, lang)
#
#     global LANGUAGE_TEXTS[lang]

"""
    isOnOffMatched(payload, deviceName; siteId = CURRENT_SITE_ID)

Action to be combined with the ADoSnipsOnOFF intent.
Depending on the payload the function returns:
* :on if "on"
* :off if "off"
* :matched, if the device is matched but no on or off
* :unmatched, if one of
    * wrong siteId
    * wrong device
## Arguments:
* `payload`: payload of intent
* `siteId`: siteId of the device to be matched with the payload of intent
            if `siteId == "any"`, the device will be matched w/o caring
            about siteId or room.
* `deviceName` : name of device to be matched with the payload of intent
"""
function isOnOffMatched(payload, deviceName; siteId = CURRENT_SITE_ID)

    result = :unmatched

    if siteId == "any"
        commandSiteId = siteId
    else
        commandSiteId = extractSlotValue(payload, "room")
        if commandSiteId == nothing
            commandSiteId = payload[:siteId]
        end
    end

    printDebug("siteId: $siteId")
    printDebug("payload[:siteId]: $(payload[:siteId])")
    printDebug("commandSiteId: $commandSiteId")
    printDebug("deviceName: $deviceName")

    if commandSiteId == siteId

        # test device name from payload
        #
        if isInSlot(payload, "device", deviceName)
            if isInSlot(payload, "on_or_off", "ON")
                result = :on
            elseif isInSlot(payload, "on_or_off", "OFF")
                result = :off
            else
                result = :matched
            end
        end
    end
    return result
end




"""
    configureIntent(intent, on)

Enable or disable an intent.

## Arguments:
* `intent`: one intent to be configured
* `on`: boolean value; if `true`, the intent is enabled; if `false`
  it is disabled.
 """
function configureIntent(intent, on)

    topic = "hermes/dialogueManager/configure"

    payload = Dict(:siteId=>CURRENT_SITE_ID,
                   :intents=>[Dict(:intentId=>intent, :enable=>on)])

    publishMQTT(topic, payload)
end



"""
    isValidOrEnd(param; errorMsg = "parameter is nothing")

End the session, with the message, if the param is `nothing`
and returns false or true otherwise.

Function is a shortcut:
```Julia
if param == nothing
    Snips.publishEndSession(:error)
    return true
end
```
is:
```Julia
Snips.isValidOrEnd(param, :error) || return true
```

## Arguments:
* param: any value (from slot or config.ini) that may be `nothing`
* errorMsg: Error as string or key of a text in the
  languages Dict (::Symbol).
"""
function isValidOrEnd(param; errorMsg)

    if param == nothing || length(param) < 1
        publishEndSession( errorMsg)
        return false
    else
        return true
    end
end
