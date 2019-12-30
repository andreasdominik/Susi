#!/usr/local/bin/julia
#
# main executable script of ADos's SniosHermesQnD framework.
# It loads all skills into one Julia environment.
#
# Normally, it is NOT necessary to change anything in this file,
# unless you know what you are doing!
#
# A. Dominik, April 2019, © GPL3
#

# get dir of framework installation and
# skill installations (one level higher)
#
const FRAMEWORK_DIR = @__DIR__
const SKILLS_DIR = replace(FRAMEWORK_DIR, r"/[^/]*/?$"=>"")
include("$FRAMEWORK_DIR/SnipsHermesQnD/src/SnipsHermesQnD.jl")

# list of intents and related actions:
# (name of intent, name of developer, module, function to be executed)
#
INTENT_ACTIONS = Tuple{AbstractString, AbstractString, AbstractString,
                       Module, Function}[]


# search all dir-tree for files like loader-<name>.jl
#
loaders = AbstractString[]
for (root, dirs, files) in walkdir(SKILLS_DIR)

    files = filter(f->occursin(r"^loader-.*\.jl", f), files)
    paths = root .* "/" .* files
    append!(loaders, paths)
end

println("[ADoSnipsQnD loader]: $(length(loaders)) skills found to load.")

for loader in loaders
    global INTENT_ACTIONS
    println("[ADoSnipsQnD loader]: loading Julia app $loader.")
    include(loader)
end

# start listening to MQTT with main callback
#
import Main.SnipsHermesQnD
SnipsHermesQnD.readConfig(FRAMEWORK_DIR)

# const intents = [i[2]*":"*i[1] for i in INTENT_ACTIONS]
# SnipsHermesQnD.subscribe2Intents(intents, SnipsHermesQnD.mainCallback)
const topics = [i[3] for i in INTENT_ACTIONS]
SnipsHermesQnD.subscribe2Topics(topics, SnipsHermesQnD.mainCallback)
end
