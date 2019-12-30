

# DO NOT CHANGE THE FOLLOWING 3 LINES UNLESS YOU KNOW
# WHAT YOU ARE DOING!
# set CONTINUE_WO_HOTWORD to true to be able to chain
# commands without need of a hotword in between:
#
lang = Snips.getConfig(:language)
const LANG = (lang != nothing) ? lang : "de"

const CONTINUE_WO_HOTWORD = true
const DEVELOPER_NAME = "andreasdominik"
Snips.setDeveloperName(DEVELOPER_NAME)
Snips.setModule(@__MODULE__)

# Slots:
# Name of slots to be extracted from intents:
#
SLOT_ROOM = "room"
SLOT_DEVICE = "device"
SLOT_ON_OFF = "on_or_off"

# name of entry in config.ini:
#
INI_NAMES = :on_off_devices



#
# link between actions and intents:
#
# language settings:
# 1) set LANG to "en", "de", "fr", etc.
# 2) link the Dict with messages to the version with
#    desired language as defined in languages.jl:
#
if LANG == "de"
    Snips.registerIntentAction("ADoSnipsOnOffDE", ignoreDevice)
    TEXTS = TEXTS_DE
else
    Snips.registerIntentAction("ADoSnipsOnOffEN", ignoreDevice)
    TEXTS = TEXTS_EN
end
    Snips.registerTriggerAction("ADoSnipsScheduler", schedulerAction)
