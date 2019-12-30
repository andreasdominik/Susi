#!/usr/local/bin/julia
#
# Daemon for a Julia-based NLU as a Snips-replacement.
#
# (c) A. Dominik, April 2019, © GPL3
#

# get dirs
#
if length(ARGS) > 0
    const TOML_FILE = ARGS[1]
else
    const TOML_FILE = "/home/andreas/Documents/Projekte/2019-Susi/Susi/etc/susi.toml"
    # const TOML_FILE = "/etc/susi.toml"
end

const NLU_DIR = @__DIR__
# const SKILLS_DIR = replace(FRAMEWORK_DIR, r"/[^/]*/?$"=>"")
include("$NLU_DIR/Modules/TOML/TOML.jl")
using Main.TOML

toml = TOML.parsefile(TOML_FILE)
@show toml

# # list of intents and related actions:
# # (name of intent, name of developer, module, function to be executed)
# #
# INTENT_ACTIONS = Tuple{AbstractString, AbstractString, AbstractString,
#                        Module, Function}[]
#
#
# # search all dir-tree for files like loader-<name>.jl
# #
# loaders = AbstractString[]
# for (root, dirs, files) in walkdir(SKILLS_DIR)
#
#     files = filter(f->occursin(r"^loader-.*\.jl", f), files)
#     paths = root .* "/" .* files
#     append!(loaders, paths)
# end
#
# println("[ADoSnipsQnD loader]: $(length(loaders)) skills found to load.")
#
# for loader in loaders
#     global INTENT_ACTIONS
#     println("[ADoSnipsQnD loader]: loading Julia app $loader.")
#     include(loader)
# end
#
# # start listening to MQTT with main callback
# #
# import Main.SnipsHermesQnD
# SnipsHermesQnD.readConfig(FRAMEWORK_DIR)
#
# # const intents = [i[2]*":"*i[1] for i in INTENT_ACTIONS]
# # SnipsHermesQnD.subscribe2Intents(intents, SnipsHermesQnD.mainCallback)
# const topics = [i[3] for i in INTENT_ACTIONS]
# SnipsHermesQnD.subscribe2Topics(topics, SnipsHermesQnD.mainCallback)
# end
