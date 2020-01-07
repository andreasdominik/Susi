#!/usr/local/bin/julia
#
# Daemon for a Julia-based NLU as a Snips-replacement.
#
# (c) A. Dominik, April 2019, © GPL3
#

# get dirs
#
if length(ARGS) > 0
    const CONFIG_FILE = ARGS[1]
else
    const CONFIG_FILE = "/home/andreas/Documents/Projekte/2019-Susi/Susi/etc/susi.toml"
    # const TOML_FILE = "/etc/susi.toml"
end

const NLU_DIR = @__DIR__
# const SKILLS_DIR = replace(FRAMEWORK_DIR, r"/[^/]*/?$"=>"")
include("$NLU_DIR/Modules/TOML/TOML.jl")
import Main.TOML
include("$NLU_DIR/Modules/NLU/NLU.jl")
import Main.NLU

# load config:
#
# config = TOML.parsefile(CONFIG_FILE)
NLU.readConfig(CONFIG_FILE)
NLU.setSkillDir()

# for each skill:
#
NLU.loadIntents()
NLU.listener()
#
# run forever ...
