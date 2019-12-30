#
# The main file for the App.
#
# Normally, it is NOT necessary to change anything in this file,
# unless you know what you are doing!
#
module QnDintents

const MODULE_DIR = @__DIR__
const APP_DIR = replace(MODULE_DIR, r"/[^/]*/?$"=>"")
const SKILLS_DIR = replace(APP_DIR, r"/[^/]*/?$"=>"")
const APP_NAME = split(APP_DIR, "/")[end]
const FRAMEWORK_DIR = "$SKILLS_DIR/ADoSnipsQnD"
include("$FRAMEWORK_DIR/SnipsHermesQnD/src/SnipsHermesQnD.jl")
import .SnipsHermesQnD
Snips = SnipsHermesQnD

import Dates

Snips.readConfig("$APP_DIR")
Snips.readConfig("$FRAMEWORK_DIR")
Snips.setLanguage(Snips.getConfig(:language))
Snips.setAppDir(APP_DIR)
Snips.setAppName("QnDintents")
Snips.printDebug("APP_NAME(QnDintents) = $(Snips.getAppName())")


include("api.jl")
include("skill-actions.jl")
include("languages.jl")
include("scheduler.jl")
include("config.jl")
include("exported.jl")

# Channel for transfer of new actions to the scheduler:
# and run the scheduler task:
#
actionChannel = Channel(64)
deleteChannel = Channel(64)
@async startScheduler()

export getIntentActions, callBackrun

end
