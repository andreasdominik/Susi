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


"""
    setSiteId(siteId)

Set the siteId in the Module SnipsHermesQnD
(necessary to direct the say() output to the current room)
"""
function setSiteId(siteId)

    global CURRENT_SITE_ID = siteId
end

"""
    getSiteId()

Return the siteId in the Module SnipsHermesQnD
(necessary to direct the say() output to the current room)
"""
function getSiteId()

    return CURRENT_SITE_ID
end



"""
    setSessionId(sessionId)

Set the sessionId in the Module SnipsHermesQnD.
The sessionId will be used to publish Hermes messages
inside a runing session. The framework handles this in the background.

## Arguments:
* sessionId: as String from a Hermes payload.
"""
function setSessionId(sessionId)

    global CURRENT_SESSION_ID = sessionId
end

"""
    getSessionId()

Return the sessionId of the currently running session.
"""
function getSessionId()

    return CURRENT_SESSION_ID
end



"""
    setDeveloperName(name)

Set the developer name of the currently running app in the Module SnipsHermesQnD.
The framework adds the name to MQTT messages in the background.

## Arguments:
* developerName: Name of the developer of the current app
                  i.e. the part before the colon of an intent name.
"""
function setDeveloperName(name)

    global CURRENT_DEVEL_NAME = name
end

"""
    getDeveloperName()

Return the name of the develpper of the currently running app.
"""
function getDeveloperName()

    return CURRENT_DEVEL_NAME
end



"""
    setModule(currentModule)

Set the module of the currently running app in SnipsHermesQnD.
The framework uses this in the background.

## Arguments:
* currentModule: The module in which the current skill is running.
                 (acessible via marco `@__MODULE__`)
"""
function setModule(currentModule)

    global CURRENT_MODULE = currentModule
end

"""
    getModule()

Return the module of the currently running app.
"""
function getModule()

    return CURRENT_MODULE
end





"""
    setTopic(topic)

Set the topic for which the currently running app is working.
The framework uses this in the background.

## Arguments:
* topic: name of current topic
"""
function setTopic(topic)

    global CURRENT_TOPIC = topic
end

"""
    getTopic()

Return the topic of the currently running app.
"""
function getTopic()

    return CURRENT_TOPIC
end


"""
    setIntent(topic)

Set the intent for which the currently running app is working.
The framework uses this in the background.

## Arguments:
* topic: name of current topic
"""
function setIntent(topic)

    m = match(r"hermes/intent/\w+:(?<intent>\w+)", topic)
    if m != nothing
        global CURRENT_INTENT = m[:intent]
    else
        global CURRENT_INTENT = "unkown_intent"
    end
end

"""
    getIntent()

Return the intent name of the currently running app.
"""
function getIntent()

    return CURRENT_INTENT
end
