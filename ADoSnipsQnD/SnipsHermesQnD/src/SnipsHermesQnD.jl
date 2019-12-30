module SnipsHermesQnD

import JSON
import StatsBase
using Dates
using Distributed

include("utils.jl")
include("snips.jl")
include("mqtt.jl")
include("hermes.jl")
include("intents.jl")
include("config.jl")
include("dates.jl")
include("db.jl")
include("schedule.jl")
include("gpio.jl")
include("shelly.jl")
include("weather.jl")
include("languages.jl")
include("callback.jl")

CONFIG_INI = Dict{Symbol, Any}()
prefix = nothing    # prefix for parameter names
CURRENT_SITE_ID = "default"
CURRENT_SESSION_ID = "1"
CURRENT_DEVEL_NAME = "unknown"
CURRENT_MODULE = Main
CURRENT_INTENT = "none"
CURRENT_APP_DIR = ""
CURRENT_APP_NAME = "QnD framework"

# set default language and texts to en
#
DEFAULT_LANG = "en"
LANG = DEFAULT_LANG
TEXTS = TEXTS_EN
setLanguage(LANG)
LANGUAGE_TEXTS = Dict{Any, Any}()   # one entry for every language, e.g. "en", "de", ...
INI_MATCH = "must_include"

# List of intents to listen to:
# (intent, developer, complete topic, module, skill-action)
#
SKILL_INTENT_ACTIONS = Tuple{AbstractString, AbstractString, AbstractString,
                             Module, Function}[]

export subscribeMQTT, readOneMQTT, publishMQTT, publishMQTTfile,
       subscribe2Intents, subscribe2Topics, listenIntentsOneTime,
       publishEndSession, publishContinueSession,
       publishStartSessionAction, publishStartSessionNotification,
       publishSystemTrigger,publishListenTrigger, makeSystemTrigger,
       configureIntent,
       registerIntentAction, registerTriggerAction,
       getIntentActions, setIntentActions,
       askYesOrNoOrUnknown, askYesOrNo,
       publishSay,
       setLanguage, addText, langText,
       setSiteId, getSiteId,
       setSessionId, getSessionId,
       setDeveloperName, getDeveloperName, setModule, getModule,
       setAppDir, getAppDir, setAppName, getAppName,
       setTopic, getTopic, setIntent, getIntent,
       readConfig, matchConfig, getConfig, isInConfig, getAllConfig,
       isConfigValid, isValidOrEnd, setConfigPrefix, resetConfigPrefix,
       tryrun, tryReadTextfile, ping,
       tryParseJSONfile, tryParseJSON, tryMkJSON,
       extractSlotValue, isInSlot, isOnOffMatched, readTimeFromSlot,
       readableDateTime,
       setGPIO, printDebug, printLog,
       switchShelly1, switchShelly25relay, moveShelly25roller,
       allOccuresin, oneOccursin, allOccursinOrder,
       isFalseDetection,
       dbWritePayload, dbWriteValue, dbReadEntry, dbReadValue, dbHasEntry,
       schedulerAddAction, schedulerAddActions, schedulerMakeAction,
       schedulerDeleteAll, schedulerDeleteTopic, schedulerDeleteOrigin,
       getOpenWeather

end # module
